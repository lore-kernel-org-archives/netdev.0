From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net 2/2] nfp: handle page allocation failures
Date: Tue, 10 Oct 2017 09:16:23 -0700
Message-ID: <20171010161623.23838-3-jakub.kicinski@netronome.com>
References: <20171010161623.23838-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:44803 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932089AbdJJQQg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 12:16:36 -0400
Received: by mail-pf0-f171.google.com with SMTP id x7so7430454pfa.1
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 09:16:35 -0700 (PDT)
In-Reply-To: <20171010161623.23838-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

page_address() does not handle NULL argument gracefully,
make sure we NULL-check the page pointer before passing it
to page_address().

Fixes: ecd63a0217d5 ("nfp: add XDP support in the driver")
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 1c0187f0af51..e118b5f23996 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1180,10 +1180,14 @@ static void *nfp_net_rx_alloc_one(struct nfp_net_dp *dp, dma_addr_t *dma_addr)
 {
 	void *frag;
 
-	if (!dp->xdp_prog)
+	if (!dp->xdp_prog) {
 		frag = netdev_alloc_frag(dp->fl_bufsz);
-	else
-		frag = page_address(alloc_page(GFP_KERNEL | __GFP_COLD));
+	} else {
+		struct page *page;
+
+		page = alloc_page(GFP_KERNEL | __GFP_COLD);
+		frag = page ? page_address(page) : NULL;
+	}
 	if (!frag) {
 		nn_dp_warn(dp, "Failed to alloc receive page frag\n");
 		return NULL;
@@ -1203,10 +1207,14 @@ static void *nfp_net_napi_alloc_one(struct nfp_net_dp *dp, dma_addr_t *dma_addr)
 {
 	void *frag;
 
-	if (!dp->xdp_prog)
+	if (!dp->xdp_prog) {
 		frag = napi_alloc_frag(dp->fl_bufsz);
-	else
-		frag = page_address(alloc_page(GFP_ATOMIC | __GFP_COLD));
+	} else {
+		struct page *page;
+
+		page = alloc_page(GFP_ATOMIC | __GFP_COLD);
+		frag = page ? page_address(page) : NULL;
+	}
 	if (!frag) {
 		nn_dp_warn(dp, "Failed to alloc receive page frag\n");
 		return NULL;
-- 
2.14.1
