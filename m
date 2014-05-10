From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 09/11] net: cdc_ncm: use sane defaults for rx/tx buffers
Date: Sat, 10 May 2014 17:41:47 +0200
Message-ID: <1399736509-1159-10-git-send-email-bjorn@mork.no>
References: <1399736509-1159-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-usb@vger.kernel.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	Enrico Mioso <mrkiko.rs@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:43756 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751971AbaEJPmU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 May 2014 11:42:20 -0400
In-Reply-To: <1399736509-1159-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lots of devices request much larger buffers than reasonable. This
cause real problems for users of hosts with limited resources.

Reducing the default buffer size to 16kB for such devices is
a reasonable trade-off between allowing them to aggregate traffic
and avoiding memory exhaustion on resource restrained hosts.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c   | 12 ++++++++++--
 include/linux/usb/cdc_ncm.h |  4 ++++
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index a28c964b35a9..7d315b983e7e 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -480,10 +480,18 @@ static void cdc_ncm_fix_modulus(struct usbnet *de=
v)
 static int cdc_ncm_setup(struct usbnet *dev)
 {
 	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+	u32 def_rx, def_tx;
+
+	/* be conservative when selecting intial buffer size to
+	 * increase the number of hosts this will work for
+	 */
+	def_rx =3D min_t(u32, CDC_NCM_NTB_DEF_SIZE_RX,
+		       le32_to_cpu(ctx->ncm_parm.dwNtbInMaxSize));
+	def_tx =3D min_t(u32, CDC_NCM_NTB_DEF_SIZE_TX,
+		       le32_to_cpu(ctx->ncm_parm.dwNtbOutMaxSize));
=20
 	/* clamp rx_max and tx_max and inform device */
-	cdc_ncm_update_rxtx_max(dev, le32_to_cpu(ctx->ncm_parm.dwNtbInMaxSize=
),
-				le32_to_cpu(ctx->ncm_parm.dwNtbOutMaxSize));
+		cdc_ncm_update_rxtx_max(dev, def_rx, def_tx);
=20
 	/* sanitize the modulus and remainder values */
 	cdc_ncm_fix_modulus(dev);
diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index 4eeaf6db20c8..1921bdadd9ab 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -52,6 +52,10 @@
 #define	CDC_NCM_NTB_MAX_SIZE_TX			32768	/* bytes */
 #define	CDC_NCM_NTB_MAX_SIZE_RX			32768	/* bytes */
=20
+/* Initial NTB length */
+#define	CDC_NCM_NTB_DEF_SIZE_TX			16384	/* bytes */
+#define	CDC_NCM_NTB_DEF_SIZE_RX			16384	/* bytes */
+
 /* Minimum value for MaxDatagramSize, ch. 6.2.9 */
 #define	CDC_NCM_MIN_DATAGRAM_SIZE		1514	/* bytes */
=20
--=20
2.0.0.rc2
