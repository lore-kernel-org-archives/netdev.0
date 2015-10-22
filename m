From: Thomas Haller <thaller@redhat.com>
Subject: [PATCH iproute2] ip-address: properly display zero IPv4 peer address
Date: Thu, 22 Oct 2015 10:34:28 +0200
Message-ID: <1445502868-29474-1-git-send-email-thaller@redhat.com>
Cc: Thomas Haller <thaller@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39057 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751523AbbJVIed (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Oct 2015 04:34:33 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (Postfix) with ESMTPS id 4DABCC075D95
	for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 08:34:33 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel allows for zero IPv4 peer addresses (IFA_ADDRESS):

   ip address add 192.168.5.1 peer 0.0.0.0/24 dev dummy

which is distinct from a usual address like:

   ip address add 192.168.5.1/24 dev dummy
   ip address add 192.168.5.1 peer 192.168.5.1/24 dev dummy

For IPv4, a missing IFA_ADDRESS attribute means that the peer
is 0.0.0.0. See inet_fill_ifaddr(), which does:

  if ((ifa->ifa_address &&
       nla_put_in_addr(skb, IFA_ADDRESS, ifa->ifa_address)) ||

Signed-off-by: Thomas Haller <thaller@redhat.com>
---
 ip/ipaddress.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index f290205..6fc4520 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -949,7 +949,8 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 
 	if (!rta_tb[IFA_LOCAL])
 		rta_tb[IFA_LOCAL] = rta_tb[IFA_ADDRESS];
-	if (!rta_tb[IFA_ADDRESS])
+	if (!rta_tb[IFA_ADDRESS] &&
+	    ifa->ifa_family != AF_INET)
 		rta_tb[IFA_ADDRESS] = rta_tb[IFA_LOCAL];
 
 	if (filter.ifindex && filter.ifindex != ifa->ifa_index)
@@ -1034,16 +1035,18 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 						RTA_DATA(rta_tb[IFA_LOCAL]),
 						abuf, sizeof(abuf)));
 
-		if (rta_tb[IFA_ADDRESS] == NULL ||
+		if (rta_tb[IFA_ADDRESS] != NULL &&
 		    memcmp(RTA_DATA(rta_tb[IFA_ADDRESS]), RTA_DATA(rta_tb[IFA_LOCAL]),
 			   ifa->ifa_family == AF_INET ? 4 : 16) == 0) {
 			fprintf(fp, "/%d ", ifa->ifa_prefixlen);
 		} else {
 			fprintf(fp, " peer %s/%d ",
-				format_host(ifa->ifa_family,
-					    RTA_PAYLOAD(rta_tb[IFA_ADDRESS]),
-					    RTA_DATA(rta_tb[IFA_ADDRESS]),
-					    abuf, sizeof(abuf)),
+				rta_tb[IFA_ADDRESS]
+					? format_host(ifa->ifa_family,
+						      RTA_PAYLOAD(rta_tb[IFA_ADDRESS]),
+						      RTA_DATA(rta_tb[IFA_ADDRESS]),
+						      abuf, sizeof(abuf))
+					: "0.0.0.0",
 				ifa->ifa_prefixlen);
 		}
 	}
-- 
2.4.3
