From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 4/4] ip_tunnel: Add GUE support
Date: Wed,  1 Oct 2014 21:46:39 -0700
Message-ID: <1412225199-24942-5-git-send-email-therbert@google.com>
References: <1412225199-24942-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:57556 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751992AbaJBErS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 00:47:18 -0400
Received: by mail-pa0-f51.google.com with SMTP id lj1so1553133pab.24
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 21:47:17 -0700 (PDT)
In-Reply-To: <1412225199-24942-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows configuring IPIP, sit, and GRE tunnels to use GUE.
This is very similar to fou excpet that we need to insert the GUE header
in addition to the UDP header on transmit.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/uapi/linux/if_tunnel.h |  1 +
 net/ipv4/ip_tunnel.c           | 13 +++++++++++++
 2 files changed, 14 insertions(+)

diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
index 7c832af..280d9e0 100644
--- a/include/uapi/linux/if_tunnel.h
+++ b/include/uapi/linux/if_tunnel.h
@@ -64,6 +64,7 @@ enum {
 enum tunnel_encap_types {
 	TUNNEL_ENCAP_NONE,
 	TUNNEL_ENCAP_FOU,
+	TUNNEL_ENCAP_GUE,
 };
 
 #define TUNNEL_ENCAP_FLAG_CSUM		(1<<0)
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 54ace25..79f2ac0 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -56,6 +56,7 @@
 #include <net/netns/generic.h>
 #include <net/rtnetlink.h>
 #include <net/udp.h>
+#include <net/gue.h>
 
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ipv6.h>
@@ -495,6 +496,8 @@ static int ip_encap_hlen(struct ip_tunnel_encap *e)
 		return 0;
 	case TUNNEL_ENCAP_FOU:
 		return sizeof(struct udphdr);
+	case TUNNEL_ENCAP_GUE:
+		return sizeof(struct udphdr) + sizeof(struct guehdr);
 	default:
 		return -EINVAL;
 	}
@@ -546,6 +549,15 @@ static int fou_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 	skb_reset_transport_header(skb);
 	uh = udp_hdr(skb);
 
+	if (e->type == TUNNEL_ENCAP_GUE) {
+		struct guehdr *guehdr = (struct guehdr *)&uh[1];
+
+		guehdr->version = 0;
+		guehdr->hlen = 0;
+		guehdr->flags = 0;
+		guehdr->next_hdr = *protocol;
+	}
+
 	uh->dest = e->dport;
 	uh->source = sport;
 	uh->len = htons(skb->len);
@@ -565,6 +577,7 @@ int ip_tunnel_encap(struct sk_buff *skb, struct ip_tunnel *t,
 	case TUNNEL_ENCAP_NONE:
 		return 0;
 	case TUNNEL_ENCAP_FOU:
+	case TUNNEL_ENCAP_GUE:
 		return fou_build_header(skb, &t->encap, t->encap_hlen,
 					protocol, fl4);
 	default:
-- 
2.1.0.rc2.206.gedb03e5
