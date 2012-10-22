From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH v2 net-next 08/13] net: cdc_ncm: export shared symbols and definitions
Date: Mon, 22 Oct 2012 22:56:35 +0200
Message-ID: <1350939400-27209-9-git-send-email-bjorn@mork.no>
References: <1350939400-27209-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Greg Suarez <gpsuarez2512@gmail.com>,
	"Fangxiaozhi (Franko)" <fangxiaozhi@huawei.com>,
	Dan Williams <dcbw@redhat.com>,
	Aleksander Morgado <aleksander@lanedo.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:48604 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756357Ab2JVU5W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2012 16:57:22 -0400
In-Reply-To: <1350939400-27209-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move symbols and definitons which can be shared with a
MBIM driver in a new header.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c   |   97 ++++-----------------------------
 include/linux/usb/cdc_ncm.h |  124 +++++++++++++++++++++++++++++++++++=
++++++++
 2 files changed, 135 insertions(+), 86 deletions(-)
 create mode 100644 include/linux/usb/cdc_ncm.h

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 2dd2734..17b4ba0 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -51,90 +51,10 @@
 #include <linux/atomic.h>
 #include <linux/usb/usbnet.h>
 #include <linux/usb/cdc.h>
+#include <linux/usb/cdc_ncm.h>
=20
 #define	DRIVER_VERSION				"14-Mar-2012"
=20
-/* CDC NCM subclass 3.2.1 */
-#define USB_CDC_NCM_NDP16_LENGTH_MIN		0x10
-
-/* Maximum NTB length */
-#define	CDC_NCM_NTB_MAX_SIZE_TX			32768	/* bytes */
-#define	CDC_NCM_NTB_MAX_SIZE_RX			32768	/* bytes */
-
-/* Minimum value for MaxDatagramSize, ch. 6.2.9 */
-#define	CDC_NCM_MIN_DATAGRAM_SIZE		1514	/* bytes */
-
-/* Minimum value for MaxDatagramSize, ch. 8.1.3 */
-#define CDC_MBIM_MIN_DATAGRAM_SIZE              2048    /* bytes */
-
-#define	CDC_NCM_MIN_TX_PKT			512	/* bytes */
-
-/* Default value for MaxDatagramSize */
-#define	CDC_NCM_MAX_DATAGRAM_SIZE		8192	/* bytes */
-
-/*
- * Maximum amount of datagrams in NCM Datagram Pointer Table, not coun=
ting
- * the last NULL entry.
- */
-#define	CDC_NCM_DPT_DATAGRAMS_MAX		40
-
-/* Restart the timer, if amount of datagrams is less than given value =
*/
-#define	CDC_NCM_RESTART_TIMER_DATAGRAM_CNT	3
-#define	CDC_NCM_TIMER_PENDING_CNT		2
-#define CDC_NCM_TIMER_INTERVAL			(400UL * NSEC_PER_USEC)
-
-/* The following macro defines the minimum header space */
-#define	CDC_NCM_MIN_HDR_SIZE \
-	(sizeof(struct usb_cdc_ncm_nth16) + sizeof(struct usb_cdc_ncm_ndp16) =
+ \
-	(CDC_NCM_DPT_DATAGRAMS_MAX + 1) * sizeof(struct usb_cdc_ncm_dpe16))
-
-#define CDC_NCM_NDP_SIZE \
-	(sizeof(struct usb_cdc_ncm_ndp16) +				\
-	      (CDC_NCM_DPT_DATAGRAMS_MAX + 1) * sizeof(struct usb_cdc_ncm_dpe=
16))
-
-struct cdc_ncm_ctx {
-	struct usb_cdc_ncm_ntb_parameters ncm_parm;
-	struct hrtimer tx_timer;
-	struct tasklet_struct bh;
-
-	const struct usb_cdc_ncm_desc *func_desc;
-	const struct usb_cdc_mbim_desc *mbim_desc;
-	const struct usb_cdc_header_desc *header_desc;
-	const struct usb_cdc_union_desc *union_desc;
-	const struct usb_cdc_ether_desc *ether_desc;
-
-	struct net_device *netdev;
-	struct usb_device *udev;
-	struct usb_host_endpoint *in_ep;
-	struct usb_host_endpoint *out_ep;
-	struct usb_host_endpoint *status_ep;
-	struct usb_interface *intf;
-	struct usb_interface *control;
-	struct usb_interface *data;
-
-	struct sk_buff *tx_curr_skb;
-	struct sk_buff *tx_rem_skb;
-	__le32 tx_rem_sign;
-
-	spinlock_t mtx;
-	atomic_t stop;
-
-	u32 tx_timer_pending;
-	u32 tx_curr_frame_num;
-	u32 rx_speed;
-	u32 tx_speed;
-	u32 rx_max;
-	u32 tx_max;
-	u32 max_datagram_size;
-	u16 tx_max_datagrams;
-	u16 tx_remainder;
-	u16 tx_modulus;
-	u16 tx_ndp_modulus;
-	u16 tx_seq;
-	u16 rx_seq;
-	u16 connected;
-};
-
 static void cdc_ncm_txpath_bh(unsigned long param);
 static void cdc_ncm_tx_timeout_start(struct cdc_ncm_ctx *ctx);
 static enum hrtimer_restart cdc_ncm_tx_timer_cb(struct hrtimer *hr_tim=
er);
@@ -447,7 +367,7 @@ static const struct ethtool_ops cdc_ncm_ethtool_ops=
 =3D {
 	.nway_reset =3D usbnet_nway_reset,
 };
=20
-static int cdc_ncm_bind_common(struct usbnet *dev, struct usb_interfac=
e *intf, u8 data_altsetting)
+int cdc_ncm_bind_common(struct usbnet *dev, struct usb_interface *intf=
, u8 data_altsetting)
 {
 	struct cdc_ncm_ctx *ctx;
 	struct usb_driver *driver;
@@ -605,8 +525,9 @@ error:
 	dev_info(&dev->udev->dev, "bind() failure\n");
 	return -ENODEV;
 }
+EXPORT_SYMBOL_GPL(cdc_ncm_bind_common);
=20
-static void cdc_ncm_unbind(struct usbnet *dev, struct usb_interface *i=
ntf)
+void cdc_ncm_unbind(struct usbnet *dev, struct usb_interface *intf)
 {
 	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
 	struct usb_driver *driver =3D driver_of(intf);
@@ -636,6 +557,7 @@ static void cdc_ncm_unbind(struct usbnet *dev, stru=
ct usb_interface *intf)
 	usb_set_intfdata(ctx->intf, NULL);
 	cdc_ncm_free(ctx);
 }
+EXPORT_SYMBOL_GPL(cdc_ncm_unbind);
=20
 static int cdc_ncm_bind(struct usbnet *dev, struct usb_interface *intf=
)
 {
@@ -701,7 +623,7 @@ static struct usb_cdc_ncm_ndp16 *cdc_ncm_ndp(struct=
 cdc_ncm_ctx *ctx, struct sk_
 	return ndp16;
 }
=20
-static struct sk_buff *
+struct sk_buff *
 cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, struct sk_buff *skb, __=
le32 sign)
 {
 	struct usb_cdc_ncm_nth16 *nth16;
@@ -858,6 +780,7 @@ exit_no_skb:
 		cdc_ncm_tx_timeout_start(ctx);
 	return NULL;
 }
+EXPORT_SYMBOL_GPL(cdc_ncm_fill_tx_frame);
=20
 static void cdc_ncm_tx_timeout_start(struct cdc_ncm_ctx *ctx)
 {
@@ -924,7 +847,7 @@ error:
 }
=20
 /* verify NTB header and return offset of first NDP, or negative error=
 */
-static int cdc_ncm_rx_verify_nth16(struct cdc_ncm_ctx *ctx, struct sk_=
buff *skb_in)
+int cdc_ncm_rx_verify_nth16(struct cdc_ncm_ctx *ctx, struct sk_buff *s=
kb_in)
 {
 	struct usb_cdc_ncm_nth16 *nth16;
 	int len;
@@ -966,9 +889,10 @@ static int cdc_ncm_rx_verify_nth16(struct cdc_ncm_=
ctx *ctx, struct sk_buff *skb_
 error:
 	return ret;
 }
+EXPORT_SYMBOL_GPL(cdc_ncm_rx_verify_nth16);
=20
 /* verify NDP header and return number of datagrams, or negative error=
 */
-static int cdc_ncm_rx_verify_ndp16(struct sk_buff *skb_in, int ndpoffs=
et)
+int cdc_ncm_rx_verify_ndp16(struct sk_buff *skb_in, int ndpoffset)
 {
 	struct usb_cdc_ncm_ndp16 *ndp16;
 	int ret =3D -EINVAL;
@@ -999,6 +923,7 @@ static int cdc_ncm_rx_verify_ndp16(struct sk_buff *=
skb_in, int ndpoffset)
 error:
 	return ret;
 }
+EXPORT_SYMBOL_GPL(cdc_ncm_rx_verify_ndp16);
=20
 static int cdc_ncm_rx_fixup(struct usbnet *dev, struct sk_buff *skb_in=
)
 {
diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
new file mode 100644
index 0000000..d1719a7
--- /dev/null
+++ b/include/linux/usb/cdc_ncm.h
@@ -0,0 +1,124 @@
+/*
+ * Copyright (C) ST-Ericsson 2010-2012
+ * Contact: Alexey Orishko <alexey.orishko@stericsson.com>
+ * Original author: Hans Petter Selasky <hans.petter.selasky@stericsso=
n.com>
+ *
+ * USB Host Driver for Network Control Model (NCM)
+ * http://www.usb.org/developers/devclass_docs/NCM10.zip
+ *
+ * The NCM encoding, decoding and initialization logic
+ * derives from FreeBSD 8.x. if_cdce.c and if_cdcereg.h
+ *
+ * This software is available to you under a choice of one of two
+ * licenses. You may choose this file to be licensed under the terms
+ * of the GNU General Public License (GPL) Version 2 or the 2-clause
+ * BSD license listed below:
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyrigh=
t
+ *    notice, this list of conditions and the following disclaimer in =
the
+ *    documentation and/or other materials provided with the distribut=
ion.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' =
AND
+ * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, T=
HE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR =
PURPOSE
+ * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LI=
ABLE
+ * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQ=
UENTIAL
+ * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE G=
OODS
+ * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTIO=
N)
+ * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,=
 STRICT
+ * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN A=
NY WAY
+ * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY=
 OF
+ * SUCH DAMAGE.
+ */
+
+/* CDC NCM subclass 3.2.1 */
+#define USB_CDC_NCM_NDP16_LENGTH_MIN		0x10
+
+/* Maximum NTB length */
+#define	CDC_NCM_NTB_MAX_SIZE_TX			32768	/* bytes */
+#define	CDC_NCM_NTB_MAX_SIZE_RX			32768	/* bytes */
+
+/* Minimum value for MaxDatagramSize, ch. 6.2.9 */
+#define	CDC_NCM_MIN_DATAGRAM_SIZE		1514	/* bytes */
+
+/* Minimum value for MaxDatagramSize, ch. 8.1.3 */
+#define CDC_MBIM_MIN_DATAGRAM_SIZE		2048	/* bytes */
+
+#define	CDC_NCM_MIN_TX_PKT			512	/* bytes */
+
+/* Default value for MaxDatagramSize */
+#define	CDC_NCM_MAX_DATAGRAM_SIZE		8192	/* bytes */
+
+/*
+ * Maximum amount of datagrams in NCM Datagram Pointer Table, not coun=
ting
+ * the last NULL entry.
+ */
+#define	CDC_NCM_DPT_DATAGRAMS_MAX		40
+
+/* Restart the timer, if amount of datagrams is less than given value =
*/
+#define	CDC_NCM_RESTART_TIMER_DATAGRAM_CNT	3
+#define	CDC_NCM_TIMER_PENDING_CNT		2
+#define CDC_NCM_TIMER_INTERVAL			(400UL * NSEC_PER_USEC)
+
+/* The following macro defines the minimum header space */
+#define	CDC_NCM_MIN_HDR_SIZE \
+	(sizeof(struct usb_cdc_ncm_nth16) + sizeof(struct usb_cdc_ncm_ndp16) =
+ \
+	(CDC_NCM_DPT_DATAGRAMS_MAX + 1) * sizeof(struct usb_cdc_ncm_dpe16))
+
+#define CDC_NCM_NDP_SIZE \
+	(sizeof(struct usb_cdc_ncm_ndp16) +				\
+	      (CDC_NCM_DPT_DATAGRAMS_MAX + 1) * sizeof(struct usb_cdc_ncm_dpe=
16))
+
+struct cdc_ncm_ctx {
+	struct usb_cdc_ncm_ntb_parameters ncm_parm;
+	struct hrtimer tx_timer;
+	struct tasklet_struct bh;
+
+	const struct usb_cdc_ncm_desc *func_desc;
+	const struct usb_cdc_mbim_desc   *mbim_desc;
+	const struct usb_cdc_header_desc *header_desc;
+	const struct usb_cdc_union_desc *union_desc;
+	const struct usb_cdc_ether_desc *ether_desc;
+
+	struct net_device *netdev;
+	struct usb_device *udev;
+	struct usb_host_endpoint *in_ep;
+	struct usb_host_endpoint *out_ep;
+	struct usb_host_endpoint *status_ep;
+	struct usb_interface *intf;
+	struct usb_interface *control;
+	struct usb_interface *data;
+
+	struct sk_buff *tx_curr_skb;
+	struct sk_buff *tx_rem_skb;
+	__le32 tx_rem_sign;
+
+	spinlock_t mtx;
+	atomic_t stop;
+
+	u32 tx_timer_pending;
+	u32 tx_curr_frame_num;
+	u32 rx_speed;
+	u32 tx_speed;
+	u32 rx_max;
+	u32 tx_max;
+	u32 max_datagram_size;
+	u16 tx_max_datagrams;
+	u16 tx_remainder;
+	u16 tx_modulus;
+	u16 tx_ndp_modulus;
+	u16 tx_seq;
+	u16 rx_seq;
+	u16 connected;
+};
+
+extern int cdc_ncm_bind_common(struct usbnet *dev, struct usb_interfac=
e *intf, u8 data_altsetting);
+extern void cdc_ncm_unbind(struct usbnet *dev, struct usb_interface *i=
ntf);
+extern struct sk_buff *cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, =
struct sk_buff *skb, __le32 sign);
+extern int cdc_ncm_rx_verify_nth16(struct cdc_ncm_ctx *ctx, struct sk_=
buff *skb_in);
+extern int cdc_ncm_rx_verify_ndp16(struct sk_buff *skb_in, int ndpoffs=
et);
--=20
1.7.10.4
