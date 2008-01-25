From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 1/7 net-2.6.25] [IPV4]: Fix memory leak on error path during FIB initialization.
Date: Fri, 25 Jan 2008 16:51:57 +0300
Message-ID: <1201269123-20378-1-git-send-email-den@openvz.org>
Cc: netdev@vger.kernel.org, devel@openvz.org,
	containers@lists.osdl.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:59029 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755399AbYAYNv5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2008 08:51:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net->ipv4.fib_table_hash is not freed when fib4_rules_init failed. The problem
has been introduced by the following commit.
commit c8050bf6d84785a7edd2e81591e8f833231477e8
Author: Denis V. Lunev <den@openvz.org>
Date:   Thu Jan 10 03:28:24 2008 -0800

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/fib_frontend.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index d282618..d0507f4 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -975,6 +975,7 @@ static struct notifier_block fib_netdev_notifier = {
 
 static int __net_init ip_fib_net_init(struct net *net)
 {
+	int err;
 	unsigned int i;
 
 	net->ipv4.fib_table_hash = kzalloc(
@@ -985,7 +986,14 @@ static int __net_init ip_fib_net_init(struct net *net)
 	for (i = 0; i < FIB_TABLE_HASHSZ; i++)
 		INIT_HLIST_HEAD(&net->ipv4.fib_table_hash[i]);
 
-	return fib4_rules_init(net);
+	err = fib4_rules_init(net);
+	if (err < 0)
+		goto fail;
+	return 0;
+
+fail:
+	kfree(net->ipv4.fib_table_hash);
+	return err;
 }
 
 static void __net_exit ip_fib_net_exit(struct net *net)
-- 
1.5.3.rc5

