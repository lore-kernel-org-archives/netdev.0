From: Patrick McHardy <kaber@trash.net>
Subject: [NETFILTER 09/10]: Handle NAT in IPsec policy checks
Date: Sat,  7 Jan 2006 02:09:43 +0100 (MET)
Message-ID: <20060107010908.8712.62691.sendpatchset@localhost.localdomain>
References: <20060107010855.8712.68786.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David S. Miller <davem@davemloft.net>
In-Reply-To: <20060107010855.8712.68786.sendpatchset@localhost.localdomain>
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
commit dcaa54019ab79d6db75572a239fdc0df0d8019be
tree cf231c2e385835e3c7e25772c86c480e3646fd84
parent 7573dacaa96b4bd8ddc1be7139d17f7c95010413
author Patrick McHardy <kaber@trash.net> Sat, 07 Jan 2006 01:27:39 +0100
committer Patrick McHardy <kaber@trash.net> Sat, 07 Jan 2006 01:27:39 +0100

 include/linux/netfilter.h              |   16 ++++++++++
 net/dccp/ipv4.c                        |    2 +
 net/ipv4/netfilter.c                   |    3 ++
 net/ipv4/netfilter/ip_nat_standalone.c |   50 +++++++++++++++++++++++++++++++-
 net/xfrm/xfrm_policy.c                 |    2 +
 5 files changed, 70 insertions(+), 3 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 79bb977..84506df 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -274,6 +274,20 @@ struct nf_queue_rerouter {
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
@@ -282,6 +296,8 @@ extern struct proc_dir_entry *proc_net_n
 #else /* !CONFIG_NETFILTER */
 #define NF_HOOK(pf, hook, skb, indev, outdev, okfn) (okfn)(skb)
 static inline void nf_ct_attach(struct sk_buff *new, struct sk_buff *skb) {}
+static inline void
+nf_nat_decode_session(struct sk_buff *skb, struct flowi *fl, int family) {}
 #endif /*CONFIG_NETFILTER*/
 
 #endif /*__KERNEL__*/
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 23ba177..00f9832 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -986,6 +986,7 @@ int dccp_v4_rcv(struct sk_buff *skb)
 
 	if (!xfrm4_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_and_relse;
+	nf_reset(skb);
 
 	return sk_receive_skb(sk, skb);
 
@@ -1099,7 +1100,6 @@ int dccp_v4_destroy_sock(struct sock *sk
 		kfree_skb(sk->sk_send_head);
 		sk->sk_send_head = NULL;
 	}
-	nf_reset(skb);
 
 	/* Clean up a referenced DCCP bind bucket. */
 	if (inet_csk(sk)->icsk_bind_hash != NULL)
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index 4c637a1..3321092 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -86,6 +86,9 @@ int ip_route_me_harder(struct sk_buff **
 }
 EXPORT_SYMBOL(ip_route_me_harder);
 
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
index f2edc92..59614a9 100644
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
@@ -985,6 +986,7 @@ int __xfrm_policy_check(struct sock *sk,
 
 	if (xfrm_decode_session(skb, &fl, family) < 0)
 		return 0;
+	nf_nat_decode_session(skb, &fl, family);
 
 	sk_sid = security_sk_sid(sk, &fl, fl_dir);
 
