From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH 1/6] macvtap: zerocopy: fix offset calculation when building
	skb
Date: Mon, 16 Apr 2012 14:07:49 +0800
Message-ID: <20120416060749.14140.19433.stgit@intel-e5620-16-2.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com
To: netdev@vger.kernel.org, xma@us.ibm.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the offset calculation when build skb:

- offset1 were used as skb data offset not vector offset
- reset offset to zero only when we advance to next vector

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 0427c65..bd4a70d 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -505,10 +505,11 @@ static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
 		if (copy > size) {
 			++from;
 			--count;
-		}
+			offset = 0;
+		} else
+			offset += size;
 		copy -= size;
 		offset1 += size;
-		offset = 0;
 	}
 
 	if (len == offset1)
@@ -519,13 +520,13 @@ static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
 		int num_pages;
 		unsigned long base;
 
-		len = from->iov_len - offset1;
+		len = from->iov_len - offset;
 		if (!len) {
-			offset1 = 0;
+			offset = 0;
 			++from;
 			continue;
 		}
-		base = (unsigned long)from->iov_base + offset1;
+		base = (unsigned long)from->iov_base + offset;
 		size = ((base & ~PAGE_MASK) + len + ~PAGE_MASK) >> PAGE_SHIFT;
 		num_pages = get_user_pages_fast(base, size, 0, &page[i]);
 		if ((num_pages != size) ||
@@ -546,7 +547,7 @@ static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
 			len -= size;
 			i++;
 		}
-		offset1 = 0;
+		offset = 0;
 		++from;
 	}
 	return 0;
