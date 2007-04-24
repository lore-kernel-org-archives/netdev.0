From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [RFC] bridge: if no STP then forward all BPDU's
Date: Wed, 25 Apr 2007 01:22:09 +0200
Message-ID: <20070424232209.GA14399@xi.wantstofly.org>
References: <20070424161226.0372f5e8@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:46182 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753965AbXDXXWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 19:22:14 -0400
Content-Disposition: inline
In-Reply-To: <20070424161226.0372f5e8@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 24, 2007 at 04:12:26PM -0700, Stephen Hemminger wrote:

> The bridge code by default captures all spanning tree packets and
> doesn't forward them. I propose that this might not be a good idea.

As far as I remember, the original bridge code did pass through BPDUs
when STP was disabled.  I think that that is the only right way to
behave.


> --- bridge-2.6.22.orig/net/bridge/br_input.c
> +++ bridge-2.6.22/net/bridge/br_input.c
> @@ -131,8 +131,16 @@ struct sk_buff *br_handle_frame(struct n
>  	if (!is_valid_ether_addr(eth_hdr(skb)->h_source))
>  		goto drop;
>  
> -	if (unlikely(is_link_local(dest))) {
> -		skb->pkt_type = PACKET_HOST;
> +	/*
> +	 * If STP is running, then trap all link-local (802.1x) frames
> +	 * process through normal receive path.
> +	 *
> +	 * For safety, if not running STP then act as a completely transparent
> +	 * device. This means that if STP is running on another machine, it
> +	 * can still detect cycles.
> +	 */
> +	if (p->br->stp_enabled != BR_NO_STP && is_link_local(dest)) {
> +		/* skb->pkt_type should already be PACKET_MULTICAST */

(Does this check include PAUSE frames?  We still don't want to
forward PAUSE frames in any case..)
