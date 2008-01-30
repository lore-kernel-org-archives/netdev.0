From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH net-2.6.25 4/7][ATM]: [br2864] routed support
Date: Wed, 30 Jan 2008 15:49:26 -0500
Message-ID: <200801302049.m0UKnQhr032004@cmf.nrl.navy.mil>
References: <3f696b20801282342q43537963ueb8fb9cf3389ac03@mail.gmail.com>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: "Chung-Chi Lo" <linolo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:42242 "EHLO
	ginger.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751165AbYA3Uus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 15:50:48 -0500
In-reply-to: <3f696b20801282342q43537963ueb8fb9cf3389ac03@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <3f696b20801282342q43537963ueb8fb9cf3389ac03@mail.gmail.com>,"Chung-
Chi Lo" writes:
>> +       } else { /* vc-mux */
>> +               if (brdev->payload == p_routed) {
>
>add line
>
>			skb->protocol = __constant_htons(ETH_P_IP);
>
>here just like LLC did?
>
>> +                       skb_reset_network_header(skb);
>> +                       skb->pkt_type = PACKET_HOST;

yes, that is missing but it needs to be a little more complicated than
that i think.  you need to examine the first byte to see if its an
ipv4 or ipv6 datagram.  something like:

			struct iphdr *iph = skb_network_header(skb);

                        skb_reset_network_header(skb);
			iph = skb_network_header(skb);
			if (iph->version == 4)
				skb->protocol = __constant_htons(ETH_P_IP);
			else if (iph->version == 6)
				skb->protocol = __constant_htons(ETH_P_IPV6);
			else
				/* drop the packet */
                        skb->pkt_type = PACKET_HOST;

how does that look?

>+       } else {
>+               skb_push(skb, 2);
>+               if (brdev->payload == p_bridged)
>+                       memset(skb->data, 0, 2);
>+       }
>
>Here should be
>
>	} else {
>		if (brdev->payload == p_bridged) {
>			skb_push(skb, 2);
>			memset(skb->data, 0, 2);
>		}
>	}
>
>Because VCMUX and routed mode doesn't need two bytes in header.

yeah, another oversight.  your fix is correct. i bet you have guessed
that we dont use vc multiplexing.
