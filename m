From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH] net/mlx4_en: do batched put_page using atomic_sub
Date: Mon, 18 Apr 2016 14:34:05 +0300
Message-ID: <146097924572.15144.10837875571142670008.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, Yishai Hadas <yishaih@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes couple error paths after allocation failures.
Atomic set of page reference counter is safe only if it is zero,
otherwise set can race with any speculative get_page_unless_zero.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 56d070d9cf01..7d25bc9c1b22 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -126,7 +126,9 @@ out:
 			dma_unmap_page(priv->ddev, page_alloc[i].dma,
 				page_alloc[i].page_size, PCI_DMA_FROMDEVICE);
 			page = page_alloc[i].page;
-			set_page_count(page, 1);
+			/* Revert changes done by mlx4_alloc_pages */
+			page_ref_sub(page, page_alloc[i].page_size /
+					   priv->frag_info[i].frag_stride - 1);
 			put_page(page);
 		}
 	}
@@ -176,7 +178,9 @@ out:
 		dma_unmap_page(priv->ddev, page_alloc->dma,
 			       page_alloc->page_size, PCI_DMA_FROMDEVICE);
 		page = page_alloc->page;
-		set_page_count(page, 1);
+		/* Revert changes done by mlx4_alloc_pages */
+		page_ref_sub(page, page_alloc->page_size /
+				   priv->frag_info[i].frag_stride - 1);
 		put_page(page);
 		page_alloc->page = NULL;
 	}
