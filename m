From: Ivan Mikhaylov <ivan@ru.ibm.com>
Subject: [PATCH] net/ibm/emac: fix size of emac dump memory areas
Date: Thu, 21 May 2015 19:11:02 +0400
Message-ID: <20150521191102.45bd4a18@fr-ThinkPad-W520>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix in send of emac regs dump to ethtool which
causing in wrong data interpretation on ethtool
layer for MII and EMAC.

Signed-off-by: Ivan Mikhaylov <ivan@ru.ibm.com>
---
 drivers/net/ethernet/ibm/emac/core.c |   16 ++++++----------
 drivers/net/ethernet/ibm/emac/core.h |    7 ++-----
 2 files changed, 8 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index de79193..b9df0cb 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -2084,12 +2084,8 @@ static void emac_ethtool_get_pauseparam(struct net_device *ndev,
 
 static int emac_get_regs_len(struct emac_instance *dev)
 {
-	if (emac_has_feature(dev, EMAC_FTR_EMAC4))
-		return sizeof(struct emac_ethtool_regs_subhdr) +
-			EMAC4_ETHTOOL_REGS_SIZE(dev);
-	else
 		return sizeof(struct emac_ethtool_regs_subhdr) +
-			EMAC_ETHTOOL_REGS_SIZE(dev);
+			sizeof(struct emac_regs);
 }
 
 static int emac_ethtool_get_regs_len(struct net_device *ndev)
@@ -2114,15 +2110,15 @@ static void *emac_dump_regs(struct emac_instance *dev, void *buf)
 	struct emac_ethtool_regs_subhdr *hdr = buf;
 
 	hdr->index = dev->cell_index;
-	if (emac_has_feature(dev, EMAC_FTR_EMAC4)) {
+	if (emac_has_feature(dev, EMAC_FTR_EMAC4SYNC)) {
+		hdr->version = EMAC4SYNC_ETHTOOL_REGS_VER;
+	} else if (emac_has_feature(dev, EMAC_FTR_EMAC4)) {
 		hdr->version = EMAC4_ETHTOOL_REGS_VER;
-		memcpy_fromio(hdr + 1, dev->emacp, EMAC4_ETHTOOL_REGS_SIZE(dev));
-		return (void *)(hdr + 1) + EMAC4_ETHTOOL_REGS_SIZE(dev);
 	} else {
 		hdr->version = EMAC_ETHTOOL_REGS_VER;
-		memcpy_fromio(hdr + 1, dev->emacp, EMAC_ETHTOOL_REGS_SIZE(dev));
-		return (void *)(hdr + 1) + EMAC_ETHTOOL_REGS_SIZE(dev);
 	}
+	memcpy_fromio(hdr + 1, dev->emacp, sizeof(struct emac_regs));
+	return (void *)(hdr + 1) + sizeof(struct emac_regs);
 }
 
 static void emac_ethtool_get_regs(struct net_device *ndev,
diff --git a/drivers/net/ethernet/ibm/emac/core.h b/drivers/net/ethernet/ibm/emac/core.h
index 67f342a..28df374 100644
--- a/drivers/net/ethernet/ibm/emac/core.h
+++ b/drivers/net/ethernet/ibm/emac/core.h
@@ -461,10 +461,7 @@ struct emac_ethtool_regs_subhdr {
 };
 
 #define EMAC_ETHTOOL_REGS_VER		0
-#define EMAC_ETHTOOL_REGS_SIZE(dev) 	((dev)->rsrc_regs.end - \
-					 (dev)->rsrc_regs.start + 1)
-#define EMAC4_ETHTOOL_REGS_VER      	1
-#define EMAC4_ETHTOOL_REGS_SIZE(dev)	((dev)->rsrc_regs.end -	\
-					 (dev)->rsrc_regs.start + 1)
+#define EMAC4_ETHTOOL_REGS_VER		1
+#define EMAC4SYNC_ETHTOOL_REGS_VER	2
 
 #endif /* __IBM_NEWEMAC_CORE_H */
-- 
1.7.9.5
