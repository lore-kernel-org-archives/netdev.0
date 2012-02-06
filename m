From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next] gro: introduce gro_mac_header_len
Date: Mon, 6 Feb 2012 18:44:03 +0200
Message-ID: <4F300353.2080705@mellanox.com>
References: <1328541706.2220.50.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <4F2FF050.7040400@mellanox.com> <1328545627.2220.72.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20120206.113145.1284864994961472499.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<herbert-F6s6mLieUQo7FNHlEwC/lvQIK84fMopw@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120206.113145.1284864994961472499.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2/6/2012 6:31 PM, David Miller wrote:
> We really need an explanation, probably both in the commit message and 
> the comments next to this new struct member, explaining why in the 
> world we can't use ->hard_header_len for this. 

Dave,

As I wrote earlier on this thread, the reason is that in order to be 
able to xmit skb's for which the stack doesn't provide a neighbour, 
IPoIB makes sure to have extra INFINIBAND_ALEN bytes headroom on skbs. 
Such that the ipoib hard_header functions writes a "ipoib_pseudoheader" 
(= hw address) on the skb and the xmit function grabs it from there and 
use that pseudoheader to search for the actual IB L2 address handle kept 
for that dest. Example such skbs are unicast ARP replies and multicast. 
see below some relevant code sections from ipoib_main.c

Or.

> static void ipoib_setup(struct net_device *dev)
> [...]
>         /*
>          * We add in INFINIBAND_ALEN to allow for the destination
>          * address "pseudoheader" for skbs without neighbour struct.
>          */
>         dev->hard_header_len     = IPOIB_ENCAP_LEN + INFINIBAND_ALEN;
>         dev->addr_len            = INFINIBAND_ALEN;
>         dev->type                = ARPHRD_INFINIBAND;


> static int ipoib_hard_header(struct sk_buff *skb,
>                              struct net_device *dev,
>                              unsigned short type,
>                              const void *daddr, const void *saddr, 
> unsigned len)
>         [...]
>         /*
>          * If we don't have a neighbour structure, stuff the
>          * destination address onto the front of the skb so we can
>          * figure out where to send the packet later.
>          */
>


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
