From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 0/3] tun: fix aio
Date: Mon, 20 Apr 2009 15:21:38 +0300
Message-ID: <20090420122137.GA6768@dhcp-1-124.tlv.redhat.com>
References: <20090420112527.GA6692@dhcp-1-124.tlv.redhat.com> <20090420120930.GA4941@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, rusty@rustcorp.com.au
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:39569 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755073AbZDTMWu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2009 08:22:50 -0400
Content-Disposition: inline
In-Reply-To: <20090420120930.GA4941@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 20, 2009 at 08:09:30PM +0800, Herbert Xu wrote:
> Michael S. Tsirkin <mst@redhat.com> wrote:
> >
> > Note: I started out just allocating and copying the iovec rather than adding
> > yet another skb-iterating routine, but this turned out to add small but
> > measurable overhead on data path: tx time per packet jumped from 6500 to 6700 ns
> > (let me know if you want to see that version of the patch).
> 
> Can you please post the copying version as well so we can compare?

Sure. Here it is: much smaller, but slightly slower.

	tun: fix aio read/aio write

	tun device uses skb_copy_datagram_from_iovec for write
	and memcpy_to_iovec for read, which modify the iovec,
	violating the contract for aio_read/aio_write which
	get const iovec * and are assumed not to modify it.
	As a result, attempts to perform io_submut on tap device
	fail with -EINVAL.

	A simple fix for this is to copy the iovec and work on a copy.

	Signed-off-by: Michael S. Tsirkin <m.s.tsirkin@gmail.com>

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 16716ae..9059738 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -657,11 +657,12 @@ static __inline__ ssize_t tun_get_user(struct tun_struct *tun,
 	return count;
 }
 
-static ssize_t tun_chr_aio_write(struct kiocb *iocb, const struct iovec *iv,
+static ssize_t tun_chr_aio_write(struct kiocb *iocb, const struct iovec *uiv,
 			      unsigned long count, loff_t pos)
 {
 	struct file *file = iocb->ki_filp;
 	struct tun_struct *tun = tun_get(file);
+	struct iovec *iv;
 	ssize_t result;
 
 	if (!tun)
@@ -669,9 +670,17 @@ static ssize_t tun_chr_aio_write(struct kiocb *iocb, const struct iovec *iv,
 
 	DBG(KERN_INFO "%s: tun_chr_write %ld\n", tun->dev->name, count);
 
-	result = tun_get_user(tun, (struct iovec *)iv, iov_length(iv, count),
-			      file->f_flags & O_NONBLOCK);
+ 	iv = kmalloc(count * sizeof *iv, GFP_KERNEL);
+	if (!iv) {
+		result = -ENOMEM;
+		goto out;
+	}
+	memcpy(iv, uiv, count * sizeof *iv);
 
+	result = tun_get_user(tun, iv, iov_length(iv, count),
+			      file->f_flags & O_NONBLOCK);
+	kfree(iv);
+out:
 	tun_put(tun);
 	return result;
 }
@@ -679,7 +688,8 @@ static ssize_t tun_chr_aio_write(struct kiocb *iocb, const struct iovec *iv,
 /* Put packet to the user space buffer */
 static __inline__ ssize_t tun_put_user(struct tun_struct *tun,
 				       struct sk_buff *skb,
-				       struct iovec *iv, int len)
+				       struct iovec *iv,
+				       ssize_t len)
 {
 	struct tun_pi pi = { 0, skb->protocol };
 	ssize_t total = 0;
@@ -742,7 +752,7 @@ static __inline__ ssize_t tun_put_user(struct tun_struct *tun,
 	return total;
 }
 
-static ssize_t tun_chr_aio_read(struct kiocb *iocb, const struct iovec *iv,
+static ssize_t tun_chr_aio_read(struct kiocb *iocb, const struct iovec *uiv,
 			    unsigned long count, loff_t pos)
 {
 	struct file *file = iocb->ki_filp;
@@ -751,17 +761,24 @@ static ssize_t tun_chr_aio_read(struct kiocb *iocb, const struct iovec *iv,
 	DECLARE_WAITQUEUE(wait, current);
 	struct sk_buff *skb;
 	ssize_t len, ret = 0;
+	struct iovec *iv;
 
 	if (!tun)
 		return -EBADFD;
 
 	DBG(KERN_INFO "%s: tun_chr_read\n", tun->dev->name);
 
-	len = iov_length(iv, count);
+	len = iov_length(uiv, count);
 	if (len < 0) {
 		ret = -EINVAL;
 		goto out;
 	}
+	iv = kmalloc(count * sizeof *iv, GFP_KERNEL);
+	if (!iv) {
+		ret = -ENOMEM;
+		goto out;
+	}
+	memcpy(iv, uiv, count * sizeof *iv);
 
 	add_wait_queue(&tfile->read_wait, &wait);
 	while (len) {
@@ -788,14 +805,14 @@ static ssize_t tun_chr_aio_read(struct kiocb *iocb, const struct iovec *iv,
 		}
 		netif_wake_queue(tun->dev);
 
-		ret = tun_put_user(tun, skb, (struct iovec *) iv, len);
+		ret = tun_put_user(tun, skb, iv, len);
 		kfree_skb(skb);
 		break;
 	}
 
 	current->state = TASK_RUNNING;
 	remove_wait_queue(&tfile->read_wait, &wait);
-
+	kfree(iv);
 out:
 	tun_put(tun);
 	return ret;
