From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv7] add mergeable buffers support to vhost_net
Date: Mon, 10 May 2010 20:31:50 +0300
Message-ID: <20100510173149.GE28798@redhat.com>
References: <1272488232.11307.4.camel@w-dls.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.osdl.org
To: David L Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56519 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751844Ab0EJRfv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 May 2010 13:35:51 -0400
Content-Disposition: inline
In-Reply-To: <1272488232.11307.4.camel@w-dls.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 28, 2010 at 01:57:12PM -0700, David L Stevens wrote:
> @@ -218,18 +248,19 @@ static void handle_rx(struct vhost_net *
>  	use_mm(net->dev.mm);
>  	mutex_lock(&vq->mutex);
>  	vhost_disable_notify(vq);
> -	hdr_size = vq->hdr_size;
> +	vhost_hlen = vq->vhost_hlen;
>  
>  	vq_log = unlikely(vhost_has_feature(&net->dev, VHOST_F_LOG_ALL)) ?
>  		vq->log : NULL;
>  
> -	for (;;) {
> -		head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
> -					 ARRAY_SIZE(vq->iov),
> -					 &out, &in,
> -					 vq_log, &log);
> +	while ((datalen = vhost_head_len(vq, sock->sk))) {
> +		headcount = vhost_get_desc_n(vq, vq->heads,
> +					     datalen + vhost_hlen,
> +					     &in, vq_log, &log);
> +		if (headcount < 0)
> +			break;
>  		/* OK, now we need to know about added descriptors. */
> -		if (head == vq->num) {
> +		if (!headcount) {
>  			if (unlikely(vhost_enable_notify(vq))) {
>  				/* They have slipped one in as we were
>  				 * doing that: check again. */


So I think this breaks handling for a failure mode where
we get an skb that is larger than the max packet guest
can get. The right thing to do in this case is to
drop the skb, we currently do this by passing
truncate flag to recvmsg.

In particular, with mergeable buffers off, if we get an skb
that does not fit in a single packet, this code will
spread it over multiple buffers.

You should be able to reproduce this fairly easily
by disabling both indirect buffers and mergeable buffers
on qemu command line. With current code TCP still
works by falling back on small packets. I think
with your code it will get stuck forever once
we get an skb that is too large for us to handle.

-- 
MST


