From: Wilco Baan Hofman <wilco@baanhofman.nl>
Subject: IPv6 GRE sending to undefined destinations
Date: Fri, 06 Mar 2015 17:34:20 +0100
Message-ID: <54F9D70C.7030409@baanhofman.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps.baanhofman.nl ([92.222.219.102]:58029 "EHLO
	vps.baanhofman.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755643AbbCFQlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 11:41:36 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by vps.baanhofman.nl (Postfix) with ESMTP id DED141040D86
	for <netdev@vger.kernel.org>; Fri,  6 Mar 2015 17:34:45 +0100 (CET)
Received: from vps.baanhofman.nl ([127.0.0.1])
	by localhost (vps.baanhofman.nl [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id VcOaiQeCyMyL for <netdev@vger.kernel.org>;
	Fri,  6 Mar 2015 17:34:20 +0100 (CET)
Received: from [10.255.1.55] (84-245-6-207.dsl.cambrium.nl [84.245.6.207])
	(Authenticated sender: wilco)
	by vps.baanhofman.nl (Postfix) with ESMTPSA id B1B8F1040D85
	for <netdev@vger.kernel.org>; Fri,  6 Mar 2015 17:34:20 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

When using the netlink sendmsg api to pass sockaddr_ll to an IPv6 GRE
interface, strange things happen.

For one, an IPv6 address does not fit into sockaddr_ll.ssl_addr (8 bytes).
Writing 8 0xff bytes into this field causes it to send the packet, but
it also leaks 8 bytes of kernel memory into the packet going out of the
interface.

Now, I have a use case for using this, that is to implement DMVPN/NHRP
over IPv6 GRE, with OpenNHRP for which I need to have a multipoint GRE
connection. With IPv4 this was already implemented with the sll
interface, changing the sll_addr changes the destination of the packet
header.

With the following patch I am able to make it work, but I'm not sure
about the implications of changing the size of the sll_addr buffer.

-- Wilco Baan Hofman



>From 9cebcdd74cdbdeda0159aebfb5e64d9b8efc4006 Mon Sep 17 00:00:00 2001
From: Wilco Baan Hofman <wilco@baanhofman.nl>
Date: Fri, 6 Mar 2015 17:25:05 +0100
Subject: [PATCH] Fix ip6_gre sending packets to undefined destinations.

---
 include/uapi/linux/if_packet.h | 2 +-
 net/ipv6/ip6_gre.c             | 8 ++++++++
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_packet.h
index da2d668..415cbc4 100644
--- a/include/uapi/linux/if_packet.h
+++ b/include/uapi/linux/if_packet.h
@@ -16,7 +16,7 @@ struct sockaddr_ll {
     unsigned short    sll_hatype;
     unsigned char    sll_pkttype;
     unsigned char    sll_halen;
-    unsigned char    sll_addr[8];
+    unsigned char    sll_addr[16];
 };
 
 /* Packet types */
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index bc28b7d..c9aee7d 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1205,8 +1205,16 @@ static int ip6gre_header(struct sk_buff *skb,
struct net_device *dev,
     return -t->hlen;
 }
 
+static int ip6gre_header_parse(const struct sk_buff *skb, unsigned char
*haddr)
+{
+    const struct ipv6hdr *ipv6h = (const struct ipv6hdr
*)skb_mac_header(skb);
+    memcpy(haddr, &ipv6h->saddr, sizeof(struct in6_addr));
+    return sizeof(struct in6_addr);
+}
+
 static const struct header_ops ip6gre_header_ops = {
     .create    = ip6gre_header,
+    .parse    = ip6gre_header_parse,
 };
 
 static const struct net_device_ops ip6gre_netdev_ops = {
-- 
1.8.5.2
