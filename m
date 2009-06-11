From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: virtio-net header alignment
Date: Thu, 11 Jun 2009 11:01:06 -0700
Message-ID: <1244743266.9669.64.camel@w-sridhar.beaverton.ibm.com>
References: <OF1B881599.F1B4A2EF-ON802575BB.0036EA40-802575BC.0041BFB5@au1.ibm.com>
	 <200905251601.29327.rusty@rustcorp.com.au> <1243268223.32745.25.camel@blaa>
	 <20090610051227.GB16563@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Danielius Kudinskas <kudinskas@uk.ibm.com>,
	aliguori@linux.vnet.ibm.com, Paul T Knowles <pablo@uk.ibm.com>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:48433 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755857AbZFKSBI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 14:01:08 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n5BHuL6E000701
	for <netdev@vger.kernel.org>; Thu, 11 Jun 2009 13:56:21 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5BI19jw245722
	for <netdev@vger.kernel.org>; Thu, 11 Jun 2009 14:01:10 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n5BI18CU011530
	for <netdev@vger.kernel.org>; Thu, 11 Jun 2009 14:01:09 -0400
In-Reply-To: <20090610051227.GB16563@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-06-10 at 15:12 +1000, Herbert Xu wrote:
> On Mon, May 25, 2009 at 05:17:03PM +0100, Mark McLoughlin wrote:
> > 
> > Perhaps; would padding struct virtio_net_hdr_mrg_rxbuf have avoided it?
> > 
> > Cc-ing Herbert, he initially wrote the guest side of this.
> 
> Does this fix it?
> 
> virtio_net: Fix IP alignment on mergeable RX path
> 
> We need to enforce the IP alignment on the mergeable RX path just
> like the other RX path.  Not doing so results in misaligned IP
> headers.

I think this fixes the old RX path rather than the mergeable RX path.
try_fill_recv_maxbufs() is called from try_fill_recv()

        if (!vi->mergeable_rx_bufs) {
                try_fill_recv_maxbufs(vi);
                return;
        }

-Sridhar

> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 4d1d479..52fba8e 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -283,10 +283,11 @@ static void try_fill_recv_maxbufs(struct virtnet_info *vi)
>  	for (;;) {
>  		struct virtio_net_hdr *hdr;
> 
> -		skb = netdev_alloc_skb(vi->dev, MAX_PACKET_LEN);
> +		skb = netdev_alloc_skb(vi->dev, MAX_PACKET_LEN + NET_IP_ALIGN);
>  		if (unlikely(!skb))
>  			break;
> 
> +		skb_reserve(skb, NET_IP_ALIGN);
>  		skb_put(skb, MAX_PACKET_LEN);
> 
>  		hdr = skb_vnet_hdr(skb);
> 
> Cheers,

