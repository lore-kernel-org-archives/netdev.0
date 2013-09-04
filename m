From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH] net/core: Order-3 frag allocator causes SWIOTLB bouncing under Xen
Date: Wed, 4 Sep 2013 21:47:18 +0100
Message-ID: <1378327638-23956-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Li Zefan <lizefan@huawei.com>,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<malcolm.crossley@citrix.com>, <david.vrabel@citrix.com>,
	<xen-devel@lists.xen.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

THIS PATCH IS NOT INTENDED TO BE UPSTREAMED, IT HAS ONLY INFORMING PURPOSES!

I've noticed a performance regression with upstream kernels when used as Dom0
under Xen. The classic kernel can utilize the whole bandwidth of a 10G NIC
(ca. 9.3 Gbps), but upstream can reach only ca. 7 Gbps. I found that it
happens because SWIOTLB has to do double buffering. The per task frag
allocator introduced in 5640f7 creates 32 kb frags, which are not contiguous
in mfn space.
This patch provides a workaround by going back to the old way. The possible
ideas came up to solve this:

* make sure Dom0 memory is contiguous: it sounds trivial, but doesn't work with
driver domains, and there are lots of situations where this is not possible.
* use PVH Dom0: so we will have IOMMU. In the future sometime.
* use IOMMU with PV Dom0: this seems to happen earlier.

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
---
 net/core/sock.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 2c097c5..854a0ea 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1812,7 +1812,7 @@ struct sk_buff *sock_alloc_send_skb(struct sock *sk, unsigned long size,
 EXPORT_SYMBOL(sock_alloc_send_skb);
 
 /* On 32bit arches, an skb frag is limited to 2^15 */
-#define SKB_FRAG_PAGE_ORDER	get_order(32768)
+#define SKB_FRAG_PAGE_ORDER	get_order(4096)
 
 bool sk_page_frag_refill(struct sock *sk, struct page_frag *pfrag)
 {
