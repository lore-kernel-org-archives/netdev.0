From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] net: ip_finish_output_gso: If skb_gso_network_seglen
 exceeds MTU, do segmentation even for non IPSKB_FORWARDED skbs
Date: Sat, 9 Jul 2016 15:22:30 +0200
Message-ID: <20160709132230.GD2067@breakpoint.cc>
References: <1467722132-10084-1-git-send-email-shmulik.ladkani@ravellosystems.com>
 <20160705130327.GA10737@breakpoint.cc>
 <20160705170541.3f210675@pixies>
 <20160709090020.GB2067@breakpoint.cc>
 <20160709153017.791f2607@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	shmulik.ladkani@gmail.com, netdev@vger.kernel.org,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Tom Herbert <tom@herbertland.com>
To: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:36188 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932947AbcGINWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2016 09:22:40 -0400
Content-Disposition: inline
In-Reply-To: <20160709153017.791f2607@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shmulik Ladkani <shmulik.ladkani@ravellosystems.com> wrote:
> I'd appreciate any suggestion how to determine traffic is local OTHER
> THAN testing IPSKB_FORWARDED; If we have such a way, there wouldn't be an
> impact on local traffic.
> 
> > What about setting IPCB FORWARD flag in iptunnel_xmit if
> > skb->skb_iif != 0... instead?
> 
> Can you please elaborate?

[ not even compile tested ]

diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -65,6 +65,7 @@ void iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 	struct net_device *dev = skb->dev;
 	struct iphdr *iph;
 	int err;
+	bool fwd = skb->skb_iif > 0;
 
 	skb_scrub_packet(skb, xnet);
 
@@ -72,6 +73,9 @@ void iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 	skb_dst_set(skb, &rt->dst);
 	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
 
+	if (fwd)
+		IPCB(skb)->flags = IPSKB_FORWARDED;
+
 	/* Push down and install the IP header. */
 	skb_push(skb, sizeof(struct iphdr));
 	skb_reset_network_header(skb);
