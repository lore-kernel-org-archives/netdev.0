From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] [NET] Save space for sk_alloc_slab() failure message.
Date: Fri, 18 Mar 2005 03:30:39 +0900 (JST)
Message-ID: <20050318.033039.116005935.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

(Almost) all callers of sk_alloc_slab() handle its failure like this:

  if (sk_alloc_slab(&prot, "sock")) {
    sk_alloc_slab_error(&prot);	/* except for sctp */
    goto out;
  }

So, why don't we move sk_alloc_slab_error() into sk_alloc_slab()
for simplification and save text segment?

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

===== include/net/sock.h 1.99 vs edited =====
--- 1.99/include/net/sock.h	2005-03-16 08:24:42 +09:00
+++ edited/include/net/sock.h	2005-03-18 03:00:59 +09:00
@@ -561,11 +561,6 @@
 extern int sk_alloc_slab(struct proto *prot, char *name);
 extern void sk_free_slab(struct proto *prot);
 
-static inline void sk_alloc_slab_error(struct proto *proto)
-{
-	printk(KERN_CRIT "%s: Can't create sock SLAB cache!\n", proto->name);
-}
-
 static __inline__ void sk_set_owner(struct sock *sk, struct module *owner)
 {
 	/*
===== net/core/sock.c 1.65 vs edited =====
--- 1.65/net/core/sock.c	2005-03-16 08:20:37 +09:00
+++ edited/net/core/sock.c	2005-03-18 03:05:04 +09:00
@@ -1374,7 +1374,13 @@
 				       prot->slab_obj_size, 0,
 				       SLAB_HWCACHE_ALIGN, NULL, NULL);
 
-	return prot->slab != NULL ? 0 : -ENOBUFS;
+	if (prot->slab == NULL) {
+		printk(KERN_CRIT "%s: Can't create sock SLAB cache!\n",
+		       prot->name);
+		return -ENOBUFS;
+	}
+
+	return 0;
 }
 
 EXPORT_SYMBOL(sk_alloc_slab);
===== net/ipv4/af_inet.c 1.84 vs edited =====
--- 1.84/net/ipv4/af_inet.c	2005-01-14 13:41:05 +09:00
+++ edited/net/ipv4/af_inet.c	2005-03-18 03:00:06 +09:00
@@ -1027,20 +1027,16 @@
 	}
 
 	rc = sk_alloc_slab(&tcp_prot, "tcp_sock");
-	if (rc) {
-		sk_alloc_slab_error(&tcp_prot);
+	if (rc)
 		goto out;
-	}
+
 	rc = sk_alloc_slab(&udp_prot, "udp_sock");
-	if (rc) {
-		sk_alloc_slab_error(&udp_prot);
+	if (rc)
 		goto out_tcp_free_slab;
-	}
+
 	rc = sk_alloc_slab(&raw_prot, "raw_sock");
-	if (rc) {
-		sk_alloc_slab_error(&raw_prot);
+	if (rc)
 		goto out_udp_free_slab;
-	}
 
 	/*
 	 *	Tell SOCKET that we are alive... 
===== net/ipv6/af_inet6.c 1.90 vs edited =====
--- 1.90/net/ipv6/af_inet6.c	2005-03-10 13:39:44 +09:00
+++ edited/net/ipv6/af_inet6.c	2005-03-18 03:00:29 +09:00
@@ -711,20 +711,17 @@
 	}
 
 	err = sk_alloc_slab(&tcpv6_prot, "tcpv6_sock");
-	if (err) {
-		sk_alloc_slab_error(&tcpv6_prot);
+	if (err)
 		goto out;
-	}
+
 	err = sk_alloc_slab(&udpv6_prot, "udpv6_sock");
-	if (err) {
-		sk_alloc_slab_error(&udpv6_prot);
+	if (err)
 		goto out_tcp_free_slab;
-	}
+
 	err = sk_alloc_slab(&rawv6_prot, "rawv6_sock");
-	if (err) {
-		sk_alloc_slab_error(&rawv6_prot);
+	if (err)
 		goto out_udp_free_slab;
-	}
+
 
 	/* Register the socket-side information for inet6_create.  */
 	for(r = &inetsw6[0]; r < &inetsw6[SOCK_MAX]; ++r)

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
