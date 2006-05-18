From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Netchannel subsystem update.
Date: Thu, 18 May 2006 14:34:44 +0400
Message-ID: <20060518103443.GB26183@2ka.mipt.ru>
References: <200605051248.42662.kelly@au.ibm.com> <200605161102.29472.kelly@au.ibm.com> <20060516061909.GA28670@2ka.mipt.ru> <20060515.235712.26771832.davem@davemloft.net> <20060516173416.GA22552@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, kelly@au1.ibm.com, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:3487 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1750798AbWERKft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 May 2006 06:35:49 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060516173416.GA22552@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This updates brings new features to the following supported:
* unified cache to store netchannels (IPv4 and stub for fied cache
  to store netchannels (IPv4 and stub for IPv6 hashes, TCP and UDP)
* skb queueing mechanism
* netchannel creation/removing/reading commands
* netchannel's callback to allocate/free pages (for
  example to get data from mapped area) not only from SLAB cache
* netchannel's callback to move/copy data to userspace

Added:
* memory limits (soft limits, since update is not protected).
* blocking reading.
* two types of data reading backends (copy_to_user(), copy to (could be
  mapped) area).

Patch against previous release is attached.
Userspace application, design and implementation notes, full patchsets
can be found at project homepage [1].

1. Network channel homepage.
http://tservice.net.ru/~s0mbre/old/?section=projects&item=netchannel


I would like to rise a question about how netchannel object should be
handled by system in general, i.e. should netchannels be associated with
process or they should live by themselfs, i.e. like routes?
My implementation allows netchannels to be setup permanently, so process
can exit and then new one can bind to existing netchannel and read it's
data, but it requires some tricks to create mapping of it's pages into 
process' context...
Also if netchannel is created, but no process is associated with it, who
will process protocol state machine?

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/include/linux/netchannel.h b/include/linux/netchannel.h
index e87a148..7ab2fa0 100644
--- a/include/linux/netchannel.h
+++ b/include/linux/netchannel.h
@@ -32,13 +32,20 @@ enum netchannel_commands {
 	NETCHANNEL_DUMP,
 };
 
+enum netchannel_type {
+	NETCHANNEL_COPY_USER = 0,
+	NETCHANNEL_MMAP,
+	NETCHANEL_VM_HACK,
+};
+
 struct unetchannel
 {
 	__u32			src, dst;		/* source/destination hashes */
 	__u16			sport, dport;		/* source/destination ports */
 	__u8			proto;			/* IP protocol number */
-	__u8			listen;
-	__u8			reserved[2];
+	__u8			type;			/* Netchannel type */
+	__u8			memory_limit_order;	/* Memor limit order */
+	__u8			reserved;
 };
 
 struct unetchannel_control
@@ -46,6 +53,8 @@ struct unetchannel_control
 	struct unetchannel	unc;
 	__u32			cmd;
 	__u32			len;
+	__u32			flags;
+	__u32			timeout;
 };
 
 #ifdef __KERNEL__
@@ -60,9 +69,14 @@ struct netchannel
 
 	struct page *		(*nc_alloc_page)(unsigned int size);
 	void			(*nc_free_page)(struct page *page);
-	int			(*nc_read_data)(struct netchannel *, unsigned int *len, void __user *arg);
+	int			(*nc_read_data)(struct netchannel *, unsigned int *timeout, unsigned int *len, void *arg);
+
+	struct sk_buff_head 	recv_queue;
+	wait_queue_head_t	wait;
+
+	unsigned int		qlen;
 
-	struct sk_buff_head 	list;
+	void			*priv;
 };
 
 struct netchannel_cache_head
@@ -71,5 +85,15 @@ struct netchannel_cache_head
 	struct mutex		mutex;
 };
 
+#define NETCHANNEL_MAX_ORDER	32
+#define NETCHANNEL_MIN_ORDER	PAGE_SHIFT
+
+struct netchannel_mmap
+{
+	struct page		**page;
+	unsigned int		pnum;
+	unsigned int		poff;
+};
+
 #endif /* __KERNEL__ */
 #endif /* __NETCHANNEL_H */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index accd00b..ba82aa2 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -301,7 +301,6 @@ struct sk_buff {
  *	Handling routines are only of interest to the kernel
  */
 #include <linux/slab.h>
-#include <linux/netchannel.h>
 
 #include <asm/system.h>
 
@@ -316,10 +315,11 @@ static inline struct sk_buff *alloc_skb(
 }
 
 #ifdef CONFIG_NETCHANNEL
+struct unetchannel;
 extern struct sk_buff *netchannel_alloc(struct unetchannel *unc, unsigned int header_size, 
 		unsigned int total_size, gfp_t gfp_mask);
 #else
-static struct sk_buff *netchannel_alloc(struct unetchannel *unc, unsigned int header_size, 
+static struct sk_buff *netchannel_alloc(void *unc, unsigned int header_size, 
 		unsigned int total_size, gfp_t gfp_mask)
 {
 	return NULL;
diff --git a/net/core/netchannel.c b/net/core/netchannel.c
index 169a764..96e5e5b 100644
--- a/net/core/netchannel.c
+++ b/net/core/netchannel.c
@@ -27,6 +27,8 @@
 #include <linux/slab.h>
 #include <linux/skbuff.h>
 #include <linux/errno.h>
+#include <linux/highmem.h>
+#include <linux/netchannel.h>
 
 #include <linux/in.h>
 #include <linux/ip.h>
@@ -127,6 +129,7 @@ static void netchannel_free_rcu(struct r
 {
 	struct netchannel *nc = container_of(rcu, struct netchannel, rcu_head);
 
+	netchannel_cleanup(nc);
 	kmem_cache_free(netchannel_cache, nc);
 }
 
@@ -151,8 +154,10 @@ static inline void netchannel_dump_info_
 	dport = ntohs(unc->dport);
 	sport = ntohs(unc->sport);
 
-	printk(KERN_INFO "netchannel: %s %u.%u.%u.%u:%u -> %u.%u.%u.%u:%u, proto: %u, hit: %lu, err: %d.\n",
-			prefix, NIPQUAD(src), sport, NIPQUAD(dst), dport, unc->proto, hit, err);
+	printk(KERN_NOTICE "netchannel: %s %u.%u.%u.%u:%u -> %u.%u.%u.%u:%u, "
+			"proto: %u, type: %u, order: %u, hit: %lu, err: %d.\n",
+			prefix, NIPQUAD(src), sport, NIPQUAD(dst), dport, 
+			unc->proto, unc->type, unc->memory_limit_order, hit, err);
 }
 
 static int netchannel_convert_skb_ipv6(struct sk_buff *skb, struct unetchannel *unc)
@@ -197,7 +202,7 @@ static int netchannel_convert_skb_ipv4(s
 
 	len = skb->len;
 
-	skb->h.raw = skb->nh.iph + iph->ihl*4;
+	skb->h.raw = skb->nh.raw + iph->ihl*4;
 
 	switch (unc->proto) {
 		case IPPROTO_TCP:
@@ -352,35 +357,91 @@ int netchannel_recv(struct sk_buff *skb)
 
 	nc->hit++;
 
-	skb_queue_tail(&nc->list, skb);
+	if (nc->qlen + skb->len > (1 << nc->unc.memory_limit_order)) {
+		kfree_skb(skb);
+		err = 0;
+		goto unlock;
+	}
+
+	skb_queue_tail(&nc->recv_queue, skb);
+	nc->qlen += skb->len;
 
 unlock:
 	rcu_read_unlock();
 	return err;
 }
 
+static int netchannel_wait_for_packet(struct netchannel *nc, long *timeo_p)
+{
+	int error = 0;
+	DEFINE_WAIT(wait);
+
+	prepare_to_wait_exclusive(&nc->wait, &wait, TASK_INTERRUPTIBLE);
+
+	if (skb_queue_empty(&nc->recv_queue)) {
+		if (signal_pending(current))
+			goto interrupted;
+
+		*timeo_p = schedule_timeout(*timeo_p);
+	}
+out:
+	finish_wait(&nc->wait, &wait);
+	return error;
+interrupted:
+	error = (*timeo_p == MAX_SCHEDULE_TIMEOUT) ? -ERESTARTSYS : -EINTR;
+	goto out;
+}
+
+static struct sk_buff *netchannel_get_skb(struct netchannel *nc, unsigned int *timeout, int *error)
+{
+	struct sk_buff *skb = NULL;
+	long tm = *timeout;
+
+	*error = 0;
+
+	while (1) {
+		skb = skb_dequeue(&nc->recv_queue);
+		if (skb)
+			break;
+
+		if (*timeout) {
+			*error = netchannel_wait_for_packet(nc, &tm);
+			if (*error) {
+				*timeout = tm;
+				break;
+			}
+			tm = *timeout;
+		} else {
+			*error = -EAGAIN;
+			break;
+		}
+	}
+
+	return skb;
+}
+
 /*
  * Actually it should be something like recvmsg().
  */
-static int netchannel_copy_to_user(struct netchannel *nc, unsigned int *len, void __user *arg)
+static int netchannel_copy_to_user(struct netchannel *nc, unsigned int *timeout, unsigned int *len, void *arg)
 {
 	unsigned int copied;
 	struct sk_buff *skb;
 	struct iovec to;
-	int err = -EINVAL;
-	
-	to.iov_base = arg;
-	to.iov_len = *len;
+	int err;
 
-	skb = skb_dequeue(&nc->list);
+	skb = netchannel_get_skb(nc, timeout, &err);
 	if (!skb)
-		return -EAGAIN;
+		return err;
+
+	to.iov_base = arg;
+	to.iov_len = *len;
 
 	copied = skb->len;
 	if (copied > *len)
 		copied = *len;
-	
-	if (skb->ip_summed==CHECKSUM_UNNECESSARY) {
+
+	if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
 		err = skb_copy_datagram_iovec(skb, 0, &to, copied);
 	} else {
 		err = skb_copy_and_csum_datagram_iovec(skb,0, &to);
@@ -388,56 +449,290 @@ static int netchannel_copy_to_user(struc
 
 	*len = (err == 0)?copied:0;
 
+	nc->qlen -= skb->len;
 	kfree_skb(skb);
 
 	return err;
 }
 
-static int netchannel_create(struct unetchannel *unc)
+int netchannel_skb_copy_datagram(const struct sk_buff *skb, int offset,
+			    void *to, int len)
 {
-	struct netchannel *nc;
-	int err = -ENOMEM;
-	struct netchannel_cache_head *bucket;
+	int start = skb_headlen(skb);
+	int i, copy = start - offset;
+
+	/* Copy header. */
+	if (copy > 0) {
+		if (copy > len)
+			copy = len;
+		memcpy(to, skb->data + offset, copy);
+
+		if ((len -= copy) == 0)
+			return 0;
+		offset += copy;
+		to += copy;
+	}
+
+	/* Copy paged appendix. Hmm... why does this look so complicated? */
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		int end;
+
+		BUG_TRAP(start <= offset + len);
+
+		end = start + skb_shinfo(skb)->frags[i].size;
+		if ((copy = end - offset) > 0) {
+			u8  *vaddr;
+			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+			struct page *page = frag->page;
+
+			if (copy > len)
+				copy = len;
+			vaddr = kmap(page);
+			memcpy(to, vaddr + frag->page_offset +
+					     offset - start, copy);
+			kunmap(page);
+			if (!(len -= copy))
+				return 0;
+			offset += copy;
+			to += copy;
+		}
+		start = end;
+	}
+
+	if (skb_shinfo(skb)->frag_list) {
+		struct sk_buff *list = skb_shinfo(skb)->frag_list;
+
+		for (; list; list = list->next) {
+			int end;
+
+			BUG_TRAP(start <= offset + len);
+
+			end = start + list->len;
+			if ((copy = end - offset) > 0) {
+				if (copy > len)
+					copy = len;
+				if (netchannel_skb_copy_datagram(list,
+							    offset - start,
+							    to, copy))
+					goto fault;
+				if ((len -= copy) == 0)
+					return 0;
+				offset += copy;
+				to += copy;
+			}
+			start = end;
+		}
+	}
+	if (!len)
+		return 0;
+
+fault:
+	return -EFAULT;
+}
+
+static int netchannel_copy_to_mem(struct netchannel *nc, unsigned int *timeout, unsigned int *len, void *arg)
+{
+	struct netchannel_mmap *m = nc->priv;
+	unsigned int copied, skb_offset = 0;
+	struct sk_buff *skb;
+	int err;
+
+	skb = netchannel_get_skb(nc, timeout, &err);
+	if (!skb)
+		return err;
+
+	copied = skb->len;
+
+	while (copied) {
+		int pnum = ((m->poff % PAGE_SIZE) % m->pnum);
+		struct page *page = m->page[pnum];
+		void *page_map, *ptr;
+		unsigned int sz, left;
+
+		left = PAGE_SIZE - (m->poff % (PAGE_SIZE - 1));
+		sz = min_t(unsigned int, left, copied);
+
+		if (!sz) {
+			err = -ENOSPC;
+			goto err_out;
+		}
+
+		page_map = kmap_atomic(page, KM_USER0);
+		if (!page_map) {
+			err = -ENOMEM;
+			goto err_out;
+		}
+		ptr = page_map + (m->poff % (PAGE_SIZE - 1));
+
+		err = netchannel_skb_copy_datagram(skb, skb_offset, ptr, sz);
+		if (err) {
+			kunmap_atomic(page_map, KM_USER0);
+			goto err_out;
+		}
+		kunmap_atomic(page_map, KM_USER0);
+
+		copied -= sz;
+		m->poff += sz;
+		skb_offset += sz;
+#if 1
+		if (m->poff >= PAGE_SIZE * m->pnum) {
+			//netchannel_dump_info_unc(&nc->unc, "rewind", nc->hit, 0);
+			m->poff = 0;
+		}
+#endif
+	}
+	*len = skb->len;
+
+	err = 0;
+
+err_out:
+	nc->qlen -= skb->len;
+	kfree_skb(skb);
+
+	return err;
+}
+
+static int netchannel_mmap_setup(struct netchannel *nc)
+{
+	struct netchannel_mmap *m;
+	unsigned int i, pnum;
+
+	pnum = (1 << (nc->unc.memory_limit_order - NETCHANNEL_MIN_ORDER));
+
+	m = kzalloc(sizeof(struct netchannel_mmap) + sizeof(struct page *) * pnum, GFP_KERNEL);
+	if (!m)
+		return -ENOMEM;
+
+	m->page = (struct page **)(m + 1);
+	m->pnum = pnum;
+
+	for (i=0; i<pnum; ++i) {
+		m->page[i] = alloc_page(GFP_KERNEL);
+		if (!m->page[i])
+			break;
+	}
+
+	if (i < pnum) {
+		pnum = i;
+		goto err_out_free;
+	}
+
+	nc->priv = m;
+	nc->nc_read_data = &netchannel_copy_to_mem;
+
+	return 0;
+
+err_out_free:
+	for (i=0; i<pnum; ++i)
+		__free_page(m->page[i]);
+
+	kfree(m);
+
+	return -ENOMEM;
 	
-	if (!netchannel_hash_table)
-		return -ENODEV;
+}
 
-	bucket = netchannel_bucket(unc);
+static void netchannel_mmap_cleanup(struct netchannel *nc)
+{
+	unsigned int i;
+	struct netchannel_mmap *m = nc->priv;
 
-	mutex_lock(&bucket->mutex);
+	for (i=0; i<m->pnum; ++i)
+		__free_page(m->page[i]);
 
-	if (netchannel_check_full(unc, bucket)) {
-		err = -EEXIST;
-		goto out_unlock;
+	kfree(m);
+}
+
+static void netchannel_cleanup(struct netchannel *nc)
+{
+	switch (nc->unc.type) {
+		case NETCHANNEL_COPY_USER:
+			break;
+		case NETCHANNEL_MMAP:
+			netchannel_mmap_cleanup(nc);
+			break;
+		default:
+			break;
 	}
+}
 
-	if (unc->listen && netchannel_check_dest(unc, bucket)) {
-		err = -EEXIST;
-		goto out_unlock;
+static int netchannel_setup(struct netchannel *nc)
+{
+	int ret = 0;
+
+	if (nc->unc.memory_limit_order > NETCHANNEL_MAX_ORDER)
+		return -E2BIG;
+
+	if (nc->unc.memory_limit_order < NETCHANNEL_MIN_ORDER)
+		nc->unc.memory_limit_order = NETCHANNEL_MIN_ORDER;
+	
+	switch (nc->unc.type) {
+		case NETCHANNEL_COPY_USER:
+			nc->nc_read_data = &netchannel_copy_to_user;
+			break;
+		case NETCHANNEL_MMAP:
+			ret = netchannel_mmap_setup(nc);
+			break;
+		default:
+			ret = -EINVAL;
+			break;
 	}
 
+	return ret;
+}
+
+static int netchannel_create(struct unetchannel *unc)
+{
+	struct netchannel *nc;
+	int err = -ENOMEM;
+	struct netchannel_cache_head *bucket;
+	
+	if (!netchannel_hash_table)
+		return -ENODEV;
+
 	nc = kmem_cache_alloc(netchannel_cache, GFP_KERNEL);
 	if (!nc)
-		goto out_exit;
+		return -ENOMEM;
 
 	memset(nc, 0, sizeof(struct netchannel));
 	
 	nc->hit = 0;
-	skb_queue_head_init(&nc->list);
+	skb_queue_head_init(&nc->recv_queue);
+	init_waitqueue_head(&nc->wait);
 	atomic_set(&nc->refcnt, 1);
 	memcpy(&nc->unc, unc, sizeof(struct unetchannel));
 
-	nc->nc_read_data = &netchannel_copy_to_user;
+	err = netchannel_setup(nc);
+	if (err)
+		goto err_out_free;
+	
+	bucket = netchannel_bucket(unc);
+	
+	mutex_lock(&bucket->mutex);
+	
+	if (netchannel_check_full(unc, bucket)) {
+		err = -EEXIST;
+		goto err_out_unlock;
+	}
 
 	hlist_add_head_rcu(&nc->node, &bucket->head);
 	err = 0;
 
-out_unlock:
 	mutex_unlock(&bucket->mutex);
-out_exit:
+	
 	netchannel_dump_info_unc(unc, "create", 0, err);
 
 	return err;
+
+err_out_unlock:
+	mutex_unlock(&bucket->mutex);
+
+	netchannel_cleanup(nc);
+
+err_out_free:
+	kmem_cache_free(netchannel_cache, nc);
+
+	return err;
 }
 
 static int netchannel_remove(struct unetchannel *unc)
@@ -488,11 +783,17 @@ static int netchannel_recv_data(struct u
 		nc = netchannel_check_dest(&ctl->unc, bucket);
 
 	if (!nc)
-		goto out_unlock;
+		goto err_out_unlock;
+
+	netchannel_get(nc);
+	mutex_unlock(&bucket->mutex);
 
-	ret = nc->nc_read_data(nc, &ctl->len, data);
+	ret = nc->nc_read_data(nc, &ctl->timeout, &ctl->len, data);
+	
+	netchannel_put(nc);
+	return ret;
 
-out_unlock:
+err_out_unlock:
 	mutex_unlock(&bucket->mutex);
 	return ret;
 }

-- 
	Evgeniy Polyakov
