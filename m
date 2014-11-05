From: Dong Aisheng <b29396@freescale.com>
Subject: [PATCH V3 3/3] can: m_can: workaround for transmit data less than 4 bytes
Date: Wed, 5 Nov 2014 21:16:33 +0800
Message-ID: <1415193393-30023-3-git-send-email-b29396@freescale.com>
References: <1415193393-30023-1-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <mkl@pengutronix.de>, <wg@grandegger.com>,
	<varkabhadram@gmail.com>, <netdev@vger.kernel.org>,
	<socketcan@hartkopp.net>, <b29396@freescale.com>,
	<linux-arm-kernel@lists.infradead.org>
To: <linux-can@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0104.outbound.protection.outlook.com ([157.56.111.104]:15168
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755141AbaKEOXN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2014 09:23:13 -0500
In-Reply-To: <1415193393-30023-1-git-send-email-b29396@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At least on the i.MX6SX TO1.2 with M_CAN IP version 3.0.1, an issue with
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
ChangeLog
v2->v3:
 * add i.MX chip version in issue in commit message
v1->v2:
 * initialize the first 8 bytes of Tx Buffer of Message RAM in open()
   to workaround the issue
---
 drivers/net/can/m_can/m_can.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
index eee1533..567cd27 100644
--- a/drivers/net/can/m_can/m_can.c
+++ b/drivers/net/can/m_can/m_can.c
@@ -905,6 +905,16 @@ static void m_can_chip_config(struct net_device *dev)
 	/* set bittiming params */
 	m_can_set_bittiming(dev);
 
+	/* At least on the i.MX6SX TO1.2 with M_CAN IP version 3.0.1,
+	 * (CREL = 30130506) an issue with the Message RAM was discovered.
+	 * Sending CAN frames with dlc less than 4 bytes will lead to bit
+	 * errors, when the first 8 bytes of the Message RAM have not been
+	 * initialized (i.e. written to). To work around this issue, the
+	 * first 8 bytes are initialized here.
+	 */
+	m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(0), 0x0);
+	m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(1), 0x0);
+
 	m_can_config_endisable(priv, false);
 }
 
-- 
1.9.1
