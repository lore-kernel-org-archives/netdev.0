From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [net-next PATCH] net: bridge: fix for bridging 802.1Q without
 REORDER_HDR
Date: Fri, 11 Sep 2015 12:24:45 -0700
Message-ID: <20150911122445.53cdfbcf@urahara>
References: <1441999323-29381-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35826 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751426AbbIKTYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 15:24:35 -0400
Received: by pacfv12 with SMTP id fv12so84187778pac.2
        for <netdev@vger.kernel.org>; Fri, 11 Sep 2015 12:24:34 -0700 (PDT)
In-Reply-To: <1441999323-29381-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Sep 2015 21:22:03 +0200
Phil Sutter <phil@nwl.cc> wrote:

> When forwarding packets from an 802.1Q interface with REORDER_HDR set to
> zero, the VLAN header previously inserted by vlan_do_receive() needs to
> be stripped from the packet and the mac_header adjustment undone,
> otherwise a tagged frame with first four bytes missing will be
> transmitted.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  net/bridge/br_input.c | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
> index f921a5d..e4e3fc7 100644
> --- a/net/bridge/br_input.c
> +++ b/net/bridge/br_input.c
> @@ -288,6 +288,16 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
>  	}
>  
>  forward:
> +	if (is_vlan_dev(skb->dev) &&
> +	    !(vlan_dev_priv(skb->dev)->flags & VLAN_FLAG_REORDER_HDR)) {
> +		unsigned int offset = skb->data - skb_mac_header(skb);
> +
> +		skb_push(skb, offset);
> +		memmove(skb->data + VLAN_HLEN, skb->data, 2 * ETH_ALEN);
> +		skb->mac_header += VLAN_HLEN;
> +		skb_pull(skb, offset);
> +		skb_reset_mac_len(skb);
> +	}
>  	switch (p->state) {
>  	case BR_STATE_FORWARDING:
>  		rhook = rcu_dereference(br_should_route_hook);

Thanks for finding this. Is this a new thing or has it always been there?

Sorry, this looks so special case it doesn't seem like a good idea.
Something is broken in VLAN handling if this is required.
