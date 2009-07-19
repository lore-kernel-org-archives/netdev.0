From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 2/4] inet6: Consolidate common code for IPv6 Hop Limit / Traffic Class
Date: Sun, 19 Jul 2009 20:23:37 +0200
Message-ID: <1248027819-23959-3-git-send-email-gerrit@erg.abdn.ac.uk>
References: <inet6_minor_cleanups>
 <1248027819-23959-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1248027819-23959-2-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: netdev@vger.kernel.org, Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:54919 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750879AbZGSSgY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jul 2009 14:36:24 -0400
In-Reply-To: <1248027819-23959-2-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The RFC 3542 definitions for Hop Limit (6.3) and Traffic Class (6.5) cmsg
values differ only in the names of the cmsg type. So does the code.
The patch combines these commonalities.

Further changes:
----------------
Replaced other use of temporary 'int' variable with 'val' variable.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/ipv6/datagram.c |   34 ++++++++++++----------------------
 1 files changed, 12 insertions(+), 22 deletions(-)

--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -504,10 +504,10 @@ int datagram_send_ctl(struct net *net,
 	struct cmsghdr *cmsg;
 	struct ipv6_rt_hdr *rthdr;
 	struct ipv6_opt_hdr *hdr;
+	int val;
 	int len;
 
 	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
-		int addr_type;
 
 		if (!CMSG_OK(msg, cmsg))
 			return -EINVAL;
@@ -532,17 +532,17 @@ int datagram_send_ctl(struct net *net,
 				fl->oif = src_info->ipi6_ifindex;
 			}
 
-			addr_type = __ipv6_addr_type(&src_info->ipi6_addr);
+			val = __ipv6_addr_type(&src_info->ipi6_addr);
 
 			if (fl->oif) {
 				dev = dev_get_by_index(net, fl->oif);
 				if (!dev)
 					return -ENODEV;
-			} else if (addr_type & IPV6_ADDR_LINKLOCAL)
+			} else if (val & IPV6_ADDR_LINKLOCAL)
 				return -EINVAL;
 
-			if (addr_type != IPV6_ADDR_ANY) {
-				int strict = __ipv6_addr_src_scope(addr_type) <= IPV6_ADDR_SCOPE_LINKLOCAL;
+			if (val != IPV6_ADDR_ANY) {
+				int strict = __ipv6_addr_src_scope(val) <= IPV6_ADDR_SCOPE_LINKLOCAL;
 				if (!ipv6_chk_addr(net, &src_info->ipi6_addr, strict ? dev : NULL, 0))
 					return -EINVAL;
 				ipv6_addr_copy(&fl->fl6_src, &src_info->ipi6_addr);
@@ -666,30 +666,20 @@ int datagram_send_ctl(struct net *net,
 
 		case IPV6_2292HOPLIMIT:
 		case IPV6_HOPLIMIT:
-			if (cmsg->cmsg_len != CMSG_LEN(sizeof(int)))
-				return -EINVAL;
-
-			*hlimit = *(int *)CMSG_DATA(cmsg);
-			if (*hlimit < -1 || *hlimit > 0xff)
-				return -EINVAL;
-
-			break;
-
 		case IPV6_TCLASS:
-		    {
-			int tc;
-
 			if (cmsg->cmsg_len != CMSG_LEN(sizeof(int)))
 				return -EINVAL;
 
-			tc = *(int *)CMSG_DATA(cmsg);
-			if (tc < -1 || tc > 0xff)
+			val = *(int *)CMSG_DATA(cmsg);
+			if (val < -1 || val > 0xff)
 				return -EINVAL;
 
-			*tclass = tc;
-
+			if (cmsg->cmsg_type == IPV6_TCLASS)
+				*tclass = val;
+			else
+				*hlimit = val;
 			break;
-		    }
+
 		default:
 			LIMIT_NETDEBUG(KERN_DEBUG "invalid cmsg type: %d\n",
 				       cmsg->cmsg_type);
