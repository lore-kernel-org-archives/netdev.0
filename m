From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 04/05: fix crashes in bridge netfilter caused by fragment jumps
Date: Tue, 15 Dec 2009 17:14:32 +0100 (MET)
Message-ID: <20091215161431.4146.98183.sendpatchset@x2.localnet>
References: <20091215161426.4146.55284.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59650 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759451AbZLOQOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2009 11:14:33 -0500
In-Reply-To: <20091215161426.4146.55284.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 8fa9ff6849bb86c59cc2ea9faadf3cb2d5223497
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Dec 15 16:59:59 2009 +0100

    netfilter: fix crashes in bridge netfilter caused by fragment jumps
    
    When fragments from bridge netfilter are passed to IPv4 or IPv6 conntrack
    and a reassembly queue with the same fragment key already exists from
    reassembling a similar packet received on a different device (f.i. with
    multicasted fragments), the reassembled packet might continue on a different
    codepath than where the head fragment originated. This can cause crashes
    in bridge netfilter when a fragment received on a non-bridge device (and
    thus with skb->nf_bridge == NULL) continues through the bridge netfilter
    code.
    
    Add a new reassembly identifier for packets originating from bridge
    netfilter and use it to put those packets in insolated queues.
    
    Fixes http://bugzilla.kernel.org/show_bug.cgi?id=14805
    
    Reported-and-Tested-by: Chong Qiao <qiaochong@loongson.cn>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/ip.h b/include/net/ip.h
index e6b9d12..85108cf 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -337,6 +337,7 @@ enum ip_defrag_users {
 	IP_DEFRAG_CALL_RA_CHAIN,
 	IP_DEFRAG_CONNTRACK_IN,
 	IP_DEFRAG_CONNTRACK_OUT,
+	IP_DEFRAG_CONNTRACK_BRIDGE_IN,
 	IP_DEFRAG_VS_IN,
 	IP_DEFRAG_VS_OUT,
 	IP_DEFRAG_VS_FWD
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index d691603..ccab594 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -354,6 +354,7 @@ enum ip6_defrag_users {
 	IP6_DEFRAG_LOCAL_DELIVER,
 	IP6_DEFRAG_CONNTRACK_IN,
 	IP6_DEFRAG_CONNTRACK_OUT,
+	IP6_DEFRAG_CONNTRACK_BRIDGE_IN,
 };
 
 struct ip6_create_arg {
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index fa2d6b6..331ead3 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -14,6 +14,7 @@
 #include <net/route.h>
 #include <net/ip.h>
 
+#include <linux/netfilter_bridge.h>
 #include <linux/netfilter_ipv4.h>
 #include <net/netfilter/ipv4/nf_defrag_ipv4.h>
 
@@ -34,6 +35,20 @@ static int nf_ct_ipv4_gather_frags(struct sk_buff *skb, u_int32_t user)
 	return err;
 }
 
+static enum ip_defrag_users nf_ct_defrag_user(unsigned int hooknum,
+					      struct sk_buff *skb)
+{
+#ifdef CONFIG_BRIDGE_NETFILTER
+	if (skb->nf_bridge &&
+	    skb->nf_bridge->mask & BRNF_NF_BRIDGE_PREROUTING)
+		return IP_DEFRAG_CONNTRACK_BRIDGE_IN;
+#endif
+	if (hooknum == NF_INET_PRE_ROUTING)
+		return IP_DEFRAG_CONNTRACK_IN;
+	else
+		return IP_DEFRAG_CONNTRACK_OUT;
+}
+
 static unsigned int ipv4_conntrack_defrag(unsigned int hooknum,
 					  struct sk_buff *skb,
 					  const struct net_device *in,
@@ -50,10 +65,8 @@ static unsigned int ipv4_conntrack_defrag(unsigned int hooknum,
 #endif
 	/* Gather fragments. */
 	if (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)) {
-		if (nf_ct_ipv4_gather_frags(skb,
-					    hooknum == NF_INET_PRE_ROUTING ?
-					    IP_DEFRAG_CONNTRACK_IN :
-					    IP_DEFRAG_CONNTRACK_OUT))
+		enum ip_defrag_users user = nf_ct_defrag_user(hooknum, skb);
+		if (nf_ct_ipv4_gather_frags(skb, user))
 			return NF_STOLEN;
 	}
 	return NF_ACCEPT;
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index c0a82fe..0956eba 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -20,6 +20,7 @@
 #include <net/ipv6.h>
 #include <net/inet_frag.h>
 
+#include <linux/netfilter_bridge.h>
 #include <linux/netfilter_ipv6.h>
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_helper.h>
@@ -190,6 +191,11 @@ out:
 static enum ip6_defrag_users nf_ct6_defrag_user(unsigned int hooknum,
 						struct sk_buff *skb)
 {
+#ifdef CONFIG_BRIDGE_NETFILTER
+	if (skb->nf_bridge &&
+	    skb->nf_bridge->mask & BRNF_NF_BRIDGE_PREROUTING)
+		return IP6_DEFRAG_CONNTRACK_BRIDGE_IN;
+#endif
 	if (hooknum == NF_INET_PRE_ROUTING)
 		return IP6_DEFRAG_CONNTRACK_IN;
 	else
