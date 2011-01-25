From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pch_gbe: Fix the issue that the receiving data is not
 normal.
Date: Tue, 25 Jan 2011 13:32:40 -0800 (PST)
Message-ID: <20110125.133240.59688304.davem@davemloft.net>
References: <4D3D0373.30003@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	qi.wang@intel.com, yong.y.wang@intel.com,
	andrew.chih.howe.khor@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com
To: toshiharu-linux@dsn.okisemi.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D3D0373.30003@dsn.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
Date: Mon, 24 Jan 2011 13:43:31 +0900

> This PCH_GBE driver had an issue that the receiving data is not normal.
> This driver had not removed correctly the padding data 
> which the DMA include in receiving data. 
> 
> This patch fixed this issue.
> 
> Signed-off-by: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>

There are bugs in these changes:

>  			if (skb_copy_flag) {	/* recycle  skb */
>  				struct sk_buff *new_skb;
>  				new_skb =
> -				    netdev_alloc_skb(netdev,
> -						     length + NET_IP_ALIGN);
> +				    netdev_alloc_skb(netdev, length);
>  				if (new_skb) {
>  					if (!skb_padding_flag) {
>  						skb_reserve(new_skb,
> -								NET_IP_ALIGN);
> +							PCH_GBE_DMA_PADDING);
>  					}
>  					memcpy(new_skb->data, skb->data,
>  						length);

If "!skb_padding_flag" then you will write past the end of the SKB
data in that memcpy.

You cannot allocate only "length" then proceed to reserve PCH_GBE_DMA_PADDING
and then add "length" worth of data on top of that.  In such a cause you
must allocate at least "length + PCH_GBE_DMA_PADDING".

Furthermore you _MUST_ respect NET_IP_ALIGN.  Some platforms set this value
to "0", because otherwise performance suffers greatly.

There are two seperate issues, removing the padding bytes provided by
the device, and aligning the IP headers as wanted by the cpu
architecutre.  Therefore they should be handled seperately, and we
therefore should still see references to NET_IP_ALIGN in your patch.
