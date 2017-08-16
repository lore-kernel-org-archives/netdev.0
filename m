From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next V2 1/3] tap: use build_skb() for small packet
Date: Wed, 16 Aug 2017 17:17:45 +0800
Message-ID: <3b66193a-2df1-0191-0785-20123e38460a@redhat.com>
References: <1502451678-17358-1-git-send-email-jasowang@redhat.com>
 <1502451678-17358-2-git-send-email-jasowang@redhat.com>
 <1502855120.4936.89.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170816064951-mutt-send-email-mst@kernel.org>
 <5280f66f-85cf-fa4f-1a1c-7acbac2c9ab7@redhat.com>
 <20170816065837-mutt-send-email-mst@kernel.org>
 <3b24805d-b489-2dfc-f930-0518ba1a6ea0@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------2397F0CFBC84A5FEBD698946"
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kubakici@wp.pl
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3b24805d-b489-2dfc-f930-0518ba1a6ea0@redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------2397F0CFBC84A5FEBD698946
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit



On 2017年08月16日 12:07, Jason Wang wrote:
>
>
> On 2017年08月16日 11:59, Michael S. Tsirkin wrote:
>> On Wed, Aug 16, 2017 at 11:57:51AM +0800, Jason Wang wrote:
>>>
>>> On 2017年08月16日 11:55, Michael S. Tsirkin wrote:
>>>> On Tue, Aug 15, 2017 at 08:45:20PM -0700, Eric Dumazet wrote:
>>>>> On Fri, 2017-08-11 at 19:41 +0800, Jason Wang wrote:
>>>>>> We use tun_alloc_skb() which calls sock_alloc_send_pskb() to 
>>>>>> allocate
>>>>>> skb in the past. This socket based method is not suitable for high
>>>>>> speed userspace like virtualization which usually:
>>>>>>
>>>>>> - ignore sk_sndbuf (INT_MAX) and expect to receive the packet as 
>>>>>> fast as
>>>>>>     possible
>>>>>> - don't want to be block at sendmsg()
>>>>>>
>>>>>> To eliminate the above overheads, this patch tries to use 
>>>>>> build_skb()
>>>>>> for small packet. We will do this only when the following conditions
>>>>>> are all met:
>>>>>>
>>>>>> - TAP instead of TUN
>>>>>> - sk_sndbuf is INT_MAX
>>>>>> - caller don't want to be blocked
>>>>>> - zerocopy is not used
>>>>>> - packet size is smaller enough to use build_skb()
>>>>>>
>>>>>> Pktgen from guest to host shows ~11% improvement for rx pps of tap:
>>>>>>
>>>>>> Before: ~1.70Mpps
>>>>>> After : ~1.88Mpps
>>>>>>
>>>>>> What's more important, this makes it possible to implement XDP 
>>>>>> for tap
>>>>>> before creating skbs.
>>>>> Well well well.
>>>>>
>>>>> You do realize that tun_build_skb() is not thread safe ?
>>>> The issue is alloc frag, isn't it?
>>>> I guess for now we can limit this to XDP mode only, and
>>>> just allocate full pages in that mode.
>>>>
>>>>
>>> Limit this to XDP mode only does not prevent user from sending 
>>> packets to
>>> same queue in parallel I think?
>>>
>>> Thanks
>> Yes but then you can just drop the page frag allocator since
>> XDP is assumed not to care about truesize for most packets.
>>
>
> Ok, let me do some test to see the numbers between the two methods first.
>
> Thanks

It looks like full page allocation just produce too much stress on the 
page allocator.

I get 1.58Mpps (full page) vs 1.95Mpps (page frag) with the patches 
attached.

Since non-XDP case can also benefit from build_skb(), I tend to use 
spinlock instead of full page in this case.

Thanks

--------------2397F0CFBC84A5FEBD698946
Content-Type: text/x-patch;
 name="0001-tun-thread-safe-tun_build_skb.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0001-tun-thread-safe-tun_build_skb.patch"

>From 0b9d930e8192466a9c4b85d136193f9c5f01d96a Mon Sep 17 00:00:00 2001
From: Jason Wang <jasowang@redhat.com>
Date: Wed, 16 Aug 2017 13:48:11 +0800
Subject: [PATCH] tun: thread safe tun_build_skb()

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c | 33 ++++++++++++++++++---------------
 1 file changed, 18 insertions(+), 15 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 5892284..c72c2ea 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1247,6 +1247,8 @@ static void tun_rx_batched(struct tun_struct *tun, struct tun_file *tfile,
 static bool tun_can_build_skb(struct tun_struct *tun, struct tun_file *tfile,
 			      int len, int noblock, bool zerocopy)
 {
+	struct bpf_prog *xdp_prog;
+
 	if ((tun->flags & TUN_TYPE_MASK) != IFF_TAP)
 		return false;
 
@@ -1263,7 +1265,11 @@ static bool tun_can_build_skb(struct tun_struct *tun, struct tun_file *tfile,
 	    SKB_DATA_ALIGN(sizeof(struct skb_shared_info)) > PAGE_SIZE)
 		return false;
 
-	return true;
+	rcu_read_lock();
+	xdp_prog = rcu_dereference(tun->xdp_prog);
+	rcu_read_unlock();
+
+	return xdp_prog;
 }
 
 static struct sk_buff *tun_build_skb(struct tun_struct *tun,
@@ -1272,7 +1278,7 @@ static struct sk_buff *tun_build_skb(struct tun_struct *tun,
 				     struct virtio_net_hdr *hdr,
 				     int len, int *generic_xdp)
 {
-	struct page_frag *alloc_frag = &tfile->alloc_frag;
+	struct page *page = alloc_page(GFP_KERNEL);
 	struct sk_buff *skb;
 	struct bpf_prog *xdp_prog;
 	int buflen = SKB_DATA_ALIGN(len + TUN_RX_PAD) +
@@ -1283,15 +1289,15 @@ static struct sk_buff *tun_build_skb(struct tun_struct *tun,
 	bool xdp_xmit = false;
 	int err;
 
-	if (unlikely(!skb_page_frag_refill(buflen, alloc_frag, GFP_KERNEL)))
+	if (unlikely(!page))
 		return ERR_PTR(-ENOMEM);
 
-	buf = (char *)page_address(alloc_frag->page) + alloc_frag->offset;
-	copied = copy_page_from_iter(alloc_frag->page,
-				     alloc_frag->offset + TUN_RX_PAD,
-				     len, from);
-	if (copied != len)
+	buf = (char *)page_address(page);
+	copied = copy_page_from_iter(page, TUN_RX_PAD, len, from);
+	if (copied != len) {
+		put_page(page);
 		return ERR_PTR(-EFAULT);
+	}
 
 	if (hdr->gso_type)
 		*generic_xdp = 1;
@@ -1313,11 +1319,9 @@ static struct sk_buff *tun_build_skb(struct tun_struct *tun,
 
 		switch (act) {
 		case XDP_REDIRECT:
-			get_page(alloc_frag->page);
-			alloc_frag->offset += buflen;
 			err = xdp_do_redirect(tun->dev, &xdp, xdp_prog);
 			if (err)
-				goto err_redirect;
+				goto err_xdp;
 			return NULL;
 		case XDP_TX:
 			xdp_xmit = true;
@@ -1339,13 +1343,13 @@ static struct sk_buff *tun_build_skb(struct tun_struct *tun,
 	skb = build_skb(buf, buflen);
 	if (!skb) {
 		rcu_read_unlock();
+		put_page(page);
 		return ERR_PTR(-ENOMEM);
 	}
 
 	skb_reserve(skb, TUN_RX_PAD - delta);
 	skb_put(skb, len + delta);
-	get_page(alloc_frag->page);
-	alloc_frag->offset += buflen;
+	get_page(page);
 
 	if (xdp_xmit) {
 		skb->dev = tun->dev;
@@ -1358,9 +1362,8 @@ static struct sk_buff *tun_build_skb(struct tun_struct *tun,
 
 	return skb;
 
-err_redirect:
-	put_page(alloc_frag->page);
 err_xdp:
+	put_page(page);
 	rcu_read_unlock();
 	this_cpu_inc(tun->pcpu_stats->rx_dropped);
 	return NULL;
-- 
2.7.4


--------------2397F0CFBC84A5FEBD698946
Content-Type: text/x-patch;
 name="0001-tun-serialize-page-frag-allocation.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0001-tun-serialize-page-frag-allocation.patch"

>From c2aa968d97f1ac892a93d14cbbf06dac0b91fb49 Mon Sep 17 00:00:00 2001
From: Jason Wang <jasowang@redhat.com>
Date: Wed, 16 Aug 2017 13:17:15 +0800
Subject: [PATCH] tun: serialize page frag allocation

tun_build_skb() is not thread safe since we don't serialize protect
page frag allocation. This will lead crash when multiple threads are
sending packet into same tap queue in parallel. Solve this by
introducing a spinlock and use it to protect the page frag allocation.

Reported-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c | 35 ++++++++++++++++++++++-------------
 1 file changed, 22 insertions(+), 13 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 5892284..202b20d 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -176,6 +176,7 @@ struct tun_file {
 	struct tun_struct *detached;
 	struct skb_array tx_array;
 	struct page_frag alloc_frag;
+	spinlock_t lock;
 };
 
 struct tun_flow_entry {
@@ -1273,25 +1274,36 @@ static struct sk_buff *tun_build_skb(struct tun_struct *tun,
 				     int len, int *generic_xdp)
 {
 	struct page_frag *alloc_frag = &tfile->alloc_frag;
+	struct page *page;
 	struct sk_buff *skb;
 	struct bpf_prog *xdp_prog;
 	int buflen = SKB_DATA_ALIGN(len + TUN_RX_PAD) +
 		     SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 	unsigned int delta = 0;
+	size_t offset;
 	char *buf;
 	size_t copied;
 	bool xdp_xmit = false;
 	int err;
 
-	if (unlikely(!skb_page_frag_refill(buflen, alloc_frag, GFP_KERNEL)))
+	spin_lock(&tfile->lock);
+	if (unlikely(!skb_page_frag_refill(buflen, alloc_frag, GFP_KERNEL))) {
+		spin_unlock(&tfile->lock);
 		return ERR_PTR(-ENOMEM);
+	}
+
+	page = alloc_frag->page;
+	offset = alloc_frag->offset;
+	get_page(page);
+	buf = (char *)page_address(page) + offset;
+	alloc_frag->offset += buflen;
+	spin_unlock(&tfile->lock);
 
-	buf = (char *)page_address(alloc_frag->page) + alloc_frag->offset;
-	copied = copy_page_from_iter(alloc_frag->page,
-				     alloc_frag->offset + TUN_RX_PAD,
-				     len, from);
-	if (copied != len)
+	copied = copy_page_from_iter(page, offset + TUN_RX_PAD, len, from);
+	if (copied != len) {
+		put_page(page);
 		return ERR_PTR(-EFAULT);
+	}
 
 	if (hdr->gso_type)
 		*generic_xdp = 1;
@@ -1313,11 +1325,9 @@ static struct sk_buff *tun_build_skb(struct tun_struct *tun,
 
 		switch (act) {
 		case XDP_REDIRECT:
-			get_page(alloc_frag->page);
-			alloc_frag->offset += buflen;
 			err = xdp_do_redirect(tun->dev, &xdp, xdp_prog);
 			if (err)
-				goto err_redirect;
+				goto err_xdp;
 			return NULL;
 		case XDP_TX:
 			xdp_xmit = true;
@@ -1339,13 +1349,12 @@ static struct sk_buff *tun_build_skb(struct tun_struct *tun,
 	skb = build_skb(buf, buflen);
 	if (!skb) {
 		rcu_read_unlock();
+		put_page(page);
 		return ERR_PTR(-ENOMEM);
 	}
 
 	skb_reserve(skb, TUN_RX_PAD - delta);
 	skb_put(skb, len + delta);
-	get_page(alloc_frag->page);
-	alloc_frag->offset += buflen;
 
 	if (xdp_xmit) {
 		skb->dev = tun->dev;
@@ -1358,9 +1367,8 @@ static struct sk_buff *tun_build_skb(struct tun_struct *tun,
 
 	return skb;
 
-err_redirect:
-	put_page(alloc_frag->page);
 err_xdp:
+	put_page(page);
 	rcu_read_unlock();
 	this_cpu_inc(tun->pcpu_stats->rx_dropped);
 	return NULL;
@@ -2586,6 +2594,7 @@ static int tun_chr_open(struct inode *inode, struct file * file)
 	INIT_LIST_HEAD(&tfile->next);
 
 	sock_set_flag(&tfile->sk, SOCK_ZEROCOPY);
+	spin_lock_init(&tfile->lock);
 
 	return 0;
 }
-- 
2.7.4


--------------2397F0CFBC84A5FEBD698946--
