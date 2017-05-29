From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH v8 net-next 11/17] net: qualcomm: prepare frame decoding for UART driver
Date: Mon, 29 May 2017 13:57:19 +0200
Message-ID: <1496059045-13572-12-git-send-email-stefan.wahren@i2se.com>
References: <1496059045-13572-1-git-send-email-stefan.wahren@i2se.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Jakub Kicinski <kubakici@wp.pl>, devicetree@vger.kernel.org,
        netdev@vger.kernel.org, linux-serial@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Stefan Wahren <stefan.wahren@i2se.com>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496059045-13572-1-git-send-email-stefan.wahren@i2se.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Unfortunately the frame format is not exactly identical between SPI
and UART. In case of SPI there is an additional HW length at the
beginning. So store the initial state to make the decoding state machine
more flexible and easy to extend for UART support.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
---
 drivers/net/ethernet/qualcomm/qca_7k_common.c | 12 ++++++------
 drivers/net/ethernet/qualcomm/qca_7k_common.h |  8 ++++++--
 drivers/net/ethernet/qualcomm/qca_spi.c       |  2 +-
 3 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/qca_7k_common.c b/drivers/net/ethernet/qualcomm/qca_7k_common.c
index 6d17fbd..0d3daa9 100644
--- a/drivers/net/ethernet/qualcomm/qca_7k_common.c
+++ b/drivers/net/ethernet/qualcomm/qca_7k_common.c
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
 		if (len > buf_len || len < QCAFRM_MIN_LEN) {
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
diff --git a/drivers/net/ethernet/qualcomm/qca_7k_common.h b/drivers/net/ethernet/qualcomm/qca_7k_common.h
index 5df7c65..07bdd6c 100644
--- a/drivers/net/ethernet/qualcomm/qca_7k_common.h
+++ b/drivers/net/ethernet/qualcomm/qca_7k_common.h
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
 	u16 offset;
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
index 43cc7de..de78f60 100644
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
