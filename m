From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC davem] revert: net: Make skb->skb_iif always track skb->dev
Date: Sat, 12 Jan 2013 19:13:07 +0100
Message-ID: <20130112181307.GA1567@minipsycho.orion>
References: <50F1699E.1000200@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:63895 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753920Ab3ALSNM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 13:13:12 -0500
Received: by mail-ee0-f44.google.com with SMTP id l10so1378548eei.31
        for <netdev@vger.kernel.org>; Sat, 12 Jan 2013 10:13:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <50F1699E.1000200@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Jan 12, 2013 at 02:48:14PM CET, socketcan@hartkopp.net wrote:
>Hello Dave,
>
>in your below patch from 23 Jul 2012 you removed the check for an already set
>value of skb_iif in net/core/dev.c
>
>I'm currently working on a solution to prevent some routed CAN frames to be
>sent back onto the originating network device.

Hm, I'm not sure where exactly you want to use this information, but
can_rcv() can get it from orig_dev->ifindex

>
>With your patch it is not possible anymore to check on which netdev the
>CAN frame has originally been received, as for every routing the frame
>goes through netif_receive_skb(), which hard sets
>
>	skb->skb_iif = skb->dev->ifindex
>
>and therefore kills the original incoming interface index.
>
>To me it is not clear why skb_iff is needed anyway as the value should
>always be available via skb->dev->ifindex, right?
>
>But if skb_iff has any right to exist it should contain the first incoming
>interface on the host IMO.
>
>Please correct my if i'm wrong and/or tell me what your commit message means
>in respect to my request and why skb->dev->ifindex is not used instead of
>skb_iif. I feel somehow lost about the skb_iif intention ...

I believe that skb_iif should be removed.

>
>Best regards,
>Oliver
>
>---
>
>
>http://git.kernel.org/?p=linux/kernel/git/davem/net-next.git;a=commitdiff;h=b68581778cd0051a3fb9a2b614dee7eccb5127ff
>
>net: Make skb->skb_iif always track skb->dev
>
>Make it follow device decapsulation, from things such as VLAN and
>bonding.
>
>The stuff that actually cares about pre-demuxed device pointers, is
>handled by the "orig_dev" variable in __netif_receive_skb().  And
>the only consumer of that is the po->origdev feature of AF_PACKET
>sockets.
>
>Signed-off-by: David S. Miller <davem@davemloft.net>
>---
>
>diff --git a/net/core/dev.c b/net/core/dev.c
>index cca02ae..0ebaea1 100644
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -3173,8 +3173,6 @@ static int __netif_receive_skb(struct sk_buff *skb)
> 	if (netpoll_receive_skb(skb))
> 		return NET_RX_DROP;
> 
>-	if (!skb->skb_iif)
>-		skb->skb_iif = skb->dev->ifindex;
> 	orig_dev = skb->dev;
> 
> 	skb_reset_network_header(skb);
>@@ -3186,6 +3184,7 @@ static int __netif_receive_skb(struct sk_buff *skb)
> 	rcu_read_lock();
> 
> another_round:
>+	skb->skb_iif = skb->dev->ifindex;
> 
> 	__this_cpu_inc(softnet_data.processed);
> 
>
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
