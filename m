From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next v2 09/12] net: cdc_ncm: use sane defaults for rx/tx buffers
Date: Fri, 16 May 2014 21:48:26 +0200
Message-ID: <1400269709-18854-10-git-send-email-bjorn@mork.no>
References: <1400269709-18854-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1400269709-18854-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Lots of devices request much larger buffers than reasonable. This
cause real problems for users of hosts with limited resources.

Reducing the default buffer size to 16kB for such devices is
a reasonable trade-off between allowing them to aggregate traffic
and avoiding memory exhaustion on resource restrained hosts.

Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/cdc_ncm.c   | 12 ++++++++++--
 include/linux/usb/cdc_ncm.h |  4 ++++
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index f4b439847d04..bb53abe1f3a1 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -492,10 +492,18 @@ static void cdc_ncm_fix_modulus(struct usbnet *de=
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
+	cdc_ncm_update_rxtx_max(dev, def_rx, def_tx);
=20
 	/* sanitize the modulus and remainder values */
 	cdc_ncm_fix_modulus(dev);
diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index 88d2d7f1820f..cde506731c48 100644
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

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
