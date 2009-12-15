From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with
 vhost-net
Date: Tue, 15 Dec 2009 08:26:20 -0800
Message-ID: <1260894380.16865.13.camel@w-sridhar.beaverton.ibm.com>
References: <1260312605.19229.8.camel@w-sridhar.beaverton.ibm.com>
	 <20091213122512.GA17255@gondor.apana.org.au>
	 <20091213234055.GA28340@redhat.com>
	 <20091215144252.GA7465@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, rusty@rustcorp.com.au,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:49953 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760531AbZLOQ0f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Dec 2009 11:26:35 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e8.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id nBFGLTQG006186
	for <netdev@vger.kernel.org>; Tue, 15 Dec 2009 11:21:29 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBFGQYHT125278
	for <netdev@vger.kernel.org>; Tue, 15 Dec 2009 11:26:34 -0500
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBFGQLji003071
	for <netdev@vger.kernel.org>; Tue, 15 Dec 2009 09:26:22 -0700
In-Reply-To: <20091215144252.GA7465@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-12-15 at 22:42 +0800, Herbert Xu wrote:
> On Mon, Dec 14, 2009 at 01:40:55AM +0200, Michael S. Tsirkin wrote:
> >
> > An interesting thing is that
> > 48925e372f04f5e35fec6269127c62b2c71ab794
> > was supposed to do this already.
> 
> But Rusty missed the queue wake call.  That too needs to check
> that the required amount of space exists.

Yes. I noticied that. skb_xmit_done() doesn't check for MAX_SKB_FRAGS+2
descriptors before doing a netif_wake_queue(). We don't have any easy way 
to get the number of free desciptors in the virtqueue and we may need a 
vring_get_num_free() interface.

Also, can we do free_old_xmit_skbs() to freeup any used descriptors in
the callback(skb_xmit_done) context? I tried this, but hit a panic in
free_old_xmit_skbs(__skb_unlink() trying to remove the skb from the vi->send queue).
Looks like we need to add the skb to the vi->send queue before doing a kick.

Thanks
Sridhar

