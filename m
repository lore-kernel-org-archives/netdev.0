From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 2/8] myri10ge: fix error return code
Date: Mon, 29 Dec 2014 18:04:37 +0100
Message-ID: <1419872683-32709-3-git-send-email-Julia.Lawall@lip6.fr>
References: <1419872683-32709-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Hyong-Youb Kim <hykim@myri.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419872683-32709-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Return a negative error code on failure.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
identifier ret; expression e1,e2;
@@
(
if (\(ret < 0\|ret != 0\))
 { ... return ret; }
|
ret = 0
)
... when != ret = e1
    when != &ret
*if(...)
{
  ... when != ret = e2
      when forall
 return ret;
}
// </smpl>

The patch also modifies the test of mgp->cmd to satisfy checkpatch.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index af09905..71af98b 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -4033,8 +4033,10 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	(void)pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 	mgp->cmd = dma_alloc_coherent(&pdev->dev, sizeof(*mgp->cmd),
 				      &mgp->cmd_bus, GFP_KERNEL);
-	if (mgp->cmd == NULL)
+	if (!mgp->cmd) {
+		status = -ENOMEM;
 		goto abort_with_enabled;
+	}
 
 	mgp->board_span = pci_resource_len(pdev, 0);
 	mgp->iomem_base = pci_resource_start(pdev, 0);
