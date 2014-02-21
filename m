From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] net: tcp: RTO restart
Date: Fri, 21 Feb 2014 05:14:26 -0800
Message-ID: <1392988466.2316.11.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140218181205.GA7780@kau.se>
	 <50334B08-CD60-4C4C-9556-ACC758F75D7E@simula.no>
	 <1392832907.18849.10.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1250EA19-2144-4AC2-A802-5B1989F74B80@kau.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andreas Petlund <apetlund@simula.no>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Anna =?ISO-8859-1?Q?Brunstr=F6m?= <anna.brunstrom@kau.se>,
	Michael Welzl <michawe@ifi.uio.no>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Per Hurtig <per.hurtig@kau.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:56315 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932925AbaBUNO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 08:14:28 -0500
Received: by mail-pb0-f45.google.com with SMTP id un15so3416981pbc.4
        for <netdev@vger.kernel.org>; Fri, 21 Feb 2014 05:14:28 -0800 (PST)
In-Reply-To: <1250EA19-2144-4AC2-A802-5B1989F74B80@kau.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-02-21 at 11:49 +0100, Per Hurtig wrote:
> On 19 Feb 2014, at 19:01, Eric Dumazet <eric.dumazet@gmail.com> wrote=
:
>=20
> > On Wed, 2014-02-19 at 18:17 +0100, Andreas Petlund wrote:
> >> I=E2=80=99ve applied and tested the patch on VMs with both 32 bit =
and 64 bit kernel.
> >>=20
> >> Acked-by: Andreas Petlund <apetlund@simula.no>
> >> Tested-by: Andreas Petlund <apetlund@simula.no>
> >=20
> > Sure the patch applies, but what experimental results did you get ?
> >=20
> > My concern is that TCP_SKB_CB(skb)->when doesn't account for sojour=
n
> > time in host queues (qdisc and device).=20
> >=20
>=20
> Correct me if I=E2=80=99m wrong, but I was under the impression that =
the sojourn was
> accounted for in the RTT calculations, and therefore rather inappropr=
iate to
> be accounted for again? If this assumption is wrong, how would you pr=
opose that
> we account for the sojourn time?

This is a generic problem.=20

Thats why I added LINUX_MIB_TCPSPURIOUS_RTX_HOSTQUEUES snmp counter,
so that we can experiment with the idea of not firing RTO while origina=
l
packet is still in the host qdisc.

       struct sk_buff *skb =3D tcp_write_queue_head(sk);
       const u32 rto_time_stamp =3D TCP_SKB_CB(skb)->when;
       s32 delta =3D (s32)(tcp_time_stamp - rto_time_stamp);

       if (delta > 0)
            rto -=3D delta;

Can trivially gives rto < 0, resulting in a timer of 120 seconds
(TCP_RTO_MAX)
