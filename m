From: Marc Zyngier <marc.zyngier-5wv7dgnIgG8@public.gmane.org>
Subject: [PATCH] net: sun4i-emac: fix memory leak on bad packet
Date: Tue,  5 Aug 2014 16:44:39 +0100
Message-ID: <1407253479-30076-1-git-send-email-marc.zyngier@arm.com>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Stefan Roese <sr-ynQEQJNshbs@public.gmane.org>,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Return-path: <linux-sunxi+bncBCPZR5X4TYBBBA7YQOPQKGQEAALOK2I-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <http://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

Upon reception of a new frame, the emac driver checks for a number
of error conditions, and flag the packet as "bad" if any of these
are present. It then allocates a skb unconditionally, but only uses
it if the packet is "good". On the error path, the skb is just forgotten,
and the system leaks memory.

The piece of junk I have on my desk seems to encounter such error
frequently enough so that the box goes OOM after a couple of days,
which makes me grumpy.

Fix this by moving the allocation on the "good_packet" path (and
convert it to netdev_alloc_skb while we're at it).

Tested on a random Allwinner A20 board.

Cc: Stefan Roese <sr-ynQEQJNshbs@public.gmane.org>
Cc: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Cc: <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org> # 3.11+
Signed-off-by: Marc Zyngier <marc.zyngier-5wv7dgnIgG8@public.gmane.org>
---
 drivers/net/ethernet/allwinner/sun4i-emac.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/allwinner/sun4i-emac.c b/drivers/net/ethernet/allwinner/sun4i-emac.c
index d81e716..29b9f08 100644
--- a/drivers/net/ethernet/allwinner/sun4i-emac.c
+++ b/drivers/net/ethernet/allwinner/sun4i-emac.c
@@ -633,8 +633,10 @@ static void emac_rx(struct net_device *dev)
 		}
 
 		/* Move data from EMAC */
-		skb = dev_alloc_skb(rxlen + 4);
-		if (good_packet && skb) {
+		if (good_packet) {
+			skb = netdev_alloc_skb(dev, rxlen + 4);
+			if (!skb)
+				continue;
 			skb_reserve(skb, 2);
 			rdptr = (u8 *) skb_put(skb, rxlen - 4);
 
-- 
2.0.0
