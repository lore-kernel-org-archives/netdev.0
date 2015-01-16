From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net-next] mii: Handle link state changes for forced modes in
 mii_check_media()
Date: Fri, 16 Jan 2015 17:55:35 +0000
Message-ID: <1421430935.1222.196.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@lists.codethink.co.uk
To: ct178-internal@lists.codethink.co.uk,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:47402 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752865AbbAPRzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 12:55:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mii_check_media() does not update the link (carrier) state or log link
changes when the link mode is forced.  Drivers using the mii library
must do this themselves, but most of them do not.

Instead of changing them all, provide a sensible default behaviour
similar to mii_check_link() when the mode is forced.

via-rhine depends on it being a no-op in this case, so make its call
to mii_check_media() conditional.

Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
I've only tested this with the asix driver, which is where I found the
bug.  I reviewed all the other drivers calling mii_check_media().

Ben.

 drivers/net/ethernet/amd/pcnet32.c   |    2 +-
 drivers/net/ethernet/via/via-rhine.c |    3 ++-
 drivers/net/mii.c                    |   12 +++++++-----
 3 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index e2e3aaf..11d6e65 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -2806,7 +2806,7 @@ static void pcnet32_check_media(struct net_device *dev, int verbose)
 
 /*
  * Check for loss of link and link establishment.
- * Can not use mii_check_media because it does nothing if mode is forced.
+ * Could possibly be changed to use mii_check_media instead.
  */
 
 static void pcnet32_watchdog(struct net_device *dev)
diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 0ac7610..b3b7f5a 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -1326,7 +1326,8 @@ static void rhine_check_media(struct net_device *dev, unsigned int init_media)
 	struct rhine_private *rp = netdev_priv(dev);
 	void __iomem *ioaddr = rp->base;
 
-	mii_check_media(&rp->mii_if, netif_msg_link(rp), init_media);
+	if (!mii->force_media)
+		mii_check_media(&rp->mii_if, netif_msg_link(rp), init_media);
 
 	if (rp->mii_if.full_duplex)
 	    iowrite8(ioread8(ioaddr + ChipCmd1) | Cmd1FDuplex,
diff --git a/drivers/net/mii.c b/drivers/net/mii.c
index 4a99c39..993570b 100644
--- a/drivers/net/mii.c
+++ b/drivers/net/mii.c
@@ -302,7 +302,7 @@ void mii_check_link (struct mii_if_info *mii)
 }
 
 /**
- * mii_check_media - check the MII interface for a duplex change
+ * mii_check_media - check the MII interface for a carrier/speed/duplex change
  * @mii: the MII interface
  * @ok_to_print: OK to print link up/down messages
  * @init_media: OK to save duplex mode in @mii
@@ -318,10 +318,6 @@ unsigned int mii_check_media (struct mii_if_info *mii,
 	int advertise, lpa, media, duplex;
 	int lpa2 = 0;
 
-	/* if forced media, go no further */
-	if (mii->force_media)
-		return 0; /* duplex did not change */
-
 	/* check current and old link status */
 	old_carrier = netif_carrier_ok(mii->dev) ? 1 : 0;
 	new_carrier = (unsigned int) mii_link_ok(mii);
@@ -345,6 +341,12 @@ unsigned int mii_check_media (struct mii_if_info *mii,
 	 */
 	netif_carrier_on(mii->dev);
 
+	if (mii->force_media) {
+		if (ok_to_print)
+			netdev_info(mii->dev, "link up\n");
+		return 0; /* duplex did not change */
+	}
+
 	/* get MII advertise and LPA values */
 	if ((!init_media) && (mii->advertising))
 		advertise = mii->advertising;
-- 
1.7.10.4
