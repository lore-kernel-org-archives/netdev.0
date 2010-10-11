From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH RFC] tun: dma engine support
Date: Mon, 11 Oct 2010 22:52:08 +0200
Message-ID: <20101011205208.GA8527@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dan.j.williams@intel.com>,
	Linus Walleij <linus.walleij@stericsson.com>,
	Anatolij Gustschin <agust@denx.de>,
	Magnus Damm <damm@opensource.se>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Michael S. Tsirkin" <mst@redhat.com>, Tejun Heo <tj@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Joe Perches <joe@perches.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simple hack to use dma engine for tun RX.
Only one skb in flight at the moment.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

I am still looking at handling multiple skbs, but
sending this out for early flames and improvement suggestions.

Loopback testing seems to show only minor performance gains:
this is not really suprising as data is hot in cache already.
Where I would expect this to help more is with incoming
traffic from an external NIC. This still needs to be tested.

 drivers/dma/Kconfig   |    2 +-
 drivers/dma/iovlock.c |    2 +-
 drivers/net/tun.c     |  389 ++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 390 insertions(+), 3 deletions(-)

diff --git a/drivers/dma/Kconfig b/drivers/dma/Kconfig
index 9520cf0..7e82c00 100644
--- a/drivers/dma/Kconfig
+++ b/drivers/dma/Kconfig
@@ -202,7 +202,7 @@ comment "DMA Clients"
 	depends on DMA_ENGINE
 
 config NET_DMA
-	bool "Network: TCP receive copy offload"
+	bool "Network: TCP/TUN receive copy offload"
 	depends on DMA_ENGINE && NET
 	default (INTEL_IOATDMA || FSL_DMA)
 	help
diff --git a/drivers/dma/iovlock.c b/drivers/dma/iovlock.c
index c6917e8..121d7fd 100644
--- a/drivers/dma/iovlock.c
+++ b/drivers/dma/iovlock.c
@@ -138,7 +138,7 @@ void dma_unpin_iovec_pages(struct dma_pinned_list *pinned_list)
 
 	kfree(pinned_list);
 }
-
+EXPORT_SYMBOL_GPL(dma_unpin_iovec_pages);
 
 /*
  * We have already pinned down the pages we will be using in the iovecs.
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 55f3a3e..ddbfbc8 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -62,6 +62,8 @@
 #include <linux/nsproxy.h>
 #include <linux/virtio_net.h>
 #include <linux/rcupdate.h>
+#include <linux/dmaengine.h>
+#include <linux/pagemap.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 #include <net/rtnetlink.h>
@@ -70,6 +72,9 @@
 #include <asm/system.h>
 #include <asm/uaccess.h>
 
+int tun_dma_copybreak = 0x10000;
+module_param_named(dma_copybreak, tun_dma_copybreak, int, 0644);
+MODULE_PARM_DESC(debug_level, "Use DMA engine for messages of this length and up");
 /* Uncomment to enable debugging */
 /* #define TUN_DEBUG 1 */
 
@@ -547,6 +552,364 @@ static inline struct sk_buff *tun_alloc_skb(struct tun_struct *tun,
 	return skb;
 }
 
+#ifdef CONFIG_NET_DMA
+/* The below duplicates code from net/core and drivers/dma
+ * with the minor twist that these functions work on a const
+ * iovec with an offset. TODO: move it there? */
+static int num_pages_spanned(void __user * iov_base, size_t iov_len)
+{
+	return
+	((PAGE_ALIGN((unsigned long)iov_base + iov_len) -
+	((unsigned long)iov_base & PAGE_MASK)) >> PAGE_SHIFT);
+}
+
+/*
+ * Pin down all the iovec pages needed for len bytes.
+ * Return a struct dma_pinned_list to keep track of pages pinned down.
+ *
+ * We are allocating a single chunk of memory, and then carving it up into
+ * 3 sections, the latter 2 whose size depends on the number of iovecs and the
+ * total number of pages, respectively.
+ */
+static struct dma_pinned_list *dma_pin_const_iovec_pages(const struct iovec *iov,
+						       size_t iov_offset, size_t len)
+{
+	struct dma_pinned_list *local_list;
+	struct page **pages;
+	int i;
+	int ret;
+	int nr_iovecs = 0;
+	int iovec_len_used = 0;
+	int iovec_pages_used = 0;
+	void __user *iov_base;
+	size_t iov_len;
+
+	/* determine how many iovecs/pages there are, up front */
+	do {
+		/* Skip offset as required. */
+		iov_len = iov[nr_iovecs].iov_len;
+		if (iov_offset >= iovec_len_used + iov_len) {
+			iov_offset -= iov_len;
+			++iov;
+			continue;
+		}
+		iov_base = iov[nr_iovecs].iov_base;
+		if (!iovec_len_used) {
+			iov_base += iov_offset;
+			iov_len -= iov_offset;
+		}
+		iovec_len_used += iov_len;
+		iovec_pages_used += num_pages_spanned(iov_base, iov_len);
+		nr_iovecs++;
+	} while (iovec_len_used < len);
+
+	/* single kmalloc for pinned list, page_list[], and the page arrays */
+	local_list = kmalloc(sizeof(*local_list)
+		+ (nr_iovecs * sizeof (struct dma_page_list))
+		+ (iovec_pages_used * sizeof (struct page*)), GFP_KERNEL);
+	if (!local_list)
+		goto out;
+
+	/* list of pages starts right after the page list array */
+	pages = (struct page **) &local_list->page_list[nr_iovecs];
+
+	local_list->nr_iovecs = 0;
+
+	for (i = 0; i < nr_iovecs; i++) {
+		struct dma_page_list *page_list = &local_list->page_list[i];
+
+		iov_len = iov[i].iov_len + iov_offset;
+		iov_base = iov[i].iov_base + iov_offset;
+		iov_offset = 0;
+		len -= iov_len;
+
+		page_list->nr_pages = num_pages_spanned(iov_base, iov_len);
+		page_list->base_address = iov_base;
+
+		page_list->pages = pages;
+		pages += page_list->nr_pages;
+
+		/* pin pages down */
+		ret = get_user_pages_fast(
+			(unsigned long)iov_base,
+			page_list->nr_pages,
+			1,	/* write */
+			page_list->pages);
+
+		if (unlikely(ret < 0))
+			goto unpin;
+
+		local_list->nr_iovecs = i + 1;
+
+		if (unlikely(ret != page_list->nr_pages)) {
+			page_list->nr_pages = ret;
+			goto unpin;
+		}
+
+	}
+
+	return local_list;
+
+unpin:
+	dma_unpin_iovec_pages(local_list);
+out:
+	return NULL;
+}
+
+/*
+ * We have already pinned down the pages we will be using in the iovecs.
+ * Each entry in iov array has corresponding entry in pinned_list->page_list.
+ * Using array indexing to keep iov[] and page_list[] in sync.
+ * Initial elements in iov array's iov->iov_len will be 0 if already copied into
+ *   by another call.
+ * iov array length remaining guaranteed to be bigger than len.
+ */
+dma_cookie_t dma_memcpy_to_iovecend(struct dma_chan *chan, const struct iovec *iov,
+	struct dma_pinned_list *pinned_list, unsigned char *kdata,
+	size_t iov_offset, size_t len)
+{
+	int iov_byte_offset;
+	int copy;
+	dma_cookie_t dma_cookie = 0;
+	int iovec_idx;
+	int page_idx;
+	size_t iov_len;
+	unsigned long iov_base;
+
+	if (!chan)
+		return memcpy_toiovecend(iov, kdata, iov_offset, len);
+
+	iovec_idx = 0;
+	for (iovec_idx = 0; iovec_idx < pinned_list->nr_iovecs; ++iovec_idx) {
+		struct dma_page_list *page_list;
+
+		iov_len = iov[iovec_idx].iov_len;
+		/* skip already used-up iovecs */
+		if (iov_len <= iov_offset) {
+			iov_offset -= iov_len;
+			continue;
+		}
+
+		page_list = &pinned_list->page_list[iovec_idx];
+
+		iov_base = (unsigned long)iov[iovec_idx].iov_base + iov_offset;
+		iov_len -= iov_offset;
+		iov_offset = 0;
+		iov_byte_offset = iov_base & ~PAGE_MASK;
+		page_idx = ((iov_base & PAGE_MASK)
+			 - ((unsigned long)page_list->base_address & PAGE_MASK)) >> PAGE_SHIFT;
+
+		/* break up copies to not cross page boundary */
+		while (iov_len) {
+			copy = min_t(int, PAGE_SIZE - iov_byte_offset, len);
+			copy = min_t(int, copy, iov_len);
+
+			dma_cookie = dma_async_memcpy_buf_to_pg(chan,
+					page_list->pages[page_idx],
+					iov_byte_offset,
+					kdata,
+					copy);
+			/* poll for a descriptor slot */
+			if (unlikely(dma_cookie < 0)) {
+				dma_async_issue_pending(chan);
+				continue;
+			}
+
+			len -= copy;
+			iov_len -= copy;
+			iov_base += copy;
+
+			if (!len)
+				return dma_cookie;
+
+			kdata += copy;
+			iov_byte_offset = 0;
+			page_idx++;
+		}
+	}
+
+	/* really bad if we ever run out of iovecs */
+	BUG();
+	return -EFAULT;
+}
+
+dma_cookie_t dma_memcpy_pg_to_const_iovec(struct dma_chan *chan, const struct iovec *iov,
+	struct dma_pinned_list *pinned_list, struct page *page,
+	unsigned int offset, size_t iov_offset, size_t len)
+{
+	int iov_byte_offset;
+	int copy;
+	dma_cookie_t dma_cookie = 0;
+	int iovec_idx;
+	int page_idx;
+	int err;
+	size_t iov_len;
+	unsigned long iov_base;
+
+	/* this needs as-yet-unimplemented buf-to-buff, so punt. */
+	/* TODO: use dma for this */
+	if (!chan || !pinned_list) {
+		u8 *vaddr = kmap(page);
+		err = memcpy_toiovecend(iov, vaddr + offset, iov_offset, len);
+		kunmap(page);
+		return err;
+	}
+
+	for (iovec_idx = 0; iovec_idx < pinned_list->nr_iovecs; ++iovec_idx) {
+		struct dma_page_list *page_list;
+
+		iov_len = iov[iovec_idx].iov_len;
+		/* skip already used-up iovecs */
+		if (iov_len <= iov_offset) {
+			iov_offset -= iov_len;
+			continue;
+		}
+
+		page_list = &pinned_list->page_list[iovec_idx];
+		iov_base = (unsigned long)iov[iovec_idx].iov_base + iov_offset;
+		iov_len -= iov_offset;
+		iov_offset = 0;
+
+		iov_byte_offset = iov_base & ~PAGE_MASK;
+		page_idx = ((iov_base & PAGE_MASK)
+			 - ((unsigned long)page_list->base_address & PAGE_MASK)) >> PAGE_SHIFT;
+
+		/* break up copies to not cross page boundary */
+		while (iov_len) {
+			copy = min_t(int, PAGE_SIZE - iov_byte_offset, len);
+			copy = min_t(int, copy, iov_len);
+
+			dma_cookie = dma_async_memcpy_pg_to_pg(chan,
+					page_list->pages[page_idx],
+					iov_byte_offset,
+					page,
+					offset,
+					copy);
+			/* poll for a descriptor slot */
+			if (unlikely(dma_cookie < 0)) {
+				dma_async_issue_pending(chan);
+				continue;
+			}
+
+			len -= copy;
+			iov_len -= copy;
+			iov_base += copy;
+
+			if (!len)
+				return dma_cookie;
+
+			offset += copy;
+			iov_byte_offset = 0;
+			page_idx++;
+		}
+	}
+
+	/* really bad if we ever run out of iovecs */
+	BUG();
+	return -EFAULT;
+}
+
+/**
+ *	dma_skb_copy_datagram_iovec - Copy a datagram to an iovec.
+ *	@skb - buffer to copy
+ *	@offset - offset in the buffer to start copying from
+ *	@iovec - io vector to copy to
+ *	@len - amount of data to copy from buffer to iovec
+ *	@pinned_list - locked iovec buffer data
+ *
+ *	Note: the iovec is not modified during the copy.
+ *	Note: pinned_list is assumed pinned with the same offset.
+ */
+dma_cookie_t dma_skb_copy_datagram_const_iovec(struct dma_chan *chan,
+			struct sk_buff *skb, int offset, const struct iovec *to,
+			size_t iov_offset, 
+			size_t len, struct dma_pinned_list *pinned_list)
+{
+	int start = skb_headlen(skb);
+	int i, copy = start - offset;
+	struct sk_buff *frag_iter;
+	dma_cookie_t cookie = 0;
+
+	/* Copy header. */
+	if (copy > 0) {
+		if (copy > len)
+			copy = len;
+		cookie = dma_memcpy_to_iovecend(chan, to, pinned_list,
+						skb->data + offset, iov_offset,
+						copy);
+		if (cookie < 0)
+			goto fault;
+		len -= copy;
+		if (len == 0)
+			goto end;
+		offset += copy;
+		iov_offset += copy;
+	}
+
+	/* Copy paged appendix. Hmm... why does this look so complicated? */
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		int end;
+
+		WARN_ON(start > offset + len);
+
+		end = start + skb_shinfo(skb)->frags[i].size;
+		copy = end - offset;
+		if (copy > 0) {
+			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+			struct page *page = frag->page;
+
+			if (copy > len)
+				copy = len;
+
+			cookie = dma_memcpy_pg_to_const_iovec(chan, to, pinned_list, page,
+					frag->page_offset + offset - start, iov_offset, copy);
+			if (cookie < 0)
+				goto fault;
+			len -= copy;
+			if (len == 0)
+				goto end;
+			offset += copy;
+			iov_offset += copy;
+		}
+		start = end;
+	}
+
+	skb_walk_frags(skb, frag_iter) {
+		int end;
+
+		WARN_ON(start > offset + len);
+
+		end = start + frag_iter->len;
+		copy = end - offset;
+		if (copy > 0) {
+			if (copy > len)
+				copy = len;
+			cookie = dma_skb_copy_datagram_const_iovec(chan, frag_iter,
+							     offset - start,
+							     to, iov_offset, copy,
+							     pinned_list);
+			if (cookie < 0)
+				goto fault;
+			len -= copy;
+			if (len == 0)
+				goto end;
+			offset += copy;
+			iov_offset += copy;
+		}
+		start = end;
+	}
+
+end:
+	if (!len) {
+		skb->dma_cookie = cookie;
+		return cookie;
+	}
+
+fault:
+	return -EFAULT;
+}
+#endif
+
 /* Get packet from user space buffer */
 static __inline__ ssize_t tun_get_user(struct tun_struct *tun,
 				       const struct iovec *iv, size_t count,
@@ -706,6 +1069,9 @@ static __inline__ ssize_t tun_put_user(struct tun_struct *tun,
 {
 	struct tun_pi pi = { 0, skb->protocol };
 	ssize_t total = 0;
+	struct dma_chan *dma_chan;
+	struct dma_pinned_list *pinned_list;
+	int dma_cookie;
 
 	if (!(tun->flags & TUN_NO_PI)) {
 		if ((len -= sizeof(pi)) < 0)
@@ -768,8 +1134,29 @@ static __inline__ ssize_t tun_put_user(struct tun_struct *tun,
 	}
 
 	len = min_t(int, skb->len, len);
-
+#ifdef CONFIG_NET_DMA
+
+	if (len < tun_dma_copybreak)
+		goto copy;
+
+	dma_chan = dma_find_channel(DMA_MEMCPY);
+	if (!dma_chan)
+		goto copy;
+	pinned_list = dma_pin_const_iovec_pages(iv, total, len);
+	if (!pinned_list)
+		goto copy;
+	dma_cookie = dma_skb_copy_datagram_const_iovec(dma_chan, skb, 0, iv,
+						       total, len, pinned_list);
+	if (dma_cookie >= 0) {
+		dma_async_memcpy_issue_pending(dma_chan);
+		dma_sync_wait(dma_chan, dma_cookie);
+	}
+	dma_unpin_iovec_pages(pinned_list);
+	goto done;
+#endif
+copy:
 	skb_copy_datagram_const_iovec(skb, 0, iv, total, len);
+done:
 	total += skb->len;
 
 	tun->dev->stats.tx_packets++;
-- 
1.7.3-rc1
