From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH][NET] generalise per socket slab cache use
Date: Sat, 11 Sep 2004 00:23:32 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409110023.34342.acme@conectiva.com.br>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_2+mQBno0jqk1vLs"
Cc: Sridhar Samudrala <samudrala@us.ibm.com>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S.Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--Boundary-00=_2+mQBno0jqk1vLs
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

 Please see if it is acceptable, if it is, please pull from:

bk://kernel.bkbits.net/acme/net-2.6

 I want to improve it a bit by not passing the slab cache name to
sk_alloc_slab, but create the name from the sk->sk_prot->name member,
but unfortunately the kmem_cache_t struct stores a pointer to the slab
cache name, which also creates problems for other improvements, like
my __initstr patch, that moves the strings in __init and __exit functions to
.text.init and .text.exit, perhaps I should send a patch to the slab code
to have a char array to store the slab cache name.

 Comments?

Best Regards,

- Arnaldo

--Boundary-00=_2+mQBno0jqk1vLs
Content-Type: text/x-diff;
  charset="us-ascii";
  name="slab.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="slab.patch"

You can import this changeset into BK by piping this whole message to:
'| bk receive [path to repository]' or apply the patch as usual.

===================================================================


ChangeSet@1.2165, 2004-09-11 00:02:02-03:00, acme@conectiva.com.br
  [NET] generalise per socket slab cache use
  
  With this patch we get two new slabcaches, for sctp socks, that previously
  were being allocated on the default, that was tcp[6]_sock, i.e. wasting 288
  bytes per sock in the IPv4 case and 256 bytes for the IPv6 version, this is in
  preparation for DCCP (or any other new protocol :) ).
  
  With this in place another nice side effect that is easier to achieve is to
  get rid of struct sock sk->sk_slab, and instead use sk->sk_prot->slab, saving
  sizeof(void *) on every struct sock instance, but this unfortunatly has to
  wait for the conversion of all protocols that use per socket slabcaches to
  use sk->sk_prot, AF_UNIX is the only one AFAIK, so I'll try to convert it to
  use sk->sk_prot and then get rid of sk->sk_slab.
  
  As for the protocols that don't use per socket slabcaches its just a matter
  of defaulting to sk_cachep at sk_free time if sk->sk_prot is NULL.
  
  [root@qemu ~]# modprobe sctp
  [root@qemu ~]# grep _sock /proc/slabinfo
  sctpv6_sock            9      9    864    9    2 : tunables   54   27    0 :
  sctp_sock              0      0    736    5    1 : tunables   54   27    0 :
  rawv6_sock             3      6    640    6    1 : tunables   54   27    0 : 
  udpv6_sock             0      0    608    6    1 : tunables   54   27    0 :
  tcpv6_sock             1      7   1120    7    2 : tunables   24   12    0 :
  unix_sock              6     10    384   10    1 : tunables   54   27    0 :
  raw_sock               2      8    480    8    1 : tunables   54   27    0 :
  udp_sock               0      0    512    7    1 : tunables   54   27    0 :
  tcp_sock               0      0   1024    4    1 : tunables   54   27    0 :


 include/linux/ipv6.h     |    4 +
 include/net/raw.h        |    1 
 include/net/sctp/sctp.h  |    1 
 include/net/sock.h       |    7 ++
 include/net/tcp.h        |    3 
 net/core/sock.c          |   21 ++++++
 net/ipv4/af_inet.c       |  103 ++++++++++++++------------------
 net/ipv4/raw.c           |    1 
 net/ipv4/tcp_ipv4.c      |    1 
 net/ipv4/tcp_minisocks.c |    2 
 net/ipv4/udp.c           |    1 
 net/ipv6/af_inet6.c      |  151 +++++++++++++++++++----------------------------
 net/ipv6/raw.c           |    6 +
 net/ipv6/tcp_ipv6.c      |    6 +
 net/ipv6/udp.c           |    6 +
 net/sctp/ipv6.c          |   24 +++++--
 net/sctp/protocol.c      |   26 +++++---
 net/sctp/socket.c        |   30 +++++++++
 18 files changed, 231 insertions(+), 163 deletions(-)


diff -Nru a/include/linux/ipv6.h b/include/linux/ipv6.h
--- a/include/linux/ipv6.h	2004-09-11 00:15:42 -03:00
+++ b/include/linux/ipv6.h	2004-09-11 00:15:42 -03:00
@@ -282,6 +282,10 @@
 	return &((struct raw6_sock *)__sk)->raw6;
 }
 
+struct ipv6_sk_offset {
+	int	offset;
+};
+
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 #define __ipv6_only_sock(sk)	(inet6_sk(sk)->ipv6only)
 #define ipv6_only_sock(sk)	((sk)->sk_family == PF_INET6 && __ipv6_only_sock(sk))
diff -Nru a/include/net/raw.h b/include/net/raw.h
--- a/include/net/raw.h	2004-09-11 00:15:42 -03:00
+++ b/include/net/raw.h	2004-09-11 00:15:42 -03:00
@@ -17,7 +17,6 @@
 #ifndef _RAW_H
 #define _RAW_H
 
-
 extern struct proto raw_prot;
 
 
diff -Nru a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
--- a/include/net/sctp/sctp.h	2004-09-11 00:15:42 -03:00
+++ b/include/net/sctp/sctp.h	2004-09-11 00:15:42 -03:00
@@ -505,6 +505,7 @@
 /* External references. */
 
 extern struct proto sctp_prot;
+extern struct proto sctpv6_prot;
 extern struct proc_dir_entry *proc_net_sctp;
 void sctp_put_port(struct sock *sk);
 
diff -Nru a/include/net/sock.h b/include/net/sock.h
--- a/include/net/sock.h	2004-09-11 00:15:42 -03:00
+++ b/include/net/sock.h	2004-09-11 00:15:42 -03:00
@@ -410,6 +410,9 @@
 	return test_bit(flag, &sk->sk_flags);
 }
 
+extern int sk_alloc_slab(struct proto *prot, char *name);
+extern void sk_free_slab(struct proto *prot);
+
 static inline void sk_acceptq_removed(struct sock *sk)
 {
 	sk->sk_ack_backlog--;
@@ -554,6 +557,10 @@
 	int			*sysctl_wmem;
 	int			*sysctl_rmem;
 	int			max_header;
+
+	kmem_cache_t		*slab;
+	int			slab_obj_size;
+	void			*af_specific;
 
 	char			name[32];
 
diff -Nru a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h	2004-09-11 00:15:42 -03:00
+++ b/include/net/tcp.h	2004-09-11 00:15:42 -03:00
@@ -153,9 +153,6 @@
 #define tcp_lhash_wait	(tcp_hashinfo.__tcp_lhash_wait)
 #define tcp_portalloc_lock (tcp_hashinfo.__tcp_portalloc_lock)
 
-/* SLAB cache for TCP socks */
-extern kmem_cache_t *tcp_sk_cachep;
-
 extern kmem_cache_t *tcp_bucket_cachep;
 extern struct tcp_bind_bucket *tcp_bucket_create(struct tcp_bind_hashbucket *head,
 						 unsigned short snum);
diff -Nru a/net/core/sock.c b/net/core/sock.c
--- a/net/core/sock.c	2004-09-11 00:15:42 -03:00
+++ b/net/core/sock.c	2004-09-11 00:15:42 -03:00
@@ -1343,6 +1343,27 @@
 
 EXPORT_SYMBOL(sk_common_release);
 
+int sk_alloc_slab(struct proto *prot, char *name)
+{
+	prot->slab = kmem_cache_create(name,
+				       prot->slab_obj_size, 0,
+				       SLAB_HWCACHE_ALIGN, NULL, NULL);
+
+	return prot->slab != NULL ? 0 : -ENOBUFS;
+}
+
+EXPORT_SYMBOL(sk_alloc_slab);
+
+void sk_free_slab(struct proto *prot)
+{
+	if (prot->slab != NULL) {
+		kmem_cache_destroy(prot->slab);
+		prot->slab = NULL;
+	}
+}
+
+EXPORT_SYMBOL(sk_free_slab);
+
 EXPORT_SYMBOL(__lock_sock);
 EXPORT_SYMBOL(__release_sock);
 EXPORT_SYMBOL(sk_alloc);
diff -Nru a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
--- a/net/ipv4/af_inet.c	2004-09-11 00:15:42 -03:00
+++ b/net/ipv4/af_inet.c	2004-09-11 00:15:42 -03:00
@@ -121,11 +121,6 @@
 
 extern void ip_mc_drop_socket(struct sock *sk);
 
-/* Per protocol sock slabcache */
-kmem_cache_t *tcp_sk_cachep;
-static kmem_cache_t *udp_sk_cachep;
-static kmem_cache_t *raw4_sk_cachep;
-
 /* The inetsw table contains everything that inet_create needs to
  * build a new socket.
  */
@@ -228,28 +223,6 @@
 	return err;
 }
 
-static __inline__ kmem_cache_t *inet_sk_slab(int protocol)
-{
-	kmem_cache_t* rc = tcp_sk_cachep;
-
-	if (protocol == IPPROTO_UDP)
-		rc = udp_sk_cachep;
-	else if (protocol == IPPROTO_RAW)
-		rc = raw4_sk_cachep;
-	return rc;
-}
-
-static __inline__ int inet_sk_size(int protocol)
-{
-	int rc = sizeof(struct tcp_sock);
-
-	if (protocol == IPPROTO_UDP)
-		rc = sizeof(struct udp_sock);
-	else if (protocol == IPPROTO_RAW)
-		rc = sizeof(struct raw_sock);
-	return rc;
-}
-
 /*
  *	Create an inet socket.
  */
@@ -260,13 +233,12 @@
 	struct list_head *p;
 	struct inet_protosw *answer;
 	struct inet_opt *inet;
-	int err = -ENOBUFS;
+	struct proto *answer_prot;
+	unsigned char answer_flags;
+	char answer_no_check;
+	int err;
 
 	sock->state = SS_UNCONNECTED;
-	sk = sk_alloc(PF_INET, GFP_KERNEL, inet_sk_size(protocol),
-		      inet_sk_slab(protocol));
-	if (!sk)
-		goto out;
 
 	/* Look for the requested type/protocol pair. */
 	answer = NULL;
@@ -292,21 +264,35 @@
 
 	err = -ESOCKTNOSUPPORT;
 	if (!answer)
-		goto out_sk_free;
+		goto out_rcu_unlock;
 	err = -EPERM;
 	if (answer->capability > 0 && !capable(answer->capability))
-		goto out_sk_free;
+		goto out_rcu_unlock;
 	err = -EPROTONOSUPPORT;
 	if (!protocol)
-		goto out_sk_free;
-	err = 0;
+		goto out_rcu_unlock;
+
 	sock->ops = answer->ops;
-	sk->sk_prot = answer->prot;
-	sk->sk_no_check = answer->no_check;
-	if (INET_PROTOSW_REUSE & answer->flags)
-		sk->sk_reuse = 1;
+	answer_prot = answer->prot;
+	answer_no_check = answer->no_check;
+	answer_flags = answer->flags;
 	rcu_read_unlock();
 
+	BUG_TRAP(answer_prot->slab != NULL);
+
+	err = -ENOBUFS;
+	sk = sk_alloc(PF_INET, GFP_KERNEL,
+		      answer_prot->slab_obj_size,
+		      answer_prot->slab);
+	if (sk == NULL)
+		goto out;
+
+	err = 0;
+	sk->sk_prot = answer_prot;
+	sk->sk_no_check = answer_no_check;
+	if (INET_PROTOSW_REUSE & answer_flags)
+		sk->sk_reuse = 1;
+
 	inet = inet_sk(sk);
 
 	if (SOCK_RAW == sock->type) {
@@ -359,9 +345,8 @@
 	}
 out:
 	return err;
-out_sk_free:
+out_rcu_unlock:
 	rcu_read_unlock();
-	sk_free(sk);
 	goto out;
 }
 
@@ -1010,24 +995,23 @@
 	struct sk_buff *dummy_skb;
 	struct inet_protosw *q;
 	struct list_head *r;
+	int rc = -EINVAL;
 
 	if (sizeof(struct inet_skb_parm) > sizeof(dummy_skb->cb)) {
 		printk(KERN_CRIT "%s: panic\n", __FUNCTION__);
-		return -EINVAL;
+		goto out;
 	}
 
-	tcp_sk_cachep = kmem_cache_create("tcp_sock",
-					  sizeof(struct tcp_sock), 0,
-					  SLAB_HWCACHE_ALIGN, NULL, NULL);
-	udp_sk_cachep = kmem_cache_create("udp_sock",
-					  sizeof(struct udp_sock), 0,
-					  SLAB_HWCACHE_ALIGN, NULL, NULL);
-	raw4_sk_cachep = kmem_cache_create("raw4_sock",
-					   sizeof(struct raw_sock), 0,
-					   SLAB_HWCACHE_ALIGN, NULL, NULL);
-	if (!tcp_sk_cachep || !udp_sk_cachep || !raw4_sk_cachep)
-		printk(KERN_CRIT
-		       "inet_init: Can't create protocol sock SLAB caches!\n");
+	rc = sk_alloc_slab(&tcp_prot, "tcp_sock");
+	if (rc)
+		goto out;
+	rc = sk_alloc_slab(&udp_prot, "udp_sock");
+	if (rc)
+		goto out_tcp_free_slab;
+	rc = sk_alloc_slab(&raw_prot, "raw_sock");
+	if (rc)
+		goto out_udp_free_slab;
+
 	/*
 	 *	Tell SOCKET that we are alive... 
 	 */
@@ -1097,7 +1081,14 @@
 
 	ipfrag_init();
 
-	return 0;
+	rc = 0;
+out:
+	return rc;
+out_tcp_free_slab:
+	sk_free_slab(&tcp_prot);
+out_udp_free_slab:
+	sk_free_slab(&udp_prot);
+	goto out;
 }
 
 module_init(inet_init);
diff -Nru a/net/ipv4/raw.c b/net/ipv4/raw.c
--- a/net/ipv4/raw.c	2004-09-11 00:15:42 -03:00
+++ b/net/ipv4/raw.c	2004-09-11 00:15:42 -03:00
@@ -719,6 +719,7 @@
 	.backlog_rcv =	raw_rcv_skb,
 	.hash =		raw_v4_hash,
 	.unhash =	raw_v4_unhash,
+	.slab_obj_size = sizeof(struct raw_sock),
 };
 
 #ifdef CONFIG_PROC_FS
diff -Nru a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c	2004-09-11 00:15:42 -03:00
+++ b/net/ipv4/tcp_ipv4.c	2004-09-11 00:15:42 -03:00
@@ -2617,6 +2617,7 @@
 	.sysctl_wmem		= sysctl_tcp_wmem,
 	.sysctl_rmem		= sysctl_tcp_rmem,
 	.max_header		= MAX_TCP_HEADER,
+	.slab_obj_size		= sizeof(struct tcp_sock),
 };
 
 
diff -Nru a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
--- a/net/ipv4/tcp_minisocks.c	2004-09-11 00:15:42 -03:00
+++ b/net/ipv4/tcp_minisocks.c	2004-09-11 00:15:42 -03:00
@@ -687,7 +687,7 @@
 	/* allocate the newsk from the same slab of the master sock,
 	 * if not, at sk_free time we'll try to free it from the wrong
 	 * slabcache (i.e. is it TCPv4 or v6?) -acme */
-	struct sock *newsk = sk_alloc(PF_INET, GFP_ATOMIC, 0, sk->sk_slab);
+	struct sock *newsk = sk_alloc(PF_INET, GFP_ATOMIC, 0, sk->sk_prot->slab);
 
 	if(newsk != NULL) {
 		struct tcp_opt *newtp;
diff -Nru a/net/ipv4/udp.c b/net/ipv4/udp.c
--- a/net/ipv4/udp.c	2004-09-11 00:15:42 -03:00
+++ b/net/ipv4/udp.c	2004-09-11 00:15:42 -03:00
@@ -1320,6 +1320,7 @@
 	.hash =		udp_v4_hash,
 	.unhash =	udp_v4_unhash,
 	.get_port =	udp_v4_get_port,
+	.slab_obj_size = sizeof(struct udp_sock),
 };
 
 /* ------------------------------------------------------------------------ */
diff -Nru a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
--- a/net/ipv6/af_inet6.c	2004-09-11 00:15:42 -03:00
+++ b/net/ipv6/af_inet6.c	2004-09-11 00:15:42 -03:00
@@ -90,11 +90,6 @@
 atomic_t inet6_sock_nr;
 #endif
 
-/* Per protocol sock slabcache */
-kmem_cache_t *tcp6_sk_cachep;
-kmem_cache_t *udp6_sk_cachep;
-kmem_cache_t *raw6_sk_cachep;
-
 /* The inetsw table contains everything that inet_create needs to
  * build a new socket.
  */
@@ -110,37 +105,11 @@
 #endif
 }
 
-static __inline__ kmem_cache_t *inet6_sk_slab(int protocol)
-{
-        kmem_cache_t* rc = tcp6_sk_cachep;
-
-        if (protocol == IPPROTO_UDP)
-                rc = udp6_sk_cachep;
-        else if (protocol == IPPROTO_RAW)
-                rc = raw6_sk_cachep;
-        return rc;
-}
-
-static __inline__ int inet6_sk_size(int protocol)
+static inline struct ipv6_pinfo *inet6_sk_generic(struct sock *sk)
 {
-        int rc = sizeof(struct tcp6_sock);
+	const struct ipv6_sk_offset *offset = sk->sk_prot->af_specific;
 
-        if (protocol == IPPROTO_UDP)
-                rc = sizeof(struct udp6_sock);
-        else if (protocol == IPPROTO_RAW)
-                rc = sizeof(struct raw6_sock);
-        return rc;
-}
-
-static __inline__ struct ipv6_pinfo *inet6_sk_generic(struct sock *sk)
-{
-	struct ipv6_pinfo *rc = (&((struct tcp6_sock *)sk)->inet6);
-
-        if (sk->sk_protocol == IPPROTO_UDP)
-                rc = (&((struct udp6_sock *)sk)->inet6);
-        else if (sk->sk_protocol == IPPROTO_RAW)
-                rc = (&((struct raw6_sock *)sk)->inet6);
-        return rc;
+	return (struct ipv6_pinfo *)(((u8 *)sk) + offset->offset);
 }
 
 static int inet6_create(struct socket *sock, int protocol)
@@ -151,11 +120,10 @@
 	struct tcp6_sock* tcp6sk;
 	struct list_head *p;
 	struct inet_protosw *answer;
-
-	sk = sk_alloc(PF_INET6, GFP_KERNEL, inet6_sk_size(protocol),
-		      inet6_sk_slab(protocol));
-	if (sk == NULL) 
-		goto do_oom;
+	struct proto *answer_prot;
+	unsigned char answer_flags;
+	char answer_no_check;
+	int rc;
 
 	/* Look for the requested type/protocol pair. */
 	answer = NULL;
@@ -179,22 +147,40 @@
 		answer = NULL;
 	}
 
+	rc = -ESOCKTNOSUPPORT;
 	if (!answer)
-		goto free_and_badtype;
+		goto out_rcu_unlock;
+	rc = -EPERM;
 	if (answer->capability > 0 && !capable(answer->capability))
-		goto free_and_badperm;
+		goto out_rcu_unlock;
+	rc = -EPROTONOSUPPORT;
 	if (!protocol)
-		goto free_and_noproto;
+		goto out_rcu_unlock;
 
 	sock->ops = answer->ops;
+
+	answer_prot = answer->prot;
+	answer_no_check = answer->no_check;
+	answer_flags = answer->flags;
+	rcu_read_unlock();
+
+	BUG_TRAP(answer_prot->slab != NULL);
+
+	rc = -ENOBUFS;
+	sk = sk_alloc(PF_INET6, GFP_KERNEL,
+		      answer_prot->slab_obj_size,
+		      answer_prot->slab);
+	if (sk == NULL)
+		goto out;
+
 	sock_init_data(sock, sk);
 	sk_set_owner(sk, THIS_MODULE);
 
-	sk->sk_prot = answer->prot;
-	sk->sk_no_check = answer->no_check;
-	if (INET_PROTOSW_REUSE & answer->flags)
+	rc = 0;
+	sk->sk_prot = answer_prot;
+	sk->sk_no_check = answer_no_check;
+	if (INET_PROTOSW_REUSE & answer_flags)
 		sk->sk_reuse = 1;
-	rcu_read_unlock();
 
 	inet = inet_sk(sk);
 
@@ -248,28 +234,17 @@
 		sk->sk_prot->hash(sk);
 	}
 	if (sk->sk_prot->init) {
-		int err = sk->sk_prot->init(sk);
-		if (err != 0) {
+		rc = sk->sk_prot->init(sk);
+		if (rc) {
 			sk_common_release(sk);
-			return err;
+			goto out;
 		}
 	}
-	return 0;
-
-free_and_badtype:
-	rcu_read_unlock();
-	sk_free(sk);
-	return -ESOCKTNOSUPPORT;
-free_and_badperm:
-	rcu_read_unlock();
-	sk_free(sk);
-	return -EPERM;
-free_and_noproto:
+out:
+	return rc;
+out_rcu_unlock:
 	rcu_read_unlock();
-	sk_free(sk);
-	return -EPROTONOSUPPORT;
-do_oom:
-	return -ENOBUFS;
+	goto out;
 }
 
 
@@ -709,24 +684,20 @@
 #endif
 #endif
 
-	if (sizeof(struct inet6_skb_parm) > sizeof(dummy_skb->cb))
-	{
+	if (sizeof(struct inet6_skb_parm) > sizeof(dummy_skb->cb)) {
 		printk(KERN_CRIT "inet6_proto_init: size fault\n");
 		return -EINVAL;
 	}
-	/* allocate our sock slab caches */
-        tcp6_sk_cachep = kmem_cache_create("tcp6_sock",
-					   sizeof(struct tcp6_sock), 0,
-                                           SLAB_HWCACHE_ALIGN, NULL, NULL);
-        udp6_sk_cachep = kmem_cache_create("udp6_sock",
-					   sizeof(struct udp6_sock), 0,
-                                           SLAB_HWCACHE_ALIGN, NULL, NULL);
-        raw6_sk_cachep = kmem_cache_create("raw6_sock",
-					   sizeof(struct raw6_sock), 0,
-                                           SLAB_HWCACHE_ALIGN, NULL, NULL);
-        if (!tcp6_sk_cachep || !udp6_sk_cachep || !raw6_sk_cachep)
-                printk(KERN_CRIT "%s: Can't create protocol sock SLAB "
-		       "caches!\n", __FUNCTION__);
+
+	err = sk_alloc_slab(&tcpv6_prot, "tcpv6_sock");
+	if (err)
+		goto out;
+	err = sk_alloc_slab(&udpv6_prot, "udpv6_sock");
+	if (err)
+		goto out_tcp_free_slab;
+	err = sk_alloc_slab(&rawv6_prot, "rawv6_sock");
+	if (err)
+		goto out_udp_free_slab;
 
 	/* Register the socket-side information for inet6_create.  */
 	for(r = &inetsw6[0]; r < &inetsw6[SOCK_MAX]; ++r)
@@ -745,7 +716,7 @@
 	/* Initialise ipv6 mibs */
 	err = init_ipv6_mibs();
 	if (err)
-		goto init_mib_fail;
+		goto out_raw_free_slab;
 	
 	/*
 	 *	ipngwg API draft makes clear that the correct semantics
@@ -798,8 +769,9 @@
 	/* Init v6 transport protocols. */
 	udpv6_init();
 	tcpv6_init();
-
-	return 0;
+	err = 0;
+out:
+	return err;
 
 #ifdef CONFIG_PROC_FS
 proc_if6_fail:
@@ -824,8 +796,13 @@
 	ipv6_sysctl_unregister();
 #endif
 	cleanup_ipv6_mibs();
-init_mib_fail:
-	return err;
+out_raw_free_slab:
+	sk_free_slab(&rawv6_prot);
+out_udp_free_slab:
+	sk_free_slab(&udpv6_prot);
+out_tcp_free_slab:
+	sk_free_slab(&tcpv6_prot);
+	goto out;
 }
 module_init(inet6_init);
 
@@ -854,9 +831,9 @@
 	ipv6_sysctl_unregister();	
 #endif
 	cleanup_ipv6_mibs();
-	kmem_cache_destroy(tcp6_sk_cachep);
-	kmem_cache_destroy(udp6_sk_cachep);
-	kmem_cache_destroy(raw6_sk_cachep);
+	sk_free_slab(&rawv6_prot);
+	sk_free_slab(&udpv6_prot);
+	sk_free_slab(&tcpv6_prot);
 }
 module_exit(inet6_exit);
 
diff -Nru a/net/ipv6/raw.c b/net/ipv6/raw.c
--- a/net/ipv6/raw.c	2004-09-11 00:15:42 -03:00
+++ b/net/ipv6/raw.c	2004-09-11 00:15:42 -03:00
@@ -973,6 +973,10 @@
 	return(0);
 }
 
+struct ipv6_sk_offset raw_sock_offset = {
+	.offset = offsetof(struct udp6_sock, inet6),
+};
+
 struct proto rawv6_prot = {
 	.name =		"RAW",
 	.close =	rawv6_close,
@@ -989,6 +993,8 @@
 	.backlog_rcv =	rawv6_rcv_skb,
 	.hash =		raw_v6_hash,
 	.unhash =	raw_v6_unhash,
+	.slab_obj_size = sizeof(struct raw6_sock),
+	.af_specific =	&raw_sock_offset,
 };
 
 #ifdef CONFIG_PROC_FS
diff -Nru a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c	2004-09-11 00:15:42 -03:00
+++ b/net/ipv6/tcp_ipv6.c	2004-09-11 00:15:42 -03:00
@@ -2119,6 +2119,10 @@
 }
 #endif
 
+struct ipv6_sk_offset tcp_sock_offset = {
+	.offset = offsetof(struct tcp6_sock, inet6),
+};
+
 struct proto tcpv6_prot = {
 	.name			= "TCPv6",
 	.close			= tcp_close,
@@ -2145,6 +2149,8 @@
 	.sysctl_wmem		= sysctl_tcp_wmem,
 	.sysctl_rmem		= sysctl_tcp_rmem,
 	.max_header		= MAX_TCP_HEADER,
+	.slab_obj_size		= sizeof(struct tcp6_sock),
+	.af_specific		= &tcp_sock_offset,
 };
 
 static struct inet6_protocol tcpv6_protocol = {
diff -Nru a/net/ipv6/udp.c b/net/ipv6/udp.c
--- a/net/ipv6/udp.c	2004-09-11 00:15:42 -03:00
+++ b/net/ipv6/udp.c	2004-09-11 00:15:42 -03:00
@@ -1031,6 +1031,10 @@
 
 /* ------------------------------------------------------------------------ */
 
+struct ipv6_sk_offset udp_sock_offset = {
+	.offset = offsetof(struct udp6_sock, inet6),
+};
+
 struct proto udpv6_prot = {
 	.name =		"UDP",
 	.close =	udpv6_close,
@@ -1046,6 +1050,8 @@
 	.hash =		udp_v6_hash,
 	.unhash =	udp_v6_unhash,
 	.get_port =	udp_v6_get_port,
+	.slab_obj_size = sizeof(struct udp6_sock),
+	.af_specific =	&udp_sock_offset,
 };
 
 extern struct proto_ops inet6_dgram_ops;
diff -Nru a/net/sctp/ipv6.c b/net/sctp/ipv6.c
--- a/net/sctp/ipv6.c	2004-09-11 00:15:42 -03:00
+++ b/net/sctp/ipv6.c	2004-09-11 00:15:42 -03:00
@@ -583,8 +583,8 @@
 	struct ipv6_pinfo *newnp, *np = inet6_sk(sk);
 	struct sctp6_sock *newsctp6sk;
 
-	newsk = sk_alloc(PF_INET6, GFP_KERNEL, sizeof(struct sctp6_sock),
-			 sk->sk_slab);
+	newsk = sk_alloc(PF_INET6, GFP_KERNEL, sk->sk_prot->slab_obj_size,
+			 sk->sk_prot->slab);
 	if (!newsk)
 		goto out;
 
@@ -892,7 +892,7 @@
 static struct inet_protosw sctpv6_seqpacket_protosw = {
 	.type          = SOCK_SEQPACKET,
 	.protocol      = IPPROTO_SCTP,
-	.prot 	       = &sctp_prot,
+	.prot 	       = &sctpv6_prot,
 	.ops           = &inet6_seqpacket_ops,
 	.capability    = -1,
 	.no_check      = 0,
@@ -901,7 +901,7 @@
 static struct inet_protosw sctpv6_stream_protosw = {
 	.type          = SOCK_STREAM,
 	.protocol      = IPPROTO_SCTP,
-	.prot 	       = &sctp_prot,
+	.prot 	       = &sctpv6_prot,
 	.ops           = &inet6_seqpacket_ops,
 	.capability    = -1,
 	.no_check      = 0,
@@ -963,9 +963,14 @@
 /* Initialize IPv6 support and register with inet6 stack.  */
 int sctp_v6_init(void)
 {
+	int rc = sk_alloc_slab(&sctpv6_prot, "sctpv6_sock");
+
+	if (rc)
+		goto out;
 	/* Register inet6 protocol. */
+	rc = -EAGAIN;
 	if (inet6_add_protocol(&sctpv6_protocol, IPPROTO_SCTP) < 0)
-		return -EAGAIN;
+		goto out_sctp_free_slab;
 
 	/* Add SCTPv6(UDP and TCP style) to inetsw6 linked list. */
 	inet6_register_protosw(&sctpv6_seqpacket_protosw);
@@ -979,8 +984,12 @@
 
 	/* Register notifier for inet6 address additions/deletions. */
 	register_inet6addr_notifier(&sctp_inetaddr_notifier);
-
-	return 0;
+	rc = 0;
+out:
+	return rc;
+out_sctp_free_slab:
+	sk_free_slab(&sctpv6_prot);
+	goto out;
 }
 
 /* IPv6 specific exit support. */
@@ -991,4 +1000,5 @@
 	inet6_unregister_protosw(&sctpv6_seqpacket_protosw);
 	inet6_unregister_protosw(&sctpv6_stream_protosw);
 	unregister_inet6addr_notifier(&sctp_inetaddr_notifier);
+	sk_free_slab(&sctpv6_prot);
 }
diff -Nru a/net/sctp/protocol.c b/net/sctp/protocol.c
--- a/net/sctp/protocol.c	2004-09-11 00:15:42 -03:00
+++ b/net/sctp/protocol.c	2004-09-11 00:15:42 -03:00
@@ -554,8 +554,8 @@
 	struct inet_opt *inet = inet_sk(sk);
 	struct inet_opt *newinet;
 
-	newsk = sk_alloc(PF_INET, GFP_KERNEL, sizeof(struct sctp_sock),
-			 sk->sk_slab);
+	newsk = sk_alloc(PF_INET, GFP_KERNEL, sk->sk_prot->slab_obj_size,
+			 sk->sk_prot->slab);
 	if (!newsk)
 		goto out;
 
@@ -962,23 +962,29 @@
 __init int sctp_init(void)
 {
 	int i;
-	int status = 0;
+	int status = -EINVAL;
 	unsigned long goal;
 	int order;
 
 	/* SCTP_DEBUG sanity check. */
 	if (!sctp_sanity_check())
-		return -EINVAL;
+		goto out;
+
+	status = sk_alloc_slab(&sctp_prot, "sctp_sock");
+	if (status)
+		goto out;
 
 	/* Add SCTP to inet_protos hash table.  */
+	status = -EAGAIN;
 	if (inet_add_protocol(&sctp_protocol, IPPROTO_SCTP) < 0)
-		return -EAGAIN;
+		goto err_add_protocol;
 
 	/* Add SCTP(TCP and UDP style) to inetsw linked list.  */
 	inet_register_protosw(&sctp_seqpacket_protosw);
 	inet_register_protosw(&sctp_stream_protosw);
 
 	/* Allocate a cache pools. */
+	status = -ENOBUFS;
 	sctp_bucket_cachep = kmem_cache_create("sctp_bind_bucket",
 					       sizeof(struct sctp_bind_bucket),
 					       0, SLAB_HWCACHE_ALIGN,
@@ -1154,8 +1160,11 @@
 	sctp_get_local_addr_list();
 
 	__unsafe(THIS_MODULE);
-	return 0;
-
+	status = 0;
+out:
+	return status;
+err_add_protocol:
+	sk_free_slab(&sctp_prot);
 err_ctl_sock_init:
 	sctp_v6_exit();
 err_v6_init:
@@ -1183,7 +1192,7 @@
 	inet_del_protocol(&sctp_protocol, IPPROTO_SCTP);
 	inet_unregister_protosw(&sctp_seqpacket_protosw);
 	inet_unregister_protosw(&sctp_stream_protosw);
-	return status;
+	goto out;
 }
 
 /* Exit handler for the SCTP protocol.  */
@@ -1224,6 +1233,7 @@
 	inet_del_protocol(&sctp_protocol, IPPROTO_SCTP);
 	inet_unregister_protosw(&sctp_seqpacket_protosw);
 	inet_unregister_protosw(&sctp_stream_protosw);
+	sk_free_slab(&sctp_prot);
 }
 
 module_init(sctp_init);
diff -Nru a/net/sctp/socket.c b/net/sctp/socket.c
--- a/net/sctp/socket.c	2004-09-11 00:15:42 -03:00
+++ b/net/sctp/socket.c	2004-09-11 00:15:42 -03:00
@@ -4622,4 +4622,34 @@
 	.hash        =	sctp_hash,
 	.unhash      =	sctp_unhash,
 	.get_port    =	sctp_get_port,
+	.slab_obj_size = sizeof(struct sctp_sock),
 };
+
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+struct ipv6_sk_offset sctp_sock_offset = {
+	.offset = offsetof(struct sctp6_sock, inet6),
+};
+
+struct proto sctpv6_prot = {
+	.name		= "SCTPv6",
+	.close		= sctp_close,
+	.connect	= sctp_connect,
+	.disconnect	= sctp_disconnect,
+	.accept		= sctp_accept,
+	.ioctl		= sctp_ioctl,
+	.init		= sctp_init_sock,
+	.destroy	= sctp_destroy_sock,
+	.shutdown	= sctp_shutdown,
+	.setsockopt	= sctp_setsockopt,
+	.getsockopt	= sctp_getsockopt,
+	.sendmsg	= sctp_sendmsg,
+	.recvmsg	= sctp_recvmsg,
+	.bind		= sctp_bind,
+	.backlog_rcv	= sctp_backlog_rcv,
+	.hash		= sctp_hash,
+	.unhash		= sctp_unhash,
+	.get_port	= sctp_get_port,
+	.slab_obj_size	= sizeof(struct sctp6_sock),
+	.af_specific	= &sctp_sock_offset,
+};
+#endif /* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */


--Boundary-00=_2+mQBno0jqk1vLs--
