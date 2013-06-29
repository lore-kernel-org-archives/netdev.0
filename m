From: Timo Teras <timo.teras@iki.fi>
Subject: ip_tunnel mtu calculation
Date: Sat, 29 Jun 2013 17:57:01 +0300
Message-ID: <20130629175701.73c17a16@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: Pravin B Shelar <pshelar@nicira.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:47299 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752844Ab3F2O4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jun 2013 10:56:50 -0400
Received: by mail-wi0-f180.google.com with SMTP id c10so1738836wiw.13
        for <netdev@vger.kernel.org>; Sat, 29 Jun 2013 07:56:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm reviewing changes since 3.9 to net-next and observed that, the
tunnel refactoring had the following change in ip_gre xmit path.

In ip_tunnel_xmit() mtu is now calculated as:
        if (df)
                mtu = dst_mtu(&rt->dst) - dev->hard_header_len
                                        - sizeof(struct iphdr);
        else
                mtu = skb_dst(skb) ? dst_mtu(skb_dst(skb)) : dev->mtu;

And it used to be in ip_gre.c: ipgre_tunnel_xmit():
        if (df)
                mtu = dst_mtu(&rt->dst) - dev->hard_header_len - tunnel->hlen;
        else
                mtu = skb_dst(skb) ? dst_mtu(skb_dst(skb)) : dev->mtu;

I notice that tunnel->hlen is replaced with sizeof(struct iphdr), but
in case of GRE those are not the same thing. And the refactored
ip_gre.c does not set hard_header_len either. So it would like the mtu
is now miscalculated (planning to give a full test-spin for net-next
next week).

It seems the tunnel->hlen used to be the full length, including
sizeof(struct iphdr).

But the new, refactored code seems exclude sizeof(struct iphdr) from
the tunnel->hlen. So would the following be appropriate?

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 394cebc..ac3a9a1 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -564,7 +564,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 
 	if (df)
 		mtu = dst_mtu(&rt->dst) - dev->hard_header_len
-					- sizeof(struct iphdr);
+			- tunnel->hlen - sizeof(struct iphdr);
 	else
 		mtu = skb_dst(skb) ? dst_mtu(skb_dst(skb)) : dev->mtu;
 
