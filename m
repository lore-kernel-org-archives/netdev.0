From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] sh_eth: uninline sh_eth_{write|read}()
Date: Sun, 13 Dec 2015 01:44:50 +0300
Message-ID: <4404920.p7TanuLbY1@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org, ben.hutchings@codethink.co.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f51.google.com ([209.85.215.51]:34471 "EHLO
	mail-lf0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183AbbLLWo6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Dec 2015 17:44:58 -0500
Received: by lfcy184 with SMTP id y184so26438250lfc.1
        for <netdev@vger.kernel.org>; Sat, 12 Dec 2015 14:44:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 3365711df024 ("sh_eth: WARN on access to a register not implemented in
in  a particular chip") added WARN_ON() to sh_eth_{read|write}(), thus making
it  unacceptable for these functions to be *inline* anymore. Remove *inline*
and move the functions from the header to the driver itself. Below   is our
code economy with ARM gcc 4.7.3:

$ size drivers/net/ethernet/renesas/sh_eth.o{~,}
   text	   data	    bss	    dec	    hex	filename
  32489	   1140	      0	  33629	   835d	drivers/net/ethernet/renesas/sh_eth.o~
  25413	   1140	      0	  26553	   67b9	drivers/net/ethernet/renesas/sh_eth.o

Suggested-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against DaveM's 'net-next.git' repo.

 drivers/net/ethernet/renesas/sh_eth.c |   24 ++++++++++++++++++++++++
 drivers/net/ethernet/renesas/sh_eth.h |   25 -------------------------
 2 files changed, 24 insertions(+), 25 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -52,6 +52,8 @@
 		NETIF_MSG_RX_ERR| \
 		NETIF_MSG_TX_ERR)
 
+#define SH_ETH_OFFSET_INVALID	((u16)~0)
+
 #define SH_ETH_OFFSET_DEFAULTS			\
 	[0 ... SH_ETH_MAX_REGISTER_OFFSET - 1] = SH_ETH_OFFSET_INVALID
 
@@ -404,6 +406,28 @@ static const u16 sh_eth_offset_fast_sh3_
 static void sh_eth_rcv_snd_disable(struct net_device *ndev);
 static struct net_device_stats *sh_eth_get_stats(struct net_device *ndev);
 
+static void sh_eth_write(struct net_device *ndev, u32 data, int enum_index)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	u16 offset = mdp->reg_offset[enum_index];
+
+	if (WARN_ON(offset == SH_ETH_OFFSET_INVALID))
+		return;
+
+	iowrite32(data, mdp->addr + offset);
+}
+
+static u32 sh_eth_read(struct net_device *ndev, int enum_index)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	u16 offset = mdp->reg_offset[enum_index];
+
+	if (WARN_ON(offset == SH_ETH_OFFSET_INVALID))
+		return ~0U;
+
+	return ioread32(mdp->addr + offset);
+}
+
 static bool sh_eth_is_gether(struct sh_eth_private *mdp)
 {
 	return mdp->reg_offset == sh_eth_offset_gigabit;
Index: net-next/drivers/net/ethernet/renesas/sh_eth.h
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.h
+++ net-next/drivers/net/ethernet/renesas/sh_eth.h
@@ -546,31 +546,6 @@ static inline void sh_eth_soft_swap(char
 #endif
 }
 
-#define SH_ETH_OFFSET_INVALID	((u16) ~0)
-
-static inline void sh_eth_write(struct net_device *ndev, u32 data,
-				int enum_index)
-{
-	struct sh_eth_private *mdp = netdev_priv(ndev);
-	u16 offset = mdp->reg_offset[enum_index];
-
-	if (WARN_ON(offset == SH_ETH_OFFSET_INVALID))
-		return;
-
-	iowrite32(data, mdp->addr + offset);
-}
-
-static inline u32 sh_eth_read(struct net_device *ndev, int enum_index)
-{
-	struct sh_eth_private *mdp = netdev_priv(ndev);
-	u16 offset = mdp->reg_offset[enum_index];
-
-	if (WARN_ON(offset == SH_ETH_OFFSET_INVALID))
-		return ~0U;
-
-	return ioread32(mdp->addr + offset);
-}
-
 static inline void *sh_eth_tsu_get_offset(struct sh_eth_private *mdp,
 					  int enum_index)
 {
