From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [TCP] Modularise tcpdiag
Date: Fri, 29 Oct 2004 14:38:58 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029043858.GA27907@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="sdtB3X0nJg68CQEu"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--sdtB3X0nJg68CQEu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

This is the first step in fixing the tcpdiag/modular ipv6 issue.
We modularise tcpdiag in the obvious way.

Next we can move out the IPv6-specific stuff.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--sdtB3X0nJg68CQEu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/Kconfig 1.20 vs edited =====
--- 1.20/net/ipv4/Kconfig	2004-10-27 05:32:28 +10:00
+++ edited/net/ipv4/Kconfig	2004-10-29 13:46:20 +10:00
@@ -345,5 +345,14 @@
 	  
 	  If unsure, say Y.
 
+config IP_TCPDIAG
+	tristate "IP: TCP socket monitoring interface"
+	default y
+	---help---
+	  Support for TCP socket monitoring interface used by native Linux
+	  tools such as ss.
+	  
+	  If unsure, say Y.
+
 source "net/ipv4/ipvs/Kconfig"
 
===== net/ipv4/Makefile 1.25 vs edited =====
--- 1.25/net/ipv4/Makefile	2004-09-24 05:47:15 +10:00
+++ edited/net/ipv4/Makefile	2004-10-29 13:47:13 +10:00
@@ -6,7 +6,7 @@
 	     ip_input.o ip_fragment.o ip_forward.o ip_options.o \
 	     ip_output.o ip_sockglue.o \
 	     tcp.o tcp_input.o tcp_output.o tcp_timer.o tcp_ipv4.o tcp_minisocks.o \
-	     tcp_diag.o datagram.o raw.o udp.o arp.o icmp.o devinet.o af_inet.o igmp.o \
+	     datagram.o raw.o udp.o arp.o icmp.o devinet.o af_inet.o igmp.o \
 	     sysctl_net_ipv4.o fib_frontend.o fib_semantics.o fib_hash.o
 
 obj-$(CONFIG_PROC_FS) += proc.o
@@ -22,6 +22,7 @@
 obj-$(CONFIG_IP_PNP) += ipconfig.o
 obj-$(CONFIG_NETFILTER)	+= netfilter/
 obj-$(CONFIG_IP_VS) += ipvs/
+obj-$(CONFIG_IP_TCPDIAG) += tcp_diag.o 
 
 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
 		      xfrm4_output.o
===== net/ipv4/tcp.c 1.83 vs edited =====
--- 1.83/net/ipv4/tcp.c	2004-10-27 05:27:43 +10:00
+++ edited/net/ipv4/tcp.c	2004-10-29 10:36:00 +10:00
@@ -2152,6 +2152,8 @@
 	info->tcpi_total_retrans = tp->total_retrans;
 }
 
+EXPORT_SYMBOL_GPL(tcp_get_info);
+
 int tcp_getsockopt(struct sock *sk, int level, int optname, char __user *optval,
 		   int __user *optlen)
 {
@@ -2358,8 +2360,6 @@
 	printk(KERN_INFO "TCP: Hash tables configured "
 	       "(established %d bind %d)\n",
 	       tcp_ehash_size << 1, tcp_bhash_size);
-
-	tcpdiag_init();
 }
 
 EXPORT_SYMBOL(tcp_accept);
===== net/ipv4/tcp_diag.c 1.25 vs edited =====
--- 1.25/net/ipv4/tcp_diag.c	2004-10-28 07:27:31 +10:00
+++ edited/net/ipv4/tcp_diag.c	2004-10-29 14:20:37 +10:00
@@ -776,9 +776,19 @@
 	}
 }
 
-void __init tcpdiag_init(void)
+static int __init tcpdiag_init(void)
 {
 	tcpnl = netlink_kernel_create(NETLINK_TCPDIAG, tcpdiag_rcv);
 	if (tcpnl == NULL)
-		panic("tcpdiag_init: Cannot create netlink socket.");
+		return -ENOMEM;
+	return 0;
 }
+
+static void __exit tcpdiag_exit(void)
+{
+	sock_release(tcpnl->sk_socket);
+}
+
+module_init(tcpdiag_init);
+module_exit(tcpdiag_exit);
+MODULE_LICENSE("GPL");
===== net/ipv4/tcp_ipv4.c 1.102 vs edited =====
--- 1.102/net/ipv4/tcp_ipv4.c	2004-10-26 13:26:08 +10:00
+++ edited/net/ipv4/tcp_ipv4.c	2004-10-29 11:18:12 +10:00
@@ -535,6 +535,8 @@
 	return sk;
 }
 
+EXPORT_SYMBOL_GPL(tcp_v4_lookup);
+
 static inline __u32 tcp_v4_init_sequence(struct sock *sk, struct sk_buff *skb)
 {
 	return secure_tcp_sequence_number(skb->nh.iph->daddr,
===== net/ipv6/tcp_ipv6.c 1.99 vs edited =====
--- 1.99/net/ipv6/tcp_ipv6.c	2004-10-26 13:50:56 +10:00
+++ edited/net/ipv6/tcp_ipv6.c	2004-10-29 11:18:56 +10:00
@@ -364,6 +364,8 @@
 	return sk;
 }
 
+EXPORT_SYMBOL_GPL(tcp_v6_lookup);
+
 
 /*
  * Open request hash tables.

--sdtB3X0nJg68CQEu--
