From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 1/2] sh_eth: fix bitbang memory leak
Date: Wed, 20 Mar 2013 02:40:23 +0300
Message-ID: <201303200240.23975.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:63567 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933625Ab3CSWjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 18:39:11 -0400
Received: by mail-la0-f43.google.com with SMTP id ek20so1986327lab.30
        for <netdev@vger.kernel.org>; Tue, 19 Mar 2013 15:39:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sh_mdio_init() allocates pointer to 'struct bb_info' but only stores it locally,
so that sh_mdio_release() can't free it on driver unload.  Add the pointer to
'struct bb_info' to 'struct sh_eth_private', so that sh_mdio_init() can save
'bitbang' variable for sh_mdio_release() to be able to free it later...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |    5 +++++
 drivers/net/ethernet/renesas/sh_eth.h |    1 +
 2 files changed, 6 insertions(+)

Index: renesas/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- renesas.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ renesas/drivers/net/ethernet/renesas/sh_eth.c
@@ -2220,6 +2220,7 @@ static void sh_eth_tsu_init(struct sh_et
 /* MDIO bus release function */
 static int sh_mdio_release(struct net_device *ndev)
 {
+	struct sh_eth_private *mdp = netdev_priv(ndev);
 	struct mii_bus *bus = dev_get_drvdata(&ndev->dev);
 
 	/* unregister mdio bus */
@@ -2234,6 +2235,9 @@ static int sh_mdio_release(struct net_de
 	/* free bitbang info */
 	free_mdio_bitbang(bus);
 
+	/* free bitbang memory */
+	kfree(mdp->bitbang);
+
 	return 0;
 }
 
@@ -2262,6 +2266,7 @@ static int sh_mdio_init(struct net_devic
 	bitbang->ctrl.ops = &bb_ops;
 
 	/* MII controller setting */
+	mdp->bitbang = bitbang;
 	mdp->mii_bus = alloc_mdio_bitbang(&bitbang->ctrl);
 	if (!mdp->mii_bus) {
 		ret = -ENOMEM;
Index: renesas/drivers/net/ethernet/renesas/sh_eth.h
===================================================================
--- renesas.orig/drivers/net/ethernet/renesas/sh_eth.h
+++ renesas/drivers/net/ethernet/renesas/sh_eth.h
@@ -705,6 +705,7 @@ struct sh_eth_private {
 	const u16 *reg_offset;
 	void __iomem *addr;
 	void __iomem *tsu_addr;
+	struct bb_info *bitbang;
 	u32 num_rx_ring;
 	u32 num_tx_ring;
 	dma_addr_t rx_desc_dma;
