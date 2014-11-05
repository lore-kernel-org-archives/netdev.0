From: Dong Aisheng <b29396@freescale.com>
Subject: [PATCH V2 2/4] can: m_can: workaround for transmit data less than 4 bytes
Date: Wed, 5 Nov 2014 15:58:44 +0800
Message-ID: <1415174326-6623-2-git-send-email-b29396@freescale.com>
References: <1415174326-6623-1-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <mkl@pengutronix.de>, <wg@grandegger.com>,
	<varkabhadram@gmail.com>, <netdev@vger.kernel.org>,
	<socketcan@hartkopp.net>, <b29396@freescale.com>,
	<linux-arm-kernel@lists.infradead.org>
To: <linux-can@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1415174326-6623-1-git-send-email-b29396@freescale.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At least on the i.MX6SX with M_CAN IP version 3.0.x, an issue with
the Message RAM was discovered. Sending CAN frames with dlc less
than 4 bytes will lead to bit errors, when the first 8 bytes of
the Message RAM have not been initialized (i.e. written to).
To work around this issue, the first 8 bytes are initialized in open()
function.

Without the workaround, we can easily see the following errors:
root@imx6qdlsolo:~# ip link set can0 up type can bitrate 1000000
[   66.882520] IPv6: ADDRCONF(NETDEV_CHANGE): can0: link becomes ready
root@imx6qdlsolo:~# cansend can0 123#112233
[   66.935640] m_can 20e8000.can can0: Bit Error Uncorrected

Signed-off-by: Dong Aisheng <b29396@freescale.com>
---
ChangeLog since v1:
 * initialize the first 8 bytes of Tx Buffer of Message RAM in open()
   to workaround the issue
---
 drivers/net/can/m_can/m_can.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
index 664fe30..f47c200 100644
--- a/drivers/net/can/m_can/m_can.c
+++ b/drivers/net/can/m_can/m_can.c
@@ -902,6 +902,15 @@ static void m_can_chip_config(struct net_device *dev)
 	/* set bittiming params */
 	m_can_set_bittiming(dev);
 
+	/* At least on the i.MX6SX with M_CAN IP version 3.0.x, an issue with
+	 * the Message RAM was discovered. Sending CAN frames with dlc less
+	 * than 4 bytes will lead to bit errors, when the first 8 bytes of
+	 * the Message RAM have not been initialized (i.e. written to).
+	 * To work around this issue, the first 8 bytes are initialized here.
+	 */
+	m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(0), 0x0);
+	m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(1), 0x0);
+
 	m_can_config_endisable(priv, false);
 }
 
-- 
1.9.1

