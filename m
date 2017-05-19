From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 7/9] fou: make local function static
Date: Fri, 19 May 2017 09:55:54 -0700
Message-ID: <20170519165556.483-8-sthemmin@microsoft.com>
References: <20170519165556.483-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:34469 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754951AbdESQ4M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 12:56:12 -0400
Received: by mail-pg0-f54.google.com with SMTP id u28so40776581pgn.1
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 09:56:12 -0700 (PDT)
In-Reply-To: <20170519165556.483-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The build header functions are not used by any other code.

net/ipv6/fou6.c:36:5: warning: no previous prototype for ‘fou6_build_header’ [-Wmissing-prototypes]
net/ipv6/fou6.c:54:5: warning: no previous prototype for ‘gue6_build_header’ [-Wmissing-prototypes]

Need to do some code rearranging to satisfy different Kconfig possiblities.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 net/ipv4/fou.c  | 82 ++++++++++++++++++++++++++++-----------------------------
 net/ipv6/fou6.c | 14 +++++-----
 2 files changed, 47 insertions(+), 49 deletions(-)

diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 805f6607f8d9..8e0257d01200 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -8,6 +8,7 @@
 #include <linux/kernel.h>
 #include <net/genetlink.h>
 #include <net/gue.h>
+#include <net/fou.h>
 #include <net/ip.h>
 #include <net/protocol.h>
 #include <net/udp.h>
@@ -859,25 +860,6 @@ size_t gue_encap_hlen(struct ip_tunnel_encap *e)
 }
 EXPORT_SYMBOL(gue_encap_hlen);
 
-static void fou_build_udp(struct sk_buff *skb, struct ip_tunnel_encap *e,
-			  struct flowi4 *fl4, u8 *protocol, __be16 sport)
-{
-	struct udphdr *uh;
-
-	skb_push(skb, sizeof(struct udphdr));
-	skb_reset_transport_header(skb);
-
-	uh = udp_hdr(skb);
-
-	uh->dest = e->dport;
-	uh->source = sport;
-	uh->len = htons(skb->len);
-	udp_set_csum(!(e->flags & TUNNEL_ENCAP_FLAG_CSUM), skb,
-		     fl4->saddr, fl4->daddr, skb->len);
-
-	*protocol = IPPROTO_UDP;
-}
-
 int __fou_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 		       u8 *protocol, __be16 *sport, int type)
 {
@@ -894,24 +876,6 @@ int __fou_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 }
 EXPORT_SYMBOL(__fou_build_header);
 
-int fou_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
-		     u8 *protocol, struct flowi4 *fl4)
-{
-	int type = e->flags & TUNNEL_ENCAP_FLAG_CSUM ? SKB_GSO_UDP_TUNNEL_CSUM :
-						       SKB_GSO_UDP_TUNNEL;
-	__be16 sport;
-	int err;
-
-	err = __fou_build_header(skb, e, protocol, &sport, type);
-	if (err)
-		return err;
-
-	fou_build_udp(skb, e, fl4, protocol, sport);
-
-	return 0;
-}
-EXPORT_SYMBOL(fou_build_header);
-
 int __gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 		       u8 *protocol, __be16 *sport, int type)
 {
@@ -985,8 +949,46 @@ int __gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 }
 EXPORT_SYMBOL(__gue_build_header);
 
-int gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
-		     u8 *protocol, struct flowi4 *fl4)
+#ifdef CONFIG_NET_FOU_IP_TUNNELS
+
+static void fou_build_udp(struct sk_buff *skb, struct ip_tunnel_encap *e,
+			  struct flowi4 *fl4, u8 *protocol, __be16 sport)
+{
+	struct udphdr *uh;
+
+	skb_push(skb, sizeof(struct udphdr));
+	skb_reset_transport_header(skb);
+
+	uh = udp_hdr(skb);
+
+	uh->dest = e->dport;
+	uh->source = sport;
+	uh->len = htons(skb->len);
+	udp_set_csum(!(e->flags & TUNNEL_ENCAP_FLAG_CSUM), skb,
+		     fl4->saddr, fl4->daddr, skb->len);
+
+	*protocol = IPPROTO_UDP;
+}
+
+static int fou_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
+			    u8 *protocol, struct flowi4 *fl4)
+{
+	int type = e->flags & TUNNEL_ENCAP_FLAG_CSUM ? SKB_GSO_UDP_TUNNEL_CSUM :
+						       SKB_GSO_UDP_TUNNEL;
+	__be16 sport;
+	int err;
+
+	err = __fou_build_header(skb, e, protocol, &sport, type);
+	if (err)
+		return err;
+
+	fou_build_udp(skb, e, fl4, protocol, sport);
+
+	return 0;
+}
+
+static int gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
+			    u8 *protocol, struct flowi4 *fl4)
 {
 	int type = e->flags & TUNNEL_ENCAP_FLAG_CSUM ? SKB_GSO_UDP_TUNNEL_CSUM :
 						       SKB_GSO_UDP_TUNNEL;
@@ -1001,9 +1003,7 @@ int gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 
 	return 0;
 }
-EXPORT_SYMBOL(gue_build_header);
 
-#ifdef CONFIG_NET_FOU_IP_TUNNELS
 
 static const struct ip_tunnel_encap_ops fou_iptun_ops = {
 	.encap_hlen = fou_encap_hlen,
diff --git a/net/ipv6/fou6.c b/net/ipv6/fou6.c
index 9ea249b9451e..6de3c04b0f30 100644
--- a/net/ipv6/fou6.c
+++ b/net/ipv6/fou6.c
@@ -14,6 +14,8 @@
 #include <net/udp.h>
 #include <net/udp_tunnel.h>
 
+#if IS_ENABLED(CONFIG_IPV6_FOU_TUNNEL)
+
 static void fou6_build_udp(struct sk_buff *skb, struct ip_tunnel_encap *e,
 			   struct flowi6 *fl6, u8 *protocol, __be16 sport)
 {
@@ -33,8 +35,8 @@ static void fou6_build_udp(struct sk_buff *skb, struct ip_tunnel_encap *e,
 	*protocol = IPPROTO_UDP;
 }
 
-int fou6_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
-		      u8 *protocol, struct flowi6 *fl6)
+static int fou6_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
+			     u8 *protocol, struct flowi6 *fl6)
 {
 	__be16 sport;
 	int err;
@@ -49,10 +51,9 @@ int fou6_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 
 	return 0;
 }
-EXPORT_SYMBOL(fou6_build_header);
 
-int gue6_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
-		      u8 *protocol, struct flowi6 *fl6)
+static int gue6_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
+			     u8 *protocol, struct flowi6 *fl6)
 {
 	__be16 sport;
 	int err;
@@ -67,9 +68,6 @@ int gue6_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 
 	return 0;
 }
-EXPORT_SYMBOL(gue6_build_header);
-
-#if IS_ENABLED(CONFIG_IPV6_FOU_TUNNEL)
 
 static const struct ip6_tnl_encap_ops fou_ip6tun_ops = {
 	.encap_hlen = fou_encap_hlen,
-- 
2.11.0
