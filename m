From: Amine Kherbouche <amine.kherbouche@6wind.com>
Subject: [PATCH v3 1/1] ip_tunnel: add mpls over gre encapsulation
Date: Wed, 27 Sep 2017 11:37:13 +0200
Message-ID: <198fd7591bc1daae4727ee8b950e116b59f2d4c3.1506504229.git.amine.kherbouche@6wind.com>
References: <cover.1506504229.git.amine.kherbouche@6wind.com>
Cc: amine.kherbouche@6wind.com, equinox@diac24.net
To: netdev@vger.kernel.org, xeb@mail.ru, roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:48203 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750854AbdI0Jhj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 05:37:39 -0400
Received: by mail-wm0-f50.google.com with SMTP id m127so15984646wmm.3
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 02:37:39 -0700 (PDT)
In-Reply-To: <cover.1506504229.git.amine.kherbouche@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit introduces the MPLSoGRE support (RFC 4023), using ip tunnel
API.

Encap:
  - Add a new iptunnel type mpls.
  - Share tx path: gre type mpls loaded from skb->protocol.

Decap:
  - pull gre hdr and call mpls_forward().

Signed-off-by: Amine Kherbouche <amine.kherbouche@6wind.com>
---
 include/linux/mpls.h           |  2 ++
 include/uapi/linux/if_tunnel.h |  1 +
 net/ipv4/ip_gre.c              | 11 +++++++++
 net/ipv6/ip6_gre.c             | 11 +++++++++
 net/mpls/af_mpls.c             | 52 ++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 77 insertions(+)

diff --git a/include/linux/mpls.h b/include/linux/mpls.h
index 384fb22..57203c1 100644
--- a/include/linux/mpls.h
+++ b/include/linux/mpls.h
@@ -8,4 +8,6 @@
 #define MPLS_TC_MASK		(MPLS_LS_TC_MASK >> MPLS_LS_TC_SHIFT)
 #define MPLS_LABEL_MASK		(MPLS_LS_LABEL_MASK >> MPLS_LS_LABEL_SHIFT)
 
+int mpls_gre_rcv(struct sk_buff *skb, int gre_hdr_len);
+
 #endif  /* _LINUX_MPLS_H */
diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
index 2e52088..a2f48c0 100644
--- a/include/uapi/linux/if_tunnel.h
+++ b/include/uapi/linux/if_tunnel.h
@@ -84,6 +84,7 @@ enum tunnel_encap_types {
 	TUNNEL_ENCAP_NONE,
 	TUNNEL_ENCAP_FOU,
 	TUNNEL_ENCAP_GUE,
+	TUNNEL_ENCAP_MPLS,
 };
 
 #define TUNNEL_ENCAP_FLAG_CSUM		(1<<0)
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 9cee986..0a898f4 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -32,6 +32,9 @@
 #include <linux/netfilter_ipv4.h>
 #include <linux/etherdevice.h>
 #include <linux/if_ether.h>
+#if IS_ENABLED(CONFIG_MPLS)
+#include <linux/mpls.h>
+#endif
 
 #include <net/sock.h>
 #include <net/ip.h>
@@ -412,6 +415,14 @@ static int gre_rcv(struct sk_buff *skb)
 			return 0;
 	}
 
+	if (unlikely(tpi.proto == htons(ETH_P_MPLS_UC))) {
+#if IS_ENABLED(CONFIG_MPLS)
+		return mpls_gre_rcv(skb, hdr_len);
+#else
+		goto drop;
+#endif
+	}
+
 	if (ipgre_rcv(skb, &tpi, hdr_len) == PACKET_RCVD)
 		return 0;
 
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index c82d41e..5a0f5e1 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -34,6 +34,9 @@
 #include <linux/hash.h>
 #include <linux/if_tunnel.h>
 #include <linux/ip6_tunnel.h>
+#if IS_ENABLED(CONFIG_MPLS)
+#include <linux/mpls.h>
+#endif
 
 #include <net/sock.h>
 #include <net/ip.h>
@@ -476,6 +479,14 @@ static int gre_rcv(struct sk_buff *skb)
 	if (hdr_len < 0)
 		goto drop;
 
+	if (unlikely(tpi.proto == htons(ETH_P_MPLS_UC))) {
+#if IS_ENABLED(CONFIG_MPLS)
+		return mpls_gre_rcv(skb, hdr_len);
+#else
+		goto drop;
+#endif
+	}
+
 	if (iptunnel_pull_header(skb, hdr_len, tpi.proto, false))
 		goto drop;
 
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index c5b9ce4..53ec7c0 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -16,6 +16,7 @@
 #include <net/arp.h>
 #include <net/ip_fib.h>
 #include <net/netevent.h>
+#include <net/ip_tunnels.h>
 #include <net/netns/generic.h>
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ipv6.h>
@@ -39,6 +40,36 @@ static int one = 1;
 static int label_limit = (1 << 20) - 1;
 static int ttl_max = 255;
 
+#if IS_ENABLED(CONFIG_NET_IP_TUNNEL)
+size_t ipgre_mpls_encap_hlen(struct ip_tunnel_encap *e)
+{
+	return sizeof(struct mpls_shim_hdr);
+}
+
+static const struct ip_tunnel_encap_ops mpls_iptun_ops = {
+	.encap_hlen	= ipgre_mpls_encap_hlen,
+};
+
+static int ipgre_tunnel_encap_add_mpls_ops(void)
+{
+	return ip_tunnel_encap_add_ops(&mpls_iptun_ops, TUNNEL_ENCAP_MPLS);
+}
+
+static void ipgre_tunnel_encap_del_mpls_ops(void)
+{
+	ip_tunnel_encap_del_ops(&mpls_iptun_ops, TUNNEL_ENCAP_MPLS);
+}
+#else
+static int ipgre_tunnel_encap_add_mpls_ops(void)
+{
+	return 0;
+}
+
+static void ipgre_tunnel_encap_del_mpls_ops(void)
+{
+}
+#endif
+
 static void rtmsg_lfib(int event, u32 label, struct mpls_route *rt,
 		       struct nlmsghdr *nlh, struct net *net, u32 portid,
 		       unsigned int nlm_flags);
@@ -443,6 +474,22 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 	return NET_RX_DROP;
 }
 
+int mpls_gre_rcv(struct sk_buff *skb, int gre_hdr_len)
+{
+	if (unlikely(!pskb_may_pull(skb, gre_hdr_len)))
+		goto drop;
+
+	/* Pop GRE hdr and reset the skb */
+	skb_pull(skb, gre_hdr_len);
+	skb_reset_network_header(skb);
+
+	return mpls_forward(skb, skb->dev, NULL, NULL);
+drop:
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+EXPORT_SYMBOL(mpls_gre_rcv);
+
 static struct packet_type mpls_packet_type __read_mostly = {
 	.type = cpu_to_be16(ETH_P_MPLS_UC),
 	.func = mpls_forward,
@@ -2485,6 +2532,10 @@ static int __init mpls_init(void)
 		      0);
 	rtnl_register(PF_MPLS, RTM_GETNETCONF, mpls_netconf_get_devconf,
 		      mpls_netconf_dump_devconf, 0);
+	err = ipgre_tunnel_encap_add_mpls_ops();
+	if (err)
+		pr_err("Can't add mpls over gre tunnel ops\n");
+
 	err = 0;
 out:
 	return err;
@@ -2502,6 +2553,7 @@ static void __exit mpls_exit(void)
 	dev_remove_pack(&mpls_packet_type);
 	unregister_netdevice_notifier(&mpls_dev_notifier);
 	unregister_pernet_subsys(&mpls_net_ops);
+	ipgre_tunnel_encap_del_mpls_ops();
 }
 module_exit(mpls_exit);
 
-- 
2.1.4
