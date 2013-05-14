From: Cong Wang <amwang@redhat.com>
Subject: Re: Some netfilter compile errors when CONFIG_IPV6=m
Date: Tue, 14 May 2013 10:48:22 +0800
Message-ID: <1368499702.2507.7.camel@cr0>
References: <1368499552.2507.5.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1368499552.2507.5.camel@cr0>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-05-14 at 10:45 +0800, Cong Wang wrote:
> net/built-in.o: In function `tproxy_tg_init':
> /home/wangcong/linux/net/netfilter/xt_TPROXY.c:415: undefined reference
> to `nf_defrag_ipv6_enable'
> net/built-in.o: In function `socket_mt_init':
> /home/wangcong/linux/net/netfilter/xt_socket.c:366: undefined reference
> to `nf_defrag_ipv6_enable'

I don't know why we keep an empty definition for
nf_defrag_ipv6_enable(), so I make a patch to remove it, not sure if it
makes sense.


diff --git a/include/net/netfilter/ipv4/nf_defrag_ipv4.h
b/include/net/netfilter/ipv4/nf_defrag_ipv4.h
deleted file mode 100644
index 6b00ea3..0000000
--- a/include/net/netfilter/ipv4/nf_defrag_ipv4.h
+++ /dev/null
@@ -1,6 +0,0 @@
-#ifndef _NF_DEFRAG_IPV4_H
-#define _NF_DEFRAG_IPV4_H
-
-extern void nf_defrag_ipv4_enable(void);
-
-#endif /* _NF_DEFRAG_IPV4_H */
diff --git a/include/net/netfilter/ipv6/nf_defrag_ipv6.h
b/include/net/netfilter/ipv6/nf_defrag_ipv6.h
index fd79c9a..7ba91bb 100644
--- a/include/net/netfilter/ipv6/nf_defrag_ipv6.h
+++ b/include/net/netfilter/ipv6/nf_defrag_ipv6.h
@@ -1,8 +1,6 @@
 #ifndef _NF_DEFRAG_IPV6_H
 #define _NF_DEFRAG_IPV6_H
 
-extern void nf_defrag_ipv6_enable(void);
-
 extern int nf_ct_frag6_init(void);
 extern void nf_ct_frag6_cleanup(void);
 extern struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32
user);
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 567d841..7344253 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -27,7 +27,6 @@
 #include <net/netfilter/nf_conntrack_core.h>
 #include <net/netfilter/ipv4/nf_conntrack_ipv4.h>
 #include <net/netfilter/nf_nat_helper.h>
-#include <net/netfilter/ipv4/nf_defrag_ipv4.h>
 #include <net/netfilter/nf_log.h>
 
 static bool ipv4_pkt_to_tuple(const struct sk_buff *skb, unsigned int
nhoff,
@@ -464,7 +463,6 @@ static int __init
nf_conntrack_l3proto_ipv4_init(void)
 	int ret = 0;
 
 	need_conntrack();
-	nf_defrag_ipv4_enable();
 
 	ret = nf_register_sockopt(&so_getorigdst);
 	if (ret < 0) {
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c
b/net/ipv4/netfilter/nf_defrag_ipv4.c
index 7428155..b2ec6f1 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -16,7 +16,6 @@
 
 #include <linux/netfilter_bridge.h>
 #include <linux/netfilter_ipv4.h>
-#include <net/netfilter/ipv4/nf_defrag_ipv4.h>
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 #include <net/netfilter/nf_conntrack.h>
 #endif
@@ -117,11 +116,6 @@ static void __exit nf_defrag_fini(void)
 	nf_unregister_hooks(ipv4_defrag_ops, ARRAY_SIZE(ipv4_defrag_ops));
 }
 
-void nf_defrag_ipv4_enable(void)
-{
-}
-EXPORT_SYMBOL_GPL(nf_defrag_ipv4_enable);
-
 module_init(nf_defrag_init);
 module_exit(nf_defrag_fini);
 
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 97bcf2b..3fc4d53 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -460,7 +460,6 @@ static int __init
nf_conntrack_l3proto_ipv6_init(void)
 	int ret = 0;
 
 	need_conntrack();
-	nf_defrag_ipv6_enable();
 
 	ret = nf_register_sockopt(&so_getorigdst6);
 	if (ret < 0) {
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index aacd121..97c876f 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -125,12 +125,6 @@ static void __exit nf_defrag_fini(void)
 	nf_unregister_hooks(ipv6_defrag_ops, ARRAY_SIZE(ipv6_defrag_ops));
 	nf_ct_frag6_cleanup();
 }
-
-void nf_defrag_ipv6_enable(void)
-{
-}
-EXPORT_SYMBOL_GPL(nf_defrag_ipv6_enable);
-
 module_init(nf_defrag_init);
 module_exit(nf_defrag_fini);
 
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index d7f1953..fc7384d 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -20,8 +20,6 @@
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter_ipv4/ip_tables.h>
 
-#include <net/netfilter/ipv4/nf_defrag_ipv4.h>
-
 #if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 #define XT_TPROXY_HAVE_IPV6 1
 #include <net/if_inet6.h>
@@ -410,11 +408,6 @@ static struct xt_target tproxy_tg_reg[]
__read_mostly = {
 
 static int __init tproxy_tg_init(void)
 {
-	nf_defrag_ipv4_enable();
-#ifdef XT_TPROXY_HAVE_IPV6
-	nf_defrag_ipv6_enable();
-#endif
-
 	return xt_register_targets(tproxy_tg_reg, ARRAY_SIZE(tproxy_tg_reg));
 }
 
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 63b2bdb..c588d68 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -20,7 +20,6 @@
 #include <net/sock.h>
 #include <net/inet_sock.h>
 #include <net/netfilter/nf_tproxy_core.h>
-#include <net/netfilter/ipv4/nf_defrag_ipv4.h>
 
 #if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 #define XT_SOCKET_HAVE_IPV6 1
@@ -361,11 +360,6 @@ static struct xt_match socket_mt_reg[]
__read_mostly = {
 
 static int __init socket_mt_init(void)
 {
-	nf_defrag_ipv4_enable();
-#ifdef XT_SOCKET_HAVE_IPV6
-	nf_defrag_ipv6_enable();
-#endif
-
 	return xt_register_matches(socket_mt_reg, ARRAY_SIZE(socket_mt_reg));
 }


