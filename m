From: Anton Vorontsov <avorontsov@mvista.com>
Subject: [PATCH 1/2] fsl_pq_mdio: Fix kernel oops during OF address translation
Date: Fri, 23 Apr 2010 21:12:35 +0400
Message-ID: <20100423171235.GA2140@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sandeep Gopalpet <Sandeep.Kumar@freescale.com>,
	linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

Old P1020RDB device trees were not specifing tbipa address for
MDIO nodes, which is now causing this kernel oops:

 ...
 eth2: TX BD ring size for Q[6]: 256
 eth2: TX BD ring size for Q[7]: 256
 Unable to handle kernel paging request for data at address 0x00000000
 Faulting instruction address: 0xc0015504
 Oops: Kernel access of bad area, sig: 11 [#1]
 ...
 NIP [c0015504] memcpy+0x3c/0x9c
 LR [c000a9f8] __of_translate_address+0xfc/0x21c
 Call Trace:
 [df839e00] [c000a94c] __of_translate_address+0x50/0x21c (unreliable)
 [df839e50] [c01a33e8] get_gfar_tbipa+0xb0/0xe0
 ...

The old device trees are buggy, though having a dead ethernet is
better than a dead kernel, so fix the issue by using of_iomap().

Also, a somewhat similar issue exist in the probe() routine, though
there the oops is only a possibility. Nonetheless, fix it too.

Signed-off-by: Anton Vorontsov <avorontsov@mvista.com>
---
 drivers/net/fsl_pq_mdio.c |   20 ++++++++++++++------
 1 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/net/fsl_pq_mdio.c b/drivers/net/fsl_pq_mdio.c
index d5160ed..3acac5f 100644
--- a/drivers/net/fsl_pq_mdio.c
+++ b/drivers/net/fsl_pq_mdio.c
@@ -205,8 +205,6 @@ static int fsl_pq_mdio_find_free(struct mii_bus *new_bus)
 static u32 __iomem *get_gfar_tbipa(struct fsl_pq_mdio __iomem *regs, struct device_node *np)
 {
 	struct gfar __iomem *enet_regs;
-	u32 __iomem *ioremap_tbipa;
-	u64 addr, size;
 
 	/*
 	 * This is mildly evil, but so is our hardware for doing this.
@@ -220,9 +218,7 @@ static u32 __iomem *get_gfar_tbipa(struct fsl_pq_mdio __iomem *regs, struct devi
 		return &enet_regs->tbipa;
 	} else if (of_device_is_compatible(np, "fsl,etsec2-mdio") ||
 			of_device_is_compatible(np, "fsl,etsec2-tbi")) {
-		addr = of_translate_address(np, of_get_address(np, 1, &size, NULL));
-		ioremap_tbipa = ioremap(addr, size);
-		return ioremap_tbipa;
+		return of_iomap(np, 1);
 	} else
 		return NULL;
 }
@@ -279,6 +275,7 @@ static int fsl_pq_mdio_probe(struct of_device *ofdev,
 	u32 __iomem *tbipa;
 	struct mii_bus *new_bus;
 	int tbiaddr = -1;
+	const u32 *addrp;
 	u64 addr = 0, size = 0;
 	int err = 0;
 
@@ -297,8 +294,19 @@ static int fsl_pq_mdio_probe(struct of_device *ofdev,
 	new_bus->priv = priv;
 	fsl_pq_mdio_bus_name(new_bus->id, np);
 
+	addrp = of_get_address(np, 0, &size, NULL);
+	if (!addrp) {
+		err = -EINVAL;
+		goto err_free_bus;
+	}
+
 	/* Set the PHY base address */
-	addr = of_translate_address(np, of_get_address(np, 0, &size, NULL));
+	addr = of_translate_address(np, addrp);
+	if (addr == OF_BAD_ADDR) {
+		err = -EINVAL;
+		goto err_free_bus;
+	}
+
 	map = ioremap(addr, size);
 	if (!map) {
 		err = -ENOMEM;
-- 
1.7.0.5
