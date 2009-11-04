From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 3/3] gianfar: Fix compiler and sparse warnings
Date: Thu, 5 Nov 2009 01:53:00 +0300
Message-ID: <20091104225300.GC29537@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Andy Fleming <afleming@freescale.com>,
	Sandeep Gopalpet <Sandeep.Kumar@freescale.com>,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.ru.mvista.com ([213.79.90.228]:11194 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S932940AbZKDWwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 17:52:55 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit fba4ed030cfae7efdb6b79a57b0c5a9d72c9de83 ("gianfar: Add Multiple
Queue Support") introduced the following warnings:

  CHECK   gianfar.c
gianfar.c:333:8: warning: incorrect type in assignment (different address spaces)
gianfar.c:333:8:    expected unsigned int [usertype] *baddr
gianfar.c:333:8:    got unsigned int [noderef] <asn:2>*<noident>
[... 67 lines skipped ...]
gianfar.c:2565:3: warning: incorrect type in argument 1 (different type sizes)
gianfar.c:2565:3:    expected unsigned long const *addr
gianfar.c:2565:3:    got unsigned int *<noident>
  CC      gianfar.o
gianfar.c: In function 'gfar_probe':
gianfar.c:985: warning: passing argument 1 of 'find_next_bit' from incompatible pointer type
gianfar.c:985: warning: passing argument 1 of 'find_next_bit' from incompatible pointer type
gianfar.c:993: warning: passing argument 1 of 'find_next_bit' from incompatible pointer type
gianfar.c:993: warning: passing argument 1 of 'find_next_bit' from incompatible pointer type
gianfar.c: In function 'gfar_configure_coalescing':
gianfar.c:1680: warning: passing argument 1 of 'find_next_bit' from incompatible pointer type
gianfar.c:1680: warning: passing argument 1 of 'find_next_bit' from incompatible pointer type
gianfar.c:1688: warning: passing argument 1 of 'find_next_bit' from incompatible pointer type
gianfar.c:1688: warning: passing argument 1 of 'find_next_bit' from incompatible pointer type
gianfar.c: In function 'gfar_poll':
gianfar.c:2565: warning: passing argument 1 of 'find_next_bit' from incompatible pointer type
gianfar.c:2565: warning: passing argument 1 of 'find_next_bit' from incompatible pointer type
gianfar.c:2566: warning: passing argument 2 of 'test_bit' from incompatible pointer type
gianfar.c:2585: warning: passing argument 2 of 'set_bit' from incompatible pointer type

Following warnings left unfixed (looks like sparse doesn't like
locks in loops, so __acquires/__releases() doesn't help):

gianfar.c:441:40: warning: context imbalance in 'lock_rx_qs': wrong count at exit
gianfar.c:441:40:    context '<noident>': wanted 0, got 1
gianfar.c:449:40: warning: context imbalance in 'lock_tx_qs': wrong count at exit
gianfar.c:449:40:    context '<noident>': wanted 0, got 1
gianfar.c:458:3: warning: context imbalance in 'unlock_rx_qs': __context__ statement expected different context
gianfar.c:458:3:    context '<noident>': wanted >= 0, got -1
gianfar.c:466:3: warning: context imbalance in 'unlock_tx_qs': __context__ statement expected different context
gianfar.c:466:3:    context '<noident>': wanted >= 0, got -1

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/gianfar.c |   14 ++++++++------
 drivers/net/gianfar.h |   10 +++++-----
 2 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 086d40d..197b358 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -327,7 +327,7 @@ cleanup:
 static void gfar_init_tx_rx_base(struct gfar_private *priv)
 {
 	struct gfar __iomem *regs = priv->gfargrp[0].regs;
-	u32 *baddr;
+	u32 __iomem *baddr;
 	int i;
 
 	baddr = &regs->tbase0;
@@ -770,7 +770,8 @@ static unsigned int reverse_bitmap(unsigned int bit_map, unsigned int max_qs)
 	return new_bit_map;
 }
 
-u32 cluster_entry_per_class(struct gfar_private *priv, u32 rqfar, u32 class)
+static u32 cluster_entry_per_class(struct gfar_private *priv, u32 rqfar,
+				   u32 class)
 {
 	u32 rqfpr = FPR_FILER_MASK;
 	u32 rqfcr = 0x0;
@@ -849,7 +850,7 @@ static int gfar_probe(struct of_device *ofdev,
 	int len_devname;
 	u32 rstat = 0, tstat = 0, rqueue = 0, tqueue = 0;
 	u32 isrg = 0;
-	u32 *baddr;
+	u32 __iomem *baddr;
 
 	err = gfar_of_init(ofdev, &dev);
 
@@ -1658,10 +1659,10 @@ void gfar_start(struct net_device *dev)
 }
 
 void gfar_configure_coalescing(struct gfar_private *priv,
-	unsigned int tx_mask, unsigned int rx_mask)
+	unsigned long tx_mask, unsigned long rx_mask)
 {
 	struct gfar __iomem *regs = priv->gfargrp[0].regs;
-	u32 *baddr;
+	u32 __iomem *baddr;
 	int i = 0;
 
 	/* Backward compatible case ---- even if we enable
@@ -2546,7 +2547,8 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 	struct gfar_priv_tx_q *tx_queue = NULL;
 	struct gfar_priv_rx_q *rx_queue = NULL;
 	int rx_cleaned = 0, budget_per_queue = 0, rx_cleaned_per_queue = 0;
-	int tx_cleaned = 0, i, left_over_budget = budget, serviced_queues = 0;
+	int tx_cleaned = 0, i, left_over_budget = budget;
+	unsigned long serviced_queues = 0;
 	int num_queues = 0;
 	unsigned long flags;
 
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 44b63da..cbb4510 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -986,10 +986,10 @@ struct gfar_priv_grp {
 	struct gfar_private *priv;
 	struct gfar __iomem *regs;
 	unsigned int grp_id;
-	unsigned int rx_bit_map;
-	unsigned int tx_bit_map;
-	unsigned int num_tx_queues;
-	unsigned int num_rx_queues;
+	unsigned long rx_bit_map;
+	unsigned long tx_bit_map;
+	unsigned long num_tx_queues;
+	unsigned long num_rx_queues;
 	unsigned int rstat;
 	unsigned int tstat;
 	unsigned int imask;
@@ -1118,7 +1118,7 @@ extern void gfar_halt(struct net_device *dev);
 extern void gfar_phy_test(struct mii_bus *bus, struct phy_device *phydev,
 		int enable, u32 regnum, u32 read);
 extern void gfar_configure_coalescing(struct gfar_private *priv,
-		unsigned int tx_mask, unsigned int rx_mask);
+		unsigned long tx_mask, unsigned long rx_mask);
 void gfar_init_sysfs(struct net_device *dev);
 
 extern const struct ethtool_ops gfar_ethtool_ops;
-- 
1.6.3.3
