From: Patrick McHardy <kaber@trash.net>
Subject: [RFC, PATCH 3/5]: netfilter+ipsec - input hooks
Date: Thu, 18 Mar 2004 17:32:14 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4059CF0E.3050708@trash.net>
References: <20040308110331.GA20719@gondor.apana.org.au>	<404C874D.4000907@trash.net> <20040308115858.75cdddca.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090305020603060809060000"
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040308115858.75cdddca.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090305020603060809060000
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds new hooks for input, it is the worst of all patches.
Packets should traverse PRE_ROUTING+LOCAL_IN before decryption and
PRE_ROUTING+LOCAL_IN/FORWARD afterwards. This is tricky because I
didn't find an elegant way to determine when decapsulation is done.
Currently, packets reposted into the stack don't traverse the hooks
at the normal positions but at a later time when we know decapsulation
if done:

- if a reposted packet has a non-local destination after input routing
decapsulation must be done, it then traverses the PRE_ROUTING hook.

- otherwise, it continues until ip_local_deliver_finish but also
skips the LOCAL_IN hook. All xfrm protocol-handlers are marked with
xfrm_prot. If the protocol handler of a packet with a secpath
pointer is a non-xfrm-protocol the packet was handled by ipsec and
is done now, it traverses the PRE_ROUTING and LOCAL_IN hooks then.
This catches packets from both tunnel-mode and transport-mode SAs.

Because the hooks are traversed at a later time than usual several
not-so-nice things have to be done in the nf_postxfrm_* functions.

I don't see a better way currently, but I'm sure you do ;)


--------------090305020603060809060000
Content-Type: text/x-patch;
 name="03-input-hooks.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="03-input-hooks.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/03/18 16:41:37+01:00 kaber@trash.net 
#   [NETFILTER]: post-ipsec input hooks
# 
# net/ipv4/xfrm4_tunnel.c
#   2004/03/18 16:41:31+01:00 kaber@trash.net +1 -0
#   [NETFILTER]: post-ipsec input hooks
# 
# net/ipv4/ipcomp.c
#   2004/03/18 16:41:31+01:00 kaber@trash.net +1 -0
#   [NETFILTER]: post-ipsec input hooks
# 
# net/ipv4/ip_input.c
#   2004/03/18 16:41:31+01:00 kaber@trash.net +15 -6
#   [NETFILTER]: post-ipsec input hooks
# 
# net/ipv4/esp4.c
#   2004/03/18 16:41:31+01:00 kaber@trash.net +1 -0
#   [NETFILTER]: post-ipsec input hooks
# 
# net/ipv4/ah4.c
#   2004/03/18 16:41:31+01:00 kaber@trash.net +1 -0
#   [NETFILTER]: post-ipsec input hooks
# 
# net/core/netfilter.c
#   2004/03/18 16:41:31+01:00 kaber@trash.net +50 -3
#   [NETFILTER]: post-ipsec input hooks
# 
# include/net/protocol.h
#   2004/03/18 16:41:31+01:00 kaber@trash.net +1 -0
#   [NETFILTER]: post-ipsec input hooks
# 
# include/linux/netfilter_ipv4.h
#   2004/03/18 16:41:31+01:00 kaber@trash.net +15 -0
#   [NETFILTER]: post-ipsec input hooks
# 
diff -Nru a/include/linux/netfilter_ipv4.h b/include/linux/netfilter_ipv4.h
--- a/include/linux/netfilter_ipv4.h	Thu Mar 18 16:45:35 2004
+++ b/include/linux/netfilter_ipv4.h	Thu Mar 18 16:45:35 2004
@@ -83,6 +83,21 @@
    Returns true or false. */
 extern int skb_ip_make_writable(struct sk_buff **pskb,
 				unsigned int writable_len);
+
+#ifdef CONFIG_XFRM
+extern int nf_postxfrm_input(struct sk_buff *skb);
+extern int nf_postxfrm_nonlocal(struct sk_buff *skb);
+#else /* CONFIG_XFRM */
+static inline int nf_postxfrm_input(struct sk_buff *skb)
+{
+	return 0;
+}
+
+static inline int nf_postxfrm_nonlocal(struct sk_buff *skb)
+{
+	return 0;
+}
+#endif /* CONFIG_XFRM */
 #endif /*__KERNEL__*/
 
 #endif /*__LINUX_IP_NETFILTER_H*/
diff -Nru a/include/net/protocol.h b/include/net/protocol.h
--- a/include/net/protocol.h	Thu Mar 18 16:45:35 2004
+++ b/include/net/protocol.h	Thu Mar 18 16:45:35 2004
@@ -39,6 +39,7 @@
 	int			(*handler)(struct sk_buff *skb);
 	void			(*err_handler)(struct sk_buff *skb, u32 info);
 	int			no_policy;
+	int			xfrm_prot;
 };
 
 #if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
diff -Nru a/net/core/netfilter.c b/net/core/netfilter.c
--- a/net/core/netfilter.c	Thu Mar 18 16:45:35 2004
+++ b/net/core/netfilter.c	Thu Mar 18 16:45:35 2004
@@ -11,6 +11,7 @@
  */
 #include <linux/config.h>
 #include <linux/netfilter.h>
+#include <linux/netfilter_ipv4.h>
 #include <net/protocol.h>
 #include <linux/init.h>
 #include <linux/skbuff.h>
@@ -25,6 +26,7 @@
 #include <linux/icmp.h>
 #include <net/sock.h>
 #include <net/route.h>
+#include <net/xfrm.h>
 #include <linux/ip.h>
 
 /* In this code, we can be waiting indefinitely for userspace to
@@ -625,9 +627,6 @@
 	struct dst_entry *odst;
 	unsigned int hh_len;
 
-	/* some non-standard hacks like ipt_REJECT.c:send_reset() can cause
-	 * packets with foreign saddr to appear on the NF_IP_LOCAL_OUT hook.
-	 */
 	if (inet_addr_type(iph->saddr) == RTN_LOCAL) {
 		fl.nl_u.ip4_u.daddr = iph->daddr;
 		fl.nl_u.ip4_u.saddr = iph->saddr;
@@ -679,6 +678,54 @@
 
 	return 0;
 }
+
+#ifdef CONFIG_XFRM
+static inline int nf_postxfrm_done(struct sk_buff *skb)
+{
+	return 0;
+}
+
+static inline int nf_postxfrm_input2(struct sk_buff *skb)
+{
+	if (inet_addr_type(skb->nh.iph->daddr) != RTN_LOCAL) {
+		if (ip_route_me_harder(&skb) == 0)
+			dst_input(skb);
+		else
+			kfree_skb(skb);
+		return -1;
+	}
+
+	return NF_HOOK(PF_INET, NF_IP_LOCAL_IN, skb, skb->dev, NULL,
+	               nf_postxfrm_done);
+}
+
+int nf_postxfrm_input(struct sk_buff *skb)
+{
+	int off = skb->data - skb->nh.raw;
+
+	__skb_push(skb, off);
+	/* Fix header len and checksum if last xfrm was transport mode */
+	if (!skb->sp->x[skb->sp->len - 1].xvec->props.mode) {
+		skb->nh.iph->tot_len = htons(skb->len);
+		ip_send_check(skb->nh.iph);
+	}
+
+	nf_reset(skb);
+	if (NF_HOOK(PF_INET, NF_IP_PRE_ROUTING, skb, skb->dev, NULL,
+	            nf_postxfrm_input2) != 0)
+		return -1;
+
+	__skb_pull(skb, off);
+	return 0;
+}
+
+int nf_postxfrm_nonlocal(struct sk_buff *skb)
+{
+	nf_reset(skb);
+	return NF_HOOK(PF_INET, NF_IP_PRE_ROUTING, skb, skb->dev, NULL,
+	               nf_postxfrm_done);
+}
+#endif /* CONFIG_XFRM */
 
 int skb_ip_make_writable(struct sk_buff **pskb, unsigned int writable_len)
 {
diff -Nru a/net/ipv4/ah4.c b/net/ipv4/ah4.c
--- a/net/ipv4/ah4.c	Thu Mar 18 16:45:35 2004
+++ b/net/ipv4/ah4.c	Thu Mar 18 16:45:35 2004
@@ -344,6 +344,7 @@
 	.handler	=	xfrm4_rcv,
 	.err_handler	=	ah4_err,
 	.no_policy	=	1,
+	.xfrm_prot	=	1,
 };
 
 static int __init ah4_init(void)
diff -Nru a/net/ipv4/esp4.c b/net/ipv4/esp4.c
--- a/net/ipv4/esp4.c	Thu Mar 18 16:45:35 2004
+++ b/net/ipv4/esp4.c	Thu Mar 18 16:45:35 2004
@@ -577,6 +577,7 @@
 	.handler	=	xfrm4_rcv,
 	.err_handler	=	esp4_err,
 	.no_policy	=	1,
+	.xfrm_prot	=	1,
 };
 
 static int __init esp4_init(void)
diff -Nru a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
--- a/net/ipv4/ip_input.c	Thu Mar 18 16:45:35 2004
+++ b/net/ipv4/ip_input.c	Thu Mar 18 16:45:35 2004
@@ -224,6 +224,12 @@
 	resubmit:
 		hash = protocol & (MAX_INET_PROTOS - 1);
 		raw_sk = sk_head(&raw_v4_htable[hash]);
+		ipprot = inet_protos[hash];
+		smp_read_barrier_depends();
+
+		if (skb->sp && !ipprot->xfrm_prot)
+			if (nf_postxfrm_input(skb))
+				goto out;
 
 		/* If there maybe a raw socket we must check - if not we
 		 * don't care less
@@ -231,10 +237,9 @@
 		if (raw_sk)
 			raw_v4_input(skb, skb->nh.iph, hash);
 
-		if ((ipprot = inet_protos[hash]) != NULL) {
+		if (ipprot != NULL) {
 			int ret;
 
-			smp_read_barrier_depends();
 			if (!ipprot->no_policy &&
 			    !xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb)) {
 				kfree_skb(skb);
@@ -279,8 +284,8 @@
 			return 0;
 	}
 
-	return NF_HOOK(PF_INET, NF_IP_LOCAL_IN, skb, skb->dev, NULL,
-		       ip_local_deliver_finish);
+	return NF_HOOK_COND(PF_INET, NF_IP_LOCAL_IN, skb, skb->dev, NULL,
+	                    ip_local_deliver_finish, !skb->sp);
 }
 
 static inline int ip_rcv_finish(struct sk_buff *skb)
@@ -346,6 +351,10 @@
 		}
 	}
 
+	if (skb->sp && !(((struct rtable *)skb->dst)->rt_flags&RTCF_LOCAL))
+		if (nf_postxfrm_nonlocal(skb))
+			goto drop;
+
 	return dst_input(skb);
 
 inhdr_error:
@@ -418,8 +427,8 @@
 		}
 	}
 
-	return NF_HOOK(PF_INET, NF_IP_PRE_ROUTING, skb, dev, NULL,
-		       ip_rcv_finish);
+	return NF_HOOK_COND(PF_INET, NF_IP_PRE_ROUTING, skb, dev, NULL,
+	                    ip_rcv_finish, !skb->sp);
 
 inhdr_error:
 	IP_INC_STATS_BH(IpInHdrErrors);
diff -Nru a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
--- a/net/ipv4/ipcomp.c	Thu Mar 18 16:45:35 2004
+++ b/net/ipv4/ipcomp.c	Thu Mar 18 16:45:35 2004
@@ -408,6 +408,7 @@
 	.handler	=	xfrm4_rcv,
 	.err_handler	=	ipcomp4_err,
 	.no_policy	=	1,
+	.xfrm_prot	=	1,
 };
 
 static int __init ipcomp4_init(void)
diff -Nru a/net/ipv4/xfrm4_tunnel.c b/net/ipv4/xfrm4_tunnel.c
--- a/net/ipv4/xfrm4_tunnel.c	Thu Mar 18 16:45:35 2004
+++ b/net/ipv4/xfrm4_tunnel.c	Thu Mar 18 16:45:35 2004
@@ -171,6 +171,7 @@
 	.handler	=	ipip_rcv,
 	.err_handler	=	ipip_err,
 	.no_policy	=	1,
+	.xfrm_prot	=	1,
 };
 
 static int __init ipip_init(void)


--------------090305020603060809060000--
