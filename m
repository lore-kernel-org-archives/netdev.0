From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 2/5] sfc: Correct validation of peer_page_count in
 efx_vfdi_set_status_page()
Date: Thu, 23 Feb 2012 17:40:45 +0000
Message-ID: <1330018845.2511.3.camel@bwh-desktop>
References: <1330018734.2511.1.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:7260 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752207Ab2BWRks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 12:40:48 -0500
In-Reply-To: <1330018734.2511.1.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

efx_vfdi_set_status_page() validates the peer page count by
calculating the size of a request containing that many addresses and
comparing that with the maximum valid request size (4KB).  The
calculation involves a multiplication that may overflow on a 32-bit
system.

We use kcalloc() to allocate memory to store the addresses; that also
does a multiplication and it does check for integer overflow, so any
values larger than 0x1fffffff will be rejected.  However, values in
the range [0x1fffffffc, 0x1fffffff] pass boh tests and result in an
attempt to allocate nearly 4GB on the heap.  This should be rejected
rather quickly as it's obviously impossible on a 32-bit system, and
indeed the maximum possible heap allocation is 32MB.  Still, let's
make absolutely sure by fixing the initial validation.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/siena_sriov.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sfc/siena_sriov.c b/drivers/net/ethernet/sfc/siena_sriov.c
index 5c6839e..80976e8 100644
--- a/drivers/net/ethernet/sfc/siena_sriov.c
+++ b/drivers/net/ethernet/sfc/siena_sriov.c
@@ -796,12 +796,13 @@ static int efx_vfdi_set_status_page(struct efx_vf *vf)
 {
 	struct efx_nic *efx = vf->efx;
 	struct vfdi_req *req = vf->buf.addr;
-	unsigned int page_count;
+	u64 page_count = req->u.set_status_page.peer_page_count;
+	u64 max_page_count =
+		(EFX_PAGE_SIZE -
+		 offsetof(struct vfdi_req, u.set_status_page.peer_page_addr[0]))
+		/ sizeof(req->u.set_status_page.peer_page_addr[0]);
 
-	page_count = req->u.set_status_page.peer_page_count;
-	if (!req->u.set_status_page.dma_addr || EFX_PAGE_SIZE <
-	    offsetof(struct vfdi_req,
-		     u.set_status_page.peer_page_addr[page_count])) {
+	if (!req->u.set_status_page.dma_addr || page_count > max_page_count) {
 		if (net_ratelimit())
 			netif_err(efx, hw, efx->net_dev,
 				  "ERROR: Invalid SET_STATUS_PAGE from %s\n",
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
