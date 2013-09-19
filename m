From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ip6tnl: do route updating for redirect in
 ip6_tnl_err()
Date: Thu, 19 Sep 2013 14:02:13 -0400 (EDT)
Message-ID: <20130919.140213.417316271045370155.davem@davemloft.net>
References: <1379474877-3097-1-git-send-email-duanj.fnst@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, duanj.fnst@cn.fujitsu.com
To: djduanjiong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53168 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751157Ab3ISSCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Sep 2013 14:02:15 -0400
In-Reply-To: <1379474877-3097-1-git-send-email-duanj.fnst@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <djduanjiong@gmail.com>
Date: Tue, 17 Sep 2013 20:27:57 -0700

> After the ip6_tnl_err() is called, the rel_msg is assigned to
> 0, and the ip4ip6_err() will return directly, the instruction
> below will not be executed.
> 
> In rfc2473, we can know that the tunnel ICMP redirect message
> should not be reported to the source of the original packet,
> so we can handle it in ip6_tnl_err().
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

I do not think this change is correct.

> @@ -576,9 +579,6 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
>  		rel_type = ICMP_DEST_UNREACH;
>  		rel_code = ICMP_FRAG_NEEDED;
>  		break;
> -	case NDISC_REDIRECT:
> -		rel_type = ICMP_REDIRECT;
> -		rel_code = ICMP_REDIR_HOST;
>  	default:
>  		return 0;
>  	}

The bug is a missing "break;" statement for this case, and:

> @@ -637,8 +637,6 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
>  
>  		skb_dst(skb2)->ops->update_pmtu(skb_dst(skb2), NULL, skb2, rel_info);
>  	}
> -	if (rel_type == ICMP_REDIRECT)
> -		skb_dst(skb2)->ops->redirect(skb_dst(skb2), NULL, skb2);
>  

We absolutely must run the ipv4 dst_ops redirect handler here so you must
keep this code around as well.

The only change you need to make is to add the missing break;
statement to ip4ip6_err() and then also add appropriate NDISC_REDIRECT
handling to ip6ip6_err().
