From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] bnx2x: avoid two atomic ops per page on x86
Date: Fri, 20 Jan 2017 08:25:34 -0800
Message-ID: <1484929534.16328.134.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Gabriel Krisman Bertazi <krisman@linux.vnet.ibm.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <ariel.elior@cavium.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34763 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752331AbdATQZg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 11:25:36 -0500
Received: by mail-pf0-f193.google.com with SMTP id y143so5753644pfb.1
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 08:25:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Commit 4cace675d687 ("bnx2x: Alloc 4k fragment for each rx ring buffer
element") added extra put_page() and get_page() calls on arches where
PAGE_SIZE=4K like x86

Reorder things to avoid this overhead. 

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Gabriel Krisman Bertazi <krisman@linux.vnet.ibm.com>
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
Cc: Ariel Elior <ariel.elior@cavium.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |   15 ++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 3e199d3e461ef5dd237e3176bcb666f878ac..c0dac0e5696d7d01457a42c2c13f1640c2e2 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -549,14 +549,7 @@ static int bnx2x_alloc_rx_sge(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 	struct bnx2x_alloc_pool *pool = &fp->page_pool;
 	dma_addr_t mapping;
 
-	if (!pool->page || (PAGE_SIZE - pool->offset) < SGE_PAGE_SIZE) {
-
-		/* put page reference used by the memory pool, since we
-		 * won't be using this page as the mempool anymore.
-		 */
-		if (pool->page)
-			put_page(pool->page);
-
+	if (!pool->page) {
 		pool->page = alloc_pages(gfp_mask, PAGES_PER_SGE_SHIFT);
 		if (unlikely(!pool->page))
 			return -ENOMEM;
@@ -571,7 +564,6 @@ static int bnx2x_alloc_rx_sge(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 		return -ENOMEM;
 	}
 
-	get_page(pool->page);
 	sw_buf->page = pool->page;
 	sw_buf->offset = pool->offset;
 
@@ -581,7 +573,10 @@ static int bnx2x_alloc_rx_sge(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 	sge->addr_lo = cpu_to_le32(U64_LO(mapping));
 
 	pool->offset += SGE_PAGE_SIZE;
-
+	if (PAGE_SIZE - pool->offset >= SGE_PAGE_SIZE)
+		get_page(pool->page);
+	else
+		pool->page = NULL;
 	return 0;
 }
 
