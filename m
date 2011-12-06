From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCHv2 net-next 4/4] caif: Replace BUG_ON with WARN_ON.
Date: Tue,  6 Dec 2011 23:15:44 +0100
Message-ID: <1323209744-9718-4-git-send-email-sjur.brandeland@stericsson.com>
References: <1323209744-9718-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Roar=20F=C3=B8rde?= <roar.forde@stericsson.com>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:62053 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754813Ab1LFWQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 17:16:02 -0500
Received: by mail-lpp01m010-f46.google.com with SMTP id p5so1832677lag.19
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2011 14:16:01 -0800 (PST)
In-Reply-To: <1323209744-9718-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Roar F=C3=B8rde <roar.forde@stericsson.com>

BUG_ON is too strict in a number of circumstances,
use WARN_ON instead. Protocol errors should not halt the system.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
Since v1: removed and changed some OOM related printouts.

 drivers/net/caif/caif_hsi.c     |    2 +-
 drivers/net/caif/caif_serial.c  |    4 ++--
 drivers/net/caif/caif_shmcore.c |    6 +++++-
 net/caif/caif_dev.c             |   10 ++++------
 4 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index a85b29e..0a4fc62 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -933,7 +933,7 @@ static int cfhsi_xmit(struct sk_buff *skb, struct n=
et_device *dev)
=20
 		/* Create HSI frame. */
 		len =3D cfhsi_tx_frm(desc, cfhsi);
-		BUG_ON(!len);
+		WARN_ON(!len);
=20
 		/* Set up new transfer. */
 		res =3D cfhsi->dev->cfhsi_tx(cfhsi->tx_buf, len, cfhsi->dev);
diff --git a/drivers/net/caif/caif_serial.c b/drivers/net/caif/caif_ser=
ial.c
index 23406e6..9341a2d 100644
--- a/drivers/net/caif/caif_serial.c
+++ b/drivers/net/caif/caif_serial.c
@@ -261,7 +261,7 @@ static int handle_tx(struct ser_device *ser)
 		skb_pull(skb, tty_wr);
 		if (skb->len =3D=3D 0) {
 			struct sk_buff *tmp =3D skb_dequeue(&ser->head);
-			BUG_ON(tmp !=3D skb);
+			WARN_ON(tmp !=3D skb);
 			if (in_interrupt())
 				dev_kfree_skb_irq(skb);
 			else
@@ -305,7 +305,7 @@ static void ldisc_tx_wakeup(struct tty_struct *tty)
=20
 	ser =3D tty->disc_data;
 	BUG_ON(ser =3D=3D NULL);
-	BUG_ON(ser->tty !=3D tty);
+	WARN_ON(ser->tty !=3D tty);
 	handle_tx(ser);
 }
=20
diff --git a/drivers/net/caif/caif_shmcore.c b/drivers/net/caif/caif_sh=
mcore.c
index fd59e37..5b20413 100644
--- a/drivers/net/caif/caif_shmcore.c
+++ b/drivers/net/caif/caif_shmcore.c
@@ -337,7 +337,11 @@ static void shm_rx_work_func(struct work_struct *r=
x_work)
 			/* Get a suitable CAIF packet and copy in data. */
 			skb =3D netdev_alloc_skb(pshm_drv->pshm_dev->pshm_netdev,
 							frm_pck_len + 1);
-			BUG_ON(skb =3D=3D NULL);
+
+			if (skb =3D=3D NULL) {
+				pr_info("OOM: Try next frame in descriptor\n");
+				break;
+			}
=20
 			p =3D skb_put(skb, frm_pck_len);
 			memcpy(p, pbuf->desc_vptr + frm_pck_ofs, frm_pck_len);
diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index 9b298c1..b0ce14f 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -58,7 +58,6 @@ static int q_high =3D 50; /* Percent */
 struct cfcnfg *get_cfcnfg(struct net *net)
 {
 	struct caif_net *caifn;
-	BUG_ON(!net);
 	caifn =3D net_generic(net, caif_net_id);
 	if (!caifn)
 		return NULL;
@@ -69,7 +68,6 @@ EXPORT_SYMBOL(get_cfcnfg);
 static struct caif_device_entry_list *caif_device_list(struct net *net=
)
 {
 	struct caif_net *caifn;
-	BUG_ON(!net);
 	caifn =3D net_generic(net, caif_net_id);
 	if (!caifn)
 		return NULL;
@@ -507,15 +505,15 @@ static struct notifier_block caif_device_notifier=
 =3D {
 static int caif_init_net(struct net *net)
 {
 	struct caif_net *caifn =3D net_generic(net, caif_net_id);
-	BUG_ON(!caifn);
+	if (WARN_ON(!caifn))
+		return -EINVAL;
+
 	INIT_LIST_HEAD(&caifn->caifdevs.list);
 	mutex_init(&caifn->caifdevs.lock);
=20
 	caifn->cfg =3D cfcnfg_create();
-	if (!caifn->cfg) {
-		pr_warn("can't create cfcnfg\n");
+	if (!caifn->cfg)
 		return -ENOMEM;
-	}
=20
 	return 0;
 }
--=20
1.7.0.4
