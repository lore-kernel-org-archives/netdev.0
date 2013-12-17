From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] bridge: br_handle_local_finish should not return
 zero
Date: Tue, 17 Dec 2013 13:55:42 -0800
Message-ID: <20131217135542.21976b05@nehalam.linuxnetplumber.net>
References: <52ACC4F8.6080703@hotsplots.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Martin Faecknitz <faecknitz@hotsplots.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:46343 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753311Ab3LQVzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 16:55:46 -0500
Received: by mail-pb0-f44.google.com with SMTP id rq2so7516055pbb.31
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 13:55:45 -0800 (PST)
In-Reply-To: <52ACC4F8.6080703@hotsplots.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 14 Dec 2013 21:52:08 +0100
Martin Faecknitz <faecknitz@hotsplots.de> wrote:

> br_handle_local_finish is called by NF_HOOK(...) after accepting the packet. If
> the return value of NF_HOOK(...) is zero (i.e. the return value of
> br_handle_local_finish), the packet is passed to the network stack. This
> behavior conflicts with netfilter hooks which return NF_STOLEN/NF_QUEUE. In this
> case, NF_HOOK(...) returns also zero (see nf_hook_slow) but
> br_handle_local_finish was never called. The packet will still passed to the
> network stack.
> 
> Signed-off-by: Martin Faecknitz
> 
> --- a/net/bridge/br_input.c
> +++ b/net/bridge/br_input.c
> @@ -149,7 +149,7 @@ static int br_handle_local_finish(struct sk_buff *skb)
>  	br_vlan_get_tag(skb, &vid);
>  	if (p->flags & BR_LEARNING)
>  		br_fdb_update(p->br, p, eth_hdr(skb)->h_source, vid);
> -	return 0;	 /* process further */
> +	return 1;	 /* process further */
>  }
> 
>  /*
> @@ -208,7 +208,7 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
> 
>  		/* Deliver packet to local host only */
>  		if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
> -			    NULL, br_handle_local_finish)) {
> +			    NULL, br_handle_local_finish) != 1) {
>  			return RX_HANDLER_CONSUMED; /* consumed by filter */
>  		} else {
>  			*pskb = skb;
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

I think the input code was incorrectly assuming the model of that receive logic
should return NET_RX_SUCCESS(0) or NET_RX_DROP(1). (Note DECNET has same bug).

Rather than hardcode in 0 and 1. why not use NF_DROP, NF_ACCEPT instead?
