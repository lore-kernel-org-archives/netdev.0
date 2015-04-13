From: Sebastian Poehn <sebastian.poehn@gmail.com>
Subject: Re: [FYI] xfrm: Don't lookup sk_policy for timewait sockets
Date: Mon, 13 Apr 2015 17:09:20 +0200
Message-ID: <1428937760.6534.23.camel@googlemail.com>
References: <1428570461.25985.240.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150409.143727.1391401196320839634.davem@davemloft.net>
	 <20150409191441.GE20653@breakpoint.cc>
	 <20150409.170720.1374561715105253435.davem@davemloft.net>
	 <20150409212144.GH20653@breakpoint.cc>
	 <1428664454.10242.19.camel@googlemail.com>
	 <1428912255.6534.5.camel@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>
To: Sebastian Poehn <sebastian.poehn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:37776 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932108AbbDMPJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 11:09:23 -0400
Received: by widdi4 with SMTP id di4so55935604wid.0
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 08:09:21 -0700 (PDT)
In-Reply-To: <1428912255.6534.5.camel@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-04-13 at 10:04 +0200, Sebastian Poehn wrote:
> 
> Played around with sending crafted packets to a transparent tw socket.
> 
> For SYN tproxy does the re-lookup of the listening socket, which is fine. But for
> packets without SYN is assigns the tw socket. However this is not an issue as the
> fw mark is set, policy routing processes frame, so it becomes input and finally is
> dropped in TCP receive path. But if I remove the policy routing rule the frame
> enters the forwarding path.
> 
> Unfortunately this did not trigger the panic but this may be just by chance.
> 
> However I can't explain what is wrong with the ip rule maybe setup related.
> 
First of all: This issue will only happen if there is something screwed up with 
policy routing. We don't use any 'exotic' policy to match the TPROXY traffic nor
is there anything that could damage the mark.

ip rule add from all fwmark 0x1/0x1 lookup X

However it happens - maybe a race with configuration.

I found TPROXY behavior correct:
1) For SYN on tw socket it assigns listening socket
2) Otherwise tw socket is assigned with is required for protocol conformity

Principally the problem is that TPROXY cannot ensure that policy routing is
working correctly. Florian suggested me to clean skb->sk in ip_forward. I even think
dropping the frame is fine. Not sure if this is suited for mainline.

diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 939992c..2fc3b3e 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -82,6 +82,10 @@ int ip_forward(struct sk_buff *skb)
 	if (skb->pkt_type != PACKET_HOST)
 		goto drop;
 
+	/* this should happen neither */
+	if (unlikely(skb->sk))
+		goto drop;
+
 	if (skb_warn_if_lro(skb))
 		goto drop;
 		
Signed-off-by: Sebastian Poehn <sebastian.poehn@gmail.com> 
