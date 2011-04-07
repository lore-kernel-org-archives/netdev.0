From: Michael Smith <msmith@cbnco.com>
Subject: [PATCH v2 2/2] Disable rp_filter for IPsec packets
Date: Thu,  7 Apr 2011 10:51:51 -0400
Message-ID: <1302187911-20688-3-git-send-email-msmith@cbnco.com>
References: <1302187911-20688-1-git-send-email-msmith@cbnco.com>
 <1302187911-20688-2-git-send-email-msmith@cbnco.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.cbnco.com ([207.164.182.72]:47792 "EHLO smtp.cbnco.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754993Ab1DGOp2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2011 10:45:28 -0400
Received: from localhost (localhost [127.0.0.1])
	by smtp.cbnco.com (Postfix) with ESMTP id 6F0D9B75554
	for <netdev@vger.kernel.org>; Thu,  7 Apr 2011 10:45:25 -0400 (EDT)
Received: from smtp.cbnco.com ([127.0.0.1])
 by localhost (mail.cbnco.com [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 15219-08 for <netdev@vger.kernel.org>;
 Thu,  7 Apr 2011 10:45:25 -0400 (EDT)
Received: from sles10-64.jrz.cbn (dmzgw2.cbnco.com [207.164.182.65])
	by smtp.cbnco.com (Postfix) with ESMTPS id 20C3EB75473
	for <netdev@vger.kernel.org>; Thu,  7 Apr 2011 10:45:24 -0400 (EDT)
In-Reply-To: <1302187911-20688-2-git-send-email-msmith@cbnco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The reverse path filter interferes with IPsec subnet-to-subnet tunnels,
especially when the link to the IPsec peer is on an interface other than
the one hosting the default route.

With dynamic routing, where the peer might be reachable through eth0
today and eth1 tomorrow, it's difficult to keep rp_filter enabled unless
fake routes to the remote subnets are configured on the interface
currently used to reach the peer.

IPsec provides a much stronger anti-spoofing policy than rp_filter, so
this patch disables the rp_filter for packets with a security path.

Signed-off-by: Michael Smith <msmith@cbnco.com>
---
 include/net/xfrm.h      |    9 +++++++++
 net/ipv4/fib_frontend.c |    6 +++++-
 2 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 6ae4bc5..65ea313 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -957,6 +957,15 @@ struct sec_path {
 	struct xfrm_state	*xvec[XFRM_MAX_DEPTH];
 };
 
+static inline int secpath_exists(struct sk_buff *skb)
+{
+#ifdef CONFIG_XFRM
+	return skb->sp != NULL;
+#else
+	return 0;
+#endif
+}
+
 static inline struct sec_path *
 secpath_get(struct sec_path *sp)
 {
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index f162f84..2252471 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -44,6 +44,7 @@
 #include <net/arp.h>
 #include <net/ip_fib.h>
 #include <net/rtnetlink.h>
+#include <net/xfrm.h>
 
 #ifndef CONFIG_IP_MULTIPLE_TABLES
 
@@ -211,7 +212,10 @@ int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst, u8 tos,
 	in_dev = __in_dev_get_rcu(dev);
 	if (in_dev) {
 		no_addr = in_dev->ifa_list == NULL;
-		rpf = IN_DEV_RPFILTER(in_dev);
+
+		/* Ignore rp_filter for packets protected by IPsec. */
+		rpf = secpath_exists(skb) ? 0 : IN_DEV_RPFILTER(in_dev);
+
 		accept_local = IN_DEV_ACCEPT_LOCAL(in_dev);
 		fl4.flowi4_mark = IN_DEV_SRC_VMARK(in_dev) ? skb->mark : 0;
 	}
-- 
1.6.3.2

