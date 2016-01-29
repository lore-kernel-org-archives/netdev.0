From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Kernel unaligned access at __skb_flow_dissect
Date: Fri, 29 Jan 2016 11:04:37 -0800 (PST)
Message-ID: <20160129.110437.472340480320526154.davem@davemloft.net>
References: <20160129180651.GA17127@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38984 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751124AbcA2TEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 14:04:40 -0500
In-Reply-To: <20160129180651.GA17127@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Fri, 29 Jan 2016 13:06:51 -0500

> @@ -102,6 +102,17 @@ __be32 __skb_flow_get_ports(const struct sk_buff *skb, int 
>  }
>  EXPORT_SYMBOL(__skb_flow_get_ports);
>  
> +static inline __be32 ip6_flowlabel_align(const u8 *hdr)
> +{
> +       union {
> +               __u8 w[4];
> +               __u32 flow;
> +       } ip6_flow;
> +
> +       memcpy(ip6_flow.w, hdr, 4);
 ...
> -               flow_label = ip6_flowlabel(iph);
> +               flow_label = ip6_flowlabel_align((const u8 *)iph);

Casting is not a foolproof solution.

The compiler is allowed to legally walk through the casts and discover that
the original type has certain alignment guarantees and use them in it's
inline expansion of memcpy().

Also, so much stuff in this file is going to trip over this issue if
the IP header isn't even 4 byte aligned.
