From: Quentin Armitage <quentin@armitage.org.uk>
Subject: [PATCH] Fix returned tc and hoplimit values for route with IPv6 encapsulation
Date: Sun, 27 Mar 2016 17:06:11 +0100
Message-ID: <1459094771-24749-1-git-send-email-quentin@armitage.org.uk>
Cc: Quentin Armitage <quentin@armitage.org.uk>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rslrsmtp2.opaltelecom.net ([62.24.128.202]:59956 "EHLO
	iprslrsmtp2msp.cpwnetworks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752219AbcC0QQq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2016 12:16:46 -0400
Received: from [92.27.6.192] (helo=nabal.armitage.org.uk)
	by rslr-smtp-1.cpwnetworks.com with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.63)
	(envelope-from <quentin@armitage.org.uk>)
	id 1akDD0-0005nz-0m
	for netdev@vger.kernel.org; Sun, 27 Mar 2016 17:06:34 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For a route with IPv6 encapsulation, the traffic class and hop limit
values are interchanged when returned to userspace by the kernel.
For example, see below.

># ip route add 192.168.0.1 dev eth0.2 encap ip6 dst 0x50 tc 0x50 hoplimit 100 table 1000
># ip route show table 1000
192.168.0.1  encap ip6 id 0 src :: dst fe83::1 hoplimit 80 tc 100 dev eth0.2  scope link

Signed-off-by: Quentin Armitage <quentin@armitage.org.uk>
---
 net/ipv4/ip_tunnel_core.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 02dd990..6165f30 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -372,8 +372,8 @@ static int ip6_tun_fill_encap_info(struct sk_buff *skb,
 	if (nla_put_be64(skb, LWTUNNEL_IP6_ID, tun_info->key.tun_id) ||
 	    nla_put_in6_addr(skb, LWTUNNEL_IP6_DST, &tun_info->key.u.ipv6.dst) ||
 	    nla_put_in6_addr(skb, LWTUNNEL_IP6_SRC, &tun_info->key.u.ipv6.src) ||
-	    nla_put_u8(skb, LWTUNNEL_IP6_HOPLIMIT, tun_info->key.tos) ||
-	    nla_put_u8(skb, LWTUNNEL_IP6_TC, tun_info->key.ttl) ||
+	    nla_put_u8(skb, LWTUNNEL_IP6_TC, tun_info->key.tos) ||
+	    nla_put_u8(skb, LWTUNNEL_IP6_HOPLIMIT, tun_info->key.ttl) ||
 	    nla_put_be16(skb, LWTUNNEL_IP6_FLAGS, tun_info->key.tun_flags))
 		return -ENOMEM;
 
-- 
1.7.7.6
