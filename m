From: Stefan Wahren <stefan.wahren-eS4NqCHxEME@public.gmane.org>
Subject: [PATCH RFC v4 05/10] net: qualcomm: prepare frame decoding for UART driver
Date: Mon, 27 Mar 2017 15:37:23 +0200
Message-ID: <1490621848-24828-6-git-send-email-stefan.wahren@i2se.com>
References: <1490621848-24828-1-git-send-email-stefan.wahren@i2se.com>
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        Jiri Slaby <jslaby-IBi9RG/b67k@public.gmane.org>,
        Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
        Sebastian Reichel <sre-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Stefan Wahren <stefan.wahren-eS4NqCHxEME@public.gmane.org>
To: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1490621848-24828-1-git-send-email-stefan.wahren-eS4NqCHxEME@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Unfortunately the frame format is not exactly identical between SPI
and UART. In case of SPI there is an additional HW length at the
beginning. So store the initial state to make the decoding state machine
more flexible and easy to extend for UART support.

Signed-off-by: Stefan Wahren <stefan.wahren-eS4NqCHxEME@public.gmane.org>
---
 drivers/net/ethernet/qualcomm/qca_common.c | 12 ++++++------
 drivers/net/ethernet/qualcomm/qca_common.h |  8 ++++++--
 drivers/net/ethernet/qualcomm/qca_spi.c    |  2 +-
 3 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/qca_common.c b/drivers/net/ethernet/qualcomm/qca_common.c
index 26453a9..d930524 100644
--- a/drivers/net/ethernet/qualcomm/qca_common.c
+++ b/drivers/net/ethernet/qualcomm/qca_common.c
@@ -83,7 +83,7 @@ qcafrm_fsm_decode(struct qcafrm_handle *handle, u8 *buf, u16 buf_len, u8 recv_by
 
 		if (recv_byte != 0x00) {
 			/* first two bytes of length must be 0 */
-			handle->state = QCAFRM_HW_LEN0;
+			handle->state = handle->init;
 		}
 		break;
 	case QCAFRM_HW_LEN2:
@@ -97,7 +97,7 @@ qcafrm_fsm_decode(struct qcafrm_handle *handle, u8 *buf, u16 buf_len, u8 recv_by
 	case QCAFRM_WAIT_AA4:
 		if (recv_byte != 0xAA) {
 			ret = QCAFRM_NOHEAD;
-			handle->state = QCAFRM_HW_LEN0;
+			handle->state = handle->init;
 		} else {
 			handle->state--;
 		}
@@ -119,7 +119,7 @@ qcafrm_fsm_decode(struct qcafrm_handle *handle, u8 *buf, u16 buf_len, u8 recv_by
 		len = handle->offset;
 		if (len > buf_len || len < QCAFRM_ETHMINLEN) {
 			ret = QCAFRM_INVLEN;
-			handle->state = QCAFRM_HW_LEN0;
+			handle->state = handle->init;
 		} else {
 			handle->state = (enum qcafrm_state)(len + 1);
 			/* Remaining number of bytes. */
@@ -135,7 +135,7 @@ qcafrm_fsm_decode(struct qcafrm_handle *handle, u8 *buf, u16 buf_len, u8 recv_by
 	case QCAFRM_WAIT_551:
 		if (recv_byte != 0x55) {
 			ret = QCAFRM_NOTAIL;
-			handle->state = QCAFRM_HW_LEN0;
+			handle->state = handle->init;
 		} else {
 			handle->state = QCAFRM_WAIT_552;
 		}
@@ -143,11 +143,11 @@ qcafrm_fsm_decode(struct qcafrm_handle *handle, u8 *buf, u16 buf_len, u8 recv_by
 	case QCAFRM_WAIT_552:
 		if (recv_byte != 0x55) {
 			ret = QCAFRM_NOTAIL;
-			handle->state = QCAFRM_HW_LEN0;
+			handle->state = handle->init;
 		} else {
 			ret = handle->offset;
 			/* Frame is fully received. */
-			handle->state = QCAFRM_HW_LEN0;
+			handle->state = handle->init;
 		}
 		break;
 	}
diff --git a/drivers/net/ethernet/qualcomm/qca_common.h b/drivers/net/ethernet/qualcomm/qca_common.h
index d5e795d..431f99d 100644
--- a/drivers/net/ethernet/qualcomm/qca_common.h
+++ b/drivers/net/ethernet/qualcomm/qca_common.h
@@ -61,6 +61,7 @@
 #define QCAFRM_ERR_BASE -1000
 
 enum qcafrm_state {
+	/* HW length is only available on SPI */
 	QCAFRM_HW_LEN0 = 0x8000,
 	QCAFRM_HW_LEN1 = QCAFRM_HW_LEN0 - 1,
 	QCAFRM_HW_LEN2 = QCAFRM_HW_LEN1 - 1,
@@ -101,6 +102,8 @@ enum qcafrm_state {
 struct qcafrm_handle {
 	/*  Current decoding state */
 	enum qcafrm_state state;
+	/* Initial state depends on connection type */
+	enum qcafrm_state init;
 
 	/* Offset in buffer (borrowed for length too) */
 	s16 offset;
@@ -113,9 +116,10 @@ u16 qcafrm_create_header(u8 *buf, u16 len);
 
 u16 qcafrm_create_footer(u8 *buf);
 
-static inline void qcafrm_fsm_init(struct qcafrm_handle *handle)
+static inline void qcafrm_fsm_init_spi(struct qcafrm_handle *handle)
 {
-	handle->state = QCAFRM_HW_LEN0;
+	handle->init = QCAFRM_HW_LEN0;
+	handle->state = handle->init;
 }
 
 /*   Gather received bytes and try to extract a full Ethernet frame
diff --git a/drivers/net/ethernet/qualcomm/qca_spi.c b/drivers/net/ethernet/qualcomm/qca_spi.c
index 65adc10..3617bde 100644
--- a/drivers/net/ethernet/qualcomm/qca_spi.c
+++ b/drivers/net/ethernet/qualcomm/qca_spi.c
@@ -638,7 +638,7 @@ qcaspi_netdev_open(struct net_device *dev)
 	qca->intr_req = 1;
 	qca->intr_svc = 0;
 	qca->sync = QCASPI_SYNC_UNKNOWN;
-	qcafrm_fsm_init(&qca->frm_handle);
+	qcafrm_fsm_init_spi(&qca->frm_handle);
 
 	qca->spi_thread = kthread_run((void *)qcaspi_spi_thread,
 				      qca, "%s", dev->name);
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
