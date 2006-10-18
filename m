From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH,RFC] bridge: call eth_type_trans() in br_pass_frame_up()
Date: Wed, 18 Oct 2006 09:37:30 -0700
Message-ID: <20061018093730.3bc5b433@freekitty>
References: <20061018091445.GB18850@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tbillman@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:9666 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161231AbWJRQhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 12:37:34 -0400
To: Lennert Buytenhek <buytenh@wantstofly.org>
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

No, this will cause packets coming in from other interfaces to be incorrectly
marked as OTHERHOST. Think of the following:


	eth0:  00:11:11:0:1:2
	eth1:  00:11:11:0:1:3
	br0:   00:11:11:0:1:2

If packet arrives with Destination Address (DA) of 00:11:11:0:1:3 on eth1
then your change will mark it as OTHERHOST.

The case you are trying to fix is an ARP packet arriving on eth1 with
the DA of eth0. That implies some sort of mismatch or cycle in your topology,
it is not clear if the packet should just be dropped.


-- 
Stephen Hemminger <shemminger@osdl.org>
