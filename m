From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: MOD_{INC,SEC}_USE_COUNT() in net/ipv{4,6}
Date: Wed, 09 Apr 2003 20:41:57 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030409.204157.51648508.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

This patch (against 2.5.67) converts MOD_{INC,DEC}_USE_COUNT in 
net/ipv{4,6} to try_module_get() and module_put().

Thanks you.

Index: net/ipv4/ip_gre.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv4/ip_gre.c,v
retrieving revision 1.1.1.8
diff -u -r1.1.1.8 ip_gre.c
--- net/ipv4/ip_gre.c	22 Mar 2003 01:52:17 -0000	1.1.1.8
+++ net/ipv4/ip_gre.c	9 Apr 2003 11:28:11 -0000
@@ -262,10 +262,11 @@
 	if (!create)
 		return NULL;
 
-	MOD_INC_USE_COUNT;
+	if (!try_module_get(THIS_MODULE))
+		return NULL;
 	dev = kmalloc(sizeof(*dev) + sizeof(*t), GFP_KERNEL);
 	if (dev == NULL) {
-		MOD_DEC_USE_COUNT;
+		module_put(THIS_MODULE);
 		return NULL;
 	}
 	memset(dev, 0, sizeof(*dev) + sizeof(*t));
@@ -297,7 +298,7 @@
 
 failed:
 	kfree(dev);
-	MOD_DEC_USE_COUNT;
+	module_put(THIS_MODULE);
 	return NULL;
 }
 
@@ -305,7 +306,7 @@
 {
 	if (dev != &ipgre_fb_tunnel_dev) {
 		kfree(dev);
-		MOD_DEC_USE_COUNT;
+		module_put(THIS_MODULE);
 	}
 }
 
@@ -920,7 +921,8 @@
 	struct ip_tunnel_parm p;
 	struct ip_tunnel *t;
 
-	MOD_INC_USE_COUNT;
+	if (!try_module_get(THIS_MODULE))
+		return -EBUSY;
 
 	switch (cmd) {
 	case SIOCGETTUNNEL:
@@ -1035,7 +1037,7 @@
 	}
 
 done:
-	MOD_DEC_USE_COUNT;
+	module_put(THIS_MODULE);
 	return err;
 }
 
@@ -1115,7 +1117,8 @@
 {
 	struct ip_tunnel *t = (struct ip_tunnel*)dev->priv;
 
-	MOD_INC_USE_COUNT;
+	if (!try_module_get(THIS_MODULE))
+		return -EBUSY;
 	if (MULTICAST(t->parms.iph.daddr)) {
 		struct flowi fl = { .oif = t->parms.link,
 				    .nl_u = { .ip4_u =
@@ -1125,13 +1128,13 @@
 				    .proto = IPPROTO_GRE };
 		struct rtable *rt;
 		if (ip_route_output_key(&rt, &fl)) {
-			MOD_DEC_USE_COUNT;
+			module_put(THIS_MODULE);
 			return -EADDRNOTAVAIL;
 		}
 		dev = rt->u.dst.dev;
 		ip_rt_put(rt);
 		if (__in_dev_get(dev) == NULL) {
-			MOD_DEC_USE_COUNT;
+			module_put(THIS_MODULE);
 			return -EADDRNOTAVAIL;
 		}
 		t->mlink = dev->ifindex;
@@ -1150,7 +1153,7 @@
 			in_dev_put(in_dev);
 		}
 	}
-	MOD_DEC_USE_COUNT;
+	module_put(THIS_MODULE);
 	return 0;
 }
 
@@ -1247,13 +1250,14 @@
 #ifdef MODULE
 static int ipgre_fb_tunnel_open(struct net_device *dev)
 {
-	MOD_INC_USE_COUNT;
+	if (!try_module_get(THIS_MODULE))
+		return -EBUSY;
 	return 0;
 }
 
 static int ipgre_fb_tunnel_close(struct net_device *dev)
 {
-	MOD_DEC_USE_COUNT;
+	module_put(THIS_MODULE);
 	return 0;
 }
 #endif
Index: net/ipv4/ipip.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv4/ipip.c,v
retrieving revision 1.1.1.8
diff -u -r1.1.1.8 ipip.c
--- net/ipv4/ipip.c	22 Mar 2003 01:52:17 -0000	1.1.1.8
+++ net/ipv4/ipip.c	9 Apr 2003 11:28:11 -0000
@@ -231,10 +231,11 @@
 	if (!create)
 		return NULL;
 
-	MOD_INC_USE_COUNT;
+	if (!try_module_get(THIS_MODULE))
+		return NULL;
 	dev = kmalloc(sizeof(*dev) + sizeof(*t), GFP_KERNEL);
 	if (dev == NULL) {
-		MOD_DEC_USE_COUNT;
+		module_put(THIS_MODULE);
 		return NULL;
 	}
 	memset(dev, 0, sizeof(*dev) + sizeof(*t));
@@ -266,7 +267,7 @@
 
 failed:
 	kfree(dev);
-	MOD_DEC_USE_COUNT;
+	module_put(THIS_MODULE);
 	return NULL;
 }
 
@@ -274,7 +275,7 @@
 {
 	if (dev != &ipip_fb_tunnel_dev) {
 		kfree(dev);
-		MOD_DEC_USE_COUNT;
+		module_put(THIS_MODULE);
 	}
 }
 
@@ -682,7 +683,8 @@
 	struct ip_tunnel_parm p;
 	struct ip_tunnel *t;
 
-	MOD_INC_USE_COUNT;
+	if (!try_module_get(THIS_MODULE))
+		return -EBUSY;
 
 	switch (cmd) {
 	case SIOCGETTUNNEL:
@@ -782,7 +784,7 @@
 	}
 
 done:
-	MOD_DEC_USE_COUNT;
+	module_put(THIS_MODULE);
 	return err;
 }
 
@@ -861,13 +863,14 @@
 #ifdef MODULE
 static int ipip_fb_tunnel_open(struct net_device *dev)
 {
-	MOD_INC_USE_COUNT;
+	if (!try_module_get(THIS_MODULE))
+		return -EBUSY;
 	return 0;
 }
 
 static int ipip_fb_tunnel_close(struct net_device *dev)
 {
-	MOD_DEC_USE_COUNT;
+	module_put(THIS_MODULE);
 	return 0;
 }
 #endif
Index: net/ipv6/af_inet6.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/af_inet6.c,v
retrieving revision 1.1.1.11
diff -u -r1.1.1.11 af_inet6.c
--- net/ipv6/af_inet6.c	8 Apr 2003 08:57:58 -0000	1.1.1.11
+++ net/ipv6/af_inet6.c	9 Apr 2003 11:28:11 -0000
@@ -111,7 +111,7 @@
 #ifdef INET_REFCNT_DEBUG
 	atomic_dec(&inet6_sock_nr);
 #endif
-	MOD_DEC_USE_COUNT;
+	module_put(THIS_MODULE);
 }
 
 static __inline__ kmem_cache_t *inet6_sk_slab(int protocol)
@@ -242,7 +242,10 @@
 	atomic_inc(&inet6_sock_nr);
 	atomic_inc(&inet_sock_nr);
 #endif
-	MOD_INC_USE_COUNT;
+	if (!try_get_module(THIS_MODULE)) {
+		inet_sock_release(sk);
+		return -EBUSY;
+	}
 
 	if (inet->num) {
 		/* It assumes that any protocol which allows
@@ -255,7 +258,7 @@
 	if (sk->prot->init) {
 		int err = sk->prot->init(sk);
 		if (err != 0) {
-			MOD_DEC_USE_COUNT;
+			module_put(THIS_MODULE);
 			inet_sock_release(sk);
 			return err;
 		}
Index: net/ipv6/ipv6_sockglue.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/ipv6_sockglue.c,v
retrieving revision 1.1.1.8
diff -u -r1.1.1.8 ipv6_sockglue.c
--- net/ipv6/ipv6_sockglue.c	8 Apr 2003 08:57:58 -0000	1.1.1.8
+++ net/ipv6/ipv6_sockglue.c	9 Apr 2003 11:28:11 -0000
@@ -196,7 +196,7 @@
 #ifdef INET_REFCNT_DEBUG
 			atomic_dec(&inet6_sock_nr);
 #endif
-			MOD_DEC_USE_COUNT;
+			module_put(THIS_MODULE);
 			retv = 0;
 			break;
 		}
Index: net/ipv6/sit.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/sit.c,v
retrieving revision 1.1.1.8
diff -u -r1.1.1.8 sit.c
--- net/ipv6/sit.c	22 Mar 2003 01:52:23 -0000	1.1.1.8
+++ net/ipv6/sit.c	9 Apr 2003 11:28:11 -0000
@@ -170,10 +170,11 @@
 	if (!create)
 		return NULL;
 
-	MOD_INC_USE_COUNT;
+	if (!try_module_get(THIS_MODULE))
+		return NULL;
 	dev = kmalloc(sizeof(*dev) + sizeof(*t), GFP_KERNEL);
 	if (dev == NULL) {
-		MOD_DEC_USE_COUNT;
+		module_put(THIS_MODULE);
 		return NULL;
 	}
 	memset(dev, 0, sizeof(*dev) + sizeof(*t));
@@ -205,7 +206,7 @@
 
 failed:
 	kfree(dev);
-	MOD_DEC_USE_COUNT;
+	module_put(THIS_MODULE);
 	return NULL;
 }
 
@@ -213,7 +214,7 @@
 {
 	if (dev != &ipip6_fb_tunnel_dev) {
 		kfree(dev);
-		MOD_DEC_USE_COUNT;
+		module_put(THIS_MODULE);
 	}
 }
 
@@ -622,7 +623,8 @@
 	struct ip_tunnel_parm p;
 	struct ip_tunnel *t;
 
-	MOD_INC_USE_COUNT;
+	if (!try_module_get(THIS_MODULE))
+		return -EBUSY;
 
 	switch (cmd) {
 	case SIOCGETTUNNEL:
@@ -721,7 +723,7 @@
 	}
 
 done:
-	MOD_DEC_USE_COUNT;
+	module_put(THIS_MODULE);
 	return err;
 }
 
@@ -801,13 +803,14 @@
 #ifdef MODULE
 static int ipip6_fb_tunnel_open(struct net_device *dev)
 {
-	MOD_INC_USE_COUNT;
+	if (!try_module_get(THIS_MODULE))
+		return -EBUSY;
 	return 0;
 }
 
 static int ipip6_fb_tunnel_close(struct net_device *dev)
 {
-	MOD_DEC_USE_COUNT;
+	module_put(THIS_MODULE);
 	return 0;
 }
 #endif

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
