From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [TCP] Modular IPv6 support in tcpdiag
Date: Wed, 3 Nov 2004 20:44:51 +1100
Message-ID: <20041103094451.GA20220@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="n8g4imXOkfNTN/H1"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--n8g4imXOkfNTN/H1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

This patch allows tcpdiag to support ipv6 work as a module when itself
is also a module.

I was planning for a more extensible method but now I think the effort
would be better directed at a new generic socket netlink interface than
the TCP-specific tcpdiag.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--n8g4imXOkfNTN/H1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/Kconfig 1.22 vs edited =====
--- 1.22/net/ipv4/Kconfig	2004-11-02 11:48:28 +11:00
+++ edited/net/ipv4/Kconfig	2004-11-03 20:39:16 +11:00
@@ -351,12 +351,16 @@
 
 config IP_TCPDIAG
 	tristate "IP: TCP socket monitoring interface"
+	depends on INET
 	default y
 	---help---
 	  Support for TCP socket monitoring interface used by native Linux
 	  tools such as ss.
 	  
 	  If unsure, say Y.
+
+config IP_TCPDIAG_IPV6
+	def_bool (IP_TCPDIAG=y && IPV6=y) || (IP_TCPDIAG=m && IPV6)
 
 source "net/ipv4/ipvs/Kconfig"
 
===== net/ipv4/tcp_diag.c 1.26 vs edited =====
--- 1.26/net/ipv4/tcp_diag.c	2004-11-02 11:48:28 +11:00
+++ edited/net/ipv4/tcp_diag.c	2004-11-03 20:37:03 +11:00
@@ -103,14 +103,12 @@
 		r->tcpdiag_wqueue = 0;
 		r->tcpdiag_uid = 0;
 		r->tcpdiag_inode = 0;
-#ifdef CONFIG_IPV6
 		if (r->tcpdiag_family == AF_INET6) {
 			ipv6_addr_copy((struct in6_addr *)r->id.tcpdiag_src,
 				       &tw->tw_v6_rcv_saddr);
 			ipv6_addr_copy((struct in6_addr *)r->id.tcpdiag_dst,
 				       &tw->tw_v6_daddr);
 		}
-#endif
 		nlh->nlmsg_len = skb->tail - b;
 		return skb->len;
 	}
@@ -120,7 +118,6 @@
 	r->id.tcpdiag_src[0] = inet->rcv_saddr;
 	r->id.tcpdiag_dst[0] = inet->daddr;
 
-#ifdef CONFIG_IPV6
 	if (r->tcpdiag_family == AF_INET6) {
 		struct ipv6_pinfo *np = inet6_sk(sk);
 
@@ -129,7 +126,6 @@
 		ipv6_addr_copy((struct in6_addr *)r->id.tcpdiag_dst,
 			       &np->daddr);
 	}
-#endif
 
 #define EXPIRES_IN_MS(tmo)  ((tmo-jiffies)*1000+HZ-1)/HZ
 
@@ -188,11 +184,19 @@
 	return -1;
 }
 
-extern struct sock *tcp_v4_lookup(u32 saddr, u16 sport, u32 daddr, u16 dport, int dif);
-#ifdef CONFIG_IPV6
+extern struct sock *tcp_v4_lookup(u32 saddr, u16 sport, u32 daddr, u16 dport,
+				  int dif);
+#ifdef CONFIG_IP_TCPDIAG_IPV6
 extern struct sock *tcp_v6_lookup(struct in6_addr *saddr, u16 sport,
 				  struct in6_addr *daddr, u16 dport,
 				  int dif);
+#else
+static inline struct sock *tcp_v6_lookup(struct in6_addr *saddr, u16 sport,
+					 struct in6_addr *daddr, u16 dport,
+					 int dif)
+{
+	return NULL;
+}
 #endif
 
 static int tcpdiag_get_exact(struct sk_buff *in_skb, const struct nlmsghdr *nlh)
@@ -207,13 +211,11 @@
 				   req->id.tcpdiag_src[0], req->id.tcpdiag_sport,
 				   req->id.tcpdiag_if);
 	}
-#ifdef CONFIG_IPV6
 	else if (req->tcpdiag_family == AF_INET6) {
 		sk = tcp_v6_lookup((struct in6_addr*)req->id.tcpdiag_dst, req->id.tcpdiag_dport,
 				   (struct in6_addr*)req->id.tcpdiag_src, req->id.tcpdiag_sport,
 				   req->id.tcpdiag_if);
 	}
-#endif
 	else {
 		return -EINVAL;
 	}
@@ -422,14 +424,12 @@
 		struct inet_opt *inet = inet_sk(sk);
 
 		entry.family = sk->sk_family;
-#ifdef CONFIG_IPV6
 		if (entry.family == AF_INET6) {
 			struct ipv6_pinfo *np = inet6_sk(sk);
 
 			entry.saddr = np->rcv_saddr.s6_addr32;
 			entry.daddr = np->daddr.s6_addr32;
 		} else
-#endif
 		{
 			entry.saddr = &inet->rcv_saddr;
 			entry.daddr = &inet->daddr;
@@ -482,14 +482,12 @@
 	r->tcpdiag_wqueue = 0;
 	r->tcpdiag_uid = sock_i_uid(sk);
 	r->tcpdiag_inode = 0;
-#ifdef CONFIG_IPV6
 	if (r->tcpdiag_family == AF_INET6) {
 		ipv6_addr_copy((struct in6_addr *)r->id.tcpdiag_src,
 			       &req->af.v6_req.loc_addr);
 		ipv6_addr_copy((struct in6_addr *)r->id.tcpdiag_dst,
 			       &req->af.v6_req.rmt_addr);
 	}
-#endif
 	nlh->nlmsg_len = skb->tail - b;
 
 	return skb->len;
@@ -545,16 +543,12 @@
 
 			if (bc) {
 				entry.saddr =
-#ifdef CONFIG_IPV6
 					(entry.family == AF_INET6) ?
 					req->af.v6_req.loc_addr.s6_addr32 :
-#endif
 					&req->af.v4_req.loc_addr;
 				entry.daddr = 
-#ifdef CONFIG_IPV6
 					(entry.family == AF_INET6) ?
 					req->af.v6_req.rmt_addr.s6_addr32 :
-#endif
 					&req->af.v4_req.rmt_addr;
 				entry.dport = ntohs(req->rmt_port);
 

--n8g4imXOkfNTN/H1--
