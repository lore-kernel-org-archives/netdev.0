From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 5 Sep 2016 13:10:16 +1000
Message-ID: <20160905131016.12c38970@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Sean Wang <sean.wang@mediatek.com>,
        Nelson Chang <nelson.chang@mediatek.com>,
        Wei Yongjun <weiyj.lk@gmail.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:38474 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753369AbcIEDKp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 4 Sep 2016 23:10:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/ethernet/mediatek/mtk_eth_soc.c

between commits:

  d3bd1ce4db8e ("net: ethernet: mediatek: remove redundant free_irq for devm_request_irq allocated irq")
  7c6b0d76fa02 ("net: ethernet: mediatek: fix logic unbalance between probe and remove")

from the net tree and commits:

  45d339309f49 ("net: mediatek: remove unnecessary platform_set_drvdata()")
  bacfd110e059 ("net: ethernet: mediatek: modify to use the PDMA instead of the QDMA for Ethernet RX")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/ethernet/mediatek/mtk_eth_soc.c
index d9199151a83e,2dadfa961898..000000000000
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@@ -334,9 -338,12 +334,10 @@@ static void mtk_mdio_cleanup(struct mtk
  		return;
  
  	mdiobus_unregister(eth->mii_bus);
 -	of_node_put(eth->mii_bus->dev.of_node);
 -	mdiobus_free(eth->mii_bus);
  }
  
- static inline void mtk_irq_disable(struct mtk_eth *eth, u32 mask)
+ static inline void mtk_irq_disable(struct mtk_eth *eth,
+ 				   unsigned reg, u32 mask)
  {
  	unsigned long flags;
  	u32 val;
@@@ -1501,7 -1513,11 +1508,8 @@@ static void mtk_uninit(struct net_devic
  	struct mtk_eth *eth = mac->hw;
  
  	phy_disconnect(mac->phy_dev);
- 	mtk_irq_disable(eth, ~0);
 -	mtk_mdio_cleanup(eth);
+ 	mtk_irq_disable(eth, MTK_QDMA_INT_MASK, ~0);
+ 	mtk_irq_disable(eth, MTK_PDMA_INT_MASK, ~0);
 -	free_irq(eth->irq[1], dev);
 -	free_irq(eth->irq[2], dev);
  }
  
  static int mtk_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
@@@ -1913,8 -1920,6 +1921,7 @@@ static int mtk_remove(struct platform_d
  	netif_napi_del(&eth->tx_napi);
  	netif_napi_del(&eth->rx_napi);
  	mtk_cleanup(eth);
 +	mtk_mdio_cleanup(eth);
- 	platform_set_drvdata(pdev, NULL);
  
  	return 0;
  }
