From: Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 1/2] can: bfin_can: simplify xmit id1 setup
Date: Fri, 24 Jun 2011 10:33:01 -0400
Message-ID: <1308925982-14645-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
To: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

If we look closely, the 4 writes to TRANSMIT_CHL.id1 can be collapsed
down into much simpler code.  So do just that.

This also fixes a build failure due to the I/O macros no longer
getting pulled in.  Their minor (and accidental) usage here gets
dropped as part of the unification.

Signed-off-by: Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
---
 drivers/net/can/bfin_can.c |   21 ++++++---------------
 1 files changed, 6 insertions(+), 15 deletions(-)

diff --git a/drivers/net/can/bfin_can.c b/drivers/net/can/bfin_can.c
index b6e890d..dc6ef4a 100644
--- a/drivers/net/can/bfin_can.c
+++ b/drivers/net/can/bfin_can.c
@@ -243,21 +243,12 @@ static int bfin_can_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* fill id */
 	if (id & CAN_EFF_FLAG) {
 		bfin_write16(&reg->chl[TRANSMIT_CHL].id0, id);
-		if (id & CAN_RTR_FLAG)
-			writew(((id & 0x1FFF0000) >> 16) | IDE | AME | RTR,
-					&reg->chl[TRANSMIT_CHL].id1);
-		else
-			writew(((id & 0x1FFF0000) >> 16) | IDE | AME,
-					&reg->chl[TRANSMIT_CHL].id1);
-
-	} else {
-		if (id & CAN_RTR_FLAG)
-			writew((id << 2) | AME | RTR,
-				&reg->chl[TRANSMIT_CHL].id1);
-		else
-			bfin_write16(&reg->chl[TRANSMIT_CHL].id1,
-					(id << 2) | AME);
-	}
+		val = ((id & 0x1FFF0000) >> 16) | IDE;
+	} else
+		val = (id << 2);
+	if (id & CAN_RTR_FLAG)
+		val |= RTR;
+	bfin_write16(&reg->chl[TRANSMIT_CHL].id1, val | AME);
 
 	/* fill payload */
 	for (i = 0; i < 8; i += 2) {
-- 
1.7.5.3
