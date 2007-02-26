From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH,RFC] bridge: call eth_type_trans() in br_pass_frame_up()
Date: Mon, 26 Feb 2007 10:40:31 -0800
Message-ID: <20070226104031.09930077@freekitty>
References: <20061018091445.GB18850@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	tbillman@gmail.com
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:56340 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030405AbXBZSke (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Feb 2007 13:40:34 -0500
In-Reply-To: <20061018091445.GB18850@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 18 Oct 2006 11:14:45 +0200
Lennert Buytenhek <buytenh@wantstofly.org> wrote:

> Hi,
> 
> I've been seeing a failure to reply to incoming ARP packets on a bridge
> interface until after the first few packets have been transmitted over
> that interface, and the patch below seems to fix the issue, the 'issue'
> being that the incoming ARP packets are marked with PACKET_OTHERHOST,
> and there not being anything to set that back to PACKET_HOST even if
> the destination MAC address matches the bridge interface's MAC address.
> 
> If this looks good, I'll prepare a proper commit message.
> 
> 
> cheers,
> Lennert
> 
> Signed-off-by: Tom Billman <tbillman@gmail.com>
> Signed-off-by: Lennert Buytenhek <buytenh@wantstofly.org>
> 
> --- linux-2.6.19-rc2.orig/net/bridge/br_input.c	2006-10-18 11:11:08.000000000 +0200
> +++ linux-2.6.19-rc2/net/bridge/br_input.c	2006-10-18 11:10:08.000000000 +0200
> @@ -32,6 +32,9 @@
>  	indev = skb->dev;
>  	skb->dev = br->dev;
>  
> +	skb_push(skb, ETH_HLEN);
> +	skb->protocol = eth_type_trans(skb, skb->dev);
> +
>  	NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, indev, NULL,
>  		netif_receive_skb);
>  }

No, eth_type_trans already be called by the device in the receive path.
Looks like a device driver bug, not a bridge issue.  If you add this,
the code ends up doing eth_type_trans twice.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
