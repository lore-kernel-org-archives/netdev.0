From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: enhance L2 hash helper with packet type
Date: Mon, 14 Jul 2014 19:08:39 -0700 (PDT)
Message-ID: <20140714.190839.1595507738609644305.davem@davemloft.net>
References: <1405317926-27221-1-git-send-email-Jianhua.Xie@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
	andy@greyhouse.net, Jiafei.Pan@freescale.com
To: Jianhua.Xie@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37350 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754007AbaGOCIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 22:08:41 -0400
In-Reply-To: <1405317926-27221-1-git-send-email-Jianhua.Xie@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xie Jianhua <Jianhua.Xie@freescale.com>
Date: Mon, 14 Jul 2014 14:05:26 +0800

> @@ -3002,7 +3002,7 @@ static inline u32 bond_eth_hash(struct sk_buff *skb)
>  	struct ethhdr *data = (struct ethhdr *)skb->data;
>  
>  	if (skb_headlen(skb) >= offsetof(struct ethhdr, h_proto))
> -		return data->h_dest[5] ^ data->h_source[5];
> +		return data->h_dest[5] ^ data->h_source[5] ^ data->h_proto;
>  
>  	return 0;
>  }

About the headlen check, I don't like the idea that the hash depends upon
whether we have a fully fragmented packet or not.

Just use the appropriate interface, skb_header_pointer(), and recode this
as:

	struct ethhdr *ep, _hdr;

	ep = skb_header_pointer(skb, 0, sizeof(_hdr), &_hdr);
	if (ep)
		return ep->h_dest[5] ^ ep->h_source[5] ^ ep->h_proto;
	return 0;
