From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH 3/3] IPV6: fix algorithm for updating lifetime
Date: Fri, 04 Jul 2003 18:37:03 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030704.183703.78659603.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, jmorris@intercode.com.au
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

3/3: fix algorithm for updating lifetime

This patch, depends on "IPV6: remove unused variable,"
fixes algorithm for updating lifetime according to RFC2462.
 - We should not delete an address even if prefix is 
   advertised with valid lifetime == 0.
 - support the "2 hours" rule.

Index: linux-2.5/include/net/addrconf.h
===================================================================
RCS file: /home/cvs/linux-2.5/include/net/addrconf.h,v
retrieving revision 1.11
diff -u -r1.11 addrconf.h
--- linux-2.5/include/net/addrconf.h	1 Jul 2003 16:42:06 -0000	1.11
+++ linux-2.5/include/net/addrconf.h	4 Jul 2003 07:44:17 -0000
@@ -6,6 +6,8 @@
 #define MAX_RTR_SOLICITATIONS		3
 #define RTR_SOLICITATION_INTERVAL	(4*HZ)
 
+#define MIN_VALID_LIFETIME		(2*3600)	/* 2 hours */
+
 #define TEMP_VALID_LIFETIME		(7*86400)
 #define TEMP_PREFERRED_LIFETIME		(86400)
 #define REGEN_MAX_RETRY			(5)
--- linux-2.5/net/ipv6/addrconf.c~~	Fri Jul  4 18:01:07 2003
+++ linux-2.5/net/ipv6/addrconf.c	Fri Jul  4 18:01:59 2003
@@ -1380,7 +1380,7 @@
 	if (pinfo->autoconf && in6_dev->cnf.autoconf) {
 		struct inet6_ifaddr * ifp;
 		struct in6_addr addr;
-		int create = 0;
+		int create = 0, update_lft = 0;
 
 		if (pinfo->prefix_len == 64) {
 			memcpy(&addr, &pinfo->prefix, 8);
@@ -1414,32 +1414,54 @@
 				return;
 			}
 
-			create = 1;
+			update_lft = create = 1;
 			addrconf_dad_start(ifp);
 		}
 
-		if (ifp && valid_lft == 0) {
-			ipv6_del_addr(ifp);
-			ifp = NULL;
-		}
-
 		if (ifp) {
 			int flags;
+			unsigned long now;
 #ifdef CONFIG_IPV6_PRIVACY
 			struct inet6_ifaddr *ift;
 #endif
+			u32 stored_lft;
 
+			/* update lifetime (RFC2462 5.5.3 e) */
 			spin_lock(&ifp->lock);
-			ifp->valid_lft = valid_lft;
-			ifp->prefered_lft = prefered_lft;
-			ifp->tstamp = jiffies;
-			flags = ifp->flags;
-			ifp->flags &= ~IFA_F_DEPRECATED;
-			spin_unlock(&ifp->lock);
-
-			if (!(flags&IFA_F_TENTATIVE))
-				ipv6_ifa_notify((flags&IFA_F_DEPRECATED) ?
-						0 : RTM_NEWADDR, ifp);
+			now = jiffies;
+			if (ifp->valid_lft > (now - ifp->tstamp) / HZ)
+				stored_lft = ifp->valid_lft - (now - ifp->tstamp) / HZ;
+			else
+				stored_lft = 0;
+			if (!update_lft && stored_lft) {
+				if (valid_lft > MIN_VALID_LIFETIME ||
+				    valid_lft > stored_lft)
+					update_lft = 1;
+				else if (stored_lft <= MIN_VALID_LIFETIME) {
+					/* valid_lft <= stored_lft is always true */
+					/* XXX: IPsec */
+					update_lft = 0;
+				} else {
+					valid_lft = MIN_VALID_LIFETIME;
+					if (valid_lft < prefered_lft)
+						prefered_lft = valid_lft;
+					update_lft = 1;
+				}
+			}
+
+			if (update_lft) {
+				ifp->valid_lft = valid_lft;
+				ifp->prefered_lft = prefered_lft;
+				ifp->tstamp = now;
+				flags = ifp->flags;
+				ifp->flags &= ~IFA_F_DEPRECATED;
+				spin_unlock(&ifp->lock);
+
+				if (!(flags&IFA_F_TENTATIVE))
+					ipv6_ifa_notify((flags&IFA_F_DEPRECATED) ?
+							0 : RTM_NEWADDR, ifp);
+			} else
+				spin_unlock(&ifp->lock);
 
 #ifdef CONFIG_IPV6_PRIVACY
 			read_lock_bh(&in6_dev->lock);


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
