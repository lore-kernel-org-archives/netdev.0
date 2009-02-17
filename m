From: Karl Hiramoto <karl@hiramoto.org>
Subject: Re: problem with IPoA (CLIP),  NAT, and VLANS
Date: Tue, 17 Feb 2009 12:49:07 +0100
Message-ID: <499AA433.8070308@hiramoto.org>
References: <20090216232016.GA4803@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <20090216232016.GA4803@ami.dom.local>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> Karl Hiramoto wrote, On 02/16/2009 04:02 PM:
> ...
>   
>> The problem ended up being the packet being corrupted when the vlan tag
>> was being added and skb_cow_head()  was being called.
>>
>> Anyone know why skb_cow_head() would corrupt the packet?  Perhaps it was
>> not allocated correctly?     I'm using a big-endian ARM IXP435 board.
>>     
>
> Hi,
> Very nice debugging, but I think your patch doesn't look like enough:
> 1) it skips copy for cloned skbs,
> 2) this skb_cow_head() is needed anyway, sometimes.
> So the real bug should be found in skb_cow_head() or elsewhere.
>
> I attach here 2 patches for testing:
> 2) an extention of your patch but with pskb_expand_head() called for
>    one to one copy.
>
>
>  include/linux/if_vlan.h |   13 ++++++++++---
>  1 files changed, 10 insertions(+), 3 deletions(-)
>
> diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
> index f8ff918..e9a5eb1 100644
> --- a/include/linux/if_vlan.h
> +++ b/include/linux/if_vlan.h
> @@ -202,9 +202,16 @@ static inline struct sk_buff *__vlan_put_tag(struct sk_buff *skb, u16 vlan_tci)
>  {
>  	struct vlan_ethhdr *veth;
>  
> -	if (skb_cow_head(skb, VLAN_HLEN) < 0) {
> -		kfree_skb(skb);
> -		return NULL;
> +	if (skb_headroom(skb) < VLAN_HLEN) {
> +		if (skb_cow_head(skb, VLAN_HLEN) < 0) {
> +			kfree_skb(skb);
> +			return NULL;
> +		}
> +	} else {
> +		if (pskb_expand_head(skb, 0, 0, GFP_ATOMIC) < 0) {
> +			kfree_skb(skb);
> +			return NULL;
> +		}
>  	}
>  	veth = (struct vlan_ethhdr *)skb_push(skb, VLAN_HLEN);
>  
>   


This breaks IPoA -> NAT -->VLAN for me.  Before, with a virgin 2.6.28.4 
I had no traffic.  With this patch,  what was a 50ms ping, jumps to
1050ms  and randomly there are duplicate packets.

What Patrick,  said may be the case,  that the underlaying atm driver is
not specifying the headroom.   The driver is ported to 2.6.28 from
2.6.11 based on the BSD licensed intel libaries:
http://www.intel.com/design/network/products/npfamily/download_ixp400.htm

Where underneath a bunch of layers the skb is allocated with kmalloc like:

size = PAGE_ALIGN (size + CACHE_LINE_SIZE);
order = get_order (size);
page = alloc_pages (GFP_KERNEL, order);


Why though does the same driver work with IPoE  Bridged ATM   RFC2684  ?


The other module in use is CLIP  net/atm/clip.c      I don't have any
other hardware though to test the CLIP driver with though.


A side note:  so far the original patch i sent works in all cases i have
tested, but fails with tcpdump.   I suspect its because the skb gets cloned.

Thanks,


Karl.

