From: Jason Wang <jasowang@redhat.com>
Subject: Re: macvtap MAX_SKB_FRAGS fix...
Date: Tue, 06 Aug 2013 16:39:02 +0800
Message-ID: <5200B626.9030006@redhat.com>
References: <20130805.205104.295403081094571911.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090904000102060603040309"
Cc: netdev@vger.kernel.org, mst@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24304 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754675Ab3HFIjl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 04:39:41 -0400
In-Reply-To: <20130805.205104.295403081094571911.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090904000102060603040309
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On 08/06/2013 11:51 AM, David Miller wrote:
> Jason, I want to get that into v3.4.x -stable but it needs a backport
> and I'd rather someone like you who knows the code does it rather
> than I.
>
> The issue seems that be that the arguments to uarg->callback() were
> different back then.
>
> Thanks.

Sure.

For 3.4.x we need to pick c70aa540c7a9f67add11ad3161096fb95233aa2e
(vhost: zerocopy: poll vq in zerocopy callback) first to let the
backport work. The reason of different arguments is because 3.4.x does
not track DMA failure. So we can just do uarg->callback(uarg);

Please see the attached patches.

Thanks


--------------090904000102060603040309
Content-Type: text/x-patch;
 name="0001-vhost-zerocopy-poll-vq-in-zerocopy-callback.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-vhost-zerocopy-poll-vq-in-zerocopy-callback.patch"

>From 4bc54cb526fdc65a23cb8a112c0fa0fb7c9527ac Mon Sep 17 00:00:00 2001
From: Jason Wang <jasowang@redhat.com>
Date: Wed, 2 May 2012 11:42:54 +0800
Subject: [PATCH 1/2] vhost: zerocopy: poll vq in zerocopy callback

commit c70aa540c7a9f67add11ad3161096fb95233aa2e upstream.

We add used and signal guest in worker thread but did not poll the virtqueue
during the zero copy callback. This may lead the missing of adding and
signalling during zerocopy. Solve this by polling the virtqueue and let it
wakeup the worker during callback.

Signed-off-by: Jason Wang <jasowang@redhat.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/vhost.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 1a9e2a9..a50cb9c 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1603,6 +1603,7 @@ void vhost_zerocopy_callback(struct ubuf_info *ubuf)
 	struct vhost_ubuf_ref *ubufs = ubuf->ctx;
 	struct vhost_virtqueue *vq = ubufs->vq;
 
+	vhost_poll_queue(&vq->poll);
 	/* set len = 1 to mark this desc buffers done DMA */
 	vq->heads[ubuf->desc].len = VHOST_DMA_DONE_LEN;
 	kref_put(&ubufs->kref, vhost_zerocopy_done_signal);
-- 
1.7.1


--------------090904000102060603040309
Content-Type: text/x-patch;
 name="0002-macvtap-do-not-zerocopy-if-iov-needs-more-pages-than.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0002-macvtap-do-not-zerocopy-if-iov-needs-more-pages-than.pa";
 filename*1="tch"

>From 9839e0c9838ea70ad5ce634e6474a82110a14169 Mon Sep 17 00:00:00 2001
From: Jason Wang <jasowang@redhat.com>
Date: Thu, 18 Jul 2013 10:55:16 +0800
Subject: [PATCH 2/2] macvtap: do not zerocopy if iov needs more pages than MAX_SKB_FRAGS

commit ece793fcfc417b3925844be88a6a6dc82ae8f7c6 upstream.

We try to linearize part of the skb when the number of iov is greater than
MAX_SKB_FRAGS. This is not enough since each single vector may occupy more than
one pages, so zerocopy_sg_fromiovec() may still fail and may break the guest
network.

Solve this problem by calculate the pages needed for iov before trying to do
zerocopy and switch to use copy instead of zerocopy if it needs more than
MAX_SKB_FRAGS.

This is done through introducing a new helper to count the pages for iov, and
call uarg->callback() manually when switching from zerocopy to copy to notify
vhost.

We can do further optimization on top.

This bug were introduced from b92946e2919134ebe2a4083e4302236295ea2a73
(macvtap: zerocopy: validate vectors before building skb).

Cc: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c |   62 +++++++++++++++++++++++++++++-------------------
 1 files changed, 37 insertions(+), 25 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 5151f06..77ce8b2 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -642,6 +642,28 @@ static int macvtap_skb_to_vnet_hdr(const struct sk_buff *skb,
 	return 0;
 }
 
+static unsigned long iov_pages(const struct iovec *iv, int offset,
+			       unsigned long nr_segs)
+{
+	unsigned long seg, base;
+	int pages = 0, len, size;
+
+	while (nr_segs && (offset >= iv->iov_len)) {
+		offset -= iv->iov_len;
+		++iv;
+		--nr_segs;
+	}
+
+	for (seg = 0; seg < nr_segs; seg++) {
+		base = (unsigned long)iv[seg].iov_base + offset;
+		len = iv[seg].iov_len - offset;
+		size = ((base & ~PAGE_MASK) + len + ~PAGE_MASK) >> PAGE_SHIFT;
+		pages += size;
+		offset = 0;
+	}
+
+	return pages;
+}
 
 /* Get packet from user space buffer */
 static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
@@ -688,31 +710,15 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 	if (unlikely(count > UIO_MAXIOV))
 		goto err;
 
-	if (m && m->msg_control && sock_flag(&q->sk, SOCK_ZEROCOPY))
-		zerocopy = true;
-
-	if (zerocopy) {
-		/* Userspace may produce vectors with count greater than
-		 * MAX_SKB_FRAGS, so we need to linearize parts of the skb
-		 * to let the rest of data to be fit in the frags.
-		 */
-		if (count > MAX_SKB_FRAGS) {
-			copylen = iov_length(iv, count - MAX_SKB_FRAGS);
-			if (copylen < vnet_hdr_len)
-				copylen = 0;
-			else
-				copylen -= vnet_hdr_len;
-		}
-		/* There are 256 bytes to be copied in skb, so there is enough
-		 * room for skb expand head in case it is used.
-		 * The rest buffer is mapped from userspace.
-		 */
-		if (copylen < vnet_hdr.hdr_len)
-			copylen = vnet_hdr.hdr_len;
-		if (!copylen)
-			copylen = GOODCOPY_LEN;
+	if (m && m->msg_control && sock_flag(&q->sk, SOCK_ZEROCOPY)) {
+		copylen = vnet_hdr.hdr_len ? vnet_hdr.hdr_len : GOODCOPY_LEN;
 		linear = copylen;
-	} else {
+		if (iov_pages(iv, vnet_hdr_len + copylen, count)
+		    <= MAX_SKB_FRAGS)
+			zerocopy = true;
+	}
+
+	if (!zerocopy) {
 		copylen = len;
 		linear = vnet_hdr.hdr_len;
 	}
@@ -724,9 +730,15 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 
 	if (zerocopy)
 		err = zerocopy_sg_from_iovec(skb, iv, vnet_hdr_len, count);
-	else
+	else {
 		err = skb_copy_datagram_from_iovec(skb, 0, iv, vnet_hdr_len,
 						   len);
+		if (!err && m && m->msg_control) {
+			struct ubuf_info *uarg = m->msg_control;
+			uarg->callback(uarg);
+		}
+	}
+
 	if (err)
 		goto err_kfree;
 
-- 
1.7.1


--------------090904000102060603040309--
