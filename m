From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 13/25] copy_from_iter_nocache()
Date: Tue,  9 Dec 2014 22:50:26 +0000
Message-ID: <1418165438-2205-13-git-send-email-viro@ZenIV.linux.org.uk>
References: <20141209224928.GL22149@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141209224928.GL22149@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@zeniv.linux.org.uk>

BTW, do we want memcpy_nocache()?

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 include/linux/uio.h |  1 +
 mm/iov_iter.c       | 21 +++++++++++++++++++++
 2 files changed, 22 insertions(+)

diff --git a/include/linux/uio.h b/include/linux/uio.h
index c567655..bd8569a 100644
--- a/include/linux/uio.h
+++ b/include/linux/uio.h
@@ -83,6 +83,7 @@ size_t copy_page_from_iter(struct page *page, size_t offset, size_t bytes,
 			 struct iov_iter *i);
 size_t copy_to_iter(void *addr, size_t bytes, struct iov_iter *i);
 size_t copy_from_iter(void *addr, size_t bytes, struct iov_iter *i);
+size_t copy_from_iter_nocache(void *addr, size_t bytes, struct iov_iter *i);
 size_t iov_iter_zero(size_t bytes, struct iov_iter *);
 unsigned long iov_iter_alignment(const struct iov_iter *i);
 void iov_iter_init(struct iov_iter *i, int direction, const struct iovec *iov,
diff --git a/mm/iov_iter.c b/mm/iov_iter.c
index 88c052e..a1599ca 100644
--- a/mm/iov_iter.c
+++ b/mm/iov_iter.c
@@ -399,6 +399,27 @@ size_t copy_from_iter(void *addr, size_t bytes, struct iov_iter *i)
 }
 EXPORT_SYMBOL(copy_from_iter);
 
+size_t copy_from_iter_nocache(void *addr, size_t bytes, struct iov_iter *i)
+{
+	char *to = addr;
+	if (unlikely(bytes > i->count))
+		bytes = i->count;
+
+	if (unlikely(!bytes))
+		return 0;
+
+	iterate_and_advance(i, bytes, v,
+		__copy_from_user_nocache((to += v.iov_len) - v.iov_len,
+					 v.iov_base, v.iov_len),
+		memcpy_from_page((to += v.bv_len) - v.bv_len, v.bv_page,
+				 v.bv_offset, v.bv_len),
+		memcpy((to += v.iov_len) - v.iov_len, v.iov_base, v.iov_len)
+	)
+
+	return bytes;
+}
+EXPORT_SYMBOL(copy_from_iter_nocache);
+
 size_t copy_page_to_iter(struct page *page, size_t offset, size_t bytes,
 			 struct iov_iter *i)
 {
-- 
2.1.3
