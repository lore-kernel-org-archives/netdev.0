From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: RE: [PATCH net-next 8/9] ipvlan: improve compiler hints
Date: Thu, 27 Apr 2017 15:21:16 +0000
Message-ID: <B1C1DF2ACD01FD4881736AA51731BAB2B2EFB2@ORSMSX107.amr.corp.intel.com>
References: <20170427145142.15830-1-marco.chiappero@intel.com>
 <20170427145142.15830-9-marco.chiappero@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David S . Miller" <davem@davemloft.net>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "Grandhi, Sainath" <sainath.grandhi@intel.com>,
        Mahesh Bandewar <maheshb@google.com>
To: "Chiappero, Marco" <marco.chiappero@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:2004 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752900AbdD0PVR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 11:21:17 -0400
In-Reply-To: <20170427145142.15830-9-marco.chiappero@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Chiappero, Marco
> Sent: Thursday, April 27, 2017 7:52 AM
> To: netdev@vger.kernel.org
> Cc: David S . Miller <davem@davemloft.net>; Kirsher, Jeffrey T
> <jeffrey.t.kirsher@intel.com>; Duyck, Alexander H
> <alexander.h.duyck@intel.com>; Grandhi, Sainath
> <sainath.grandhi@intel.com>; Mahesh Bandewar <maheshb@google.com>;
> Chiappero, Marco <marco.chiappero@intel.com>
> Subject: [PATCH net-next 8/9] ipvlan: improve compiler hints
> 
> Extend inlining and branch prediction hints.
> 
> Signed-off-by: Marco Chiappero <marco.chiappero@intel.com>
> ---
>  drivers/net/ipvlan/ipvlan_core.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
> index a9fc1b5..67e342d 100644
> --- a/drivers/net/ipvlan/ipvlan_core.c
> +++ b/drivers/net/ipvlan/ipvlan_core.c
> @@ -88,7 +88,7 @@ void ipvlan_ht_addr_del(struct ipvl_addr *addr)
>  	hlist_del_init_rcu(&addr->hlnode);
>  }
> 
> -unsigned int ipvlan_mac_hash(const unsigned char *addr)
> +inline unsigned int ipvlan_mac_hash(const unsigned char *addr)
>  {
>  	u32 hash = jhash_1word(__get_unaligned_cpu32(addr + 2),
>  			       ipvlan_jhash_secret);

I'm kind of surprised this isn't causing a problem with differing declarations between the declaration here and the declaration in ipvlan.h. Normally for inlining something like this you would change it to a "static inline" and move the entire declaration into the header file.

> @@ -505,7 +505,7 @@ static int ipvlan_xmit_mode_l2(struct sk_buff *skb,
> struct net_device *dev)
>  			return ipvlan_rcv_int_frame(addr, &skb);
> 
>  		skb = skb_share_check(skb, GFP_ATOMIC);
> -		if (!skb)
> +		if (unlikely(!skb))
>  			return NET_XMIT_DROP;
> 
>  		/* Packet definitely does not belong to any of the @@ -596,7
> +596,7 @@ static rx_handler_result_t ipvlan_handle_mode_l2(struct sk_buff
> **pskb,
>  			 * when work-queue processes this frame. This is
>  			 * achieved by returning RX_HANDLER_PASS.
>  			 */
> -			if (nskb)
> +			if (likely(nskb))
>  				ipvlan_multicast_enqueue(port, nskb, false);
>  		}
>  	} else {
> --
> 2.9.3
