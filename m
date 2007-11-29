From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: ZD1211RW unaligned accesses...
Date: Thu, 29 Nov 2007 16:45:33 -0500
Message-ID: <20071129214533.GD32730@tuxdriver.com>
References: <20071120.040546.222294375.davem@davemloft.net> <47442BFC.8090008@hotmail.com> <20071124150216.GA28153@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	Shaddy Baddah <shaddy_baddah@hotmail.com>,
	David Miller <davem@davemloft.net>, dsd@gentoo.org,
	kune@deine-taler.de
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4152 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757600AbXK2VqT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2007 16:46:19 -0500
Content-Disposition: inline
In-Reply-To: <20071124150216.GA28153@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

So, did the patch below fix the problem?  Should I apply it?

John

On Sat, Nov 24, 2007 at 11:02:16PM +0800, Herbert Xu wrote:
> On Wed, Nov 21, 2007 at 01:00:44PM +0000, Shaddy Baddah wrote:
> >
> > It hasn't seemed to. I patched the source (confirming the patched lines 
> > are in), compiled, installed and rebooted to effect the changes. My 
> > zd1211rw modules timestamp indicates that I have an updated module:
> 
> Thanks for your quick response and sorry for my late answer :)
> 
> I think Dave's patch is definietly on the right track but there
> are subsequent unaligned accesses of a similar kind which is
> why it still appears to be broken if you look at the kernel
> messages.
> 
> But there is definitely progress because those addresses are now
> bigger (0x394/0x39c/0x3a8 vs. 0x2** earlier).
> 
> So please try the following patch (instead of the original one)
> which should fix all the unailgned accesses in do_rx.
> 
> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --
> diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
> index a903645..d06b05b 100644
> --- a/drivers/net/wireless/zd1211rw/zd_mac.c
> +++ b/drivers/net/wireless/zd1211rw/zd_mac.c
> @@ -1166,15 +1166,16 @@ static void do_rx(unsigned long mac_ptr)
>  int zd_mac_rx_irq(struct zd_mac *mac, const u8 *buffer, unsigned int length)
>  {
>  	struct sk_buff *skb;
> +	unsigned int hlen = ALIGN(sizeof(struct zd_rt_hdr), 16);
>  
> -	skb = dev_alloc_skb(sizeof(struct zd_rt_hdr) + length);
> +	skb = dev_alloc_skb(hlen + length);
>  	if (!skb) {
>  		struct ieee80211_device *ieee = zd_mac_to_ieee80211(mac);
>  		dev_warn(zd_mac_dev(mac), "Could not allocate skb.\n");
>  		ieee->stats.rx_dropped++;
>  		return -ENOMEM;
>  	}
> -	skb_reserve(skb, sizeof(struct zd_rt_hdr));
> +	skb_reserve(skb, hlen - ZD_PLCP_HEADER_SIZE);
>  	memcpy(__skb_put(skb, length), buffer, length);
>  	skb_queue_tail(&mac->rx_queue, skb);
>  	tasklet_schedule(&mac->rx_tasklet);
> -
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
John W. Linville
linville@tuxdriver.com
