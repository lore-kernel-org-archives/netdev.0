From: "Jan Beulich" <JBeulich@suse.com>
Subject: [PATCH] adjust __net_exit
Date: Thu, 08 Mar 2012 09:37:32 +0000
Message-ID: <4F588BEC020000780007710A@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <netfilter-devel@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

__net_exit, judging by the majority of its uses, was intended to serve
as an abstraction to allow calling such annotated functions from both
__init and __exit functions. Using the (bogus and unused elsewhere)
__exit_refok to implement this is inefficient - any non-modular code
really can reside in __init (as non-modular __exit code is never used).

Therefore, adjust __net_exit to resolve to nothing (i.e. normal .text)
in modules, and __init in the core kernel.

A few other adjustments are necessary/possible with this done - those
were likely just oversights when added originally.

Signed-off-by: Jan Beulich <jbeulich@suse.com>

---
 include/net/net_namespace.h    |    6 +++++-
 net/ipv4/fib_frontend.c        |    2 +-
 net/netfilter/ipvs/ip_vs_ctl.c |    8 ++++----
 3 files changed, 10 insertions(+), 6 deletions(-)

--- 3.3-rc6/include/net/net_namespace.h
+++ 3.3-rc6-net-exit/include/net/net_namespace.h
@@ -242,7 +242,11 @@ static inline struct net *read_pnet(stru
 #define __net_initdata
 #else
 #define __net_init	__init
-#define __net_exit	__exit_refok
+#ifdef MODULE
+#define __net_exit
+#else
+#define __net_exit	__init
+#endif
 #define __net_initdata	__initdata
 #endif
 
--- 3.3-rc6/net/ipv4/fib_frontend.c
+++ 3.3-rc6-net-exit/net/ipv4/fib_frontend.c
@@ -1062,7 +1062,7 @@ fail:
 	return err;
 }
 
-static void ip_fib_net_exit(struct net *net)
+static void __net_exit ip_fib_net_exit(struct net *net)
 {
 	unsigned int i;
 
--- 3.3-rc6/net/netfilter/ipvs/ip_vs_ctl.c
+++ 3.3-rc6-net-exit/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3621,7 +3621,7 @@ static void ip_vs_genl_unregister(void)
  * per netns intit/exit func.
  */
 #ifdef CONFIG_SYSCTL
-int __net_init ip_vs_control_net_init_sysctl(struct net *net)
+static int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 {
 	int idx;
 	struct netns_ipvs *ipvs = net_ipvs(net);
@@ -3680,7 +3680,7 @@ int __net_init ip_vs_control_net_init_sy
 	return 0;
 }
 
-void __net_init ip_vs_control_net_cleanup_sysctl(struct net *net)
+static void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
@@ -3691,8 +3691,8 @@ void __net_init ip_vs_control_net_cleanu
 
 #else
 
-int __net_init ip_vs_control_net_init_sysctl(struct net *net) { return 0; }
-void __net_init ip_vs_control_net_cleanup_sysctl(struct net *net) { }
+static int __net_init ip_vs_control_net_init_sysctl(struct net *net) { return 0; }
+static void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net) { }
 
 #endif
 



