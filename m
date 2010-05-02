From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Sun, 02 May 2010 08:56:06 +0200
Message-ID: <1272783366.2173.13.camel@edumazet-laptop>
References: <20100429182347.GA8512@gargoyle.fritz.box>
	 <1272568347.2209.11.camel@edumazet-laptop>
	 <20100429214144.GA10663@gargoyle.fritz.box>
	 <20100430.163857.180417789.davem@davemloft.net>
	 <20100501110000.GB9434@gargoyle.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	xiaosuo@gmail.com, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, lenb@kernel.org, arjan@infradead.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:60091 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751025Ab0EBG4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 May 2010 02:56:18 -0400
Received: by bwz19 with SMTP id 19so780763bwz.21
        for <netdev@vger.kernel.org>; Sat, 01 May 2010 23:56:13 -0700 (PDT)
In-Reply-To: <20100501110000.GB9434@gargoyle.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 01 mai 2010 =C3=A0 13:00 +0200, Andi Kleen a =C3=A9crit :
> On Fri, Apr 30, 2010 at 04:38:57PM -0700, David Miller wrote:
> > From: Andi Kleen <ak@gargoyle.fritz.box>
> > Date: Thu, 29 Apr 2010 23:41:44 +0200
> >=20
> > >     Use io_schedule() in network stack to tell cpuidle governour =
to guarantee lower latencies
> > >=20
> > >     XXX: probably too aggressive, some of these sleeps are not un=
der high load.
> > >=20
> > >     Based on a bug report from Eric Dumazet.
> > >    =20
> > >     Signed-off-by: Andi Kleen <ak@linux.intel.com>
> >=20
> > I like this, except that we probably don't want the delayacct_blkio=
_*() calls
> > these things do.
>=20
> Yes.
>=20
> It needs more work, please don't apply it yet, to handle the "long sl=
eep" case.
>=20
> Still curious if it fixes Eric's test case.
>=20

I tried it on the right spot (since my bench was only doing recvmsg()
calls, I had to patch wait_for_packet() in net/core/datagram.c

udp_recvmsg -> __skb_recv_datagram -> wait_for_packet ->
schedule_timeout

Unfortunatly, using io_schedule_timeout() did not solve the problem.

Tell me if you need some traces or something.

Thanks !

diff --git a/net/core/datagram.c b/net/core/datagram.c
index 95b851f..051fd5b 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -113,7 +113,7 @@ static int wait_for_packet(struct sock *sk, int *er=
r, long *timeo_p)
 		goto interrupted;
=20
 	error =3D 0;
-	*timeo_p =3D schedule_timeout(*timeo_p);
+	*timeo_p =3D io_schedule_timeout(*timeo_p);
 out:
 	finish_wait(sk_sleep(sk), &wait);
 	return error;


