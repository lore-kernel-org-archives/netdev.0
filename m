From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPv6: Default Router Selection Round-robin
Date: Thu, 03 Oct 2002 01:50:57 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021003.015057.14743018.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

Linux changes default router even while it is probably reachable.
Once it becomes "non-REACHABLE," Linux trys to select one in round-robin
fashion, but once it reached end of list, it would be stuck there.

Here's the patch against 2.4.19.

Thank you in advance.

-------------------------------------------------------------------
Patch-Name: Default Router Selection Round-robin
Patch-Id: FIX_2_4_19_DEFRTR_SELECT-20020919
Patch-Author: YOSHIFUJI Hideaki / USAGI Project <yoshfuji@linux-ipv6.org>
Credit: YOSHIFUJI Hideaki / USAGI Project <yoshfuji@linux-ipv6.org>
Reference: RFC2461
-------------------------------------------------------------------
Index: net/ipv6/route.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux24/net/ipv6/route.c,v
retrieving revision 1.1.1.1
retrieving revision 1.1.1.1.14.1
diff -u -r1.1.1.1 -r1.1.1.1.14.1
--- net/ipv6/route.c	2002/08/20 09:47:02	1.1.1.1
+++ net/ipv6/route.c	2002/09/19 16:28:03	1.1.1.1.14.1
@@ -13,6 +13,17 @@
  *      2 of the License, or (at your option) any later version.
  */
 
+/*	Changes:
+ *
+ *	YOSHIFUJI Hideaki @USAGI
+ *		reworked default router selection.
+ *		- respect outgoing interface
+ *		- select from (probably) reachable routers (i.e.
+ *		routers in REACHABLE, STALE, DELAY or PROBE states).
+ *		- always select the same router if it is (probably)
+ *		reachable.  otherwise, round-robin the list.
+ */
+
 #include <linux/config.h>
 #include <linux/errno.h>
 #include <linux/types.h>
@@ -168,6 +179,7 @@
 static struct rt6_info *rt6_dflt_pointer = NULL;
 static spinlock_t rt6_dflt_lock = SPIN_LOCK_UNLOCKED;
 
+/* Default Router Selection (RFC 2461 6.3.6) */
 static struct rt6_info *rt6_best_dflt(struct rt6_info *rt, int oif)
 {
 	struct rt6_info *match = NULL;
@@ -176,63 +188,117 @@
 
 	for (sprt = rt; sprt; sprt = sprt->u.next) {
 		struct neighbour *neigh;
+		int m = 0;
 
-		if ((neigh = sprt->rt6i_nexthop) != NULL) {
-			int m = -1;
+		if (!oif ||
+		    (sprt->rt6i_dev &&
+		     sprt->rt6i_dev->ifindex == oif))
+			m += 8;
 
+		if (sprt == rt6_dflt_pointer)
+			m += 4;
+
+		if ((neigh = sprt->rt6i_nexthop) != NULL) {
+			read_lock_bh(&neigh->lock);
 			switch (neigh->nud_state) {
 			case NUD_REACHABLE:
-				if (sprt != rt6_dflt_pointer) {
-					rt = sprt;
-					goto out;
-				}
-				m = 2;
+				m += 3;
 				break;
 
+			case NUD_STALE:
 			case NUD_DELAY:
-				m = 1;
+			case NUD_PROBE:
+				m += 2;
 				break;
 
-			case NUD_STALE:
-				m = 1;
+			case NUD_NOARP:
+			case NUD_PERMANENT:
+				m += 1;
 				break;
-			};
 
-			if (oif && sprt->rt6i_dev->ifindex == oif) {
-				m += 2;
+			case NUD_INCOMPLETE:
+			default:
+				read_unlock_bh(&neigh->lock);
+				continue;
 			}
+			read_unlock_bh(&neigh->lock);
+		} else {
+			continue;
+		}
 
-			if (m >= mpri) {
-				mpri = m;
-				match = sprt;
+		if (m > mpri || m >= 12) {
+			match = sprt;
+			mpri = m;
+			if (m >= 12) {
+				/* we choose the lastest default router if it
+				 * is in (probably) reachable state.
+				 * If route changed, we should do pmtu
+				 * discovery. --yoshfuji
+				 */
+				break;
 			}
 		}
 	}
 
-	if (match) {
-		rt = match;
-	} else {
+	spin_lock(&rt6_dflt_lock);
+	if (!match) {
 		/*
 		 *	No default routers are known to be reachable.
 		 *	SHOULD round robin
 		 */
-		spin_lock(&rt6_dflt_lock);
 		if (rt6_dflt_pointer) {
-			struct rt6_info *next;
-
-			if ((next = rt6_dflt_pointer->u.next) != NULL &&
-			    next->u.dst.obsolete <= 0 &&
-			    next->u.dst.error == 0)
-				rt = next;
+			for (sprt = rt6_dflt_pointer->u.next;
+			     sprt; sprt = sprt->u.next) {
+				if (sprt->u.dst.obsolete <= 0 &&
+				    sprt->u.dst.error == 0) {
+					match = sprt;
+					break;
+				}
+			}
+			for (sprt = rt;
+			     !match && sprt && sprt != rt6_dflt_pointer; 
+			     sprt = sprt->u.next) {
+				if (sprt->u.dst.obsolete <= 0 &&
+				    sprt->u.dst.error == 0) {
+					match = sprt;
+					break;
+				}
+			}
 		}
-		spin_unlock(&rt6_dflt_lock);
 	}
 
-out:
-	spin_lock(&rt6_dflt_lock);
-	rt6_dflt_pointer = rt;
+	if (match) {
+		if (rt6_dflt_pointer != match)
+			RT6_TRACE1(KERN_INFO 
+					"changed default router: %p->%p\n",
+					rt6_dflt_pointer, match);
+		rt6_dflt_pointer = match;
+	}
 	spin_unlock(&rt6_dflt_lock);
-	return rt;
+
+	if (!match) {
+		/*
+		 * Last Resort: if no default routers found, 
+		 * use addrconf default route.
+		 * We don't record this route.
+		 */
+		for (sprt = ip6_routing_table.leaf;
+		     sprt; sprt = sprt->u.next) {
+			if ((sprt->rt6i_flags & RTF_DEFAULT) &&
+			    (!oif ||
+			     (sprt->rt6i_dev &&
+			      sprt->rt6i_dev->ifindex == oif))) {
+				match = sprt;
+				break;
+			}
+		}
+		if (!match) {
+			/* no default route.  give up. */
+			match = &ip6_null_entry;
+		}
+	}
+
+	return match;
 }
 
 struct rt6_info *rt6_lookup(struct in6_addr *daddr, struct in6_addr *saddr,

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
