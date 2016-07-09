From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] net: ip_finish_output_gso: If skb_gso_network_seglen
 exceeds MTU, do segmentation even for non IPSKB_FORWARDED skbs
Date: Sat, 9 Jul 2016 11:10:38 -0400
Message-ID: <bbd992a7-fa9c-44de-876f-4e51721c60d5@stressinduktion.org>
References: <1467722132-10084-1-git-send-email-shmulik.ladkani@ravellosystems.com>
 <20160705130327.GA10737@breakpoint.cc> <20160705170541.3f210675@pixies>
 <20160709090020.GB2067@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, shmulik.ladkani@gmail.com,
	netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>,
	Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:48068 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751513AbcGIPKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2016 11:10:39 -0400
In-Reply-To: <20160709090020.GB2067@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09.07.2016 05:00, Florian Westphal wrote:
> I am worried about this patch, skb_gso_validate_mtu is more costly than
> the ->flags & FORWARD check; everyone pays this extra cost.
> 
> What about setting IPCB FORWARD flag in iptunnel_xmit if
> skb->skb_iif != 0... instead?

That came to my mind first, too.

> Yet another possibility would be to reduce gso_size but that violates
> gro/gso symmetry...

If you see vxlan (or any other UDP encap protocol) as an in-kernel
tunnel solution/program acting as an end point it is actually legal to
modify gso_size in my opinion. Adding headers to an skb can also not be
symmetric in this case. I would not see anything bad happening because
of doing so. Do you? It is a matter of implementation. vxlan could also
eat all data and splice it anew onto a socket. It already doesn't care
about end-to-end pmtu consistency, so I can't see anything wrong with it.

To make this all safe one needs to handle the ttl in vxlan much better.
It needs to be inherited from the inner header, checked and properly
decremented on the outer header, so that vxlan itself acts as a full
blown router by itself. Otherwise endless loops are possible, as the
packet will always fit the size.

Bye,
Hannes
