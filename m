From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 09/09: nf_defrag_ipv4: fix compilation error with NF_CONNTRACK=n
Date: Thu, 18 Feb 2010 19:21:15 +0100 (MET)
Message-ID: <20100218182115.21826.32451.sendpatchset@x2.localnet>
References: <20100218182103.21826.17908.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100218182103.21826.17908.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 37ee3d5b3e979a168536e7e2f15bd1e769cb4122
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Feb 18 19:04:44 2010 +0100

    netfilter: nf_defrag_ipv4: fix compilation error with NF_CONNTRACK=n
    
    As reported by Randy Dunlap <randy.dunlap@oracle.com>, compilation
    of nf_defrag_ipv4 fails with:
    
    include/net/netfilter/nf_conntrack.h:94: error: field 'ct_general' has incomplete type
    include/net/netfilter/nf_conntrack.h:178: error: 'const struct sk_buff' has no member named 'nfct'
    include/net/netfilter/nf_conntrack.h:185: error: implicit declaration of function 'nf_conntrack_put'
    include/net/netfilter/nf_conntrack.h:294: error: 'const struct sk_buff' has no member named 'nfct'
    net/ipv4/netfilter/nf_defrag_ipv4.c:45: error: 'struct sk_buff' has no member named 'nfct'
    net/ipv4/netfilter/nf_defrag_ipv4.c:46: error: 'struct sk_buff' has no member named 'nfct'
    
    net/nf_conntrack.h must not be included with NF_CONNTRACK=n, add a
    few #ifdefs. Long term the header file should be fixed to be usable
    even with NF_CONNTRACK=n.
    
    Tested-by: Randy Dunlap <randy.dunlap@oracle.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/netfilter/nf_conntrack_zones.h b/include/net/netfilter/nf_conntrack_zones.h
index 0bbb2bd..034efe8 100644
--- a/include/net/netfilter/nf_conntrack_zones.h
+++ b/include/net/netfilter/nf_conntrack_zones.h
@@ -1,10 +1,11 @@
 #ifndef _NF_CONNTRACK_ZONES_H
 #define _NF_CONNTRACK_ZONES_H
 
-#include <net/netfilter/nf_conntrack_extend.h>
-
 #define NF_CT_DEFAULT_ZONE	0
 
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+#include <net/netfilter/nf_conntrack_extend.h>
+
 struct nf_conntrack_zone {
 	u16	id;
 };
@@ -20,4 +21,5 @@ static inline u16 nf_ct_zone(const struct nf_conn *ct)
 	return NF_CT_DEFAULT_ZONE;
 }
 
+#endif /* CONFIG_NF_CONNTRACK || CONFIG_NF_CONNTRACK_MODULE */
 #endif /* _NF_CONNTRACK_ZONES_H */
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index d498a70..cb763ae 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -16,9 +16,11 @@
 
 #include <linux/netfilter_bridge.h>
 #include <linux/netfilter_ipv4.h>
-#include <net/netfilter/nf_conntrack_zones.h>
 #include <net/netfilter/ipv4/nf_defrag_ipv4.h>
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 #include <net/netfilter/nf_conntrack.h>
+#endif
+#include <net/netfilter/nf_conntrack_zones.h>
 
 /* Returns new sk_buff, or NULL */
 static int nf_ct_ipv4_gather_frags(struct sk_buff *skb, u_int32_t user)
@@ -42,8 +44,10 @@ static enum ip_defrag_users nf_ct_defrag_user(unsigned int hooknum,
 {
 	u16 zone = NF_CT_DEFAULT_ZONE;
 
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 	if (skb->nfct)
 		zone = nf_ct_zone((struct nf_conn *)skb->nfct);
+#endif
 
 #ifdef CONFIG_BRIDGE_NETFILTER
 	if (skb->nf_bridge &&
