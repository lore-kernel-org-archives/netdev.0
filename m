From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH v3 net-next 4/8] net: qualcomm: rename qca_framing.c to qca_common.c
Date: Tue, 18 Oct 2016 13:27:30 +0200
Message-ID: <1476790054-27174-5-git-send-email-stefan.wahren@i2se.com>
References: <1476790054-27174-1-git-send-email-stefan.wahren@i2se.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Stefan Wahren <stefan.wahren@i2se.com>
To: "David S. Miller" <davem@davemloft.net>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476790054-27174-1-git-send-email-stefan.wahren@i2se.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As preparation for the upcoming UART driver we need a module
which contains common functions for both interfaces. The module
qca_framing is a good candidate but renaming to qca_common would
make it clear.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
---
 drivers/net/ethernet/qualcomm/Makefile      |   2 +-
 drivers/net/ethernet/qualcomm/qca_common.c  | 156 ++++++++++++++++++++++++++++
 drivers/net/ethernet/qualcomm/qca_common.h  | 134 ++++++++++++++++++++++++
 drivers/net/ethernet/qualcomm/qca_framing.c | 156 ----------------------------
 drivers/net/ethernet/qualcomm/qca_framing.h | 134 ------------------------
 drivers/net/ethernet/qualcomm/qca_spi.c     |   2 +-
 drivers/net/ethernet/qualcomm/qca_spi.h     |   2 +-
 7 files changed, 293 insertions(+), 293 deletions(-)
 create mode 100644 drivers/net/ethernet/qualcomm/qca_common.c
 create mode 100644 drivers/net/ethernet/qualcomm/qca_common.h
 delete mode 100644 drivers/net/ethernet/qualcomm/qca_framing.c
 delete mode 100644 drivers/net/ethernet/qualcomm/qca_framing.h

diff --git a/drivers/net/ethernet/qualcomm/Makefile b/drivers/net/ethernet/qualcomm/Makefile
index aacb0a5..8080570 100644
--- a/drivers/net/ethernet/qualcomm/Makefile
+++ b/drivers/net/ethernet/qualcomm/Makefile
@@ -3,6 +3,6 @@
 #
 
 obj-$(CONFIG_QCA7000) += qcaspi.o
-qcaspi-objs := qca_spi.o qca_framing.o qca_7k.o qca_debug.o
+qcaspi-objs := qca_spi.o qca_common.o qca_7k.o qca_debug.o
 
 obj-y += emac/
diff --git a/drivers/net/ethernet/qualcomm/qca_common.c b/drivers/net/ethernet/qualcomm/qca_common.c
new file mode 100644
index 0000000..26453a9
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/qca_common.c
@@ -0,0 +1,156 @@
+/*
+ *   Copyright (c) 2011, 2012, Atheros Communications Inc.
+ *   Copyright (c) 2014, I2SE GmbH
+ *
+ *   Permission to use, copy, modify, and/or distribute this software
+ *   for any purpose with or without fee is hereby granted, provided
+ *   that the above copyright notice and this permission notice appear
+ *   in all copies.
+ *
+ *   THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
+ *   WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
+ *   WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL
+ *   THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
+ *   CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
+ *   LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
+ *   NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
+ *   CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+/*   Atheros ethernet framing. Every Ethernet frame is surrounded
+ *   by an atheros frame while transmitted over a serial channel;
+ */
+
+#include <linux/kernel.h>
+
+#include "qca_common.h"
+
+u16
+qcafrm_create_header(u8 *buf, u16 length)
+{
+	__le16 len;
+
+	if (!buf)
+		return 0;
+
+	len = cpu_to_le16(length);
+
+	buf[0] = 0xAA;
+	buf[1] = 0xAA;
+	buf[2] = 0xAA;
+	buf[3] = 0xAA;
+	buf[4] = len & 0xff;
+	buf[5] = (len >> 8) & 0xff;
+	buf[6] = 0;
+	buf[7] = 0;
+
+	return QCAFRM_HEADER_LEN;
+}
+
+u16
+qcafrm_create_footer(u8 *buf)
+{
+	if (!buf)
+		return 0;
+
+	buf[0] = 0x55;
+	buf[1] = 0x55;
+	return QCAFRM_FOOTER_LEN;
+}
+
+/*   Gather received bytes and try to extract a full ethernet frame by
+ *   following a simple state machine.
+ *
+ * Return:   QCAFRM_GATHER       No ethernet frame fully received yet.
+ *           QCAFRM_NOHEAD       Header expected but not found.
+ *           QCAFRM_INVLEN       Atheros frame length is invalid
+ *           QCAFRM_NOTAIL       Footer expected but not found.
+ *           > 0                 Number of byte in the fully received
+ *                               Ethernet frame
+ */
+
+s32
+qcafrm_fsm_decode(struct qcafrm_handle *handle, u8 *buf, u16 buf_len, u8 recv_byte)
+{
+	s32 ret = QCAFRM_GATHER;
+	u16 len;
+
+	switch (handle->state) {
+	case QCAFRM_HW_LEN0:
+	case QCAFRM_HW_LEN1:
+		/* by default, just go to next state */
+		handle->state--;
+
+		if (recv_byte != 0x00) {
+			/* first two bytes of length must be 0 */
+			handle->state = QCAFRM_HW_LEN0;
+		}
+		break;
+	case QCAFRM_HW_LEN2:
+	case QCAFRM_HW_LEN3:
+		handle->state--;
+		break;
+	/* 4 bytes header pattern */
+	case QCAFRM_WAIT_AA1:
+	case QCAFRM_WAIT_AA2:
+	case QCAFRM_WAIT_AA3:
+	case QCAFRM_WAIT_AA4:
+		if (recv_byte != 0xAA) {
+			ret = QCAFRM_NOHEAD;
+			handle->state = QCAFRM_HW_LEN0;
+		} else {
+			handle->state--;
+		}
+		break;
+		/* 2 bytes length. */
+		/* Borrow offset field to hold length for now. */
+	case QCAFRM_WAIT_LEN_BYTE0:
+		handle->offset = recv_byte;
+		handle->state = QCAFRM_WAIT_LEN_BYTE1;
+		break;
+	case QCAFRM_WAIT_LEN_BYTE1:
+		handle->offset = handle->offset | (recv_byte << 8);
+		handle->state = QCAFRM_WAIT_RSVD_BYTE1;
+		break;
+	case QCAFRM_WAIT_RSVD_BYTE1:
+		handle->state = QCAFRM_WAIT_RSVD_BYTE2;
+		break;
+	case QCAFRM_WAIT_RSVD_BYTE2:
+		len = handle->offset;
+		if (len > buf_len || len < QCAFRM_ETHMINLEN) {
+			ret = QCAFRM_INVLEN;
+			handle->state = QCAFRM_HW_LEN0;
+		} else {
+			handle->state = (enum qcafrm_state)(len + 1);
+			/* Remaining number of bytes. */
+			handle->offset = 0;
+		}
+		break;
+	default:
+		/* Receiving Ethernet frame itself. */
+		buf[handle->offset] = recv_byte;
+		handle->offset++;
+		handle->state--;
+		break;
+	case QCAFRM_WAIT_551:
+		if (recv_byte != 0x55) {
+			ret = QCAFRM_NOTAIL;
+			handle->state = QCAFRM_HW_LEN0;
+		} else {
+			handle->state = QCAFRM_WAIT_552;
+		}
+		break;
+	case QCAFRM_WAIT_552:
+		if (recv_byte != 0x55) {
+			ret = QCAFRM_NOTAIL;
+			handle->state = QCAFRM_HW_LEN0;
+		} else {
+			ret = handle->offset;
+			/* Frame is fully received. */
+			handle->state = QCAFRM_HW_LEN0;
+		}
+		break;
+	}
+
+	return ret;
+}
diff --git a/drivers/net/ethernet/qualcomm/qca_common.h b/drivers/net/ethernet/qualcomm/qca_common.h
new file mode 100644
index 0000000..8c9b713
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/qca_common.h
@@ -0,0 +1,134 @@
+/*
+ *   Copyright (c) 2011, 2012, Atheros Communications Inc.
+ *   Copyright (c) 2014, I2SE GmbH
+ *
+ *   Permission to use, copy, modify, and/or distribute this software
+ *   for any purpose with or without fee is hereby granted, provided
+ *   that the above copyright notice and this permission notice appear
+ *   in all copies.
+ *
+ *   THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
+ *   WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
+ *   WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL
+ *   THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
+ *   CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
+ *   LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
+ *   NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
+ *   CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+/*   Atheros Ethernet framing. Every Ethernet frame is surrounded by an atheros
+ *   frame while transmitted over a serial channel.
+ */
+
+#ifndef _QCA_COMMON_H
+#define _QCA_COMMON_H
+
+#include <linux/if_ether.h>
+#include <linux/if_vlan.h>
+#include <linux/types.h>
+
+/* Frame is currently being received */
+#define QCAFRM_GATHER 0
+
+/*  No header byte while expecting it */
+#define QCAFRM_NOHEAD (QCAFRM_ERR_BASE - 1)
+
+/* No tailer byte while expecting it */
+#define QCAFRM_NOTAIL (QCAFRM_ERR_BASE - 2)
+
+/* Frame length is invalid */
+#define QCAFRM_INVLEN (QCAFRM_ERR_BASE - 3)
+
+/* Frame length is invalid */
+#define QCAFRM_INVFRAME (QCAFRM_ERR_BASE - 4)
+
+/* Min/Max Ethernet MTU */
+#define QCAFRM_ETHMINMTU 46
+#define QCAFRM_ETHMAXMTU 1500
+
+/* Min/Max frame lengths */
+#define QCAFRM_ETHMINLEN (QCAFRM_ETHMINMTU + ETH_HLEN)
+#define QCAFRM_ETHMAXLEN (QCAFRM_ETHMAXMTU + VLAN_ETH_HLEN)
+
+/* QCA7K header len */
+#define QCAFRM_HEADER_LEN 8
+
+/* QCA7K footer len */
+#define QCAFRM_FOOTER_LEN 2
+
+/* QCA7K Framing. */
+#define QCAFRM_ERR_BASE -1000
+
+enum qcafrm_state {
+	QCAFRM_HW_LEN0 = 0x8000,
+	QCAFRM_HW_LEN1 = QCAFRM_HW_LEN0 - 1,
+	QCAFRM_HW_LEN2 = QCAFRM_HW_LEN1 - 1,
+	QCAFRM_HW_LEN3 = QCAFRM_HW_LEN2 - 1,
+
+	/*  Waiting first 0xAA of header */
+	QCAFRM_WAIT_AA1 = QCAFRM_HW_LEN3 - 1,
+
+	/*  Waiting second 0xAA of header */
+	QCAFRM_WAIT_AA2 = QCAFRM_WAIT_AA1 - 1,
+
+	/*  Waiting third 0xAA of header */
+	QCAFRM_WAIT_AA3 = QCAFRM_WAIT_AA2 - 1,
+
+	/*  Waiting fourth 0xAA of header */
+	QCAFRM_WAIT_AA4 = QCAFRM_WAIT_AA3 - 1,
+
+	/*  Waiting Byte 0-1 of length (litte endian) */
+	QCAFRM_WAIT_LEN_BYTE0 = QCAFRM_WAIT_AA4 - 1,
+	QCAFRM_WAIT_LEN_BYTE1 = QCAFRM_WAIT_AA4 - 2,
+
+	/* Reserved bytes */
+	QCAFRM_WAIT_RSVD_BYTE1 = QCAFRM_WAIT_AA4 - 3,
+	QCAFRM_WAIT_RSVD_BYTE2 = QCAFRM_WAIT_AA4 - 4,
+
+	/*  The frame length is used as the state until
+	 *  the end of the Ethernet frame
+	 *  Waiting for first 0x55 of footer
+	 */
+	QCAFRM_WAIT_551 = 1,
+
+	/*  Waiting for second 0x55 of footer */
+	QCAFRM_WAIT_552 = QCAFRM_WAIT_551 - 1
+};
+
+/*   Structure to maintain the frame decoding during reception. */
+
+struct qcafrm_handle {
+	/*  Current decoding state */
+	enum qcafrm_state state;
+
+	/* Offset in buffer (borrowed for length too) */
+	s16 offset;
+
+	/* Frame length as kept by this module */
+	u16 len;
+};
+
+u16 qcafrm_create_header(u8 *buf, u16 len);
+
+u16 qcafrm_create_footer(u8 *buf);
+
+static inline void qcafrm_fsm_init(struct qcafrm_handle *handle)
+{
+	handle->state = QCAFRM_HW_LEN0;
+}
+
+/*   Gather received bytes and try to extract a full Ethernet frame
+ *   by following a simple state machine.
+ *
+ * Return:   QCAFRM_GATHER       No Ethernet frame fully received yet.
+ *           QCAFRM_NOHEAD       Header expected but not found.
+ *           QCAFRM_INVLEN       QCA7K frame length is invalid
+ *           QCAFRM_NOTAIL       Footer expected but not found.
+ *           > 0                 Number of byte in the fully received
+ *                               Ethernet frame
+ */
+
+s32 qcafrm_fsm_decode(struct qcafrm_handle *handle, u8 *buf, u16 buf_len, u8 recv_byte);
+
+#endif /* _QCA_COMMON_H */
diff --git a/drivers/net/ethernet/qualcomm/qca_framing.c b/drivers/net/ethernet/qualcomm/qca_framing.c
deleted file mode 100644
index faa924c..0000000
--- a/drivers/net/ethernet/qualcomm/qca_framing.c
+++ /dev/null
@@ -1,156 +0,0 @@
-/*
- *   Copyright (c) 2011, 2012, Atheros Communications Inc.
- *   Copyright (c) 2014, I2SE GmbH
- *
- *   Permission to use, copy, modify, and/or distribute this software
- *   for any purpose with or without fee is hereby granted, provided
- *   that the above copyright notice and this permission notice appear
- *   in all copies.
- *
- *   THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
- *   WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
- *   WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL
- *   THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
- *   CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
- *   LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
- *   NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
- *   CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
- */
-
-/*   Atheros ethernet framing. Every Ethernet frame is surrounded
- *   by an atheros frame while transmitted over a serial channel;
- */
-
-#include <linux/kernel.h>
-
-#include "qca_framing.h"
-
-u16
-qcafrm_create_header(u8 *buf, u16 length)
-{
-	__le16 len;
-
-	if (!buf)
-		return 0;
-
-	len = cpu_to_le16(length);
-
-	buf[0] = 0xAA;
-	buf[1] = 0xAA;
-	buf[2] = 0xAA;
-	buf[3] = 0xAA;
-	buf[4] = len & 0xff;
-	buf[5] = (len >> 8) & 0xff;
-	buf[6] = 0;
-	buf[7] = 0;
-
-	return QCAFRM_HEADER_LEN;
-}
-
-u16
-qcafrm_create_footer(u8 *buf)
-{
-	if (!buf)
-		return 0;
-
-	buf[0] = 0x55;
-	buf[1] = 0x55;
-	return QCAFRM_FOOTER_LEN;
-}
-
-/*   Gather received bytes and try to extract a full ethernet frame by
- *   following a simple state machine.
- *
- * Return:   QCAFRM_GATHER       No ethernet frame fully received yet.
- *           QCAFRM_NOHEAD       Header expected but not found.
- *           QCAFRM_INVLEN       Atheros frame length is invalid
- *           QCAFRM_NOTAIL       Footer expected but not found.
- *           > 0                 Number of byte in the fully received
- *                               Ethernet frame
- */
-
-s32
-qcafrm_fsm_decode(struct qcafrm_handle *handle, u8 *buf, u16 buf_len, u8 recv_byte)
-{
-	s32 ret = QCAFRM_GATHER;
-	u16 len;
-
-	switch (handle->state) {
-	case QCAFRM_HW_LEN0:
-	case QCAFRM_HW_LEN1:
-		/* by default, just go to next state */
-		handle->state--;
-
-		if (recv_byte != 0x00) {
-			/* first two bytes of length must be 0 */
-			handle->state = QCAFRM_HW_LEN0;
-		}
-		break;
-	case QCAFRM_HW_LEN2:
-	case QCAFRM_HW_LEN3:
-		handle->state--;
-		break;
-	/* 4 bytes header pattern */
-	case QCAFRM_WAIT_AA1:
-	case QCAFRM_WAIT_AA2:
-	case QCAFRM_WAIT_AA3:
-	case QCAFRM_WAIT_AA4:
-		if (recv_byte != 0xAA) {
-			ret = QCAFRM_NOHEAD;
-			handle->state = QCAFRM_HW_LEN0;
-		} else {
-			handle->state--;
-		}
-		break;
-		/* 2 bytes length. */
-		/* Borrow offset field to hold length for now. */
-	case QCAFRM_WAIT_LEN_BYTE0:
-		handle->offset = recv_byte;
-		handle->state = QCAFRM_WAIT_LEN_BYTE1;
-		break;
-	case QCAFRM_WAIT_LEN_BYTE1:
-		handle->offset = handle->offset | (recv_byte << 8);
-		handle->state = QCAFRM_WAIT_RSVD_BYTE1;
-		break;
-	case QCAFRM_WAIT_RSVD_BYTE1:
-		handle->state = QCAFRM_WAIT_RSVD_BYTE2;
-		break;
-	case QCAFRM_WAIT_RSVD_BYTE2:
-		len = handle->offset;
-		if (len > buf_len || len < QCAFRM_ETHMINLEN) {
-			ret = QCAFRM_INVLEN;
-			handle->state = QCAFRM_HW_LEN0;
-		} else {
-			handle->state = (enum qcafrm_state)(len + 1);
-			/* Remaining number of bytes. */
-			handle->offset = 0;
-		}
-		break;
-	default:
-		/* Receiving Ethernet frame itself. */
-		buf[handle->offset] = recv_byte;
-		handle->offset++;
-		handle->state--;
-		break;
-	case QCAFRM_WAIT_551:
-		if (recv_byte != 0x55) {
-			ret = QCAFRM_NOTAIL;
-			handle->state = QCAFRM_HW_LEN0;
-		} else {
-			handle->state = QCAFRM_WAIT_552;
-		}
-		break;
-	case QCAFRM_WAIT_552:
-		if (recv_byte != 0x55) {
-			ret = QCAFRM_NOTAIL;
-			handle->state = QCAFRM_HW_LEN0;
-		} else {
-			ret = handle->offset;
-			/* Frame is fully received. */
-			handle->state = QCAFRM_HW_LEN0;
-		}
-		break;
-	}
-
-	return ret;
-}
diff --git a/drivers/net/ethernet/qualcomm/qca_framing.h b/drivers/net/ethernet/qualcomm/qca_framing.h
deleted file mode 100644
index 5d96595..0000000
--- a/drivers/net/ethernet/qualcomm/qca_framing.h
+++ /dev/null
@@ -1,134 +0,0 @@
-/*
- *   Copyright (c) 2011, 2012, Atheros Communications Inc.
- *   Copyright (c) 2014, I2SE GmbH
- *
- *   Permission to use, copy, modify, and/or distribute this software
- *   for any purpose with or without fee is hereby granted, provided
- *   that the above copyright notice and this permission notice appear
- *   in all copies.
- *
- *   THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
- *   WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
- *   WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL
- *   THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
- *   CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
- *   LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
- *   NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
- *   CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
- */
-
-/*   Atheros Ethernet framing. Every Ethernet frame is surrounded by an atheros
- *   frame while transmitted over a serial channel.
- */
-
-#ifndef _QCA_FRAMING_H
-#define _QCA_FRAMING_H
-
-#include <linux/if_ether.h>
-#include <linux/if_vlan.h>
-#include <linux/types.h>
-
-/* Frame is currently being received */
-#define QCAFRM_GATHER 0
-
-/*  No header byte while expecting it */
-#define QCAFRM_NOHEAD (QCAFRM_ERR_BASE - 1)
-
-/* No tailer byte while expecting it */
-#define QCAFRM_NOTAIL (QCAFRM_ERR_BASE - 2)
-
-/* Frame length is invalid */
-#define QCAFRM_INVLEN (QCAFRM_ERR_BASE - 3)
-
-/* Frame length is invalid */
-#define QCAFRM_INVFRAME (QCAFRM_ERR_BASE - 4)
-
-/* Min/Max Ethernet MTU */
-#define QCAFRM_ETHMINMTU 46
-#define QCAFRM_ETHMAXMTU 1500
-
-/* Min/Max frame lengths */
-#define QCAFRM_ETHMINLEN (QCAFRM_ETHMINMTU + ETH_HLEN)
-#define QCAFRM_ETHMAXLEN (QCAFRM_ETHMAXMTU + VLAN_ETH_HLEN)
-
-/* QCA7K header len */
-#define QCAFRM_HEADER_LEN 8
-
-/* QCA7K footer len */
-#define QCAFRM_FOOTER_LEN 2
-
-/* QCA7K Framing. */
-#define QCAFRM_ERR_BASE -1000
-
-enum qcafrm_state {
-	QCAFRM_HW_LEN0 = 0x8000,
-	QCAFRM_HW_LEN1 = QCAFRM_HW_LEN0 - 1,
-	QCAFRM_HW_LEN2 = QCAFRM_HW_LEN1 - 1,
-	QCAFRM_HW_LEN3 = QCAFRM_HW_LEN2 - 1,
-
-	/*  Waiting first 0xAA of header */
-	QCAFRM_WAIT_AA1 = QCAFRM_HW_LEN3 - 1,
-
-	/*  Waiting second 0xAA of header */
-	QCAFRM_WAIT_AA2 = QCAFRM_WAIT_AA1 - 1,
-
-	/*  Waiting third 0xAA of header */
-	QCAFRM_WAIT_AA3 = QCAFRM_WAIT_AA2 - 1,
-
-	/*  Waiting fourth 0xAA of header */
-	QCAFRM_WAIT_AA4 = QCAFRM_WAIT_AA3 - 1,
-
-	/*  Waiting Byte 0-1 of length (litte endian) */
-	QCAFRM_WAIT_LEN_BYTE0 = QCAFRM_WAIT_AA4 - 1,
-	QCAFRM_WAIT_LEN_BYTE1 = QCAFRM_WAIT_AA4 - 2,
-
-	/* Reserved bytes */
-	QCAFRM_WAIT_RSVD_BYTE1 = QCAFRM_WAIT_AA4 - 3,
-	QCAFRM_WAIT_RSVD_BYTE2 = QCAFRM_WAIT_AA4 - 4,
-
-	/*  The frame length is used as the state until
-	 *  the end of the Ethernet frame
-	 *  Waiting for first 0x55 of footer
-	 */
-	QCAFRM_WAIT_551 = 1,
-
-	/*  Waiting for second 0x55 of footer */
-	QCAFRM_WAIT_552 = QCAFRM_WAIT_551 - 1
-};
-
-/*   Structure to maintain the frame decoding during reception. */
-
-struct qcafrm_handle {
-	/*  Current decoding state */
-	enum qcafrm_state state;
-
-	/* Offset in buffer (borrowed for length too) */
-	s16 offset;
-
-	/* Frame length as kept by this module */
-	u16 len;
-};
-
-u16 qcafrm_create_header(u8 *buf, u16 len);
-
-u16 qcafrm_create_footer(u8 *buf);
-
-static inline void qcafrm_fsm_init(struct qcafrm_handle *handle)
-{
-	handle->state = QCAFRM_HW_LEN0;
-}
-
-/*   Gather received bytes and try to extract a full Ethernet frame
- *   by following a simple state machine.
- *
- * Return:   QCAFRM_GATHER       No Ethernet frame fully received yet.
- *           QCAFRM_NOHEAD       Header expected but not found.
- *           QCAFRM_INVLEN       QCA7K frame length is invalid
- *           QCAFRM_NOTAIL       Footer expected but not found.
- *           > 0                 Number of byte in the fully received
- *                               Ethernet frame
- */
-
-s32 qcafrm_fsm_decode(struct qcafrm_handle *handle, u8 *buf, u16 buf_len, u8 recv_byte);
-
-#endif /* _QCA_FRAMING_H */
diff --git a/drivers/net/ethernet/qualcomm/qca_spi.c b/drivers/net/ethernet/qualcomm/qca_spi.c
index 5bcac62..551591d 100644
--- a/drivers/net/ethernet/qualcomm/qca_spi.c
+++ b/drivers/net/ethernet/qualcomm/qca_spi.c
@@ -43,8 +43,8 @@
 #include <linux/types.h>
 
 #include "qca_7k.h"
+#include "qca_common.h"
 #include "qca_debug.h"
-#include "qca_framing.h"
 #include "qca_spi.h"
 
 #define MAX_DMA_BURST_LEN 5000
diff --git a/drivers/net/ethernet/qualcomm/qca_spi.h b/drivers/net/ethernet/qualcomm/qca_spi.h
index 064853d..cce4802 100644
--- a/drivers/net/ethernet/qualcomm/qca_spi.h
+++ b/drivers/net/ethernet/qualcomm/qca_spi.h
@@ -32,7 +32,7 @@
 #include <linux/spi/spi.h>
 #include <linux/types.h>
 
-#include "qca_framing.h"
+#include "qca_common.h"
 
 #define QCASPI_DRV_VERSION "0.2.7-i"
 #define QCASPI_DRV_NAME    "qcaspi"
-- 
2.1.4
