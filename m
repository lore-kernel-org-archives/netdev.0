From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 1/6] [IPV4]: Fix memory leak on error path during FIB initialization.
Date: Thu, 31 Jan 2008 15:00:45 +0300
Message-ID: <1201780850-22216-1-git-send-email-den@openvz.org>
References: <47A1B835.7050600@sw.ru>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devel@openvz.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:59328 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1763915AbYAaMAr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 07:00:47 -0500
In-Reply-To: <47A1B835.7050600@sw.ru>
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

