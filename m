From: Patrick McHardy <kaber@trash.net>
Subject: [RFC, PATCH 5/5]: netfilter+ipsec - policy checks
Date: Thu, 18 Mar 2004 17:32:39 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4059CF27.4030803@trash.net>
References: <20040308110331.GA20719@gondor.apana.org.au>	<404C874D.4000907@trash.net> <20040308115858.75cdddca.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030909010207090303020502"
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040308115858.75cdddca.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030909010207090303020502
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch makes xfrm_policy_check locate the correct policy after NAT.
For protocols which do policy checks in their receive routines the
reference to nfct has to be kept until policy checks are done, the
other ones still drop it in ip_local_deliver_finish.


--------------030909010207090303020502
Content-Type: text/x-patch;
 name="05-nat-policy-check.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="05-nat-policy-check.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/03/18 16:44:21+01:00 kaber@trash.net 
#   [NETFILTER]: Make policy checks find correct policy after NAT
# 
# net/xfrm/xfrm_policy.c
#   2004/03/18 16:44:12+01:00 kaber@trash.net +2 -0
#   [NETFILTER]: Make policy checks find correct policy after NAT
# 
# net/ipv4/udp.c
#   2004/03/18 16:44:12+01:00 kaber@trash.net +2 -0
#   [NETFILTER]: Make policy checks find correct policy after NAT
# 
# net/ipv4/tcp_ipv4.c
#   2004/03/18 16:44:12+01:00 kaber@trash.net +1 -0
#   [NETFILTER]: Make policy checks find correct policy after NAT
# 
# net/ipv4/raw.c
#   2004/03/18 16:44:12+01:00 kaber@trash.net +1 -0
#   [NETFILTER]: Make policy checks find correct policy after NAT
# 
# net/ipv4/ip_input.c
#   2004/03/18 16:44:12+01:00 kaber@trash.net +6 -8
#   [NETFILTER]: Make policy checks find correct policy after NAT
# 
# net/core/netfilter.c
#   2004/03/18 16:44:12+01:00 kaber@trash.net +43 -0
#   [NETFILTER]: Make policy checks find correct policy after NAT
# 
# include/linux/netfilter.h
#   2004/03/18 16:44:12+01:00 kaber@trash.net +16 -0
#   [NETFILTER]: Make policy checks find correct policy after NAT
# 
diff -Nru a/include/linux/netfilter.h b/include/linux/netfilter.h
--- a/include/linux/netfilter.h	Thu Mar 18 16:46:27 2004
+++ b/include/linux/netfilter.h	Thu Mar 18 16:46:27 2004
@@ -171,5 +171,21 @@
 #define NF_HOOK_COND NF_HOOK
 #endif /*CONFIG_NETFILTER*/
 
+#ifdef CONFIG_XFRM
+#ifdef CONFIG_IP_NF_NAT_NEEDED
+struct flowi;
+extern void nf_nat_decode_session4(struct sk_buff *skb, struct flowi *fl);
+
+static inline void
+nf_nat_decode_session(struct sk_buff *skb, struct flowi *fl, int family)
+{
+	if (family == AF_INET)
+		nf_nat_decode_session4(skb, fl);
+}
+#else /* CONFIG_IP_NF_NAT_NEEDED */
+#define nf_nat_decode_session(skb,fl,family)
+#endif /* CONFIG_IP_NF_NAT_NEEDED */
+#endif /* CONFIG_XFRM */
+
 #endif /*__KERNEL__*/
 #endif /*__LINUX_NETFILTER_H*/
diff -Nru a/net/core/netfilter.c b/net/core/netfilter.c
--- a/net/core/netfilter.c	Thu Mar 18 16:46:27 2004
+++ b/net/core/netfilter.c	Thu Mar 18 16:46:27 2004
@@ -739,6 +739,49 @@
 	return NF_HOOK(PF_INET, NF_IP_PRE_ROUTING, skb, skb->dev, NULL,
 	               nf_postxfrm_done);
 }
+
+#ifdef CONFIG_IP_NF_NAT_NEEDED
+#include <linux/netfilter_ipv4/ip_conntrack.h>
+#include <linux/netfilter_ipv4/ip_nat.h>
+
+void nf_nat_decode_session4(struct sk_buff *skb, struct flowi *fl)
+{
+	struct ip_conntrack *ct;
+	struct ip_conntrack_tuple *t;
+	struct ip_nat_info_manip *m;
+	unsigned int i;
+
+	if (skb->nfct == NULL)
+		return;
+	ct = (struct ip_conntrack *)skb->nfct->master;
+
+	for (i = 0; i < ct->nat.info.num_manips; i++) {
+		m = &ct->nat.info.manips[i];
+		t = &ct->tuplehash[m->direction].tuple;
+
+		switch (m->hooknum) {
+		case NF_IP_PRE_ROUTING:
+			if (m->maniptype != IP_NAT_MANIP_DST)
+				break;
+			fl->fl4_dst = t->dst.ip;
+			if (t->dst.protonum == IPPROTO_TCP ||
+			    t->dst.protonum == IPPROTO_UDP)
+				fl->fl_ip_dport = t->dst.u.tcp.port;
+			break;
+#ifdef CONFIG_IP_NF_NAT_LOCAL
+		case NF_IP_LOCAL_IN:
+			if (m->maniptype != IP_NAT_MANIP_SRC)
+				break;
+			fl->fl4_src = t->src.ip;
+			if (t->dst.protonum == IPPROTO_TCP ||
+			    t->dst.protonum == IPPROTO_UDP)
+				fl->fl_ip_sport = t->src.u.tcp.port;
+			break;
+#endif
+		}
+	}
+}
+#endif /* CONFIG_IP_NF_NAT_NEEDED */
 #endif /* CONFIG_XFRM */
 
 int skb_ip_make_writable(struct sk_buff **pskb, unsigned int writable_len)
diff -Nru a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
--- a/net/ipv4/ip_input.c	Thu Mar 18 16:46:27 2004
+++ b/net/ipv4/ip_input.c	Thu Mar 18 16:46:27 2004
@@ -206,10 +206,6 @@
 
 	__skb_pull(skb, ihl);
 
-	/* Free reference early: we don't need it any more, and it may
-           hold ip_conntrack module loaded indefinitely. */
-	nf_reset(skb);
-
         /* Point into the IP datagram, just past the header. */
         skb->h.raw = skb->data;
 
@@ -240,10 +236,12 @@
 		if (ipprot != NULL) {
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
diff -Nru a/net/ipv4/raw.c b/net/ipv4/raw.c
--- a/net/ipv4/raw.c	Thu Mar 18 16:46:27 2004
+++ b/net/ipv4/raw.c	Thu Mar 18 16:46:27 2004
@@ -249,6 +249,7 @@
 		kfree_skb(skb);
 		return NET_RX_DROP;
 	}
+	nf_reset(skb);
 
 	skb_push(skb, skb->data - skb->nh.raw);
 
diff -Nru a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c	Thu Mar 18 16:46:27 2004
+++ b/net/ipv4/tcp_ipv4.c	Thu Mar 18 16:46:27 2004
@@ -1785,6 +1785,7 @@
 
 	if (!xfrm4_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_and_relse;
+	nf_reset(skb);
 
 	if (sk_filter(sk, skb, 0))
 		goto discard_and_relse;
diff -Nru a/net/ipv4/udp.c b/net/ipv4/udp.c
--- a/net/ipv4/udp.c	Thu Mar 18 16:46:27 2004
+++ b/net/ipv4/udp.c	Thu Mar 18 16:46:27 2004
@@ -1030,6 +1030,7 @@
 		kfree_skb(skb);
 		return -1;
 	}
+	nf_reset(skb);
 
 	if (up->encap_type) {
 		/*
@@ -1195,6 +1196,7 @@
 
 	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
 		goto drop;
+	nf_reset(skb);
 
 	/* No socket. Drop packet silently, if checksum is wrong */
 	if (udp_checksum_complete(skb))
diff -Nru a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
--- a/net/xfrm/xfrm_policy.c	Thu Mar 18 16:46:27 2004
+++ b/net/xfrm/xfrm_policy.c	Thu Mar 18 16:46:27 2004
@@ -21,6 +21,7 @@
 #include <linux/workqueue.h>
 #include <linux/notifier.h>
 #include <linux/netdevice.h>
+#include <linux/netfilter.h>
 #include <net/xfrm.h>
 #include <net/ip.h>
 
@@ -908,6 +909,7 @@
 
 	if (_decode_session(skb, &fl, family) < 0)
 		return 0;
+	nf_nat_decode_session(skb, &fl, family);
 
 	/* First, check used SA against their selectors. */
 	if (skb->sp) {


--------------030909010207090303020502--
