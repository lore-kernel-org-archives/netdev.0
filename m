From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 01/17] can: dev: avoid calling kfree_skb() from interrupt context
Date: Tue, 18 Nov 2014 21:37:31 +0100
Message-ID: <1416343067-9810-2-git-send-email-mkl@pengutronix.de>
References: <1416343067-9810-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de,
	=?UTF-8?q?Thomas=20K=C3=B6rper?= <thomas.koerper@esd.eu>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:47267 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754558AbaKRUhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 15:37:55 -0500
In-Reply-To: <1416343067-9810-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Thomas K=C3=B6rper <thomas.koerper@esd.eu>

ikfree_skb() is Called in can_free_echo_skb(), which might be called fr=
om (TX
Error) interrupt, which triggers the folloing warning:

[ 1153.360705] ------------[ cut here ]------------
[ 1153.360715] WARNING: CPU: 0 PID: 31 at net/core/skbuff.c:563 skb_rel=
ease_head_state+0xb9/0xd0()
[ 1153.360772] Call Trace:
[ 1153.360778]  [<c167906f>] dump_stack+0x41/0x52
[ 1153.360782]  [<c105bb7e>] warn_slowpath_common+0x7e/0xa0
[ 1153.360784]  [<c158b909>] ? skb_release_head_state+0xb9/0xd0
[ 1153.360786]  [<c158b909>] ? skb_release_head_state+0xb9/0xd0
[ 1153.360788]  [<c105bc42>] warn_slowpath_null+0x22/0x30
[ 1153.360791]  [<c158b909>] skb_release_head_state+0xb9/0xd0
[ 1153.360793]  [<c158be90>] skb_release_all+0x10/0x30
[ 1153.360795]  [<c158bf06>] kfree_skb+0x36/0x80
[ 1153.360799]  [<f8486938>] ? can_free_echo_skb+0x28/0x40 [can_dev]
[ 1153.360802]  [<f8486938>] can_free_echo_skb+0x28/0x40 [can_dev]
[ 1153.360805]  [<f849a12c>] esd_pci402_interrupt+0x34c/0x57a [esd402]
[ 1153.360809]  [<c10a75b5>] handle_irq_event_percpu+0x35/0x180
[ 1153.360811]  [<c10a7623>] ? handle_irq_event_percpu+0xa3/0x180
[ 1153.360813]  [<c10a7731>] handle_irq_event+0x31/0x50
[ 1153.360816]  [<c10a9c7f>] handle_fasteoi_irq+0x6f/0x120
[ 1153.360818]  [<c10a9c10>] ? handle_edge_irq+0x110/0x110
[ 1153.360822]  [<c1011b61>] handle_irq+0x71/0x90
[ 1153.360823]  <IRQ>  [<c168152c>] do_IRQ+0x3c/0xd0
[ 1153.360829]  [<c1680b6c>] common_interrupt+0x2c/0x34
[ 1153.360834]  [<c107d277>] ? finish_task_switch+0x47/0xf0
[ 1153.360836]  [<c167c27b>] __schedule+0x35b/0x7e0
[ 1153.360839]  [<c10a5334>] ? console_unlock+0x2c4/0x4d0
[ 1153.360842]  [<c13df500>] ? n_tty_receive_buf_common+0x890/0x890
[ 1153.360845]  [<c10707b6>] ? process_one_work+0x196/0x370
[ 1153.360847]  [<c167c723>] schedule+0x23/0x60
[ 1153.360849]  [<c1070de1>] worker_thread+0x161/0x460
[ 1153.360852]  [<c1090fcf>] ? __wake_up_locked+0x1f/0x30
[ 1153.360854]  [<c1070c80>] ? rescuer_thread+0x2f0/0x2f0
[ 1153.360856]  [<c1074f01>] kthread+0xa1/0xc0
[ 1153.360859]  [<c1680401>] ret_from_kernel_thread+0x21/0x30
[ 1153.360861]  [<c1074e60>] ? kthread_create_on_node+0x110/0x110
[ 1153.360863] ---[ end trace 5ff83639cbb74b35 ]---

This patch replaces the kfree_skb() by dev_kfree_skb_any().

Signed-off-by: Thomas K=C3=B6rper <thomas.koerper@esd.eu>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index 02492d241e4c..509d5e063d8c 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -382,7 +382,7 @@ void can_free_echo_skb(struct net_device *dev, unsi=
gned int idx)
 	BUG_ON(idx >=3D priv->echo_skb_max);
=20
 	if (priv->echo_skb[idx]) {
-		kfree_skb(priv->echo_skb[idx]);
+		dev_kfree_skb_any(priv->echo_skb[idx]);
 		priv->echo_skb[idx] =3D NULL;
 	}
 }
--=20
2.1.3
