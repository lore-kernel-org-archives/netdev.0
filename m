From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 11/13]: [NETFILTER]: Handle NAT in IPsec policy checks
Date: Sun, 20 Nov 2005 17:31:42 +0100
Message-ID: <20051120163142.16666.14733.sendpatchset@localhost.localdomain>
References: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: davem@davemloft.net
In-Reply-To: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

[NETFILTER]: Handle NAT in IPsec policy checks

Handle NAT of decapsulated IPsec packets by reconstructing the struct flowi
of the original packet from the conntrack information for IPsec policy
checks.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 8b46eb2d8365ab18cc965f37681033162a834fe5
tree 5e8b46d5acd6fa4b1445f181fcf8bce94cade5b0
parent 3f615f37e68903f0eea66f5b242bfbb1875ee204
author Patrick McHardy <kaber@trash.net> Sat, 19 Nov 2005 22:09:15 +0100
committer Patrick McHardy <kaber@trash.net> Sat, 19 Nov 2005 22:09:15 +0100

 include/linux/netfilter.h              |   16 ++++++++++
 net/ipv4/netfilter.c                   |    3 ++
 net/ipv4/netfilter/ip_nat_standalone.c |   50 +++++++++++++++++++++++++++++++-
 net/xfrm/xfrm_policy.c                 |    2 +
 4 files changed, 69 insertions(+), 2 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index be365e7..cc9ee97 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -261,6 +261,20 @@ struct nf_queue_rerouter {
 extern int nf_register_queue_rerouter(int pf, struct nf_queue_rerouter *rer);
 extern int nf_unregister_queue_rerouter(int pf);
 
+#include <net/flow.h>
+extern void (*ip_nat_decode_session)(struct sk_buff *, struct flowi *);
+
+static inline void
+nf_nat_decode_session(struct sk_buff *skb, struct flowi *fl, int family)
+{
+#ifdef CONFIG_IP_NF_NAT_NEEDED
+	void (*decodefn)(struct sk_buff *, struct flowi *);
+
+	if (family == AF_INET && (decodefn = ip_nat_decode_session) != NULL)
+		decodefn(skb, fl);
+#endif
+}
+
 #ifdef CONFIG_PROC_FS
 #include <linux/proc_fs.h>
 extern struct proc_dir_entry *proc_net_netfilter;
@@ -269,6 +283,8 @@ extern struct proc_dir_entry *proc_net_n
 #else /* !CONFIG_NETFILTER */
 #define NF_HOOK(pf, hook, skb, indev, outdev, okfn) (okfn)(skb)
 static inline void nf_ct_attach(struct sk_buff *new, struct sk_buff *skb) {}
+static inline void
+nf_nat_decode_session(struct sk_buff *skb, struct flowi *fl, int family) {}
 #endif /*CONFIG_NETFILTER*/
 
 #endif /*__KERNEL__*/
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index 8fda96a..b66856d 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -134,6 +134,9 @@ drop:
 }
 #endif /* CONFIG_XFRM */
 
+void (*ip_nat_decode_session)(struct sk_buff *, struct flowi *);
+EXPORT_SYMBOL(ip_nat_decode_session);
+
 /*
  * Extra routing may needed on local out, as the QUEUE target never
  * returns control to the table.
diff --git a/net/ipv4/netfilter/ip_nat_standalone.c b/net/ipv4/netfilter/ip_nat_standalone.c
index b518697..8b8a1f0 100644
--- a/net/ipv4/netfilter/ip_nat_standalone.c
+++ b/net/ipv4/netfilter/ip_nat_standalone.c
@@ -55,6 +55,44 @@
 			         : ((hooknum) == NF_IP_LOCAL_IN ? "LOCAL_IN"  \
 				    : "*ERROR*")))
 
+#ifdef CONFIG_XFRM
+static void nat_decode_session(struct sk_buff *skb, struct flowi *fl)
+{
+	struct ip_conntrack *ct;
+	struct ip_conntrack_tuple *t;
+	enum ip_conntrack_info ctinfo;
+	enum ip_conntrack_dir dir;
+	unsigned long statusbit;
+
+	ct = ip_conntrack_get(skb, &ctinfo);
+	if (ct == NULL)
+		return;
+	dir = CTINFO2DIR(ctinfo);
+	t = &ct->tuplehash[dir].tuple;
+
+	if (dir == IP_CT_DIR_ORIGINAL)
+		statusbit = IPS_DST_NAT;
+	else
+		statusbit = IPS_SRC_NAT;
+
+	if (ct->status & statusbit) {
+		fl->fl4_dst = t->dst.ip;
+		if (t->dst.protonum == IPPROTO_TCP ||
+		    t->dst.protonum == IPPROTO_UDP)
+			fl->fl_ip_dport = t->dst.u.tcp.port;
+	}
+
+	statusbit ^= IPS_NAT_MASK;
+
+	if (ct->status & statusbit) {
+		fl->fl4_src = t->src.ip;
+		if (t->dst.protonum == IPPROTO_TCP ||
+		    t->dst.protonum == IPPROTO_UDP)
+			fl->fl_ip_sport = t->src.u.tcp.port;
+	}
+}
+#endif
+		
 static unsigned int
 ip_nat_fn(unsigned int hooknum,
 	  struct sk_buff **pskb,
@@ -330,10 +368,14 @@ static int init_or_cleanup(int init)
 
 	if (!init) goto cleanup;
 
+#ifdef CONFIG_XFRM
+	BUG_ON(ip_nat_decode_session != NULL);
+	ip_nat_decode_session = nat_decode_session;
+#endif
 	ret = ip_nat_rule_init();
 	if (ret < 0) {
 		printk("ip_nat_init: can't setup rules.\n");
-		goto cleanup_nothing;
+		goto cleanup_decode_session;
 	}
 	ret = nf_register_hook(&ip_nat_in_ops);
 	if (ret < 0) {
@@ -381,7 +423,11 @@ static int init_or_cleanup(int init)
 	nf_unregister_hook(&ip_nat_in_ops);
  cleanup_rule_init:
 	ip_nat_rule_cleanup();
- cleanup_nothing:
+ cleanup_decode_session:
+#ifdef CONFIG_XFRM
+	ip_nat_decode_session = NULL;
+	synchronize_net();
+#endif
 	return ret;
 }
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index e441f35..8351bb0 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -22,6 +22,7 @@
 #include <linux/workqueue.h>
 #include <linux/notifier.h>
 #include <linux/netdevice.h>
+#include <linux/netfilter.h>
 #include <linux/module.h>
 #include <net/xfrm.h>
 #include <net/ip.h>
@@ -938,6 +939,7 @@ int __xfrm_policy_check(struct sock *sk,
 
 	if (xfrm_decode_session(skb, &fl, family) < 0)
 		return 0;
+	nf_nat_decode_session(skb, &fl, family);
 
 	/* First, check used SA against their selectors. */
 	if (skb->sp) {
