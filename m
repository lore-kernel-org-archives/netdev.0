From: Sangtae Ha <sangtae.ha@gmail.com>
Subject: Re: [PATCH 0/6] TCP CUBIC and Hystart
Date: Fri, 11 Mar 2011 10:58:05 -0500
Message-ID: <AANLkTimi+nJ1-PO+JYjckg-Pw3+6-zJvqPvhMjf+1Lua@mail.gmail.com>
References: <20110310165119.224046957@vyatta.com>
	<20110311102809.GB15941@xanadu.blop.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, davem@davemloft.net,
	rhee@ncsu.edu, netdev@vger.kernel.org
To: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:47750 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752730Ab1CKP6G convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2011 10:58:06 -0500
Received: by fxm17 with SMTP id 17so1110230fxm.19
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2011 07:58:05 -0800 (PST)
In-Reply-To: <20110311102809.GB15941@xanadu.blop.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Lucas,

=46rom your setup, ca->delay_min is 90 and this means the one-way delay
is 90 >> 4 (5ms).
And our gap detection threshold is 2ms, which means that if the gap is
loosely spread over 5ms with delayed ACKs, it can early terminate the
slow start. But, given the optimal cwnd is 941 in your setup, exiting
slow start one RTT before the loss (half of the optimal cwnd) is what
hystart does.

Since the resolution is now ms, can you change the gap detection to
1ms and run it again?
Also, the following change you did doesn't hurt (1ms more train to
detect the ACK train).

if ((s32)(now - ca->round_start) > ca->delay_min >> 4)

I am also testing the algorithm with HZ=3D100ms and 1000ms in my networ=
k
and will share the results soon.

Sangtae


On Fri, Mar 11, 2011 at 5:28 AM, Lucas Nussbaum <lucas.nussbaum@loria.f=
r> wrote:
> On 10/03/11 at 08:51 -0800, Stephen Hemminger wrote:
>> This patch set is my attempt at addressing the problems discovered
>> by Lucas Nussbaum.
>
> With those patches applied (and the fix I mentioned separately), it
> works much better (still with HZ=3D250).
>
> When a delayed ack train is detected, slow start ends with cwnd ~=3D =
580
> (sometimes a bit lower).
> When no delayed ack train is detected, slow start ends with the detec=
tion of the
> delay increase at cwnd in the [700:1100] range.
>
> performance is still not as good as without hystart, but it is more
> acceptable:
>
> nuttcp -i1 -n1g graphene-34.nancy.grid5000.fr
> =A0 94.8125 MB / =A0 1.00 sec =3D =A0795.3059 Mbps =A0 =A0 0 retrans
> =A0112.2500 MB / =A0 1.00 sec =3D =A0941.6325 Mbps =A0 =A0 0 retrans
> =A0112.2500 MB / =A0 1.00 sec =3D =A0941.6222 Mbps =A0 =A0 0 retrans
> =A0112.2500 MB / =A0 1.00 sec =3D =A0941.6335 Mbps =A0 =A0 0 retrans
> =A0112.2500 MB / =A0 1.00 sec =3D =A0941.6354 Mbps =A0 =A0 0 retrans
> =A0112.2500 MB / =A0 1.00 sec =3D =A0941.6231 Mbps =A0 =A0 0 retrans
> =A0112.2500 MB / =A0 1.00 sec =3D =A0941.5883 Mbps =A0 =A0 0 retrans
> =A0112.2500 MB / =A0 1.00 sec =3D =A0941.6297 Mbps =A0 =A0 0 retrans
> =A0112.2500 MB / =A0 1.00 sec =3D =A0941.6391 Mbps =A0 =A0 0 retrans
>
> =A01024.0000 MB / =A0 9.29 sec =3D =A0924.7155 Mbps 14 %TX 28 %RX 0 r=
etrans 11.39 msRTT
> During that run, no ack train was detected, but delay increase was de=
tected when cwnd=3D1105:
> hystart_update: cwnd=3D1105 ssthresh=3D1105 fnd=3D2 hs_det=3D3 =A0 cu=
r_rtt=3D122 delay_min=3D90 DELTRE=3D16
>
> However:
> echo 1 > /proc/sys/net/ipv4/route/flush; nuttcp -i1 -n1g graphene-34.=
nancy.grid5000.fr
> =A0 49.5000 MB / =A0 1.00 sec =3D =A0415.2278 Mbps =A0 =A0 0 retrans
> =A0 59.0000 MB / =A0 1.00 sec =3D =A0494.9318 Mbps =A0 =A0 0 retrans
> =A0 62.1875 MB / =A0 1.00 sec =3D =A0521.6535 Mbps =A0 =A0 0 retrans
> =A0 64.1250 MB / =A0 1.00 sec =3D =A0537.9329 Mbps =A0 =A0 0 retrans
> =A0 67.0625 MB / =A0 1.00 sec =3D =A0562.5486 Mbps =A0 =A0 0 retrans
> =A0 69.4375 MB / =A0 1.00 sec =3D =A0582.4840 Mbps =A0 =A0 0 retrans
> =A0 72.3750 MB / =A0 1.00 sec =3D =A0607.1395 Mbps =A0 =A0 0 retrans
> =A0 75.3125 MB / =A0 1.00 sec =3D =A0631.7557 Mbps =A0 =A0 0 retrans
> =A0 83.1250 MB / =A0 1.00 sec =3D =A0697.2975 Mbps =A0 =A0 0 retrans
> =A0 94.3125 MB / =A0 1.00 sec =3D =A0791.1569 Mbps =A0 =A0 0 retrans
> =A0107.6250 MB / =A0 1.00 sec =3D =A0902.8194 Mbps =A0 =A0 0 retrans
> =A0112.2500 MB / =A0 1.00 sec =3D =A0941.6231 Mbps =A0 =A0 0 retrans
>
> =A01024.0000 MB / =A012.97 sec =3D =A0662.2669 Mbps 10 %TX 20 %RX 0 r=
etrans 11.39 msRTT
> [ 3050.712333] found ACK TRAIN: cwnd=3D493 now=3D2757023598 ca->last_=
ack=3D2757023598 ca->round_start=3D2757023593 ca->delay_min=3D90 delay_=
min>>4=3D5
> [ 3050.726045] hystart_update: cwnd=3D493 ssthresh=3D493 fnd=3D1 hs_d=
et=3D3 =A0 cur_rtt=3D91 delay_min=3D90 DELTRE=3D16
> (delayed ack train detected when cwnd=3D493 =3D> slower convergence)
>
> It seems that the ack train length detection is still a bit too sensi=
tive.
> Changing:
> =A0 =A0 =A0 =A0if ((s32)(now - ca->round_start) >=3D ca->delay_min >>=
 4)
> To:
> =A0 =A0 =A0 =A0if ((s32)(now - ca->round_start) > ca->delay_min >> 4)
> makes things slightly better, but slow start still exits too early. (=
optimal cwnd=3D941).
>
> I'm not sure if we can really do something more about that. The detec=
tion by
> ack train length is inherently more likely to trigger false positives=
 since all
> acks are considered, not just a few acks at the beginning of the trai=
n. =A0I'm
> tempted to suggest to disable the ack train length detection by defau=
lt, but
> then it probably solves problems for other people, and the decrease i=
n
> performance is more acceptable now.
> --
> | Lucas Nussbaum =A0 =A0 =A0 =A0 =A0 =A0 MCF Universit=E9 Nancy 2 |
> | lucas.nussbaum@loria.fr =A0 =A0 =A0 =A0 LORIA / AlGorille |
> | http://www.loria.fr/~lnussbau/ =A0+33 3 54 95 86 19 |
>
