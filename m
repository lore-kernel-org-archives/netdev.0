From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] fix net/ipv4/route.c with gcc 3.4
Date: Tue, 22 Mar 2005 13:22:13 +0100
Message-ID: <20050322122213.GH3982@stusta.de>
References: <20050321025159.1cabd62e.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
To: Einar Lueck <elueck@de.ibm.com>
Content-Disposition: inline
In-Reply-To: <20050321025159.1cabd62e.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The following compile error comes from Linus' tree with 
CONFIG_IP_ROUTE_MULTIPATH_CACHED=y:

<--  snip  -->

...
  CC      net/ipv4/route.o
net/ipv4/route.c: In function `rt_remove_balanced_route':
net/ipv4/route.c:151: sorry, unimplemented: inlining failed in call to 'compare_keys': function body not available
net/ipv4/route.c:540: sorry, unimplemented: called from here
make[2]: *** [net/ipv4/route.o] Error 1

<--  snip  -->


This patch fixes this compile error by moving compare_keys up.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 net/ipv4/route.c |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

--- linux-2.6.12-rc1-mm1-full/net/ipv4/route.c.old	2005-03-22 13:10:35.000000000 +0100
+++ linux-2.6.12-rc1-mm1-full/net/ipv4/route.c	2005-03-22 13:12:29.000000000 +0100
@@ -148,7 +148,6 @@
 static void		 ipv4_link_failure(struct sk_buff *skb);
 static void		 ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu);
 static int rt_garbage_collect(void);
-static inline int compare_keys(struct flowi *fl1, struct flowi *fl2);
 
 
 static struct dst_ops ipv4_dst_ops = {
@@ -450,6 +449,13 @@
 
 #endif /* CONFIG_PROC_FS */
   
+static inline int compare_keys(struct flowi *fl1, struct flowi *fl2)
+{
+	return memcmp(&fl1->nl_u.ip4_u, &fl2->nl_u.ip4_u, sizeof(fl1->nl_u.ip4_u)) == 0 &&
+	       fl1->oif     == fl2->oif &&
+	       fl1->iif     == fl2->iif;
+}
+
 static __inline__ void rt_free(struct rtable *rt)
 {
 	multipath_remove(rt);
@@ -858,13 +864,6 @@
 out:	return 0;
 }
 
-static inline int compare_keys(struct flowi *fl1, struct flowi *fl2)
-{
-	return memcmp(&fl1->nl_u.ip4_u, &fl2->nl_u.ip4_u, sizeof(fl1->nl_u.ip4_u)) == 0 &&
-	       fl1->oif     == fl2->oif &&
-	       fl1->iif     == fl2->iif;
-}
-
 static int rt_intern_hash(unsigned hash, struct rtable *rt, struct rtable **rp)
 {
 	struct rtable	*rth, **rthp;
