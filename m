From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] Handle shared SKBs in VLAN receive code
Date: Fri, 10 Oct 2003 16:52:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F87464B.1020908@candelatech.com>
References: <3F87430D.2040000@tpack.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
In-Reply-To: <3F87430D.2040000@tpack.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Tommy Christensen wrote:
> As noted by Jonas Munsin, the vlan patch that went into 2.6.0-test7 did a
> kfree() rather than a kfree_skb(). Hmm.
> 
> Instead of just fixing this up, I suggest we do things the right way:
> 
> The VLAN code have long been claiming to handle shared SKBs, without 
> actually
> doing so. I have now added the call to skb_share_check().
> 
> This enables us to simply do a skb_unshare() when mangling the ethernet 
> header.
> 
> 
> Patch is against linux-2.6.0-test7 (applies to 2.4.23-pre7 as well).
> 
> -Tommy
> 
> 
> ------------------------------------------------------------------------
> 
> diff -ru linux-2.6.0-test7/net/8021q/vlan_dev.c linux-2.6/net/8021q/vlan_dev.c
> --- linux-2.6.0-test7/net/8021q/vlan_dev.c	Wed Oct  8 21:24:44 2003
> +++ linux-2.6/net/8021q/vlan_dev.c	Sat Oct 11 00:45:28 2003
> @@ -74,11 +74,7 @@
>  static inline struct sk_buff *vlan_check_reorder_header(struct sk_buff *skb)
>  {
>  	if (VLAN_DEV_INFO(skb->dev)->flags & 1) {
> -		if (skb_shared(skb) || skb_cloned(skb)) {
> -			struct sk_buff *nskb = skb_copy(skb, GFP_ATOMIC);
> -			kfree(skb);
> -			skb = nskb;
> -		}
> +		skb = skb_unshare(skb, GFP_ATOMIC);

On 2.4.22, at least, skb_unshare only checks skb_cloned(), so do we
also need to check skb_shared()?  Or was that check in the old patch above
not needed?

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
