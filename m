From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 3/6] bpf: reuse dev_is_mac_header_xmit for redirect
Date: Sat, 26 Nov 2016 01:28:06 +0100
Message-ID: <5a71b0f7704bd6b8b47333a27afb1b3e5c2c9611.1480119396.git.daniel@iogearbox.net>
References: <cover.1480119395.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42850 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751691AbcKZA2o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 19:28:44 -0500
In-Reply-To: <cover.1480119395.git.daniel@iogearbox.net>
In-Reply-To: <cover.1480119395.git.daniel@iogearbox.net>
References: <cover.1480119395.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit dcf800344a91 ("net/sched: act_mirred: Refactor detection whether
dev needs xmit at mac header") added dev_is_mac_header_xmit(); since it's
also useful elsewhere, move it to if_arp.h and reuse it for BPF.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/if_arp.h | 16 ++++++++++++++++
 net/core/filter.c      | 14 ++++----------
 net/sched/act_mirred.c | 15 +--------------
 3 files changed, 21 insertions(+), 24 deletions(-)

diff --git a/include/linux/if_arp.h b/include/linux/if_arp.h
index f563907..3355efc 100644
--- a/include/linux/if_arp.h
+++ b/include/linux/if_arp.h
@@ -44,4 +44,20 @@ static inline int arp_hdr_len(struct net_device *dev)
 		return sizeof(struct arphdr) + (dev->addr_len + sizeof(u32)) * 2;
 	}
 }
+
+static inline bool dev_is_mac_header_xmit(const struct net_device *dev)
+{
+	switch (dev->type) {
+	case ARPHRD_TUNNEL:
+	case ARPHRD_TUNNEL6:
+	case ARPHRD_SIT:
+	case ARPHRD_IPGRE:
+	case ARPHRD_VOID:
+	case ARPHRD_NONE:
+		return false;
+	default:
+		return true;
+	}
+}
+
 #endif	/* _LINUX_IF_ARP_H */
diff --git a/net/core/filter.c b/net/core/filter.c
index ea315af..698a262 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -30,6 +30,7 @@
 #include <linux/inet.h>
 #include <linux/netdevice.h>
 #include <linux/if_packet.h>
+#include <linux/if_arp.h>
 #include <linux/gfp.h>
 #include <net/ip.h>
 #include <net/protocol.h>
@@ -1696,17 +1697,10 @@ static int __bpf_redirect_common(struct sk_buff *skb, struct net_device *dev,
 static int __bpf_redirect(struct sk_buff *skb, struct net_device *dev,
 			  u32 flags)
 {
-	switch (dev->type) {
-	case ARPHRD_TUNNEL:
-	case ARPHRD_TUNNEL6:
-	case ARPHRD_SIT:
-	case ARPHRD_IPGRE:
-	case ARPHRD_VOID:
-	case ARPHRD_NONE:
-		return __bpf_redirect_no_mac(skb, dev, flags);
-	default:
+	if (dev_is_mac_header_xmit(dev))
 		return __bpf_redirect_common(skb, dev, flags);
-	}
+	else
+		return __bpf_redirect_no_mac(skb, dev, flags);
 }
 
 BPF_CALL_3(bpf_clone_redirect, struct sk_buff *, skb, u32, ifindex, u64, flags)
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index b2d417b..1af7baa 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -21,6 +21,7 @@
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/gfp.h>
+#include <linux/if_arp.h>
 #include <net/net_namespace.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
@@ -73,20 +74,6 @@ static void tcf_mirred_release(struct tc_action *a, int bind)
 static unsigned int mirred_net_id;
 static struct tc_action_ops act_mirred_ops;
 
-static bool dev_is_mac_header_xmit(const struct net_device *dev)
-{
-	switch (dev->type) {
-	case ARPHRD_TUNNEL:
-	case ARPHRD_TUNNEL6:
-	case ARPHRD_SIT:
-	case ARPHRD_IPGRE:
-	case ARPHRD_VOID:
-	case ARPHRD_NONE:
-		return false;
-	}
-	return true;
-}
-
 static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 			   struct nlattr *est, struct tc_action **a, int ovr,
 			   int bind)
-- 
1.9.3
