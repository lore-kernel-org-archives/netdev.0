From: Julien Grall <julien.grall@citrix.com>
Subject: [RFC 12/23] xen: Extend page_to_mfn to take an offset in the page
Date: Thu, 14 May 2015 18:00:52 +0100
Message-ID: <1431622863-28575-13-git-send-email-julien.grall@citrix.com>
References: <1431622863-28575-1-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>, <ian.campbell@citrix.com>,
	<stefano.stabellini@eu.citrix.com>, <linux-kernel@vger.kernel.org>,
	<tim@xen.org>, Julien Grall <julien.grall@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	"David Vrabel" <david.vrabel@citrix.com>, <netdev@vger.kernel.org>
To: <xen-devel@lists.xenproject.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1431622863-28575-1-git-send-email-julien.grall@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With 64KB page granularity support in Linux, a page will be split accross
multiple MFN (Xen is using 4KB page granularity). Thoses MFNs may not be
contiguous.

With the offset in the page, the helper will be able to know which MFN
the driver needs to retrieve.

Signed-off-by: Julien Grall <julien.grall@citrix.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: David Vrabel <david.vrabel@citrix.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/xen-netfront.c | 2 +-
 include/xen/page.h         | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 381d38f..6a0e329 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -431,7 +431,7 @@ static struct xen_netif_tx_request *xennet_make_one_txreq(
 	BUG_ON((signed short)ref < 0);
 
 	gnttab_grant_foreign_access_ref(ref, queue->info->xbdev->otherend_id,
-					page_to_mfn(page), GNTMAP_readonly);
+					page_to_mfn(page, 0), GNTMAP_readonly);
 
 	queue->tx_skbs[id].skb = skb;
 	queue->grant_tx_page[id] = page;
diff --git a/include/xen/page.h b/include/xen/page.h
index 89ae01c..8848da1 100644
--- a/include/xen/page.h
+++ b/include/xen/page.h
@@ -20,9 +20,9 @@
 
 #include <asm/xen/page.h>
 
-static inline unsigned long page_to_mfn(struct page *page)
+static inline unsigned long page_to_mfn(struct page *page, unsigned int offset)
 {
-	return pfn_to_mfn(xen_page_to_pfn(page));
+	return pfn_to_mfn(xen_page_to_pfn(page) + (offset >> XEN_PAGE_SHIFT));
 }
 
 struct xen_memory_region {
-- 
2.1.4
