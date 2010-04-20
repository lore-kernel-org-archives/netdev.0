From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] rps: shortcut net_rps_action()
Date: Tue, 20 Apr 2010 07:55:45 +0200
Message-ID: <1271742945.3845.120.camel@edumazet-laptop>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271590476.16881.4925.camel@edumazet-laptop>
	 <1271669822.16881.7520.camel@edumazet-laptop>
	 <k2u412e6f7f1004190248s8ac633beof2475645e799f2ea@mail.gmail.com>
	 <1271679244.3845.43.camel@edumazet-laptop>
	 <p2u412e6f7f1004190528l65cc6253w8b7f43f2657b551d@mail.gmail.com>
	 <1271683627.3845.44.camel@edumazet-laptop>
	 <1271686957.3845.49.camel@edumazet-laptop>
	 <1271689653.3845.73.camel@edumazet-laptop>
	 <n2y412e6f7f1004191656qd53a8d77occ407ac288c53bbc@mail.gmail.com>
	 <p2j412e6f7f1004191732p41094214yf82d2755f9081d1d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	netdev <netdev@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:57925 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751869Ab0DTFzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 01:55:55 -0400
Received: by bwz19 with SMTP id 19so138231bwz.21
        for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 22:55:50 -0700 (PDT)
In-Reply-To: <p2j412e6f7f1004191732p41094214yf82d2755f9081d1d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 20 avril 2010 =C3=A0 08:32 +0800, Changli Gao a =C3=A9crit :

> Oh, I read the code again and got the answer. After the IPI is sent,
> this softnet will be queued by the other CPUs. We prefetch the pointe=
r
> rps_ipi_next to avoid this race condition.
>=20

Speaking of prefetch business,

I partly tested following patch, I will submit it if it happens to be a
clear win.

diff --git a/net/core/dev.c b/net/core/dev.c
index 05a2b29..fe6fc9f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2349,7 +2349,9 @@ done:
 static void trigger_softirq(void *data)
 {
 	struct softnet_data *queue =3D data;
+
 	__napi_schedule(&queue->backlog);
+	prefetch(queue->input_pkt_queue.next);
 	__get_cpu_var(netdev_rx_stat).received_rps++;
 }
 #endif /* CONFIG_RPS */


