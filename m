From: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Subject: Re: [PATCH 0/6] TCP CUBIC and Hystart
Date: Fri, 11 Mar 2011 11:28:09 +0100
Message-ID: <20110311102809.GB15941@xanadu.blop.info>
References: <20110310165119.224046957@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, sangtae.ha@gmail.com, rhee@ncsu.edu,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xanadu.blop.info ([178.79.145.134]:55694 "EHLO xanadu.blop.info"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751593Ab1CKK1R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2011 05:27:17 -0500
Content-Disposition: inline
In-Reply-To: <20110310165119.224046957@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/03/11 at 08:51 -0800, Stephen Hemminger wrote:
> This patch set is my attempt at addressing the problems discovered
> by Lucas Nussbaum.

With those patches applied (and the fix I mentioned separately), it
works much better (still with HZ=3D250).

When a delayed ack train is detected, slow start ends with cwnd ~=3D 58=
0
(sometimes a bit lower).
When no delayed ack train is detected, slow start ends with the detecti=
on of the
delay increase at cwnd in the [700:1100] range.

performance is still not as good as without hystart, but it is more
acceptable:

nuttcp -i1 -n1g graphene-34.nancy.grid5000.fr
   94.8125 MB /   1.00 sec =3D  795.3059 Mbps     0 retrans
  112.2500 MB /   1.00 sec =3D  941.6325 Mbps     0 retrans
  112.2500 MB /   1.00 sec =3D  941.6222 Mbps     0 retrans
  112.2500 MB /   1.00 sec =3D  941.6335 Mbps     0 retrans
  112.2500 MB /   1.00 sec =3D  941.6354 Mbps     0 retrans
  112.2500 MB /   1.00 sec =3D  941.6231 Mbps     0 retrans
  112.2500 MB /   1.00 sec =3D  941.5883 Mbps     0 retrans
  112.2500 MB /   1.00 sec =3D  941.6297 Mbps     0 retrans
  112.2500 MB /   1.00 sec =3D  941.6391 Mbps     0 retrans

 1024.0000 MB /   9.29 sec =3D  924.7155 Mbps 14 %TX 28 %RX 0 retrans 1=
1.39 msRTT
During that run, no ack train was detected, but delay increase was dete=
cted when cwnd=3D1105:
hystart_update: cwnd=3D1105 ssthresh=3D1105 fnd=3D2 hs_det=3D3   cur_rt=
t=3D122 delay_min=3D90 DELTRE=3D16

However:
echo 1 > /proc/sys/net/ipv4/route/flush; nuttcp -i1 -n1g graphene-34.na=
ncy.grid5000.fr
   49.5000 MB /   1.00 sec =3D  415.2278 Mbps     0 retrans
   59.0000 MB /   1.00 sec =3D  494.9318 Mbps     0 retrans
   62.1875 MB /   1.00 sec =3D  521.6535 Mbps     0 retrans
   64.1250 MB /   1.00 sec =3D  537.9329 Mbps     0 retrans
   67.0625 MB /   1.00 sec =3D  562.5486 Mbps     0 retrans
   69.4375 MB /   1.00 sec =3D  582.4840 Mbps     0 retrans
   72.3750 MB /   1.00 sec =3D  607.1395 Mbps     0 retrans
   75.3125 MB /   1.00 sec =3D  631.7557 Mbps     0 retrans
   83.1250 MB /   1.00 sec =3D  697.2975 Mbps     0 retrans
   94.3125 MB /   1.00 sec =3D  791.1569 Mbps     0 retrans
  107.6250 MB /   1.00 sec =3D  902.8194 Mbps     0 retrans
  112.2500 MB /   1.00 sec =3D  941.6231 Mbps     0 retrans

 1024.0000 MB /  12.97 sec =3D  662.2669 Mbps 10 %TX 20 %RX 0 retrans 1=
1.39 msRTT
[ 3050.712333] found ACK TRAIN: cwnd=3D493 now=3D2757023598 ca->last_ac=
k=3D2757023598 ca->round_start=3D2757023593 ca->delay_min=3D90 delay_mi=
n>>4=3D5
[ 3050.726045] hystart_update: cwnd=3D493 ssthresh=3D493 fnd=3D1 hs_det=
=3D3   cur_rtt=3D91 delay_min=3D90 DELTRE=3D16
(delayed ack train detected when cwnd=3D493 =3D> slower convergence)

It seems that the ack train length detection is still a bit too sensiti=
ve.
Changing:
	if ((s32)(now - ca->round_start) >=3D ca->delay_min >> 4)
To:
	if ((s32)(now - ca->round_start) > ca->delay_min >> 4)
makes things slightly better, but slow start still exits too early. (op=
timal cwnd=3D941).

I'm not sure if we can really do something more about that. The detecti=
on by
ack train length is inherently more likely to trigger false positives s=
ince all
acks are considered, not just a few acks at the beginning of the train.=
  I'm
tempted to suggest to disable the ack train length detection by default=
, but
then it probably solves problems for other people, and the decrease in
performance is more acceptable now.
--=20
| Lucas Nussbaum             MCF Universit=E9 Nancy 2 |
| lucas.nussbaum@loria.fr         LORIA / AlGorille |
| http://www.loria.fr/~lnussbau/  +33 3 54 95 86 19 |
