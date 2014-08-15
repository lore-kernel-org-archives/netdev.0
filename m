From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/3] vxlan: propagate sock pointer to ip6tunnel_xmit path
Date: Fri, 15 Aug 2014 20:32:55 +0200
Message-ID: <1408127576-11518-2-git-send-email-jiri@resnulli.us>
References: <1408127576-11518-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, stephen@networkplumber.org,
	cwang@twopensource.com, pshelar@nicira.com,
	nicolas.dichtel@6wind.com, therbert@google.com,
	dborkman@redhat.com, edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:58361 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751116AbaHOSdC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2014 14:33:02 -0400
Received: by mail-wi0-f180.google.com with SMTP id n3so1177819wiv.7
        for <netdev@vger.kernel.org>; Fri, 15 Aug 2014 11:33:00 -0700 (PDT)
In-Reply-To: <1408127576-11518-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/vxlan.c      | 2 +-
 include/net/ip6_tunnel.h | 5 +++--
 include/net/ipv6.h       | 6 +++++-
 net/ipv6/ip6_gre.c       | 2 +-
 net/ipv6/ip6_tunnel.c    | 2 +-
 net/ipv6/output_core.c   | 6 +++---
 6 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 1fb7b37..94bfa8e 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1652,7 +1652,7 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 	ip6h->daddr	  = *daddr;
 	ip6h->saddr	  = *saddr;
 
-	ip6tunnel_xmit(skb, dev);
+	ip6tunnel_xmit(vs->sock->sk, skb, dev);
 	return 0;
 }
 #endif
diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index a5593da..ba1506e 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -70,13 +70,14 @@ __u16 ip6_tnl_parse_tlv_enc_lim(struct sk_buff *skb, __u8 *raw);
 __u32 ip6_tnl_get_cap(struct ip6_tnl *t, const struct in6_addr *laddr,
 			     const struct in6_addr *raddr);
 
-static inline void ip6tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
+static inline void ip6tunnel_xmit(struct sock *sk, struct sk_buff *skb,
+				  struct net_device *dev)
 {
 	struct net_device_stats *stats = &dev->stats;
 	int pkt_len, err;
 
 	pkt_len = skb->len;
-	err = ip6_local_out(skb);
+	err = ip6_local_out_sk(sk, skb);
 
 	if (net_xmit_eval(err) == 0) {
 		struct pcpu_sw_netstats *tstats = this_cpu_ptr(dev->tstats);
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index e8ac138..135cd58 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -802,7 +802,11 @@ int ip6_input(struct sk_buff *skb);
 int ip6_mc_input(struct sk_buff *skb);
 
 int __ip6_local_out(struct sk_buff *skb);
-int ip6_local_out(struct sk_buff *skb);
+int ip6_local_out_sk(struct sock *sk, struct sk_buff *skb);
+static inline int ip6_local_out(struct sk_buff *skb)
+{
+	return ip6_local_out_sk(skb->sk, skb);
+}
 
 /*
  *	Extension header (options) processing
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 5f19dfb..fd0812b 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -754,7 +754,7 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 		}
 	}
 
-	ip6tunnel_xmit(skb, dev);
+	ip6tunnel_xmit(skb->sk, skb, dev);
 	if (ndst)
 		ip6_tnl_dst_store(tunnel, ndst);
 	return 0;
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index f9de5a6..5e8691b 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1053,7 +1053,7 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 	ipv6h->nexthdr = proto;
 	ipv6h->saddr = fl6->saddr;
 	ipv6h->daddr = fl6->daddr;
-	ip6tunnel_xmit(skb, dev);
+	ip6tunnel_xmit(skb->sk, skb, dev);
 	if (ndst)
 		ip6_tnl_dst_store(t, ndst);
 	return 0;
diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index d746f75..8d3e9fb 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -85,14 +85,14 @@ int __ip6_local_out(struct sk_buff *skb)
 }
 EXPORT_SYMBOL_GPL(__ip6_local_out);
 
-int ip6_local_out(struct sk_buff *skb)
+int ip6_local_out_sk(struct sock *sk, struct sk_buff *skb)
 {
 	int err;
 
 	err = __ip6_local_out(skb);
 	if (likely(err == 1))
-		err = dst_output(skb);
+		err = dst_output_sk(sk, skb);
 
 	return err;
 }
-EXPORT_SYMBOL_GPL(ip6_local_out);
+EXPORT_SYMBOL_GPL(ip6_local_out_sk);
-- 
1.9.3
