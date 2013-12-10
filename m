From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: [PATCH v2] net: allwinner: emac: Add missing free_irq
Date: Tue, 10 Dec 2013 19:40:43 +0100
Message-ID: <1386700849-8496-1-git-send-email-maxime.ripard@free-electrons.com>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-sunxi+bncBD2ZNBF5VYJRBLWCTWKQKGQEFOVB4BA-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

The sun4i-emac driver uses devm_request_irq at .ndo_open time, but relies on
the managed device mechanism to actually free it. This causes an issue whenever
someone wants to restart the interface, the interrupt still being held, and not
yet released.

Fall back to using the regular request_irq at .ndo_open time, and introduce a
free_irq during .ndo_stop.

Signed-off-by: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org # 3.11+

---
Changes from v1:
  - Fixed the wrapping of request_irq

 drivers/net/ethernet/allwinner/sun4i-emac.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/allwinner/sun4i-emac.c b/drivers/net/ethernet/allwinner/sun4i-emac.c
index 50b853a..46dfb13 100644
--- a/drivers/net/ethernet/allwinner/sun4i-emac.c
+++ b/drivers/net/ethernet/allwinner/sun4i-emac.c
@@ -717,8 +717,7 @@ static int emac_open(struct net_device *dev)
 	if (netif_msg_ifup(db))
 		dev_dbg(db->dev, "enabling %s\n", dev->name);
 
-	if (devm_request_irq(db->dev, dev->irq, &emac_interrupt,
-			     0, dev->name, dev))
+	if (request_irq(dev->irq, &emac_interrupt, 0, dev->name, dev))
 		return -EAGAIN;
 
 	/* Initialize EMAC board */
@@ -774,6 +773,8 @@ static int emac_stop(struct net_device *ndev)
 
 	emac_shutdown(ndev);
 
+	free_irq(ndev->irq, ndev);
+
 	return 0;
 }
 
-- 
1.8.4.2
