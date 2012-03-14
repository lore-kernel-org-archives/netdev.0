From: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 2/4] cdc_ncm: fix MTU and max_datagram_size handling
Date: Wed, 14 Mar 2012 22:26:11 +0100
Message-ID: <1331760373-1914-2-git-send-email-alexey.orishko@stericsson.com>
References: <1331760373-1914-1-git-send-email-alexey.orishko@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
	Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1331760373-1914-1-git-send-email-alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Changes/fixes:
- inform device if max_datagram_size was changed by host
- max_datagram_size can't be bigger MTU in ETH func descr
- fix constants definitions to enable running CAIF service over NCM

Tested on Intel/ARM.

Reviewed-by: Sjur Br=C3=A6ndeland <sjur.brandeland-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Tested-by: Dmitry Tarnyagin <Dmitry.Tarnyagin-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Signed-off-by: Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
---
 drivers/net/usb/cdc_ncm.c |   34 ++++++++++++++++------------------
 1 files changed, 16 insertions(+), 18 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index a8e2a62..f8f1946 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -58,8 +58,8 @@
 #define USB_CDC_NCM_NDP16_LENGTH_MIN		0x10
=20
 /* Maximum NTB length */
-#define	CDC_NCM_NTB_MAX_SIZE_TX			16384	/* bytes */
-#define	CDC_NCM_NTB_MAX_SIZE_RX			16384	/* bytes */
+#define	CDC_NCM_NTB_MAX_SIZE_TX			32768	/* bytes */
+#define	CDC_NCM_NTB_MAX_SIZE_RX			32768	/* bytes */
=20
 /* Minimum value for MaxDatagramSize, ch. 6.2.9 */
 #define	CDC_NCM_MIN_DATAGRAM_SIZE		1514	/* bytes */
@@ -67,13 +67,13 @@
 #define	CDC_NCM_MIN_TX_PKT			512	/* bytes */
=20
 /* Default value for MaxDatagramSize */
-#define	CDC_NCM_MAX_DATAGRAM_SIZE		2048	/* bytes */
+#define	CDC_NCM_MAX_DATAGRAM_SIZE		8192	/* bytes */
=20
 /*
  * Maximum amount of datagrams in NCM Datagram Pointer Table, not coun=
ting
  * the last NULL entry. Any additional datagrams in NTB would be disca=
rded.
  */
-#define	CDC_NCM_DPT_DATAGRAMS_MAX		32
+#define	CDC_NCM_DPT_DATAGRAMS_MAX		40
=20
 /* Maximum amount of IN datagrams in NTB */
 #define	CDC_NCM_DPT_DATAGRAMS_IN_MAX		0 /* unlimited */
@@ -366,27 +366,25 @@ size_err:
 		if (err < 0) {
 			pr_debug("GET_MAX_DATAGRAM_SIZE failed, use size=3D%u\n",
 						CDC_NCM_MIN_DATAGRAM_SIZE);
-			kfree(max_datagram_size);
 		} else {
 			ctx->max_datagram_size =3D
 				le16_to_cpu(*max_datagram_size);
 			/* Check Eth descriptor value */
-			if (eth_max_sz < CDC_NCM_MAX_DATAGRAM_SIZE) {
-				if (ctx->max_datagram_size > eth_max_sz)
+			if (ctx->max_datagram_size > eth_max_sz)
 					ctx->max_datagram_size =3D eth_max_sz;
-			} else {
-				if (ctx->max_datagram_size >
-						CDC_NCM_MAX_DATAGRAM_SIZE)
-					ctx->max_datagram_size =3D
+
+			if (ctx->max_datagram_size > CDC_NCM_MAX_DATAGRAM_SIZE)
+				ctx->max_datagram_size =3D
 						CDC_NCM_MAX_DATAGRAM_SIZE;
-			}
=20
 			if (ctx->max_datagram_size < CDC_NCM_MIN_DATAGRAM_SIZE)
 				ctx->max_datagram_size =3D
 					CDC_NCM_MIN_DATAGRAM_SIZE;
=20
 			/* if value changed, update device */
-			err =3D usb_control_msg(ctx->udev,
+			if (ctx->max_datagram_size !=3D
+					le16_to_cpu(*max_datagram_size)) {
+				err =3D usb_control_msg(ctx->udev,
 						usb_sndctrlpipe(ctx->udev, 0),
 						USB_CDC_SET_MAX_DATAGRAM_SIZE,
 						USB_TYPE_CLASS | USB_DIR_OUT
@@ -394,14 +392,14 @@ size_err:
 						0,
 						iface_no, max_datagram_size,
 						2, 1000);
-			kfree(max_datagram_size);
-max_dgram_err:
-			if (err < 0)
-				pr_debug("SET_MAX_DATAGRAM_SIZE failed\n");
+				if (err < 0)
+					pr_debug("SET_MAX_DGRAM_SIZE failed\n");
+			}
 		}
