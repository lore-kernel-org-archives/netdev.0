From: Dong Aisheng <b29396@freescale.com>
Subject: [PATCH V1 4/4] can: m_can: allow to send std frame on CAN FD mode
Date: Wed, 5 Nov 2014 15:58:46 +0800
Message-ID: <1415174326-6623-4-git-send-email-b29396@freescale.com>
References: <1415174326-6623-1-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <mkl@pengutronix.de>, <wg@grandegger.com>,
	<varkabhadram@gmail.com>, <netdev@vger.kernel.org>,
	<socketcan@hartkopp.net>, <b29396@freescale.com>,
	<linux-arm-kernel@lists.infradead.org>
To: <linux-can@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0143.outbound.protection.outlook.com ([157.56.111.143]:61143
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751477AbaKEJF2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2014 04:05:28 -0500
In-Reply-To: <1415174326-6623-1-git-send-email-b29396@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code sends all CAN frames on CAN FD format(with BRS or not)
if CAN_CTRLMODE_FD is enabled.
However, even CAN_CTRLMODE_FD is enabled, the can tool may still
send normal frames.
e.g.
ip link set can0 up type can bitrate 1000000 dbitrate 1000000 fd on
cansend can0 123#112233

Therefore sending normal CAN frame on FD format seems not reasonable
and the CAN FD incapable device may not be able to receive it correctly.

The patch switches the M_CAN operation mode to ISO11898-1 instead of
staying on CAN FD operation mode by writing "11" to CMR bit if find
we're sending a normal can skb.

Signed-off-by: Dong Aisheng <b29396@freescale.com>
---
 drivers/net/can/m_can/m_can.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
index f47c200..219c4b7 100644
--- a/drivers/net/can/m_can/m_can.c
+++ b/drivers/net/can/m_can/m_can.c
@@ -1080,10 +1080,14 @@ static netdev_tx_t m_can_start_xmit(struct sk_buff *skb,
 	if (priv->can.ctrlmode & CAN_CTRLMODE_FD) {
 		cccr = m_can_read(priv, M_CAN_CCCR);
 		cccr &= ~(CCCR_CMR_MASK << CCCR_CMR_SHIFT);
-		if (cf->flags & CANFD_BRS)
-			cccr |= CCCR_CMR_CANFD_BRS << CCCR_CMR_SHIFT;
-		else
-			cccr |= CCCR_CMR_CANFD << CCCR_CMR_SHIFT;
+		if (can_is_canfd_skb(skb)) {
+			if (cf->flags & CANFD_BRS)
+				cccr |= CCCR_CMR_CANFD_BRS << CCCR_CMR_SHIFT;
+			else
+				cccr |= CCCR_CMR_CANFD << CCCR_CMR_SHIFT;
+		} else {
+			cccr |= CCCR_CMR_CAN << CCCR_CMR_SHIFT;
+		}
 		m_can_write(priv, M_CAN_CCCR, cccr);
 	}
 
-- 
1.9.1
