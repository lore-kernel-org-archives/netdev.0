From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 2/3] drivers/net/wan/dscc4.c: fix error return code
Date: Fri, 17 Aug 2012 09:46:57 +0200
Message-ID: <1345189618-13758-3-git-send-email-Julia.Lawall@lip6.fr>
References: <1345189618-13758-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1345189618-13758-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Move up the initialization of rc so that failure of pci_alloc_consistent
returns -ENOMEM as well.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
identifier ret;
expression e1,e2;
@@

if (ret < 0)
 { ... return ret; }
 ... when != ret = e1
     when forall
*if(...)
 {
  ... when != ret = e2
* return ret;
 }
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/wan/dscc4.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index 9eb6479..ef36caf 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -774,14 +774,15 @@ static int __devinit dscc4_init_one(struct pci_dev *pdev,
 	}
 	/* Global interrupt queue */
 	writel((u32)(((IRQ_RING_SIZE >> 5) - 1) << 20), ioaddr + IQLENR1);
+
+	rc = -ENOMEM;
+
 	priv->iqcfg = (__le32 *) pci_alloc_consistent(pdev,
 		IRQ_RING_SIZE*sizeof(__le32), &priv->iqcfg_dma);
 	if (!priv->iqcfg)
 		goto err_free_irq_5;
 	writel(priv->iqcfg_dma, ioaddr + IQCFG);
 
-	rc = -ENOMEM;
-
 	/*
 	 * SCC 0-3 private rx/tx irq structures
 	 * IQRX/TXi needs to be set soon. Learned it the hard way...
