From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [net-next PATCH 1/5] etherdevice: Add function for handling padding
 frame to ETH_ZLEN
Date: Tue, 25 Nov 2014 16:56:05 -0800
Message-ID: <54752525.4040509@gmail.com>
References: <20141125223727.1867.43890.stgit@ahduyck-vm-fedora20> <20141125224400.1867.48907.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:46914 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750975AbaKZA4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 19:56:07 -0500
Received: by mail-pd0-f173.google.com with SMTP id ft15so1655634pdb.4
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 16:56:07 -0800 (PST)
In-Reply-To: <20141125224400.1867.48907.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/11/14 14:44, Alexander Duyck wrote:
> This patch adds a simple function for padding a frame up to the minimum
> size for for Ethernet.  The motivation behind it is that there are a number
> of implementations throughout the network device drivers that are all doing
> the same thing, but each a little bit differently and as a result several
> implementations contain bugs such as updating the length without updating
> the tail offset and other similar issues.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> ---
>  include/linux/etherdevice.h |   21 +++++++++++++++++++++
>  1 file changed, 21 insertions(+)
> 
> diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
> index 733980f..7e436f3 100644
> --- a/include/linux/etherdevice.h
> +++ b/include/linux/etherdevice.h
> @@ -392,4 +392,25 @@ static inline unsigned long compare_ether_header(const void *a, const void *b)
>  #endif
>  }
>  
> +/**
> + * eth_skb_pad - Pad buffer to mininum number of octets for Ethernet frame
> + * @skb: Buffer to pad
> + *
> + * An Ethernet frame should have a minimum size of 60 bytes.  This function
> + * takes short frames and pads them with zeros up to the 60 byte limit.

minimum size without FCS

> + */
> +static inline int eth_skb_pad(struct sk_buff *skb)
> +{
> +	unsigned int size = skb->len;
> +
> +	if (unlikely(size < ETH_ZLEN)) {
> +		size = ETH_ZLEN - size;
> +		if (skb_pad(skb, size))
> +			return -ENOMEM;
> +		__skb_put(skb, size);
> +	}

most drivers call skb_padto(skb, ETH_ZLEN), besides the extra
__skb_put() here, this is not different.

> +
> +	return 0;
> +}
> +
>  #endif	/* _LINUX_ETHERDEVICE_H */
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
