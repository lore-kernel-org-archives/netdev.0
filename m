From: Thomas Graf <tgraf@suug.ch>
Subject: [net-next RFC 02/14] ip_tunnel: support per packet tunnel metadata
Date: Mon,  1 Jun 2015 16:27:26 +0200
Message-ID: <e5f5b823edde327bb43f5583aa7edfca4504d863.1433167295.git.tgraf@suug.ch>
References: <cover.1433167295.git.tgraf@suug.ch>
Cc: pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, dev@openvswitch.org, tom@herbertland.com,
	edumazet@google.com, jiri@resnulli.us, hannes@stressinduktion.org,
	marcelo.leitner@gmail.com, stephen@networkplumber.org,
	jpettit@nicira.com, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50908 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751609AbbFAO1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 10:27:47 -0400
In-Reply-To: <cover.1433167295.git.tgraf@suug.ch>
In-Reply-To: <cover.1433167295.git.tgraf@suug.ch>
References: <cover.1433167295.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows to attach an ip_tunnel_info metadata structure to skbs
via skb_shared_info to represent receive side tunnel information
as well as transmit side encapsulation instructions.

The new field is added to skb_shared_info as the field is typically
immutable after it has been attached. A new flag indicates whether
the metadata is meant for receive or transmit. This allows to keep
receive metadata attached to the skb all the way through the
forwarding path without mistaking it for transmit instructions. The
tun_info pointer is thus only released if a packet which has been
received on a tunnel is being forwarded to tunnel device again.

Since transmit instructions are immutable per flow which attaches
them to the skb, a reference count is introduced which allows to
reuse the metadata for many packets. Therefore, when a route later
on receives the capability to attach tunnel metadata, it will only
have to allocate the metadata once and can simply increment the
reference counter for each packet that uses that instruction set.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/linux/skbuff.h    |  1 +
 include/net/ip_tunnels.h  | 45 +++++++++++++++++++++++++++++++++++++++++++++
 net/core/skbuff.c         |  8 ++++++++
 net/ipv4/ip_tunnel_core.c | 15 +++++++++++++++
 4 files changed, 69 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 6b41c15..83f9a59 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -323,6 +323,7 @@ struct skb_shared_info {
 	unsigned short	gso_segs;
 	unsigned short  gso_type;
 	struct sk_buff	*frag_list;
+	struct ip_tunnel_info	*tun_info;
 	struct skb_shared_hwtstamps hwtstamps;
 	u32		tskey;
 	__be32          ip6_frag_id;
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 6b9d559..3968705 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -38,10 +38,20 @@ struct ip_tunnel_key {
 	__be16			tp_dst;
 } __packed __aligned(4); /* Minimize padding. */
 
+/* Indicates whether the tunnel info structure represents receive
+ * or transmit tunnel parameters.
+ */
+enum {
+	IP_TUNNEL_INFO_RX,
+	IP_TUNNEL_INFO_TX,
+};
+
 struct ip_tunnel_info {
 	struct ip_tunnel_key	key;
 	const void		*options;
+	atomic_t		refcnt;
 	u8			options_len;
+	u8			mode;
 };
 
 /* 6rd prefix/relay information */
@@ -284,6 +294,41 @@ static inline void iptunnel_xmit_stats(int err,
 	}
 }
 
+struct ip_tunnel_info *ip_tunnel_info_alloc(size_t optslen, gfp_t flags);
+
+static inline void ip_tunnel_info_get(struct ip_tunnel_info *info)
+{
+	atomic_inc(&info->refcnt);
+}
+
+static inline void ip_tunnel_info_put(struct ip_tunnel_info *info)
+{
+	if (!info)
+		return;
+
+	if (atomic_dec_and_test(&info->refcnt))
+		kfree(info);
+}
+
+static inline int skb_attach_tunnel_info(struct sk_buff *skb,
+					 struct ip_tunnel_info *info)
+{
+	if (skb_unclone(skb, GFP_ATOMIC))
+		return -ENOMEM;
+
+	ip_tunnel_info_put(skb_shinfo(skb)->tun_info);
+	ip_tunnel_info_get(info);
+	skb_shinfo(skb)->tun_info = info;
+
+	return 0;
+}
+
+static inline void skb_release_tunnel_info(struct sk_buff *skb)
+{
+	ip_tunnel_info_put(skb_shinfo(skb)->tun_info);
+	skb_shinfo(skb)->tun_info = NULL;
+}
+
 #endif /* CONFIG_INET */
 
 #endif /* __NET_IP_TUNNELS_H */
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 9bac0e6..dbbace2 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -69,6 +69,7 @@
 #include <net/sock.h>
 #include <net/checksum.h>
 #include <net/ip6_checksum.h>
+#include <net/ip_tunnels.h>
 #include <net/xfrm.h>
 
 #include <asm/uaccess.h>
@@ -594,6 +595,8 @@ static void skb_release_data(struct sk_buff *skb)
 			uarg->callback(uarg, true);
 	}
 
+	ip_tunnel_info_put(shinfo->tun_info);
+
 	if (shinfo->frag_list)
 		kfree_skb_list(shinfo->frag_list);
 
@@ -985,6 +988,11 @@ static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	skb_shinfo(new)->gso_size = skb_shinfo(old)->gso_size;
 	skb_shinfo(new)->gso_segs = skb_shinfo(old)->gso_segs;
 	skb_shinfo(new)->gso_type = skb_shinfo(old)->gso_type;
+
+	if (skb_shinfo(old)->tun_info) {
+		ip_tunnel_info_get(skb_shinfo(old)->tun_info);
+		skb_shinfo(new)->tun_info = skb_shinfo(old)->tun_info;
+	}
 }
 
 static inline int skb_alloc_rx_flag(const struct sk_buff *skb)
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 6a51a71..bbd4f91 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -190,3 +190,18 @@ struct rtnl_link_stats64 *ip_tunnel_get_stats64(struct net_device *dev,
 	return tot;
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_get_stats64);
+
+struct ip_tunnel_info *ip_tunnel_info_alloc(size_t optslen, gfp_t flags)
+{
+	struct ip_tunnel_info *info;
+
+	info = kzalloc(sizeof(*info) + optslen, flags);
+	if (!info)
+		return NULL;
+
+	info->options_len = optslen;
+
+	return info;
+
+}
+EXPORT_SYMBOL_GPL(ip_tunnel_info_alloc);
-- 
2.3.5
