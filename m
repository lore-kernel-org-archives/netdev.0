From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: rcu locking issue in mpls output code?
Date: Sun, 19 Jun 2016 20:19:20 -0600
Message-ID: <8d325ab7-bc46-dd69-288a-571d56efc545@cumulusnetworks.com>
References: <20160620004546.GP20238@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f48.google.com ([209.85.214.48]:38215 "EHLO
	mail-it0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751480AbcFTC0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 22:26:48 -0400
Received: by mail-it0-f48.google.com with SMTP id h190so29060974ith.1
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2016 19:26:47 -0700 (PDT)
In-Reply-To: <20160620004546.GP20238@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/19/16 6:45 PM, Lennert Buytenhek wrote:
> diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
> index fb31aa8..802956b 100644
> --- a/net/mpls/mpls_iptunnel.c
> +++ b/net/mpls/mpls_iptunnel.c
> @@ -105,12 +105,15 @@ static int mpls_output(struct net *net, struct sock *sk, struct sk_buff *skb)
>  		bos = false;
>  	}
>
> +	rcu_read_lock_bh();
>  	if (rt)
>  		err = neigh_xmit(NEIGH_ARP_TABLE, out_dev, &rt->rt_gateway,
>  				 skb);
>  	else if (rt6)
>  		err = neigh_xmit(NEIGH_ND_TABLE, out_dev, &rt6->rt6i_gateway,
>  				 skb);
> +	rcu_read_unlock_bh();
> +
>  	if (err)
>  		net_dbg_ratelimited("%s: packet transmission failed: %d\n",
>  				    __func__, err);
>

I think those need to be added to neigh_xmit in the

	if (likely(index < NEIGH_NR_TABLES)) {

	}

block.
