From: Tom Lendacky <toml@us.ibm.com>
Subject: [PATCH] IPSec: Missing IPv6 policy checks
Date: 28 Mar 2003 09:22:15 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1048864940.14454.10.camel@tomlt2.tomloffice.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, toml@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Below is a patch for your consideration for some policy checks that
are missing (as compared to the IPv4 code).  This patch fixes some
of the tunnel mode problems I've been encountering.

I'm not completely sure about the change to ip6_output.c as far as
the placement of the xfrm6_route_forward call within the
ip6_forward function.

Please review and let me know if I should make any changes.

Thanks,
Tom

diff -ur linux-2.5.66-orig/include/net/protocol.h linux-2.5.66/include/net/protocol.h
--- linux-2.5.66-orig/include/net/protocol.h	2003-03-24 16:00:20.000000000 -0600
+++ linux-2.5.66/include/net/protocol.h	2003-03-27 16:19:33.000000000 -0600
@@ -50,6 +50,7 @@
 			       struct inet6_skb_parm *opt,
 			       int type, int code, int offset,
 			       __u32 info);
+	int	no_policy;
 };
 
 #endif
diff -ur linux-2.5.66-orig/net/ipv6/ah6.c linux-2.5.66/net/ipv6/ah6.c
--- linux-2.5.66-orig/net/ipv6/ah6.c	2003-03-24 16:00:56.000000000 -0600
+++ linux-2.5.66/net/ipv6/ah6.c	2003-03-27 16:20:40.000000000 -0600
@@ -330,6 +330,7 @@
 static struct inet6_protocol ah6_protocol = {
 	.handler	=	xfrm6_rcv,
 	.err_handler	=	ah6_err,
+	.no_policy	=	1,
 };
 
 int __init ah6_init(void)
diff -ur linux-2.5.66-orig/net/ipv6/esp6.c linux-2.5.66/net/ipv6/esp6.c
--- linux-2.5.66-orig/net/ipv6/esp6.c	2003-03-24 16:00:52.000000000 -0600
+++ linux-2.5.66/net/ipv6/esp6.c	2003-03-27 16:21:05.000000000 -0600
@@ -499,6 +499,7 @@
 static struct inet6_protocol esp6_protocol = {
 	.handler 	=	xfrm6_rcv,
 	.err_handler	=	esp6_err,
+	.no_policy	=	1,
 };
 
 int __init esp6_init(void)
diff -ur linux-2.5.66-orig/net/ipv6/ip6_input.c linux-2.5.66/net/ipv6/ip6_input.c
--- linux-2.5.66-orig/net/ipv6/ip6_input.c	2003-03-24 16:01:13.000000000 -0600
+++ linux-2.5.66/net/ipv6/ip6_input.c	2003-03-27 16:22:28.000000000 -0600
@@ -43,6 +43,7 @@
 #include <net/ndisc.h>
 #include <net/ip6_route.h>
 #include <net/addrconf.h>
+#include <net/xfrm.h>
 


@@ -149,7 +150,14 @@
 
 	hash = nexthdr & (MAX_INET_PROTOS - 1);
 	if ((ipprot = inet6_protos[hash]) != NULL) {
-		int ret = ipprot->handler(&skb);
+		int ret;
+		
+		if (!ipprot->no_policy &&
+		    !xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb)) {
+			kfree_skb(skb);
+			return 0;
+		}
+		ret = ipprot->handler(&skb);
 		if (ret < 0) {
 			nexthdr = -ret;
 			goto resubmit;
@@ -157,9 +165,11 @@
 		IP6_INC_STATS_BH(Ip6InDelivers);
 	} else {
 		if (!raw_sk) {
-			IP6_INC_STATS_BH(Ip6InUnknownProtos);
-			icmpv6_param_prob(skb, ICMPV6_UNK_NEXTHDR,
-					  offsetof(struct ipv6hdr, nexthdr));
+			if (xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb)) {
+				IP6_INC_STATS_BH(Ip6InUnknownProtos);
+				icmpv6_param_prob(skb, ICMPV6_UNK_NEXTHDR,
+						  offsetof(struct ipv6hdr, nexthdr));
+			}
 		} else {
 			IP6_INC_STATS_BH(Ip6InDelivers);
 			kfree_skb(skb);
diff -ur linux-2.5.66-orig/net/ipv6/ip6_output.c linux-2.5.66/net/ipv6/ip6_output.c
--- linux-2.5.66-orig/net/ipv6/ip6_output.c	2003-03-24 15:59:56.000000000 -0600
+++ linux-2.5.66/net/ipv6/ip6_output.c	2003-03-27 16:22:45.000000000 -0600
@@ -50,6 +50,7 @@
 #include <net/addrconf.h>
 #include <net/rawv6.h>
 #include <net/icmp.h>
+#include <net/xfrm.h>
 
 static __inline__ void ipv6_select_ident(struct sk_buff *skb, struct frag_hdr *fhdr)
 {
@@ -747,6 +748,9 @@
 	if (ipv6_devconf.forwarding == 0)
 		goto error;
 
+	if (!xfrm6_policy_check(NULL, XFRM_POLICY_FWD, skb))
+		goto drop;
+
 	skb->ip_summed = CHECKSUM_NONE;
 
 	/*
@@ -781,6 +785,9 @@
 		return -ETIMEDOUT;
 	}
 
+	if (!xfrm6_route_forward(skb))
+		goto drop;
+
 	/* IPv6 specs say nothing about it, but it is clear that we cannot
 	   send redirects to source routed frames.
 	 */
diff -ur linux-2.5.66-orig/net/ipv6/tcp_ipv6.c linux-2.5.66/net/ipv6/tcp_ipv6.c
--- linux-2.5.66-orig/net/ipv6/tcp_ipv6.c	2003-03-24 16:00:45.000000000 -0600
+++ linux-2.5.66/net/ipv6/tcp_ipv6.c	2003-03-27 16:23:08.000000000 -0600
@@ -2193,6 +2193,7 @@
 static struct inet6_protocol tcpv6_protocol = {
 	.handler	=	tcp_v6_rcv,
 	.err_handler	=	tcp_v6_err,
+	.no_policy	=	1,
 };
 
 extern struct proto_ops inet6_stream_ops;
diff -ur linux-2.5.66-orig/net/ipv6/udp.c linux-2.5.66/net/ipv6/udp.c
--- linux-2.5.66-orig/net/ipv6/udp.c	2003-03-27 16:18:57.000000000 -0600
+++ linux-2.5.66/net/ipv6/udp.c	2003-03-27 16:23:12.000000000 -0600
@@ -955,6 +955,7 @@
 static struct inet6_protocol udpv6_protocol = {
 	.handler	=	udpv6_rcv,
 	.err_handler	=	udpv6_err,
+	.no_policy	=	1,
 };
 
 #define LINE_LEN 190
