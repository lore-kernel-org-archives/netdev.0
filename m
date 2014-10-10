From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net 4/5] mlx4: fix race accessing page->_count
Date: Fri, 10 Oct 2014 04:48:17 -0700
Message-ID: <1412941698-17502-5-git-send-email-edumazet@google.com>
References: <1412941698-17502-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Andres Lagar-Cavilla <andreslc@google.com>,
	Greg Thelen <gthelen@google.com>,
	Hugh Dickins <hughd@google.com>,
	David Rientjes <rientjes@google.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f74.google.com ([209.85.218.74]:62353 "EHLO
	mail-oi0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752521AbaJJLsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 07:48:36 -0400
Received: by mail-oi0-f74.google.com with SMTP id v63so1143934oia.3
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 04:48:36 -0700 (PDT)
In-Reply-To: <1412941698-17502-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is illegal to use atomic_set(&page->_count, ...) even if we 'own'
the page. Other entities in the kernel need to use get_page_unless_zero()
to get a reference to the page before testing page properties, so we could
loose a refcount increment.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index a33048ee9621..01660c595f5c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -76,10 +76,10 @@ static int mlx4_alloc_pages(struct mlx4_en_priv *priv,
 	page_alloc->dma = dma;
 	page_alloc->page_offset = frag_info->frag_align;
 	/* Not doing get_page() for each frag is a big win
-	 * on asymetric workloads.
+	 * on asymetric workloads. Note we can not use atomic_set().
 	 */
-	atomic_set(&page->_count,
-		   page_alloc->page_size / frag_info->frag_stride);
+	atomic_add(page_alloc->page_size / frag_info->frag_stride - 1,
+		   &page->_count);
 	return 0;
 }
 
-- 
2.1.0.rc2.206.gedb03e5
