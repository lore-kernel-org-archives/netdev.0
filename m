From: Sylvain 'ythier' Hitier <sylvain.hitier@gmail.com>
Subject: [PATCH RESEND v3] 3c59x: fix bad split of
 cpu_to_le32(pci_map_single())
Date: Tue, 7 Oct 2014 13:40:34 +0000
Message-ID: <20141007134034.GA8838@erable>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nhorman@tuxdriver.com, mroos@linux.ee,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sylvain "ythier" Hitier <sylvain.hitier@gmail.com>

In commit 6f2b6a3005b2c34c39f207a87667564f64f2f91a,
  # 3c59x: Add dma error checking and recovery
the intent is to split out the mapping from the byte-swapping in order to
insert a dma_mapping_error() check.

Kinda this semantic patch:

    // See http://coccinelle.lip6.fr/
    //
    // Beware, grouik-and-dirty!
    @@
    expression DEV, X, Y, Z;
    @@
    -   cpu_to_le32(pci_map_single(DEV, X, Y, Z))
    +   dma_addr_t addr = pci_map_single(DEV, X, Y, Z);
    +   if (dma_mapping_error(&DEV->dev, addr))
    +       /* snip */;
    +   cpu_to_le32(addr)

However, the #else part (of the #if DO_ZEROCOPY test) is changed this way:

    -   cpu_to_le32(pci_map_single(DEV, X, Y, Z))
    +   dma_addr_t addr = cpu_to_le32(pci_map_single(DEV, X, Y, Z));
    //                    ^^^^^^^^^^^
    //                    That mismatches the 3 other changes!
    +   if (dma_mapping_error(&DEV->dev, addr))
    +       /* snip */;
    +   cpu_to_le32(addr)

Let's remove the leftover cpu_to_le32() for coherency.

v2: Better changelog.
v3: Add Acked-by

Fixes: 6f2b6a3005b2c34c39f207a87667564f64f2f91a
  # 3c59x: Add dma error checking and recovery
Acked-by: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: Sylvain "ythier" Hitier <sylvain.hitier@gmail.com>
---

[Resent with maintainer and mailing-list Cc-ed]

 drivers/net/ethernet/3com/3c59x.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index 8ca49f04..0a3108b3 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -2214,7 +2214,7 @@ boomerang_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 	}
 #else
-	dma_addr = cpu_to_le32(pci_map_single(VORTEX_PCI(vp), skb->data, skb->len, PCI_DMA_TODEVICE));
+	dma_addr = pci_map_single(VORTEX_PCI(vp), skb->data, skb->len, PCI_DMA_TODEVICE);
 	if (dma_mapping_error(&VORTEX_PCI(vp)->dev, dma_addr))
 		goto out_dma_err;
 	vp->tx_ring[entry].addr = cpu_to_le32(dma_addr);
-- 
1.7.10.4

Regards,
Sylvain "ythier" Hitier

-- 
Business is about being busy, not being rich...
Lived 777 days in a Debian package => http://en.wikipedia.org/wiki/Apt,_Vaucluse
There's THE room for ideals in this mechanical place!
