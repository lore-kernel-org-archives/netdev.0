From: Tom Lendacky <toml@us.ibm.com>
Subject: [PATCH] IPSec: IPV6_IPSEC_POLICY / IPV6_XFRM_POLICY socket options
Date: 20 Mar 2003 18:40:16 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1048207217.1212.3.camel@tomlt2.tomloffice.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, toml@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I've created a patch to fix the problem of racoon not being able to 
listen on IPv6 addresses.  The problem occurs from not having support 
for the IP(V6)_IPSEC_POLICY and IP(V6)_XFRM_POLICY socket options in 
IPv6. 

Please review the patch below and let me know if my fix is ok. 

Additionally, for those wanting to run racoon you will have to update 
the sockmisc.c file.  You will need to change the #define of 
IPV6_IPSEC_POLICY to use the value 34 and not 16 (which is the 
IP_IPSEC_POLICY value). This will allow racoon to listen on an IPv6 
address, but I'm still not having luck getting racoon working over
IPv6.

Thanks, 
Tom 

diff -ur linux-2.5.65-orig/include/linux/in6.h linux-2.5.65/include/linux/in6.h
--- linux-2.5.65-orig/include/linux/in6.h	2003-03-17 15:44:11.000000000 -0600
+++ linux-2.5.65/include/linux/in6.h	2003-03-20 10:51:33.000000000 -0600
@@ -176,5 +176,8 @@
 #define IPV6_FLOWLABEL_MGR	32
 #define IPV6_FLOWINFO_SEND	33
 
+#define IPV6_IPSEC_POLICY	34
+#define IPV6_XFRM_POLICY	35
+
 
 #endif
diff -ur linux-2.5.65-orig/net/ipv4/xfrm_user.c linux-2.5.65/net/ipv4/xfrm_user.c
--- linux-2.5.65-orig/net/ipv4/xfrm_user.c	2003-03-17 15:44:08.000000000 -0600
+++ linux-2.5.65/net/ipv4/xfrm_user.c	2003-03-20 09:24:53.000000000 -0600
@@ -1080,10 +1080,26 @@
 	struct xfrm_policy *xp;
 	int nr;
 
-	if (opt != IP_XFRM_POLICY) {
-		*dir = -EOPNOTSUPP;
+	switch (family) {
+	case AF_INET:
+		if (opt != IP_XFRM_POLICY) {
+			*dir = -EOPNOTSUPP;
+			return NULL;
+		}
+		break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case AF_INET6:
+		if (opt != IPV6_XFRM_POLICY) {
+			*dir = -EOPNOTSUPP;
+			return NULL;
+		}
+		break;
+#endif
+	default:
+		*dir = -EINVAL;
 		return NULL;
 	}
+
 	*dir = -EINVAL;
 
 	if (len < sizeof(*p) ||
diff -ur linux-2.5.65-orig/net/ipv6/ipv6_sockglue.c linux-2.5.65/net/ipv6/ipv6_sockglue.c
--- linux-2.5.65-orig/net/ipv6/ipv6_sockglue.c	2003-03-17 15:43:39.000000000 -0600
+++ linux-2.5.65/net/ipv6/ipv6_sockglue.c	2003-03-20 10:07:46.000000000 -0600
@@ -47,6 +47,7 @@
 #include <net/inet_common.h>
 #include <net/tcp.h>
 #include <net/udp.h>
+#include <net/xfrm.h>
 
 #include <asm/uaccess.h>
 
@@ -386,6 +387,10 @@
 	case IPV6_FLOWLABEL_MGR:
 		retv = ipv6_flowlabel_opt(sk, optval, optlen);
 		break;
+	case IPV6_IPSEC_POLICY:
+	case IPV6_XFRM_POLICY:
+		retv = xfrm_user_policy(sk, optname, optval, optlen);
+		break;
 
 #ifdef CONFIG_NETFILTER
 	default:
diff -ur linux-2.5.65-orig/net/key/af_key.c linux-2.5.65/net/key/af_key.c
--- linux-2.5.65-orig/net/key/af_key.c	2003-03-17 15:43:49.000000000 -0600
+++ linux-2.5.65/net/key/af_key.c	2003-03-20 16:25:10.000000000 -0600
@@ -2415,8 +2415,23 @@
 	struct xfrm_policy *xp;
 	struct sadb_x_policy *pol = (struct sadb_x_policy*)data;
 
-	if (opt != IP_IPSEC_POLICY) {
-		*dir = -EOPNOTSUPP;
+	switch (family) {
+	case AF_INET:
+		if (opt != IP_IPSEC_POLICY) {
+			*dir = -EOPNOTSUPP;
+			return NULL;
+		}
+		break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case AF_INET6:
+		if (opt != IPV6_IPSEC_POLICY) {
+			*dir = -EOPNOTSUPP;
+			return NULL;
+		}
+		break;
+#endif
+	default:
+		*dir = -EINVAL;
 		return NULL;
 	}
 
