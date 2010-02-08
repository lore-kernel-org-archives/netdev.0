From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] dst: call cond_resched() in dst_gc_task()
Date: Mon, 08 Feb 2010 20:32:40 +0100
Message-ID: <1265657560.4236.80.camel@edumazet-laptop>
References: <4B700EC2.5090207@itcare.pl>
	 <1265635690.3048.8.camel@edumazet-laptop>  <4B7012BC.9000702@itcare.pl>
	 <1265637067.3048.14.camel@edumazet-laptop>  <4B7018DF.8060600@itcare.pl>
	 <1265638014.3048.20.camel@edumazet-laptop>  <4B701CA8.7050205@itcare.pl>
	 <1265639549.3048.33.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:41514 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753526Ab0BHTcq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 14:32:46 -0500
Received: by bwz19 with SMTP id 19so51425bwz.28
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2010 11:32:45 -0800 (PST)
In-Reply-To: <1265639549.3048.33.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 08 f=C3=A9vrier 2010 =C3=A0 15:32 +0100, Eric Dumazet a =C3=A9=
crit :
> Le lundi 08 f=C3=A9vrier 2010 =C3=A0 15:16 +0100, Pawe=C5=82 Staszews=
ki a =C3=A9crit :
>=20
> > >   =20
> > Some day ago after info about route cache i was have  also this inf=
o:
>=20
> > Code: fe 79 4c 00 48 85 db 74 14 48 8b 74 24 10 48 89 ef ff 13 48 8=
3 c3 08 48
> > 83 3b 00 eb ea 48 83 c4 18 5b 5d 41 5c 41 5d 41 5e 41 5f<c3>  55 48=
 89 f5 53 48
> > 89 fb 48 83 ec 08 48 8b 76 18 48 2b 75 10
> > Call Trace:
> >   <IRQ>   [<ffffffff8126826f>] ? e1000_put_txbuf+0x62/0x74
> >   [<ffffffff8126834a>] ? e1000_clean_tx_irq+0xc9/0x235
> >   [<ffffffff8126b71b>] ? e1000_clean+0x5c/0x21c
> >   [<ffffffff812f29a3>] ? net_rx_action+0x71/0x15d
> >   [<ffffffff81035311>] ? __do_softirq+0xd7/0x196
> >   [<ffffffff81002dac>] ? call_softirq+0x1c/0x28
> >   [<ffffffff812f768f>] ? dst_gc_task+0x0/0x1a7
> >   [<ffffffff81002dac>] ? call_softirq+0x1c/0x28
> >   <EOI>   [<ffffffff81004599>] ? do_softirq+0x31/0x63
> >   [<ffffffff81034ec1>] ? local_bh_enable_ip+0x75/0x86
> >   [<ffffffff812f768f>] ? dst_gc_task+0x0/0x1a7
> >   [<ffffffff812f775d>] ? dst_gc_task+0xce/0x1a7
> >   [<ffffffff8136b08c>] ? schedule+0x82c/0x906
> >   [<ffffffff8103c44f>] ? lock_timer_base+0x26/0x4b
> >   [<ffffffff810a41d6>] ? cache_reap+0x0/0x11d
> >   [<ffffffff81044c38>] ? worker_thread+0x14c/0x1dc
> >   [<ffffffff81047dcd>] ? autoremove_wake_function+0x0/0x2e
> >   [<ffffffff81044aec>] ? worker_thread+0x0/0x1dc
> >   [<ffffffff810479bd>] ? kthread+0x79/0x81
> >   [<ffffffff81002cb4>] ? kernel_thread_helper+0x4/0x10
> >   [<ffffffff81047944>] ? kthread+0x0/0x81
> >=20
> >=20
> >   [<ffffffff81002cb0>] ? kernel_thread_helper+0x0/0x10
> >=20
> >=20
>=20
> This trace is indeed very interesting, since dst_gc_task() is run fro=
m a
> work queue, and there is no scheduling point in it.
>=20
> We might need add a scheduling point in dst_gc_task() in case huge
> number of entries were flushed.
>=20

David, here is the patch I sent to Pawel to solve this problem.
This probaby is a stable candidate.

Thanks

[PATCH] dst: call cond_resched() in dst_gc_task()

On some workloads, it is quite possible to get a huge dst list to
process in dst_gc_task(), and trigger soft lockup detection.

=46ix is to call cond_resched(), as we run in process context.

Reported-by: Pawel Staszewski <pstaszewski@itcare.pl>
Tested-by: Pawel Staszewski <pstaszewski@itcare.pl>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/net/core/dst.c b/net/core/dst.c
index 57bc4d5..cb1b348 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -17,6 +17,7 @@
 #include <linux/string.h>
 #include <linux/types.h>
 #include <net/net_namespace.h>
+#include <linux/sched.h>
=20
 #include <net/dst.h>
=20
@@ -79,6 +80,7 @@ loop:
 	while ((dst =3D next) !=3D NULL) {
 		next =3D dst->next;
 		prefetch(&next->next);
+		cond_resched();
 		if (likely(atomic_read(&dst->__refcnt))) {
 			last->next =3D dst;
 			last =3D dst;



