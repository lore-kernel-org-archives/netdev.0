From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 2/2] ipv4: Restart rt_intern_hash after emergency rebuild
Date: Wed, 24 Mar 2010 16:21:54 -0400
Message-ID: <20100324195725.GC29364@hmsreliant.think-freely.org>
References: <4BAA4F3F.70703@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58141 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756620Ab0CXUV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 16:21:59 -0400
Content-Disposition: inline
In-Reply-To: <4BAA4F3F.70703@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 24, 2010 at 08:43:27PM +0300, Pavel Emelyanov wrote:
> The the rebuild changes the genid which in turn is used at the
> hash calculation. Thus if we don't restart and go on with the
> inserting the rt will happen in wrong chain.
> 
> This doesn't seem critical to me, since the proper rt entry will 
> be hashed at next skb.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> ---
>  net/ipv4/route.c |   18 ++++++++++++------
>  1 files changed, 12 insertions(+), 6 deletions(-)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 28c1c2f..bbce53e 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1097,7 +1097,7 @@ static int slow_chain_length(const struct rtable *head)
>  }
>  
>  static int rt_intern_hash(unsigned hash, struct rtable *rt,
> -			  struct rtable **rp, struct sk_buff *skb)
> +			  struct rtable **rp, struct sk_buff *skb, int in)
>  {
>  	struct rtable	*rth, **rthp;
>  	unsigned long	now;
> @@ -1217,6 +1217,12 @@ restart:
>  					rt->u.dst.dev->name, num);
>  			}
>  			rt_emergency_hash_rebuild(net);
> +			spin_unlock_bh(rt_hash_lock_addr(hash));
> +
> +			hash = rt_hash(rt->fl.fl4_dst, rt->fl.fl4_src,
> +					in ? rt->fl.iif : rt->fl.oif,
> +					rt_genid(net));
> +			goto restart;
>  		}
>  	}
Why pass in a flag here?  Perhaps it would be easier just to pass in the ifindex
that was origionally used by the caller of rt_intern_hash so that the hash could
be redone without needing to toggle on the value of the flag.  

Regards
Neil

> 
