From: Seth Forshee <seth.forshee@canonical.com>
Subject: [PATCH] xen-netfront: Remove BUGs on paged skb data which crosses a page boundary
Date: Tue, 25 Nov 2014 20:28:24 -0600
Message-ID: <1416968904-70874-1-git-send-email-seth.forshee@canonical.com>
Cc: Zoltan Kiss <zoltan.kiss@linaro.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stefan Bader <stefan.bader@canonical.com>,
	Seth Forshee <seth.forshee@canonical.com>,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These BUGs can be erroneously triggered by frags which refer to
tail pages within a compound page. The data in these pages may
overrun the hardware page while still being contained within the
compound page, but since compound_order() evaluates to 0 for tail
pages the assertion fails. The code already iterates through
subsequent pages correctly in this scenario, so the BUGs are
unnecessary and can be removed.

Fixes: f36c374782e4 ("xen/netfront: handle compound page fragments on transmit")
Cc: <stable@vger.kernel.org> # 3.7+
Signed-off-by: Seth Forshee <seth.forshee@canonical.com>
---
 drivers/net/xen-netfront.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index cca871346a0f..ece8d1804d13 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -496,9 +496,6 @@ static void xennet_make_frags(struct sk_buff *skb, struct netfront_queue *queue,
 		len = skb_frag_size(frag);
 		offset = frag->page_offset;
 
-		/* Data must not cross a page boundary. */
-		BUG_ON(len + offset > PAGE_SIZE<<compound_order(page));
-
 		/* Skip unused frames from start of page */
 		page += offset >> PAGE_SHIFT;
 		offset &= ~PAGE_MASK;
@@ -506,8 +503,6 @@ static void xennet_make_frags(struct sk_buff *skb, struct netfront_queue *queue,
 		while (len > 0) {
 			unsigned long bytes;
 
-			BUG_ON(offset >= PAGE_SIZE);
-
 			bytes = PAGE_SIZE - offset;
 			if (bytes > len)
 				bytes = len;
-- 
1.9.1
