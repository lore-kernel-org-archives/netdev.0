From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 net-next 6/7] gue: TX support for using remote checksum offload option
Date: Tue,  4 Nov 2014 09:06:56 -0800
Message-ID: <1415120817-2105-7-git-send-email-therbert@google.com>
References: <1415120817-2105-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:65007 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752372AbaKDRHf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 12:07:35 -0500
Received: by mail-ig0-f169.google.com with SMTP id hn18so6779346igb.4
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 09:07:34 -0800 (PST)
In-Reply-To: <1415120817-2105-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add if_tunnel flag TUNNEL_ENCAP_FLAG_REMCSUM to configure
remote checksum offload on an IP tunnel. Add logic in gue_build_header
to insert remote checksum offload option.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/fou.h              | 14 +++++++++++++-
 include/uapi/linux/if_tunnel.h |  1 +
 net/ipv4/fou.c                 | 35 ++++++++++++++++++++++++++++++++---
 3 files changed, 46 insertions(+), 4 deletions(-)

diff --git a/include/net/fou.h b/include/net/fou.h
index cf4ce88..25b26ff 100644
--- a/include/net/fou.h
+++ b/include/net/fou.h
@@ -20,7 +20,19 @@ static size_t fou_encap_hlen(struct ip_tunnel_encap *e)
 
 static size_t gue_encap_hlen(struct ip_tunnel_encap *e)
 {
-	return sizeof(struct udphdr) + sizeof(struct guehdr);
+	size_t len;
+	bool need_priv = false;
+
+	len = sizeof(struct udphdr) + sizeof(struct guehdr);
+
+	if (e->flags & TUNNEL_ENCAP_FLAG_REMCSUM) {
+		len += GUE_PLEN_REMCSUM;
+		need_priv = true;
+	}
+
+	len += need_priv ? GUE_LEN_PRIV : 0;
+
+	return len;
 }
 
 #endif
diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
index 280d9e0..bd3cc11 100644
--- a/include/uapi/linux/if_tunnel.h
+++ b/include/uapi/linux/if_tunnel.h
@@ -69,6 +69,7 @@ enum tunnel_encap_types {
 
 #define TUNNEL_ENCAP_FLAG_CSUM		(1<<0)
 #define TUNNEL_ENCAP_FLAG_CSUM6		(1<<1)
+#define TUNNEL_ENCAP_FLAG_REMCSUM	(1<<2)
 
 /* SIT-mode i_flags */
 #define	SIT_ISATAP	0x0001
diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index a3b8c5b..fb0db99 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -562,11 +562,19 @@ int gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 	bool csum = !!(e->flags & TUNNEL_ENCAP_FLAG_CSUM);
 	int type = csum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
 	struct guehdr *guehdr;
-	size_t optlen = 0;
+	size_t hdrlen, optlen = 0;
 	__be16 sport;
 	void *data;
 	bool need_priv = false;
 
+	if ((e->flags & TUNNEL_ENCAP_FLAG_REMCSUM) &&
+	    skb->ip_summed == CHECKSUM_PARTIAL) {
+		csum = false;
+		optlen += GUE_PLEN_REMCSUM;
+		type |= SKB_GSO_TUNNEL_REMCSUM;
+		need_priv = true;
+	}
+
 	optlen += need_priv ? GUE_LEN_PRIV : 0;
 
 	skb = iptunnel_handle_offloads(skb, csum, type);
@@ -578,7 +586,9 @@ int gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 	sport = e->sport ? : udp_flow_src_port(dev_net(skb->dev),
 					       skb, 0, 0, false);
 
-	skb_push(skb, sizeof(struct guehdr) + optlen);
+	hdrlen = sizeof(struct guehdr) + optlen;
+
+	skb_push(skb, hdrlen);
 
 	guehdr = (struct guehdr *)skb->data;
 
@@ -597,7 +607,26 @@ int gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 		*flags = 0;
 		data += GUE_LEN_PRIV;
 
-		/* Add private flags */
+		if (type & SKB_GSO_TUNNEL_REMCSUM) {
+			u16 csum_start = skb_checksum_start_offset(skb);
+			__be16 *pd = data;
+
+			if (csum_start < hdrlen)
+				return -EINVAL;
+
+			csum_start -= hdrlen;
+			pd[0] = htons(csum_start);
+			pd[1] = htons(csum_start + skb->csum_offset);
+
+			if (!skb_is_gso(skb)) {
+				skb->ip_summed = CHECKSUM_NONE;
+				skb->encapsulation = 0;
+			}
+
+			*flags |= GUE_PFLAG_REMCSUM;
+			data += GUE_PLEN_REMCSUM;
+		}
+
 	}
 
 	fou_build_udp(skb, e, fl4, protocol, sport);
-- 
2.1.0.rc2.206.gedb03e5
