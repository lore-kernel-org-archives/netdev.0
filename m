From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 12/12 net-2.6.26] [ICMP6]: Consolidate fail path icmpv6_sk_init with icmpv6_sk_exit.
Date: Fri, 29 Feb 2008 16:40:58 +0300
Message-ID: <1204292458-11636-12-git-send-email-den@openvz.org>
References: <1204292360.10368.11.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:61929 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759712AbYB2Nkl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 08:40:41 -0500
In-Reply-To: <1204292360.10368.11.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
Acked-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/ipv6/icmp.c |   29 ++++++++++++++---------------
 1 files changed, 14 insertions(+), 15 deletions(-)

diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 9f55a96..889769d 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -777,6 +777,17 @@ drop_no_count:
 	return 0;
 }
 
+
+static void __net_exit icmpv6_sk_exit(struct net *net)
+{
+	int i;
+
+	for_each_possible_cpu(i) {
+		sk_release_kernel(net->ipv6.icmp_sk[i]);
+	}
+	kfree(net->ipv6.icmp_sk);
+}
+
 /*
  * Special lock-class for __icmpv6_sk:
  */
@@ -785,7 +796,7 @@ static struct lock_class_key icmpv6_socket_sk_dst_lock_key;
 static int __net_init icmpv6_sk_init(struct net *net)
 {
 	struct sock *sk;
-	int err, i, j;
+	int err, i;
 
 	net->ipv6.icmp_sk =
 		kzalloc(nr_cpu_ids * sizeof(struct sock *), GFP_KERNEL);
@@ -827,23 +838,11 @@ static int __net_init icmpv6_sk_init(struct net *net)
 	}
 	return 0;
 
- fail:
-	for (j = 0; j < i; j++)
-		sk_release_kernel(net->ipv6.icmp_sk[j]);
-	kfree(net->ipv6.icmp_sk);
+fail:
+	icmpv6_sk_exit(net);
 	return err;
 }
 
-static void __net_exit icmpv6_sk_exit(struct net *net)
-{
-	int i;
-
-	for_each_possible_cpu(i) {
-		sk_release_kernel(net->ipv6.icmp_sk[i]);
-	}
-	kfree(net->ipv6.icmp_sk);
-}
-
 static struct pernet_operations __net_initdata icmpv6_sk_ops = {
        .init = icmpv6_sk_init,
        .exit = icmpv6_sk_exit,
-- 
1.5.3.rc5

