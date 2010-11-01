From: Sjur Braendeland <sjur.brandeland@stericsson.com>
Subject: [PATCH 2/2] caif: SPI-driver bugfix - incorrect padding.
Date: Mon,  1 Nov 2010 22:52:48 +0100
Message-ID: <1288648368-9062-2-git-send-email-sjur.brandeland@stericsson.com>
References: <1288648368-9062-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:35010 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751534Ab0KAVwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 17:52:54 -0400
Received: by ewy7 with SMTP id 7so3675566ewy.19
        for <netdev@vger.kernel.org>; Mon, 01 Nov 2010 14:52:53 -0700 (PDT)
In-Reply-To: <1288648368-9062-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>


Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 drivers/net/caif/caif_spi.c       |   57 +++++++++++++++++++++++++++--=
--------
 drivers/net/caif/caif_spi_slave.c |   13 ++++++--
 include/net/caif/caif_spi.h       |    2 +
 3 files changed, 53 insertions(+), 19 deletions(-)

diff --git a/drivers/net/caif/caif_spi.c b/drivers/net/caif/caif_spi.c
index 8427533..8b4cea5 100644
--- a/drivers/net/caif/caif_spi.c
+++ b/drivers/net/caif/caif_spi.c
@@ -33,6 +33,9 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Daniel Martensson<daniel.martensson@stericsson.com>");
 MODULE_DESCRIPTION("CAIF SPI driver");
=20
+/* Returns the number of padding bytes for alignment. */
+#define PAD_POW2(x, pow) ((((x)&((pow)-1))=3D=3D0) ? 0 : (((pow)-((x)&=
((pow)-1)))))
+
 static int spi_loop;
 module_param(spi_loop, bool, S_IRUGO);
 MODULE_PARM_DESC(spi_loop, "SPI running in loopback mode.");
@@ -41,7 +44,10 @@ MODULE_PARM_DESC(spi_loop, "SPI running in loopback =
mode.");
 module_param(spi_frm_align, int, S_IRUGO);
 MODULE_PARM_DESC(spi_frm_align, "SPI frame alignment.");
=20
-/* SPI padding options. */
+/*
+ * SPI padding options.
+ * Warning: must be a base of 2 (& operation used) and can not be zero=
 !
+ */
 module_param(spi_up_head_align, int, S_IRUGO);
 MODULE_PARM_DESC(spi_up_head_align, "SPI uplink head alignment.");
=20
@@ -240,15 +246,13 @@ static ssize_t dbgfs_frame(struct file *file, cha=
r __user *user_buf,
 static const struct file_operations dbgfs_state_fops =3D {
 	.open =3D dbgfs_open,
 	.read =3D dbgfs_state,
-	.owner =3D THIS_MODULE,
-	.llseek =3D default_llseek,
+	.owner =3D THIS_MODULE
 };
=20
 static const struct file_operations dbgfs_frame_fops =3D {
 	.open =3D dbgfs_open,
 	.read =3D dbgfs_frame,
-	.owner =3D THIS_MODULE,
-	.llseek =3D default_llseek,
+	.owner =3D THIS_MODULE
 };
=20
 static inline void dev_debugfs_add(struct cfspi *cfspi)
@@ -337,6 +341,9 @@ int cfspi_xmitfrm(struct cfspi *cfspi, u8 *buf, siz=
e_t len)
 	u8 *dst =3D buf;
 	caif_assert(buf);
=20
+	if (cfspi->slave && !cfspi->slave_talked)
+		cfspi->slave_talked =3D true;
+
 	do {
 		struct sk_buff *skb;
 		struct caif_payload_info *info;
@@ -357,8 +364,8 @@ int cfspi_xmitfrm(struct cfspi *cfspi, u8 *buf, siz=
e_t len)
 		 * Compute head offset i.e. number of bytes to add to
 		 * get the start of the payload aligned.
 		 */
-		if (spi_up_head_align) {
-			spad =3D 1 + ((info->hdr_len + 1) & spi_up_head_align);
+		if (spi_up_head_align > 1) {
+			spad =3D 1 + PAD_POW2((info->hdr_len + 1), spi_up_head_align);
 			*dst =3D (u8)(spad - 1);
 			dst +=3D spad;
 		}
@@ -373,7 +380,7 @@ int cfspi_xmitfrm(struct cfspi *cfspi, u8 *buf, siz=
e_t len)
 		 * Compute tail offset i.e. number of bytes to add to
 		 * get the complete CAIF frame aligned.
 		 */
-		epad =3D (skb->len + spad) & spi_up_tail_align;
+		epad =3D PAD_POW2((skb->len + spad), spi_up_tail_align);
 		dst +=3D epad;
=20
 		dev_kfree_skb(skb);
@@ -417,14 +424,14 @@ int cfspi_xmitlen(struct cfspi *cfspi)
 		 * Compute head offset i.e. number of bytes to add to
 		 * get the start of the payload aligned.
 		 */
-		if (spi_up_head_align)
-			spad =3D 1 + ((info->hdr_len + 1) & spi_up_head_align);
+		if (spi_up_head_align > 1)
+			spad =3D 1 + PAD_POW2((info->hdr_len + 1), spi_up_head_align);
=20
 		/*
 		 * Compute tail offset i.e. number of bytes to add to
 		 * get the complete CAIF frame aligned.
 		 */
-		epad =3D (skb->len + spad) & spi_up_tail_align;
+		epad =3D PAD_POW2((skb->len + spad), spi_up_tail_align);
=20
 		if ((skb->len + spad + epad + frm_len) <=3D CAIF_MAX_SPI_FRAME) {
 			skb_queue_tail(&cfspi->chead, skb);
@@ -433,6 +440,7 @@ int cfspi_xmitlen(struct cfspi *cfspi)
 		} else {
 			/* Put back packet. */
 			skb_queue_head(&cfspi->qhead, skb);
+			break;
 		}
 	} while (pkts <=3D CAIF_MAX_SPI_PKTS);
=20
@@ -453,6 +461,15 @@ static void cfspi_ss_cb(bool assert, struct cfspi_=
ifc *ifc)
 {
 	struct cfspi *cfspi =3D (struct cfspi *)ifc->priv;
=20
+	/*
+	 * The slave device is the master on the link. Interrupts before the
+	 * slave has transmitted are considered spurious.
+	 */
+	if (cfspi->slave && !cfspi->slave_talked) {
+		printk(KERN_WARNING "CFSPI: Spurious SS interrupt.\n");
+		return;
+	}
+
 	if (!in_interrupt())
 		spin_lock(&cfspi->lock);
 	if (assert) {
@@ -465,7 +482,8 @@ static void cfspi_ss_cb(bool assert, struct cfspi_i=
fc *ifc)
 		spin_unlock(&cfspi->lock);
=20
 	/* Wake up the xfer thread. */
-	wake_up_interruptible(&cfspi->wait);
+	if (assert)
+		wake_up_interruptible(&cfspi->wait);
 }
=20
 static void cfspi_xfer_done_cb(struct cfspi_ifc *ifc)
@@ -523,7 +541,7 @@ int cfspi_rxfrm(struct cfspi *cfspi, u8 *buf, size_=
t len)
 		 * Compute head offset i.e. number of bytes added to
 		 * get the start of the payload aligned.
 		 */
-		if (spi_down_head_align) {
+		if (spi_down_head_align > 1) {
 			spad =3D 1 + *src;
 			src +=3D spad;
 		}
@@ -564,7 +582,7 @@ int cfspi_rxfrm(struct cfspi *cfspi, u8 *buf, size_=
t len)
 		 * Compute tail offset i.e. number of bytes added to
 		 * get the complete CAIF frame aligned.
 		 */
-		epad =3D (pkt_len + spad) & spi_down_tail_align;
+		epad =3D PAD_POW2((pkt_len + spad), spi_down_tail_align);
 		src +=3D epad;
 	} while ((src - buf) < len);
=20
@@ -625,11 +643,20 @@ int cfspi_spi_probe(struct platform_device *pdev)
 	cfspi->ndev =3D ndev;
 	cfspi->pdev =3D pdev;
=20
-	/* Set flow info */
+	/* Set flow info. */
 	cfspi->flow_off_sent =3D 0;
 	cfspi->qd_low_mark =3D LOW_WATER_MARK;
 	cfspi->qd_high_mark =3D HIGH_WATER_MARK;
=20
+	/* Set slave info. */
+	if (!strncmp(cfspi_spi_driver.driver.name, "cfspi_sspi", 10)) {
+		cfspi->slave =3D true;
+		cfspi->slave_talked =3D false;
+	} else {
+		cfspi->slave =3D false;
+		cfspi->slave_talked =3D false;
+	}
+
 	/* Assign the SPI device. */
 	cfspi->dev =3D dev;
 	/* Assign the device ifc to this SPI interface. */
diff --git a/drivers/net/caif/caif_spi_slave.c b/drivers/net/caif/caif_=
spi_slave.c
index 2111dbf..1b9943a 100644
--- a/drivers/net/caif/caif_spi_slave.c
+++ b/drivers/net/caif/caif_spi_slave.c
@@ -36,10 +36,15 @@ static inline int forward_to_spi_cmd(struct cfspi *=
cfspi)
 #endif
=20
 int spi_frm_align =3D 2;
-int spi_up_head_align =3D 1;
-int spi_up_tail_align;
-int spi_down_head_align =3D 3;
-int spi_down_tail_align =3D 1;
+
+/*
+ * SPI padding options.
+ * Warning: must be a base of 2 (& operation used) and can not be zero=
 !
+ */
+int spi_up_head_align   =3D 1 << 1;
+int spi_up_tail_align   =3D 1 << 0;
+int spi_down_head_align =3D 1 << 2;
+int spi_down_tail_align =3D 1 << 1;
=20
 #ifdef CONFIG_DEBUG_FS
 static inline void debugfs_store_prev(struct cfspi *cfspi)
diff --git a/include/net/caif/caif_spi.h b/include/net/caif/caif_spi.h
index ce4570d..87c3d11 100644
--- a/include/net/caif/caif_spi.h
+++ b/include/net/caif/caif_spi.h
@@ -121,6 +121,8 @@ struct cfspi {
 	wait_queue_head_t wait;
 	spinlock_t lock;
 	bool flow_stop;
+	bool slave;
+	bool slave_talked;
 #ifdef CONFIG_DEBUG_FS
 	enum cfspi_state dbg_state;
 	u16 pcmd;
--=20
1.7.0.4

