From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] tun: fix BUG with large packets without TUN_VNET_HDR
Date: Fri, 17 Apr 2009 00:05:29 +0300
Message-ID: <20090416210528.GA5894@dhcp-1-124.tlv.redhat.com>
References: <20090416204556.GA5846@dhcp-1-124.tlv.redhat.com> <20090416135652.57afec63@nehalam>
Reply-To: "Michael S. Tsirkin" <m.s.tsirkin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mst@redhat.com, Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	Max Krasnyansky <maxk@qualcomm.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:45577 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756912AbZDPVGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 17:06:39 -0400
Received: by fg-out-1718.google.com with SMTP id e12so198174fga.17
        for <netdev@vger.kernel.org>; Thu, 16 Apr 2009 14:06:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090416135652.57afec63@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 16, 2009 at 01:56:52PM -0700, Stephen Hemminger wrote:
> On Thu, 16 Apr 2009 23:45:57 +0300
> "Michael S. Tsirkin" <mst@redhat.com> wrote:
> 
> > On a tap device, the linear part of skb must be at least ETH_HLEN,
> > otherwise eth_type_trans triggers BUG_ON in skb_pull(skb, ETH_HLEN).
> > This patch makes sure the linear part is always large enough.
> > 
> > Without the patch, tun sets the linear part size to 0 if TUN_VNET_HDR
> > is not set and the packet is too large to put in a linear skb,
> > which causes BUGs for me.
> > 
> > BTW, it seems that this behaviour has been there for a long while, since at
> > least v2.6.27 (commit f42157cb568c1eb02eca7df4da67553a9edae24a: tun: fallback
> > if skb_alloc() fails on big packets), but started triggering for me only in
> > v2.6.30-rc1, because of commit 33dccbb050bbe35b88ca8cf1228dcf3e4d4b3554 (tun:
> > Limit amount of queued packets per device), which made all large packets
> > non-linear.  Before that, most packets would still typically be linear until
> > memory gets fragmented, which hides the issue.
> > 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > ---
> 
> Why not just use pskb_may_pull?
> 
> --- a/drivers/net/tun.c	2009-04-16 13:52:00.178013518 -0700
> +++ b/drivers/net/tun.c	2009-04-16 13:55:47.227752328 -0700
> @@ -595,6 +595,9 @@ static __inline__ ssize_t tun_get_user(s
>  
>  	switch (tun->flags & TUN_TYPE_MASK) {
>  	case TUN_TUN_DEV:
> +		if (!pskb_may_pull(skb, 1))
> +			goto drop;
> +
>  		if (tun->flags & TUN_NO_PI) {
>  			switch (skb->data[0] & 0xf0) {
>  			case 0x40:
> @@ -604,6 +607,7 @@ static __inline__ ssize_t tun_get_user(s
>  				pi.proto = htons(ETH_P_IPV6);
>  				break;
>  			default:
> +			drop:
>  				tun->dev->stats.rx_dropped++;
>  				kfree_skb(skb);
>  				return -EINVAL;
> @@ -615,6 +619,9 @@ static __inline__ ssize_t tun_get_user(s
>  		skb->dev = tun->dev;
>  		break;
>  	case TUN_TAP_DEV:
> +		if (!pskb_may_pull(skb, ETH_HLEN))
> +			goto drop;
> +
>  		skb->protocol = eth_type_trans(skb, tun->dev);
>  		break;
>  	};

It seems that this would drop all packets which are larger than 1 page
if the device has TUN_VNET_HDR off. No? What am I missing?
-- 
MST
