From: Mike Manning <mmanning@brocade.com>
Subject: [PATCH] net: ipv6: Do not keep IPv6 addresses when IPv6 is disabled
Date: Fri, 12 Aug 2016 12:02:38 +0100
Message-ID: <1470999758-11535-1-git-send-email-mmanning@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:62927 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751636AbcHLLDV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 07:03:21 -0400
Received: from pps.filterd (m0000700.ppops.net [127.0.0.1])
	by m0000700.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u7CB2WZE011737
	for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 04:03:20 -0700
Received: from brmwp-exmb11.corp.brocade.com ([208.47.132.227])
	by mx0b-000f0801.pphosted.com with ESMTP id 24qmect3sj-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 04:03:20 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If IPv6 is disabled when the option is set to keep IPv6
addresses on link down, userspace is unaware of this as
there is no such indication via netlink. The solution is to
remove the IPv6 addresses in this case, which results in
netlink messages indicating removal of addresses in the
usual manner. This fix also makes the behavior consistent
with the case of having IPv6 disabled first, which stops
IPv6 addresses from being added.

Fixes: f1705ec197e7 ("net: ipv6: Make address flushing on ifdown optional")
Signed-off-by: Mike Manning <mmanning@brocade.com>
---
 net/ipv6/addrconf.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index ab3e796..df8425f 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3543,7 +3543,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 	/* combine the user config with event to determine if permanent
 	 * addresses are to be removed from address hash table
 	 */
-	keep_addr = !(how || _keep_addr <= 0);
+	keep_addr = !(how || _keep_addr <= 0 || idev->cnf.disable_ipv6);
 
 	/* Step 2: clear hash table */
 	for (i = 0; i < IN6_ADDR_HSIZE; i++) {
@@ -3599,7 +3599,7 @@ restart:
 	/* re-combine the user config with event to determine if permanent
 	 * addresses are to be removed from the interface list
 	 */
-	keep_addr = (!how && _keep_addr > 0);
+	keep_addr = (!how && _keep_addr > 0 && !idev->cnf.disable_ipv6);
 
 	INIT_LIST_HEAD(&del_list);
 	list_for_each_entry_safe(ifa, tmp, &idev->addr_list, if_list) {
-- 
1.7.10.4
