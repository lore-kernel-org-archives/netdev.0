From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] [IPV4]: Exclude "All deletion of equal addresses only differing by prefix length."
Date: Thu, 31 Mar 2005 14:47:47 +0200
Message-ID: <20050331124747.GT3086@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The address deletion fix is no longer needed since a better fix
has made it into iproute2. Better in terms of same hack but in
userspace so we don't confuse other netlink users.

Please do a

	bk pull bk://kernel.bkbits.net/tgraf/net-2.6-trunk

This will update the following files:

 include/linux/inetdevice.h |   20 --------------------
 include/linux/rtnetlink.h  |   13 -------------
 net/ipv4/devinet.c         |    6 ++----
 3 files changed, 2 insertions(+), 37 deletions(-)

through these ChangeSets:

<tgraf@suug.ch> (05/03/31 1.2199)
   Cset exclude: tgraf@suug.ch|ChangeSet|20050316221421|24742


# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/31 14:34:31+02:00 tgraf@suug.ch 
#   Cset exclude: tgraf@suug.ch|ChangeSet|20050316221421|24742
# 
# net/ipv4/devinet.c
#   2005/03/31 14:34:23+02:00 tgraf@suug.ch +0 -0
#   Exclude
# 
# include/linux/rtnetlink.h
#   2005/03/31 14:34:23+02:00 tgraf@suug.ch +0 -0
#   Exclude
# 
# include/linux/inetdevice.h
#   2005/03/31 14:34:23+02:00 tgraf@suug.ch +0 -0
#   Exclude
# 
diff -Nru a/include/linux/inetdevice.h b/include/linux/inetdevice.h
--- a/include/linux/inetdevice.h	2005-03-31 14:35:28 +02:00
+++ b/include/linux/inetdevice.h	2005-03-31 14:35:28 +02:00
@@ -7,7 +7,6 @@
 #include <linux/netdevice.h>
 #include <linux/rcupdate.h>
 #include <linux/timer.h>
-#include <linux/rtnetlink.h>
 
 struct ipv4_devconf
 {
@@ -130,25 +129,6 @@
 	if (mask & (mask+1))
 		return 1;
 	return 0;
-}
-
-static inline int inet_ifa_match_local_prefixlen(struct ifaddrmsg *ifm,
-						 struct in_ifaddr *ifa)
-{
-	int real_prefixlen = IFA_REAL_DEL_PREFIX(ifm->ifa_prefixlen);
-
-	/*
-	 * Since the prefix length hasn't been taken into account in
-	 * previous kernel versions, parts of the userspace rely on the fact
-	 * that the deletion of an address without specifying a prefix works.
-	 * We cannot break this and thus a prefix length of 32 still represents
-	 * a wildcard if no exact match is requested.
-	 */
-	if (real_prefixlen != 32 || ifm->ifa_prefixlen & IFA_PREFIX_EXACT_DEL)
-		if (real_prefixlen != ifa->ifa_prefixlen)
-			return 0;
-
-	return 1;
 }
 
 #define for_primary_ifa(in_dev)	{ struct in_ifaddr *ifa; \
diff -Nru a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
--- a/include/linux/rtnetlink.h	2005-03-31 14:35:28 +02:00
+++ b/include/linux/rtnetlink.h	2005-03-31 14:35:28 +02:00
@@ -398,19 +398,6 @@
 
 #define IFA_MAX (__IFA_MAX - 1)
 
-/*
- * Quirk for IPv4 address deletion to allow exact deletion of equal
- * addresses varying only in prefix length. A explicit exact comparison
- * of the prefix length will only be done if IFA_PREFIX_EXACT_DEL is
- * ORed to ifa_prefixlen.
- *
- * Note: This special treatment is only understood while deleting
- *       addresses and will lead to unexpected behaviour if used
- *       otherwise.
- */
-#define IFA_PREFIX_EXACT_DEL	0x40
-#define IFA_REAL_DEL_PREFIX(l)	((l) & 0x3f)
-
 /* ifa_flags */
 
 #define IFA_F_SECONDARY		0x01
diff -Nru a/net/ipv4/devinet.c b/net/ipv4/devinet.c
--- a/net/ipv4/devinet.c	2005-03-31 14:35:28 +02:00
+++ b/net/ipv4/devinet.c	2005-03-31 14:35:28 +02:00
@@ -389,7 +389,6 @@
 	struct in_device *in_dev;
 	struct ifaddrmsg *ifm = NLMSG_DATA(nlh);
 	struct in_ifaddr *ifa, **ifap;
-	int real_prefixlen = IFA_REAL_DEL_PREFIX(ifm->ifa_prefixlen);
 
 	ASSERT_RTNL();
 
@@ -400,13 +399,12 @@
 	for (ifap = &in_dev->ifa_list; (ifa = *ifap) != NULL;
 	     ifap = &ifa->ifa_next) {
 		if ((rta[IFA_LOCAL - 1] &&
-		    (!inet_ifa_match_local_prefixlen(ifm, ifa) ||
 		     memcmp(RTA_DATA(rta[IFA_LOCAL - 1]),
-			    &ifa->ifa_local, 4))) ||
+			    &ifa->ifa_local, 4)) ||
 		    (rta[IFA_LABEL - 1] &&
 		     rtattr_strcmp(rta[IFA_LABEL - 1], ifa->ifa_label)) ||
 		    (rta[IFA_ADDRESS - 1] &&
-		     (real_prefixlen != ifa->ifa_prefixlen ||
+		     (ifm->ifa_prefixlen != ifa->ifa_prefixlen ||
 		      !inet_ifa_match(*(u32*)RTA_DATA(rta[IFA_ADDRESS - 1]),
 			      	      ifa))))
 			continue;
