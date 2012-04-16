From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH 3/6] macvtap: zerocopy: validate vector length before pinning
	user pages
Date: Mon, 16 Apr 2012 14:08:07 +0800
Message-ID: <20120416060807.14140.96229.stgit@intel-e5620-16-2.englab.nay.redhat.com>
References: <20120416060749.14140.19433.stgit@intel-e5620-16-2.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com
To: netdev@vger.kernel.org, xma@us.ibm.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120416060749.14140.19433.stgit@intel-e5620-16-2.englab.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently we do not validate the vector length before calling
get_user_pages_fast(), host stack would be easily overflowed by
malicious guest driver who give us a descriptor with length greater
than MAX_SKB_FRAGS. Solve this problem by checking the free entries
before trying to pin user pages.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 7cb2684..d197a78 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -529,6 +529,8 @@ static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
 		}
 		base = (unsigned long)from->iov_base + offset;
 		size = ((base & ~PAGE_MASK) + len + ~PAGE_MASK) >> PAGE_SHIFT;
+		if (i + size >= MAX_SKB_FRAGS)
+			return -EFAULT;
 		num_pages = get_user_pages_fast(base, size, 0, &page[i]);
 		if ((num_pages != size) ||
 		    (num_pages > MAX_SKB_FRAGS - skb_shinfo(skb)->nr_frags))
