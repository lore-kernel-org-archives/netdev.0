From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] convert icmpv6_socket to per-cpu data
Date: Sun, 31 Aug 2003 12:05:21 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030831100521.GB18663@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

per-cpu data works in modules for a while now.  Also bring over a
comment from the IPv4 version and consolidate the error handling.


--- 1.40/net/ipv6/icmp.c	Mon Aug 18 12:38:34 2003
+++ edited/net/ipv6/icmp.c	Fri Aug 29 12:11:40 2003
@@ -70,12 +70,14 @@
 DEFINE_SNMP_STAT(struct icmpv6_mib, icmpv6_statistics);
 
 /*
- *	ICMP socket(s) for flow control.
+ *	The ICMP socket(s). This is the most convenient way to flow control
+ *	our ICMP output as well as maintain a clean interface throughout
+ *	all layers. All Socketless IP sends will soon be gone.
+ *
+ *	On SMP we have one ICMP socket per-cpu.
  */
-
-/* XXX We can't use per_cpu because this can be modular... */
-static struct socket *__icmpv6_socket[NR_CPUS];
-#define icmpv6_socket	__icmpv6_socket[smp_processor_id()]
+static DEFINE_PER_CPU(struct socket *, __icmpv6_socket) = NULL;
+#define icmpv6_socket	__get_cpu_var(__icmpv6_socket)
 
 static int icmpv6_rcv(struct sk_buff **pskb, unsigned int *nhoffp);
 
@@ -96,6 +98,7 @@
 static __inline__ void icmpv6_xmit_lock(void)
 {
 	local_bh_disable();
+
 	if (unlikely(!spin_trylock(&icmpv6_socket->sk->sk_lock.slock)))
 		BUG();
 }
@@ -657,33 +660,23 @@
 int __init icmpv6_init(struct net_proto_family *ops)
 {
 	struct sock *sk;
-	int i;
+	int err, i, j;
 
 	for (i = 0; i < NR_CPUS; i++) {
-		int err;
-
 		if (!cpu_possible(i))
 			continue;
 
 		err = sock_create(PF_INET6, SOCK_RAW, IPPROTO_ICMPV6,
-				  &__icmpv6_socket[i]);
+				  &per_cpu(__icmpv6_socket, i));
 		if (err < 0) {
-			int j;
-
 			printk(KERN_ERR
 			       "Failed to initialize the ICMP6 control socket "
 			       "(err %d).\n",
 			       err);
-			for (j = 0; j < i; j++) {
-				if (!cpu_possible(j))
-					continue;
-				sock_release(__icmpv6_socket[j]);
-				__icmpv6_socket[j] = NULL; /* for safety */
-			}
-			return err;
+			goto fail;
 		}
 
-		sk = __icmpv6_socket[i]->sk;
+		sk = per_cpu(__icmpv6_socket, i)->sk;
 		sk->sk_allocation = GFP_ATOMIC;
 		sk->sk_sndbuf = SK_WMEM_MAX * 2;
 		sk->sk_prot->unhash(sk);
@@ -692,16 +685,20 @@
 
 	if (inet6_add_protocol(&icmpv6_protocol, IPPROTO_ICMPV6) < 0) {
 		printk(KERN_ERR "Failed to register ICMP6 protocol\n");
-		for (i = 0; i < NR_CPUS; i++) {
-			if (!cpu_possible(i))
-				continue;
-			sock_release(__icmpv6_socket[i]);
-			__icmpv6_socket[i] = NULL;
-		}
-		return -EAGAIN;
+		err = -EAGAIN;
+		goto fail;
 	}
 
 	return 0;
+
+ fail:
+	for (j = 0; j < i; j++) {
+		if (!cpu_possible(j))
+			continue;
+		sock_release(per_cpu(__icmpv6_socket, j));
+	}
+
+	return err;
 }
 
 void icmpv6_cleanup(void)
@@ -711,8 +708,7 @@
 	for (i = 0; i < NR_CPUS; i++) {
 		if (!cpu_possible(i))
 			continue;
-		sock_release(__icmpv6_socket[i]);
-		__icmpv6_socket[i] = NULL; /* For safety. */
+		sock_release(per_cpu(__icmpv6_socket, i));
 	}
 	inet6_del_protocol(&icmpv6_protocol, IPPROTO_ICMPV6);
 }
