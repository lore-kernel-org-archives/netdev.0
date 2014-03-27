From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net 2/2] bridge: Fix handling stacked vlan tags
Date: Thu, 27 Mar 2014 17:35:24 -0400
Message-ID: <5334999C.1040608@redhat.com>
References: <1395924416-12325-1-git-send-email-makita.toshiaki@lab.ntt.co.jp> <1395924416-12325-2-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	"David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48860 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755441AbaC0Vf3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2014 17:35:29 -0400
In-Reply-To: <1395924416-12325-2-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/27/2014 08:46 AM, Toshiaki Makita wrote:
> If a bridge with vlan_filtering enabled receives frames with stacked
> vlan tags, i.e., they have two vlan tags, br_vlan_untag() strips not
> only the outer tag but also the inner tag.
> 
> br_vlan_untag() is called only from br_handle_vlan(), and in this case,
> it is enough to set skb->vlan_tci to 0 here, because vlan_tci has already
> been set before calling br_handle_vlan().
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

Acked-by: Vlad Yasevich <vyasevic@redhat.com>

-vlad

> ---
>  net/bridge/br_vlan.c | 18 +-----------------
>  1 file changed, 1 insertion(+), 17 deletions(-)
> 
> diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
> index 44f31af..c77eed5 100644
> --- a/net/bridge/br_vlan.c
> +++ b/net/bridge/br_vlan.c
> @@ -119,22 +119,6 @@ static void __vlan_flush(struct net_port_vlans *v)
>  	kfree_rcu(v, rcu);
>  }
>  
> -/* Strip the tag from the packet.  Will return skb with tci set 0.  */
> -static struct sk_buff *br_vlan_untag(struct sk_buff *skb)
> -{
> -	if (skb->protocol != htons(ETH_P_8021Q)) {
> -		skb->vlan_tci = 0;
> -		return skb;
> -	}
> -
> -	skb->vlan_tci = 0;
> -	skb = vlan_untag(skb);
> -	if (skb)
> -		skb->vlan_tci = 0;
> -
> -	return skb;
> -}
> -
>  struct sk_buff *br_handle_vlan(struct net_bridge *br,
>  			       const struct net_port_vlans *pv,
>  			       struct sk_buff *skb)
> @@ -150,7 +134,7 @@ struct sk_buff *br_handle_vlan(struct net_bridge *br,
>  	 */
>  	br_vlan_get_tag(skb, &vid);
>  	if (test_bit(vid, pv->untagged_bitmap))
> -		skb = br_vlan_untag(skb);
> +		skb->vlan_tci = 0;
>  
>  out:
>  	return skb;
> 
