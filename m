From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [2/2] Modularise xfrm_tunnel
Date: Thu, 19 Aug 2004 21:40:50 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040819114050.GA16049@gondor.apana.org.au>
References: <20040819113841.GA13872@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="4Ckj6UjgE2iN1+kY"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040819113841.GA13872@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

This patch allows the the user to build xfrm4_tunnel/xfrm6_tunnel as
modules.

This makes sense because they're only used by IPComp/IPIP/IP6Tunnel
which are modules themselves.  It also means that distros can cut
down on there core kernel size when compiling with IPsec support.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== include/net/xfrm.h 1.67 vs edited =====
--- 1.67/include/net/xfrm.h	2004-08-19 20:58:20 +10:00
+++ edited/include/net/xfrm.h	2004-08-19 21:39:53 +10:00
@@ -754,8 +754,6 @@
 extern void xfrm4_state_fini(void);
 extern void xfrm6_state_init(void);
 extern void xfrm6_state_fini(void);
-extern void xfrm6_tunnel_init(void);
-extern void xfrm6_tunnel_fini(void);
 
 extern int xfrm_state_walk(u8 proto, int (*func)(struct xfrm_state *, int, void*), void *);
 extern struct xfrm_state *xfrm_state_alloc(void);
===== net/ipv4/Kconfig 1.15 vs edited =====
--- 1.15/net/ipv4/Kconfig	2004-07-12 10:41:39 +10:00
+++ edited/net/ipv4/Kconfig	2004-08-19 21:39:53 +10:00
@@ -187,7 +187,7 @@
 config NET_IPIP
 	tristate "IP: tunneling"
 	depends on INET
-	select XFRM
+	select INET_TUNNEL
 	---help---
 	  Tunneling means encapsulating data of one protocol type within
 	  another protocol and sending it over a channel that understands the
@@ -351,11 +351,21 @@
 config INET_IPCOMP
 	tristate "IP: IPComp transformation"
 	select XFRM
+	select INET_TUNNEL
 	select CRYPTO
 	select CRYPTO_DEFLATE
 	---help---
 	  Support for IP Paylod Compression (RFC3173), typically needed
 	  for IPsec.
+	  
+	  If unsure, say Y.
+
+config INET_TUNNEL
+	tristate "IP: tunnel transformation"
+	select XFRM
+	---help---
+	  Support for generic IP tunnel transformation, which is required by
+	  the IP tunneling module as well as tunnel mode IPComp.
 	  
 	  If unsure, say Y.
 
===== net/ipv4/Makefile 1.24 vs edited =====
--- 1.24/net/ipv4/Makefile	2004-07-24 09:16:23 +10:00
+++ edited/net/ipv4/Makefile	2004-08-19 21:39:53 +10:00
@@ -19,9 +19,10 @@
 obj-$(CONFIG_INET_AH) += ah4.o
 obj-$(CONFIG_INET_ESP) += esp4.o
 obj-$(CONFIG_INET_IPCOMP) += ipcomp.o
+obj-$(CONFIG_INET_TUNNEL) += xfrm4_tunnel.o 
 obj-$(CONFIG_IP_PNP) += ipconfig.o
 obj-$(CONFIG_NETFILTER)	+= netfilter/
 obj-$(CONFIG_IP_VS) += ipvs/
 
 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
-		      xfrm4_tunnel.o xfrm4_output.o
+		      xfrm4_output.o
===== net/ipv4/xfrm4_tunnel.c 1.18 vs edited =====
--- 1.18/net/ipv4/xfrm4_tunnel.c	2004-08-19 21:38:08 +10:00
+++ edited/net/ipv4/xfrm4_tunnel.c	2004-08-19 21:39:54 +10:00
@@ -4,6 +4,7 @@
  */
 
 #include <linux/skbuff.h>
+#include <linux/module.h>
 #include <net/xfrm.h>
 #include <net/ip.h>
 #include <net/protocol.h>
@@ -43,6 +44,8 @@
 	return ret;
 }
 
+EXPORT_SYMBOL(xfrm4_tunnel_register);
+
 int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler)
 {
 	int ret;
@@ -59,6 +62,8 @@
 
 	return ret;
 }
+
+EXPORT_SYMBOL(xfrm4_tunnel_deregister);
 
 static int ipip_rcv(struct sk_buff *skb)
 {
===== net/ipv6/Kconfig 1.10 vs edited =====
--- 1.10/net/ipv6/Kconfig	2004-08-15 17:42:13 +10:00
+++ edited/net/ipv6/Kconfig	2004-08-19 21:39:54 +10:00
@@ -48,6 +48,7 @@
 	tristate "IPv6: IPComp transformation"
 	depends on IPV6
 	select XFRM
+	select INET6_TUNNEL
 	select CRYPTO
 	select CRYPTO_DEFLATE
 	---help---
@@ -56,10 +57,21 @@
 
 	  If unsure, say Y.
 
+config INET6_TUNNEL
+	tristate "IPv6: tunnel transformation"
+	depends on IPV6
+	select XFRM
+	---help---
+	  Support for generic IPv6-in-IPv6 tunnel transformation, which is
+	  required by the IPv6-in-IPv6 tunneling module as well as tunnel mode
+	  IPComp.
+	  
+	  If unsure, say Y.
+
 config IPV6_TUNNEL
 	tristate "IPv6: IPv6-in-IPv6 tunnel"
 	depends on IPV6
-	select XFRM
+	select INET6_TUNNEL
 	---help---
 	  Support for IPv6-in-IPv6 tunnels described in RFC 2473.
 
===== net/ipv6/Makefile 1.19 vs edited =====
--- 1.19/net/ipv6/Makefile	2004-08-02 07:15:02 +10:00
+++ edited/net/ipv6/Makefile	2004-08-19 21:39:54 +10:00
@@ -11,12 +11,13 @@
 		ip6_flowlabel.o ipv6_syms.o
 
 ipv6-$(CONFIG_XFRM) += xfrm6_policy.o xfrm6_state.o xfrm6_input.o \
-	xfrm6_tunnel.o xfrm6_output.o
+	xfrm6_output.o
 ipv6-objs += $(ipv6-y)
 
 obj-$(CONFIG_INET6_AH) += ah6.o
 obj-$(CONFIG_INET6_ESP) += esp6.o
 obj-$(CONFIG_INET6_IPCOMP) += ipcomp6.o
+obj-$(CONFIG_INET6_TUNNEL) += xfrm6_tunnel.o 
 obj-$(CONFIG_NETFILTER)	+= netfilter/
 
 obj-$(CONFIG_IPV6_TUNNEL) += ip6_tunnel.o
===== net/ipv6/xfrm6_policy.c 1.21 vs edited =====
--- 1.21/net/ipv6/xfrm6_policy.c	2004-08-02 07:15:03 +10:00
+++ edited/net/ipv6/xfrm6_policy.c	2004-08-19 21:39:54 +10:00
@@ -277,12 +277,10 @@
 {
 	xfrm6_policy_init();
 	xfrm6_state_init();
-	xfrm6_tunnel_init();
 }
 
 void __exit xfrm6_fini(void)
 {
-	xfrm6_tunnel_fini();
 	//xfrm6_input_fini();
 	xfrm6_policy_fini();
 	xfrm6_state_fini();
===== net/ipv6/xfrm6_tunnel.c 1.8 vs edited =====
--- 1.8/net/ipv6/xfrm6_tunnel.c	2004-08-19 20:58:20 +10:00
+++ edited/net/ipv6/xfrm6_tunnel.c	2004-08-19 21:39:54 +10:00
@@ -501,31 +501,32 @@
 	.flags          = INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
 };
 
-void __init xfrm6_tunnel_init(void)
+static int __init xfrm6_tunnel_init(void)
 {
 	X6TPRINTK3(KERN_DEBUG "%s()\n", __FUNCTION__);
 
 	if (xfrm_register_type(&xfrm6_tunnel_type, AF_INET6) < 0) {
 		X6TPRINTK1(KERN_ERR
 			   "xfrm6_tunnel init: can't add xfrm type\n");
-		return;
+		return -EAGAIN;
 	}
 	if (inet6_add_protocol(&xfrm6_tunnel_protocol, IPPROTO_IPV6) < 0) {
 		X6TPRINTK1(KERN_ERR
 			   "xfrm6_tunnel init(): can't add protocol\n");
 		xfrm_unregister_type(&xfrm6_tunnel_type, AF_INET6);
-		return;
+		return -EAGAIN;
 	}
 	if (xfrm6_tunnel_spi_init() < 0) {
 		X6TPRINTK1(KERN_ERR
 			   "xfrm6_tunnel init: failed to initialize spi\n");
 		inet6_del_protocol(&xfrm6_tunnel_protocol, IPPROTO_IPV6);
 		xfrm_unregister_type(&xfrm6_tunnel_type, AF_INET6);
-		return;
+		return -EAGAIN;
 	}
+	return 0;
 }
 
-void __exit xfrm6_tunnel_fini(void)
+static void __exit xfrm6_tunnel_fini(void)
 {
 	X6TPRINTK3(KERN_DEBUG "%s()\n", __FUNCTION__);
 
@@ -537,3 +538,7 @@
 		X6TPRINTK1(KERN_ERR
 			   "xfrm6_tunnel close: can't remove xfrm type\n");
 }
+
+module_init(xfrm6_tunnel_init);
+module_exit(xfrm6_tunnel_fini);
+MODULE_LICENSE("GPL");

--4Ckj6UjgE2iN1+kY--
