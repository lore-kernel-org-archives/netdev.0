From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/3] tipc: message reassembly using
 fragment chain
Date: Mon, 04 Nov 2013 16:12:54 -0500 (EST)
Message-ID: <20131104.161254.1576011108092991976.davem@davemloft.net>
References: <1383208814-23476-1-git-send-email-erik.hugne@ericsson.com>
	<1383208814-23476-3-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jon.maloy@ericsson.com, maloy@donjonn.com,
	paul.gortmaker@windriver.com, ying.xue@windriver.com
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54403 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155Ab3KDVM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 16:12:56 -0500
In-Reply-To: <1383208814-23476-3-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <erik.hugne@ericsson.com>
Date: Thu, 31 Oct 2013 09:40:13 +0100

> +	skb_pull(frag, msg_hdr_sz(msg));
> +	if (fragid == FIRST_FRAGMENT) {
> +		if (*head)
> +			goto out_free;
> +		*head = frag;
> +		skb_frag_list_init(*head);
>  		return 0;
> +	} else {
> +		if (!*head)
> +			goto out_free;
> +		if (!skb_has_frag_list(*head))
> +			skb_shinfo(*head)->frag_list = frag;
> +		else
> +			(*tail)->next = frag;
> +		*tail = frag;
> +		(*head)->truesize += frag->truesize;
> +	}
> +	if (fragid == LAST_FRAGMENT) {
> +		*fbuf = *head;
> +		*tail = *head = NULL;
> +		return LINK_REASM_COMPLETE;
>  	}

Please use skb_try_coalese(), and only use frag lists if that does not
succeed.

Also you must be certain to unclone the SKB if you are going to modify
it in this kind of way.

For a good example of how to attend to all of these things, see
ip_frag_reasm() in net/ipv4/ip_fragment.c
