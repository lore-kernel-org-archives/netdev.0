From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH] chelsio: convert to use netdev_for_each_mc_addr
Date: Wed, 17 Feb 2010 22:56:45 +0100
Message-ID: <20100217215645.GD2635@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44687 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754575Ab0BQV4t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 16:56:49 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/chelsio/common.h |   16 ++--------------
 drivers/net/chelsio/cxgb2.c  |    2 --
 drivers/net/chelsio/pm3393.c |    6 +++---
 3 files changed, 5 insertions(+), 19 deletions(-)

diff --git a/drivers/net/chelsio/common.h b/drivers/net/chelsio/common.h
index bb159d9..9f89fd6 100644
--- a/drivers/net/chelsio/common.h
+++ b/drivers/net/chelsio/common.h
@@ -90,25 +90,13 @@
 typedef struct adapter adapter_t;
 
 struct t1_rx_mode {
-	struct net_device *dev;
-	u32 idx;
-	struct dev_mc_list *list;
+       struct net_device *dev;
 };
 
 #define t1_rx_mode_promisc(rm)	(rm->dev->flags & IFF_PROMISC)
 #define t1_rx_mode_allmulti(rm)	(rm->dev->flags & IFF_ALLMULTI)
 #define t1_rx_mode_mc_cnt(rm)	(netdev_mc_count(rm->dev))
-
-static inline u8 *t1_get_next_mcaddr(struct t1_rx_mode *rm)
-{
-	u8 *addr = NULL;
-
-	if (rm->idx++ < t1_rx_mode_mc_cnt(rm)) {
-		addr = rm->list->dmi_addr;
-		rm->list = rm->list->next;
-	}
-	return addr;
-}
+#define t1_get_netdev(rm)	(rm->dev)
 
 #define	MAX_NPORTS 4
 #define PORT_MASK ((1 << MAX_NPORTS) - 1)
diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index 082cdb2..a54a32b 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -125,8 +125,6 @@ static void t1_set_rxmode(struct net_device *dev)
 	struct t1_rx_mode rm;
 
 	rm.dev = dev;
-	rm.idx = 0;
-	rm.list = dev->mc_list;
 	mac->ops->set_rx_mode(mac, &rm);
 }
 
diff --git a/drivers/net/chelsio/pm3393.c b/drivers/net/chelsio/pm3393.c
index 2117c4f..33d674f 100644
--- a/drivers/net/chelsio/pm3393.c
+++ b/drivers/net/chelsio/pm3393.c
@@ -375,12 +375,12 @@ static int pm3393_set_rx_mode(struct cmac *cmac, struct t1_rx_mode *rm)
 		rx_mode |= SUNI1x10GEXP_BITMSK_RXXG_MHASH_EN;
 	} else if (t1_rx_mode_mc_cnt(rm)) {
 		/* Accept one or more multicast(s). */
-		u8 *addr;
+		struct dev_mc_list *dmi;
 		int bit;
 		u16 mc_filter[4] = { 0, };
 
-		while ((addr = t1_get_next_mcaddr(rm))) {
-			bit = (ether_crc(ETH_ALEN, addr) >> 23) & 0x3f;	/* bit[23:28] */
+		netdev_for_each_mc_addr(dmi, t1_get_netdev(rm)) {
+			bit = (ether_crc(ETH_ALEN, dmi->dmi_addr) >> 23) & 0x3f; /* bit[23:28] */
 			mc_filter[bit >> 4] |= 1 << (bit & 0xf);
 		}
 		pmwrite(cmac, SUNI1x10GEXP_REG_RXXG_MULTICAST_HASH_LOW, mc_filter[0]);
-- 
1.6.6

