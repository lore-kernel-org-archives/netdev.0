From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/3] net: use skb->priority for overloading
 skb->dropcount and skb->reserved_tailroom instead of skb->mark
Date: Thu, 19 Feb 2015 15:05:00 -0500 (EST)
Message-ID: <20150219.150500.834870317013347277.davem@davemloft.net>
References: <1423715535-884-1-git-send-email-eyal.birger@gmail.com>
	<1423715535-884-3-git-send-email-eyal.birger@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
	shmulik.ladkani@gmail.com
To: eyal.birger@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56958 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752657AbbBSUFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 15:05:03 -0500
In-Reply-To: <1423715535-884-3-git-send-email-eyal.birger@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Birger <eyal.birger@gmail.com>
Date: Thu, 12 Feb 2015 06:32:14 +0200

> The purpose of overloading skb->priority is solely for retaining
> struct sk_buff size; skb->priority is not used after the skb queued
> to the socket and has the same guarentee of not being shared as
> skb->mark.

I don't think this analysis is accurate.

> @@ -621,7 +621,7 @@ struct sk_buff {
>  			__u16	csum_offset;
>  		};
>  	};
> -	__u32			priority;
> +	__u32			mark;
>  	int			skb_iif;
>  	__u32			hash;
>  	__be16			vlan_proto;
> @@ -636,7 +636,7 @@ struct sk_buff {
>  	__u32			secmark;
>  #endif
>  	union {
> -		__u32		mark;
> +		__u32		priority;
>  		__u32		dropcount;
>  		__u32		reserved_tailroom;
>  	};
> -- 

You are going to now write to dropcount in packet_rcv() and that will
corrupt skb->priority.  If we got to packet_rcv() via
dev_queue_xmit_nit() then that skb->priority value is actually going
to be used by the packet schedulers for classification, flow
scheduling, etc.

So I don't think this transformation is going to work properly.

I'm also wondering if aliasing with skb->mark, which is what happens
now, is legal too.
