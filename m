From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 5/6] ipv6 - make af_inet6 to check ip6_route_init return value
Date: Thu, 06 Dec 2007 14:53:34 +0100
Message-ID: <20071206140307.686276824@ICON-9-164-138-215.megacenter.de.ibm.com>
References: <20071206135329.598202596@ICON-9-164-138-215.megacenter.de.ibm.com>
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@vger.kernel.org,
	Benjamin Thery <benjamin.thery@bull.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:50618 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751439AbXLFOFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 09:05:35 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id lB6E5YCa064230
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 14:05:34 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB6E5Y1v2752686
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 15:05:34 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB6E5XxR010422
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 15:05:33 +0100
Content-Disposition: inline; filename=af_inet6-handle-subsystem-errors-at-init.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The af_inet6 initialization function does not check the return code
of the route initilization, so if something goes wrong, the protocol
initialization will continue anyway.
This patch takes into account the modification made in the different
route's initialization subroutines to check the return value and to 
make the protocol initialization to fail.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Acked-by: Benjamin Thery <benjamin.thery@bull.net>
---
 net/ipv6/af_inet6.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

Index: net-2.6.25/net/ipv6/af_inet6.c
===================================================================
--- net-2.6.25.orig/net/ipv6/af_inet6.c
+++ net-2.6.25/net/ipv6/af_inet6.c
@@ -849,7 +849,9 @@ static int __init inet6_init(void)
 	if (if6_proc_init())
 		goto proc_if6_fail;
 #endif
-	ip6_route_init();
+	err = ip6_route_init();
+	if (err)
+		goto ip6_route_fail;
 	ip6_flowlabel_init();
 	err = addrconf_init();
 	if (err)
@@ -874,6 +876,7 @@ out:
 addrconf_fail:
 	ip6_flowlabel_cleanup();
 	ip6_route_cleanup();
+ip6_route_fail:
 #ifdef CONFIG_PROC_FS
 	if6_proc_exit();
 proc_if6_fail:
@@ -904,6 +907,7 @@ icmp_fail:
 	cleanup_ipv6_mibs();
 out_unregister_sock:
 	sock_unregister(PF_INET6);
+	rtnl_unregister_all(PF_INET6);
 out_unregister_raw_proto:
 	proto_unregister(&rawv6_prot);
 out_unregister_udplite_proto:

-- 
