From: Thomas Graf <tgraf@suug.ch>
Subject: [IPROUTE2] Routing attribute alignment fix
Date: Mon, 21 Mar 2005 19:17:29 +0100
Message-ID: <20050321181729.GK3086@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In case someone experiences dsmark qdisc not working correctly with
the latest iproute2 release, here's patch which fixes the problem
(and possibly other problem as well). The alignment of nlmsg_len is
calculated wrong leading to wrong rta_len calculations for nested TLVs
when the data length of the last TLV added to the nested TLV is not
aligned to RTA_ALIGNTO already.

bk tree with this fix and support for multipath algorithm selection
can be found here: bk://kernel.bkbits.net/tgraf/iproute2-tgr

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/20 17:19:39+01:00 tgraf@suug.ch 
#   Fix netlink message alignment when the last routing attribute added
#   has a data length not aligned to RTA_ALIGNTO.
# 
# lib/libnetlink.c
#   2005/03/20 17:19:38+01:00 tgraf@suug.ch +4 -4
#   Fix netlink message alignment when the last routing attribute added
#   has a data length not aligned to RTA_ALIGNTO.
# 
diff -Nru a/lib/libnetlink.c b/lib/libnetlink.c
--- a/lib/libnetlink.c	2005-03-21 19:12:49 +01:00
+++ b/lib/libnetlink.c	2005-03-21 19:12:49 +01:00
@@ -491,7 +491,7 @@
 	int len = RTA_LENGTH(alen);
 	struct rtattr *rta;
 
-	if (NLMSG_ALIGN(n->nlmsg_len) + len > maxlen) {
+	if (NLMSG_ALIGN(n->nlmsg_len) + RTA_ALIGN(len) > maxlen) {
 		fprintf(stderr, "addattr_l ERROR: message exceeded bound of %d\n",maxlen);
 		return -1;
 	}
@@ -499,7 +499,7 @@
 	rta->rta_type = type;
 	rta->rta_len = len;
 	memcpy(RTA_DATA(rta), data, alen);
-	n->nlmsg_len = NLMSG_ALIGN(n->nlmsg_len) + len;
+	n->nlmsg_len = NLMSG_ALIGN(n->nlmsg_len) + RTA_ALIGN(len);
 	return 0;
 }
 
@@ -539,7 +539,7 @@
 	struct rtattr *subrta;
 	int len = RTA_LENGTH(alen);
 
-	if (RTA_ALIGN(rta->rta_len) + len > maxlen) {
+	if (RTA_ALIGN(rta->rta_len) + RTA_ALIGN(len) > maxlen) {
 		fprintf(stderr,"rta_addattr_l: Error! max allowed bound %d exceeded\n",maxlen);
 		return -1;
 	}
@@ -547,7 +547,7 @@
 	subrta->rta_type = type;
 	subrta->rta_len = len;
 	memcpy(RTA_DATA(subrta), data, alen);
-	rta->rta_len = NLMSG_ALIGN(rta->rta_len) + len;
+	rta->rta_len = NLMSG_ALIGN(rta->rta_len) + RTA_ALIGN(len);
 	return 0;
 }
 
