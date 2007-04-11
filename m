From: Patrick McHardy <kaber@trash.net>
Subject: Re: [GIT PULL] bridge update for 2.6.22
Date: Wed, 11 Apr 2007 07:19:46 +0200
Message-ID: <461C6FF2.2000700@trash.net>
References: <20070409135552.5eee2bc8@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Bart De Schuymer <bdschuym@pandora.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43748 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161196AbXDKFUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2007 01:20:38 -0400
In-Reply-To: <20070409135552.5eee2bc8@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
> index a260679..8a55276 100644
> --- a/net/bridge/br_input.c
> +++ b/net/bridge/br_input.c
>  	if (unlikely(is_link_local(dest))) {
>  		skb->pkt_type = PACKET_HOST;
> -		return NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
> -			       NULL, br_handle_local_finish) != 0;
> +
> +		return (NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
> +				NULL, br_handle_local_finish) == 0) ? skb : NULL;
>  	}


I Just want to note, this is broken in multiple ways (not by this
patch, it was already broken before). When a packet is stolen or
queued, NF_HOOK will return 0, but the packet is not owned by the
caller anymore, so we have a potential use-after-free. Additionally
the okfn owns the skb and needs to make sure it continues its path,
which br_handle_local_finish doesn't do, resulting in leaks and
broken queueing. The fix looks quite ugly, bf_handle_local_finish
would need to pass the skb back to netif_receive_skb just after the
handle_bridge call.

All this is not a problem for mainline currently since ebtables
doesn't support QUEUE yet, but since its mentioned on the TODO
list and in any case is incorrect use of NF_HOOK it feels worth
mentioning.

