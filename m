From: Patrick McHardy <kaber@trash.net>
Subject: [NF+IPsec 6/6]: Handle NAT in IPsec policy checks
Date: Mon, 17 Oct 2005 02:22:45 +0200
Message-ID: <4352EED5.2000803@trash.net>
Mime-Version: 1.0
Content-Type: text/x-patch;
 name="06.diff"
Content-Transfer-Encoding: 7bit
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Content-Disposition: inline;
 filename="06.diff"
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

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 28bfee77b74d8e81c535735b8580a5a0b52a1ccf
tree 923eb3417866e8973f05a04988f5e871cd8e71b7
parent 373ca7e8b42cb5abbaf86e41a755363aa4029850
author Patrick McHardy <kaber@trash.net> Mon, 17 Oct 2005 01:50:55 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 17 Oct 2005 01:50:55 +0200

 include/linux/netfilter.h              |   16 ++++++++++
 net/dccp/ipv4.c                        |    2 +
 net/ipv4/ip_input.c                    |   14 ++++-----
 net/ipv4/netfilter.c                   |    3 ++
 net/ipv4/netfilter/ip_nat_standalone.c |   50 +++++++++++++++++++++++++++++++-
 net/ipv4/raw.c                         |    1 +
 net/ipv4/tcp_ipv4.c                    |    3 ++
 net/ipv4/udp.c                         |    2 +
 net/sctp/input.c                       |    1 +
 net/xfrm/xfrm_policy.c                 |    2 +
 10 files changed, 84 insertions(+), 10 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -266,6 +266,20 @@ static inline int nf_defer_fragment(stru
 	return skb->nfct != NULL;
 }
 
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
@@ -275,6 +289,8 @@ extern struct proc_dir_entry *proc_net_n
 #define NF_HOOK(pf, hook, skb, indev, outdev, okfn) (okfn)(skb)
 static inline void nf_ct_attach(struct sk_buff *new, struct sk_buff *skb) {}
 static inline int nf_defer_fragment(struct sk_buff *skb) { return 0; }
+static inline void
+nf_nat_decode_session(struct sk_buff *skb, struct flowi *fl, int family) {}
 #endif /*CONFIG_NETFILTER*/
 
 #endif /*__KERNEL__*/
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -1171,6 +1171,7 @@ int dccp_v4_rcv(struct sk_buff *skb)
 		dccp_pr_debug("xfrm4_policy_check failed\n");
 		goto discard_and_relse;
 	}
+	nf_reset(skb);
 
         if (sk_filter(sk, skb, 0)) {
 		dccp_pr_debug("sk_filter failed\n");
@@ -1193,6 +1194,7 @@ int dccp_v4_rcv(struct sk_buff *skb)
 no_dccp_socket:
 	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
 		goto discard_it;
+	nf_reset(skb);
 	/*
 	 * Step 2:
 	 *		Generate Reset(No Connection) unless P.type == Reset
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -203,10 +203,6 @@ static inline int ip_local_deliver_finis
 
 	__skb_pull(skb, ihl);
 
-	/* Free reference early: we don't need it any more, and it may
-           hold ip_conntrack module loaded indefinitely. */
-	nf_reset(skb);
-
         /* Point into the IP datagram, just past the header. */
         skb->h.raw = skb->data;
 
@@ -231,10 +227,12 @@ static inline int ip_local_deliver_finis
 		if ((ipprot = rcu_dereference(inet_protos[hash])) != NULL) {
 			int ret;
 
-			if (!ipprot->no_policy &&
-			    !xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb)) {
-				kfree_skb(skb);
-				goto out;
+			if (!ipprot->no_policy) {
+				if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb)) {
+					kfree_skb(skb);
+					goto out;
+				}
+				nf_reset(skb);
 			}
 			ret = ipprot->handler(skb);
 			if (ret < 0) {
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -117,6 +117,9 @@ int ip_dst_output(struct sk_buff *skb)
 EXPORT_SYMBOL(ip_dst_output);
 #endif /* CONFIG_XFRM */
 
+void (*ip_nat_decode_session)(struct sk_buff *, struct flowi *);
+EXPORT_SYMBOL(ip_nat_decode_session);
+
 /*
  * Extra routing may needed on local out, as the QUEUE target never
  * returns control to the table.
diff --git a/net/ipv4/netfilter/ip_nat_standalone.c b/net/ipv4/netfilter/ip_nat_standalone.c
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
@@ -329,10 +367,14 @@ static int init_or_cleanup(int init)
 
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
@@ -380,7 +422,11 @@ static int init_or_cleanup(int init)
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
 
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -255,6 +255,7 @@ int raw_rcv(struct sock *sk, struct sk_b
 		kfree_skb(skb);
 		return NET_RX_DROP;
 	}
+	nf_reset(skb);
 
 	skb_push(skb, skb->data - skb->nh.raw);
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1247,6 +1247,7 @@ process:
 
 	if (!xfrm4_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_and_relse;
+	nf_reset(skb);
 
 	if (sk_filter(sk, skb, 0))
 		goto discard_and_relse;
@@ -1269,6 +1270,7 @@ process:
 no_tcp_socket:
 	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
 		goto discard_it;
+	nf_reset(skb);
 
 	if (skb->len < (th->doff << 2) || tcp_checksum_complete(skb)) {
 bad_packet:
@@ -1291,6 +1293,7 @@ do_time_wait:
 		inet_twsk_put((struct inet_timewait_sock *) sk);
 		goto discard_it;
 	}
+	nf_reset(skb);
 
 	if (skb->len < (th->doff << 2) || tcp_checksum_complete(skb)) {
 		TCP_INC_STATS_BH(TCP_MIB_INERRS);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1001,6 +1001,7 @@ static int udp_queue_rcv_skb(struct sock
 		kfree_skb(skb);
 		return -1;
 	}
+	nf_reset(skb);
 
 	if (up->encap_type) {
 		/*
@@ -1166,6 +1167,7 @@ int udp_rcv(struct sk_buff *skb)
 
 	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
 		goto drop;
+	nf_reset(skb);
 
 	/* No socket. Drop packet silently, if checksum is wrong */
 	if (udp_checksum_complete(skb))
diff --git a/net/sctp/input.c b/net/sctp/input.c
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -243,6 +243,7 @@ int sctp_rcv(struct sk_buff *skb)
 
 	if (!xfrm_policy_check(sk, XFRM_POLICY_IN, skb, family))
 		goto discard_release;
+	nf_reset(skb);
 
 	ret = sk_filter(sk, skb, 1);
 	if (ret)
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
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
@@ -937,6 +938,7 @@ int __xfrm_policy_check(struct sock *sk,
 
 	if (xfrm_decode_session(skb, &fl, family) < 0)
 		return 0;
+	nf_nat_decode_session(skb, &fl, family);
 
 	/* First, check used SA against their selectors. */
 	if (skb->sp) {
