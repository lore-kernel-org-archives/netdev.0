From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: [PATCH 1/3]ipv6:add IPV6_PKTINFO sticky option support to setsockopt()
Date: Fri, 29 Aug 2008 15:40:07 +0800
Message-ID: <48B7A7D7.3000905@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:65128 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751223AbYH2Hks (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2008 03:40:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are three reasons for me to add this support:
1.When no interface is specified in an IPV6_PKTINFO ancillary data
  item, the interface specified in an IPV6_PKTINFO sticky optionis 
  is used.

RFC3542:
6.7.  Summary of Outgoing Interface Selection

   This document and [RFC-3493] specify various methods that affect the
   selection of the packet's outgoing interface.  This subsection
   summarizes the ordering among those in order to ensure deterministic
   behavior.

   For a given outgoing packet on a given socket, the outgoing interface
   is determined in the following order:

   1. if an interface is specified in an IPV6_PKTINFO ancillary data
      item, the interface is used.

   2. otherwise, if an interface is specified in an IPV6_PKTINFO sticky
      option, the interface is used.

2.When no IPV6_PKTINFO ancillary data is received,getsockopt() should 
  return the sticky option value which set with setsockopt().

RFC 3542:
   Issuing getsockopt() for the above options will return the sticky
   option value i.e., the value set with setsockopt().  If no sticky
   option value has been set getsockopt() will return the following
   values:

3.Make the setsockopt implementation POSIX compliant.

Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>

---
 include/linux/ipv6.h     |    1 +
 net/ipv6/ipv6_sockglue.c |   22 ++++++++++++++++++++++
 2 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 641e026..28fcdbc 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -279,6 +279,7 @@ struct ipv6_pinfo {
 	struct in6_addr 	rcv_saddr;
 	struct in6_addr		daddr;
 	struct in6_addr		*daddr_cache;
+	struct in6_pktinfo	sticky_pktinfo;
 #ifdef CONFIG_IPV6_SUBTREES
 	struct in6_addr		*saddr_cache;
 #endif
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 4e5eac3..02f64be 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -390,6 +390,28 @@ sticky_done:
 		break;
 	}
 
+	case IPV6_PKTINFO:
+	{
+		struct in6_pktinfo pkt;
+
+		if (optlen == 0)
+			goto e_inval;
+		else if (optlen < sizeof(struct in6_pktinfo) || optval == NULL)
+			goto e_inval;
+
+		if (copy_from_user(&pkt, optval, optlen)) {
+				retv = -EFAULT;
+				break;
+		}
+		if(sk->sk_bound_dev_if && pkt.ipi6_ifindex != sk->sk_bound_dev_if)
+			goto e_inval;
+		
+		np->sticky_pktinfo.ipi6_ifindex = pkt.ipi6_ifindex;
+		ipv6_addr_copy(&np->sticky_pktinfo.ipi6_addr, &pkt.ipi6_addr);
+		retv = 0;
+		break;
+	}
+
 	case IPV6_2292PKTOPTIONS:
 	{
 		struct ipv6_txoptions *opt = NULL;
-- 
1.5.3.8


