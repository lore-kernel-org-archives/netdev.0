From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] convert ip6_tunnel to per-cpu data
Date: Sun, 31 Aug 2003 12:06:21 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030831100621.GC18663@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Code looks like copy & pasted from icmpv6 :)


--- 1.6/net/ipv6/ip6_tunnel.c	Mon Aug 18 13:52:14 2003
+++ edited/net/ipv6/ip6_tunnel.c	Fri Aug 29 12:11:40 2003
@@ -64,8 +64,8 @@
 #define IPV6_TCLASS_MASK (IPV6_FLOWINFO_MASK & ~IPV6_FLOWLABEL_MASK)
 
 /* socket(s) used by ip6ip6_tnl_xmit() for resending packets */
-static struct socket *__ip6_socket[NR_CPUS];
-#define ip6_socket __ip6_socket[smp_processor_id()]
+static DEFINE_PER_CPU(struct socket *, __ip6_socket) = NULL;
+#define ip6_socket	__get_cpu_var(__ip6_socket)
 
 static void ip6_xmit_lock(void)
 {
@@ -1168,7 +1168,7 @@
 			continue;
 
 		err = sock_create(PF_INET6, SOCK_RAW, IPPROTO_IPV6, 
-				  &__ip6_socket[i]);
+				  &per_cpu(__ip6_socket, i));
 		if (err < 0) {
 			printk(KERN_ERR 
 			       "Failed to create the IPv6 tunnel socket "
@@ -1176,7 +1176,7 @@
 			       err);
 			goto fail;
 		}
-		sk = __ip6_socket[i]->sk;
+		sk = per_cpu(__ip6_socket, i)->sk;
 		sk->sk_allocation = GFP_ATOMIC;
 
 		np = inet6_sk(sk);
@@ -1211,8 +1211,8 @@
 	for (j = 0; j < i; j++) {
 		if (!cpu_possible(j))
 			continue;
-		sock_release(__ip6_socket[j]);
-		__ip6_socket[j] = NULL;
+		sock_release(per_cpu(__ip6_socket, j));
+		per_cpu(__ip6_socket, j) = NULL;
 	}
 	return err;
 }
@@ -1232,8 +1232,8 @@
 	for (i = 0; i < NR_CPUS; i++) {
 		if (!cpu_possible(i))
 			continue;
-		sock_release(__ip6_socket[i]);
-		__ip6_socket[i] = NULL;
+		sock_release(per_cpu(__ip6_socket, i));
+		per_cpu(__ip6_socket, i) = NULL;
 	}
 }
 
