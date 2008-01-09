From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch net-2.6.25 08/10][NETNS][IPV6] make mld_max_msf readonly in other namespaces
Date: Wed, 09 Jan 2008 17:45:41 +0100
Message-ID: <20080109165034.129870447@localhost.localdomain>
References: <20080109164533.695191040@localhost.localdomain>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:60959 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753120AbYAIRAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 12:00:03 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id m09H02Yg448812
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 17:00:02 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m09H01Sq1126432
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 18:00:01 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m09H016j022094
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 18:00:01 +0100
Content-Disposition: inline; filename=make-mld_max_msf-readonly.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mld_max_msf protects the system with a maximum allowed multicast 
source filters. Making this variable per namespace can be potentially
an problem if someone inside a namespace set it to a big value, that
will impact the whole system including other namespaces.

I don't see any benefits to have it per namespace for now, so in order 
to keep a directory entry in a newly created namespace, I make it
read-only when we are not in the initial network namespace.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/ipv6/sysctl_net_ipv6.c |    6 ++++++
 1 file changed, 6 insertions(+)

Index: net-2.6.25/net/ipv6/sysctl_net_ipv6.c
===================================================================
--- net-2.6.25.orig/net/ipv6/sysctl_net_ipv6.c
+++ net-2.6.25/net/ipv6/sysctl_net_ipv6.c
@@ -122,6 +122,12 @@ static int ipv6_sysctl_net_init(struct n
       	ipv6_table[5].data = &net->ipv6.sysctl.frags.timeout;
     	ipv6_table[6].data = &net->ipv6.sysctl.frags.secret_interval;
 
+ 	/* We don't want this value to be per namespace, it should be global
+	   to all namespaces, so make it read-only when we are not in the
+	   init network namespace */
+    	if (net != &init_net)
+    		ipv6_table[7].mode = 0444;
+
 	net->ipv6.sysctl.table = register_net_sysctl_table(net, net_ipv6_ctl_path,
 							   ipv6_table);
 	if (!net->ipv6.sysctl.table)

-- 
