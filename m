From: Daniel McNeil <daniel@osdl.org>
Subject: [PATCH 2.5.68] net/ipv6 missing kmem_cache_destroy
Date: 29 Apr 2003 09:21:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1051633278.2446.103.camel@ibm-c.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-0IQSK81vzug9fKned0fJ"
Return-path: <netdev-bounce@oss.sgi.com>
To: "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-0IQSK81vzug9fKned0fJ
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

While trying to get ipv6 to work as a module with the new module
reference code, I notice that ipv6 is missing the kmem_cache_destroy()
calls that the init functions created.

Another problem with ipv6 is that it creates sockets in the init
routine, so there are reference to the module which will prevent it
from being unloaded.  I tried adding a module_put for every
socket created in the init routines, but ran into a problem with
inet6_exit() calling sock_unregister(PF_INET6) as the very first thing.
This caused a problem when the cleanup routines were called and
the did a sock_release().

Any ideas on how to fix this so ipv6 can be a module?
init routines creating sockets makes things difficult.

I've attached a patch to 2.5.68 to add the missing kmem_cache_destroy
calls.

BTW, how does one get on the netdev mailing list?

Thanks,

-- 
Daniel McNeil <daniel@osdl.org>

--=-0IQSK81vzug9fKned0fJ
Content-Disposition: attachment; filename=patch.2.5.68-ipv6.kmem
Content-Type: text/x-patch; name=patch.2.5.68-ipv6.kmem; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

diff -rupN -X /home/daniel/dontdiff linux-2.5.68/net/ipv6/af_inet6.c linux-2.5.68-sock/net/ipv6/af_inet6.c
--- linux-2.5.68/net/ipv6/af_inet6.c	Sat Apr 19 19:49:56 2003
+++ linux-2.5.68-sock/net/ipv6/af_inet6.c	Tue Apr 29 09:03:08 2003
@@ -871,6 +871,9 @@ static void inet6_exit(void)
 	ipv6_sysctl_unregister();	
 #endif
 	cleanup_ipv6_mibs();
+	kmem_cache_destroy(tcp6_sk_cachep);
+	kmem_cache_destroy(udp6_sk_cachep);
+	kmem_cache_destroy(raw6_sk_cachep);
 }
 module_exit(inet6_exit);
 #endif /* MODULE */
diff -rupN -X /home/daniel/dontdiff linux-2.5.68/net/ipv6/ip6_fib.c linux-2.5.68-sock/net/ipv6/ip6_fib.c
--- linux-2.5.68/net/ipv6/ip6_fib.c	Sat Apr 19 19:50:37 2003
+++ linux-2.5.68-sock/net/ipv6/ip6_fib.c	Tue Apr 29 09:03:30 2003
@@ -1241,6 +1241,8 @@ void __init fib6_init(void)
 void fib6_gc_cleanup(void)
 {
 	del_timer(&ip6_fib_timer);
+	if (fib6_node_kmem)
+		kmem_cache_destroy(fib6_node_kmem);
 }
 #endif
 
diff -rupN -X /home/daniel/dontdiff linux-2.5.68/net/ipv6/route.c linux-2.5.68-sock/net/ipv6/route.c
--- linux-2.5.68/net/ipv6/route.c	Sat Apr 19 19:50:34 2003
+++ linux-2.5.68-sock/net/ipv6/route.c	Tue Apr 29 09:04:29 2003
@@ -1897,5 +1897,6 @@ void ip6_route_cleanup(void)
 	xfrm6_fini();
 	rt6_ifdown(NULL);
 	fib6_gc_cleanup();
+	kmem_cache_destroy(ip6_dst_ops.kmem_cachep);
 }
 #endif	/* MODULE */

--=-0IQSK81vzug9fKned0fJ--
