From: Masahide Nakamura <nakam@linux-ipv6.org>
Subject: [PATCH][IPSEC] IPsec policy can be matched by ICMP type and code
Date: Mon, 9 Aug 2004 17:54:04 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040809175404.301bd60a@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

This patch makes that IPsec policy can be matched by ICMP type and
code. Actually setkey(ipsec-tools) already has their interface so it
follows setkey's manner where type/code are stored in selector. I
added shortcuts for them as a trial. Please read the patch and its log
below first.

Thinking of raw socket (in outbound case), the patch supports only
ICMP; it is out of scope such packet as user-land builds non-ICMP data
(e.g. TCP/UDP) and sends through raw socket. IMO this behavior is
enough, however does anybody have comments?

The patch is against 2.6.8-rc3. Can you check it?

Regards,
-- 
Masahide NAKAMURA


Log:
IPsec ICMP type and code support.

* inbound:
 - add entry of ICMP[46] to decode_session[46]() to update flowi.
 - add xfrm_selector_icmp_match().
* outbound:
 - store type/code to flowi when it seems to be ICMP[46] data in raw
socket.


Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>


Index: include/linux/xfrm.h
===================================================================
RCS file: /cvsroot/usagi/usagi/kernel/linux26/include/linux/xfrm.h,v
retrieving revision 1.1.1.14
diff -u -r1.1.1.14 xfrm.h
--- include/linux/xfrm.h	19 Jul 2004 16:53:28 -0000	1.1.1.14
+++ include/linux/xfrm.h	9 Aug 2004 08:31:12 -0000
@@ -43,6 +43,15 @@
 	__u8	proto;
 	int	ifindex;
 	uid_t	user;
+	/*
+	 * XXX: ICMP values defined like a manner which setkey does:
+	 * XXX: ICMP-type is "sport" area and ICMP-code is stored "dport" area.
+	 * XXX: Should it be formed union like struct flowi? --nakam
+	 */
+#define xfrmsel_icmp_type	sport
+#define xfrmsel_icmp_type_mask	sport_mask
+#define xfrmsel_icmp_code	dport
+#define xfrmsel_icmp_code_mask	dport_mask
 };
 
 #define XFRM_INF (~(__u64)0)
Index: include/net/xfrm.h
===================================================================
RCS file: /cvsroot/usagi/usagi/kernel/linux26/include/net/xfrm.h,v
retrieving revision 1.1.1.28
diff -u -r1.1.1.28 xfrm.h
--- include/net/xfrm.h	3 Aug 2004 23:00:04 -0000	1.1.1.28
+++ include/net/xfrm.h	9 Aug 2004 08:31:13 -0000
@@ -463,25 +463,54 @@
 }
 
 static inline int
+__xfrm_selector_icmp_match(struct xfrm_selector *sel, struct flowi *fl)
+{
+	/* In selector, type/code are stored 16-bit area and
+	 * should be network byte-order.
+	 */
+	__u8 *xtype = (__u8 *)&sel->xfrmsel_icmp_type;
+	__u8 *xcode = (__u8 *)&sel->xfrmsel_icmp_code;
+	__u8 *xtypemask = (__u8 *)&sel->xfrmsel_icmp_type_mask;
+	__u8 *xcodemask = (__u8 *)&sel->xfrmsel_icmp_code_mask;
+
+	return (!(xtype[0]&xtypemask[0]) &&
+		!((fl->fl_icmp_type^xtype[1])&xtypemask[1])) &&
+	       (!(xcode[0]&xcodemask[0]) &&
+		!((fl->fl_icmp_code^xcode[1])&xcodemask[1]));
+}
+
+static inline int
 __xfrm4_selector_match(struct xfrm_selector *sel, struct flowi *fl)
 {
-	return  addr_match(&fl->fl4_dst, &sel->daddr, sel->prefixlen_d) &&
-		addr_match(&fl->fl4_src, &sel->saddr, sel->prefixlen_s) &&
-		!((fl->fl_ip_dport^sel->dport)&sel->dport_mask) &&
-		!((fl->fl_ip_sport^sel->sport)&sel->sport_mask) &&
-		(fl->proto == sel->proto || !sel->proto) &&
-		(fl->oif == sel->ifindex || !sel->ifindex);
+	if (!(addr_match(&fl->fl4_dst, &sel->daddr, sel->prefixlen_d) &&
+	      addr_match(&fl->fl4_src, &sel->saddr, sel->prefixlen_s) &&
+	      (fl->proto == sel->proto || !sel->proto) &&
+	      (fl->oif == sel->ifindex || !sel->ifindex)))
+		return 0;
+	      
+	if (fl->proto == IPPROTO_ICMP)
+		return __xfrm_selector_icmp_match(sel, fl);
+	else {
+		return !((fl->fl_ip_dport^sel->dport)&sel->dport_mask) &&
+		       !((fl->fl_ip_sport^sel->sport)&sel->sport_mask);
+	}
 }
 
 static inline int
 __xfrm6_selector_match(struct xfrm_selector *sel, struct flowi *fl)
 {
-	return  addr_match(&fl->fl6_dst, &sel->daddr, sel->prefixlen_d) &&
-		addr_match(&fl->fl6_src, &sel->saddr, sel->prefixlen_s) &&
-		!((fl->fl_ip_dport^sel->dport)&sel->dport_mask) &&
-		!((fl->fl_ip_sport^sel->sport)&sel->sport_mask) &&
-		(fl->proto == sel->proto || !sel->proto) &&
-		(fl->oif == sel->ifindex || !sel->ifindex);
+	if (!(addr_match(&fl->fl6_dst, &sel->daddr, sel->prefixlen_d) &&
+	      addr_match(&fl->fl6_src, &sel->saddr, sel->prefixlen_s) &&
+	      (fl->oif == sel->ifindex || !sel->ifindex) &&
+	      (fl->proto == sel->proto || !sel->proto)))
+		return 0;
+
+	if (fl->proto == IPPROTO_ICMPV6)
+		return __xfrm_selector_icmp_match(sel, fl);
+	else {
+		return !((fl->fl_ip_dport^sel->dport)&sel->dport_mask) &&
+		       !((fl->fl_ip_sport^sel->sport)&sel->sport_mask);
+	}
 }
 
 static inline int
Index: net/ipv4/raw.c
===================================================================
RCS file: /cvsroot/usagi/usagi/kernel/linux26/net/ipv4/raw.c,v
retrieving revision 1.1.1.29
diff -u -r1.1.1.29 raw.c
--- net/ipv4/raw.c	3 Aug 2004 23:01:54 -0000	1.1.1.29
+++ net/ipv4/raw.c	9 Aug 2004 08:31:15 -0000
@@ -323,6 +323,51 @@
 	return err; 
 }
 
+static void raw_probe_proto_opt(struct flowi *fl, struct msghdr *msg)
+{
+	struct iovec *iov;
+	u8 *type = NULL;
+	u8 *code = NULL;
+	int probed = 0;
+	int i;
+
+	if (!msg->msg_iov)
+		return;
+
+	for (i = 0; i < msg->msg_iovlen; i++) {
+		iov = &msg->msg_iov[i];
+		if (!iov)
+			continue;
+
+		switch (fl->proto) {
+		case IPPROTO_ICMP:
+			/* check if one-byte field is readable or not. */
+			if (iov->iov_base && iov->iov_len < 1)
+				break;
+
+			if (!type) {
+				type = iov->iov_base;
+				/* check if code field is readable or not. */
+				if (iov->iov_len > 1)
+					code = type + 1;
+			} else if (!code)
+				code = iov->iov_base;
+
+			if (type && code) {
+				fl->fl_icmp_type = *type;
+				fl->fl_icmp_code = *code;
+				probed = 1;
+			}
+			break;
+		default:
+			probed = 1;
+			break;
+		}
+		if (probed)
+			break;
+	}
+}
+
 static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		       size_t len)
 {
@@ -429,6 +474,8 @@
 				    .proto = inet->hdrincl ? IPPROTO_RAW :
 					    		     sk->sk_protocol,
 				  };
+		raw_probe_proto_opt(&fl, msg);
+
 		err = ip_route_output_flow(&rt, &fl, sk, !(msg->msg_flags&MSG_DONTWAIT));
 	}
 	if (err)
Index: net/ipv4/xfrm4_policy.c
===================================================================
RCS file: /cvsroot/usagi/usagi/kernel/linux26/net/ipv4/xfrm4_policy.c,v
retrieving revision 1.1.1.7
diff -u -r1.1.1.7 xfrm4_policy.c
--- net/ipv4/xfrm4_policy.c	19 Jul 2004 16:55:14 -0000	1.1.1.7
+++ net/ipv4/xfrm4_policy.c	9 Aug 2004 08:31:15 -0000
@@ -183,6 +183,15 @@
 			}
 			break;
 
+		case IPPROTO_ICMP:
+			if (pskb_may_pull(skb, xprth + 2 - skb->data)) {
+				u8 *icmp = xprth;
+
+				fl->fl_icmp_type = icmp[0];
+				fl->fl_icmp_code = icmp[1];
+			}
+			break;
+
 		case IPPROTO_ESP:
 			if (pskb_may_pull(skb, xprth + 4 - skb->data)) {
 				u32 *ehdr = (u32 *)xprth;
Index: net/ipv6/raw.c
===================================================================
RCS file: /cvsroot/usagi/usagi/kernel/linux26/net/ipv6/raw.c,v
retrieving revision 1.1.1.35
diff -u -r1.1.1.35 raw.c
--- net/ipv6/raw.c	3 Aug 2004 23:01:59 -0000	1.1.1.35
+++ net/ipv6/raw.c	9 Aug 2004 08:31:15 -0000
@@ -555,6 +555,52 @@
 	IP6_INC_STATS(IPSTATS_MIB_OUTDISCARDS);
 	return err; 
 }
+
+static void rawv6_probe_proto_opt(struct flowi *fl, struct msghdr *msg)
+{
+	struct iovec *iov;
+	u8 *type = NULL;
+	u8 *code = NULL;
+	int probed = 0;
+	int i;
+
+	if (!msg->msg_iov)
+		return;
+
+	for (i = 0; i < msg->msg_iovlen; i++) {
+		iov = &msg->msg_iov[i];
+		if (!iov)
+			continue;
+
+		switch (fl->proto) {
+		case IPPROTO_ICMPV6:
+			/* check if one-byte field is readable or not. */
+			if (iov->iov_base && iov->iov_len < 1)
+				break;
+
+			if (!type) {
+				type = iov->iov_base;
+				/* check if code field is readable or not. */
+				if (iov->iov_len > 1)
+					code = type + 1;
+			} else if (!code)
+				code = iov->iov_base;
+
+			if (type && code) {
+				fl->fl_icmp_type = *type;
+				fl->fl_icmp_code = *code;
+				probed = 1;
+			}
+			break;
+		default:
+			probed = 1;
+			break;
+		}
+		if (probed)
+			break;
+	}
+}
+
 static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 		   struct msghdr *msg, size_t len)
 {
@@ -674,6 +720,8 @@
 		opt = fl6_merge_options(&opt_space, flowlabel, opt);
 
 	fl.proto = proto;
+	rawv6_probe_proto_opt(&fl, msg);
+ 
 	ipv6_addr_copy(&fl.fl6_dst, daddr);
 	if (ipv6_addr_any(&fl.fl6_src) && !ipv6_addr_any(&np->saddr))
 		ipv6_addr_copy(&fl.fl6_src, &np->saddr);
Index: net/ipv6/xfrm6_policy.c
===================================================================
RCS file: /cvsroot/usagi/usagi/kernel/linux26/net/ipv6/xfrm6_policy.c,v
retrieving revision 1.1.1.15
diff -u -r1.1.1.15 xfrm6_policy.c
--- net/ipv6/xfrm6_policy.c	3 Aug 2004 23:01:59 -0000	1.1.1.15
+++ net/ipv6/xfrm6_policy.c	9 Aug 2004 08:31:15 -0000
@@ -213,6 +213,16 @@
 			fl->proto = nexthdr;
 			return;
 
+		case IPPROTO_ICMPV6:
+			if (pskb_may_pull(skb, skb->nh.raw + offset + 2 - skb->data)) {
+				u8 *icmp = (u8 *)exthdr;
+
+				fl->fl_icmp_type = icmp[0];
+				fl->fl_icmp_code = icmp[1];
+			}
+			fl->proto = nexthdr;
+			return;
+
 		/* XXX Why are there these headers? */
 		case IPPROTO_AH:
 		case IPPROTO_ESP:
