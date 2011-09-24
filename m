From: Huajun Li <huajun.li.lee@gmail.com>
Subject: [PATCH 2/2] net: Fix potential memory leak
Date: Sat, 24 Sep 2011 23:57:14 +0800
Message-ID: <CA+v9cxYuFArVUh9gc-be-Lmy4TOTxp72VaCC4QeCEE3p1j2Ykg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	Huajun Li <huajun.li.lee@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:37651 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751705Ab1IXP5P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Sep 2011 11:57:15 -0400
Received: by mail-fx0-f46.google.com with SMTP id 4so4732097fxe.19
        for <netdev@vger.kernel.org>; Sat, 24 Sep 2011 08:57:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While preparing flow caches, once fail may cause potential memory leak , fix it.

Signed-off-by: Huajun Li <huajun.li.lee@gmail.com>
---
 net/core/flow.c |   19 ++++++++++++++++++-
 1 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/net/core/flow.c b/net/core/flow.c
index ba3e617..2dcaa03 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -420,7 +420,7 @@ static int __init flow_cache_init(struct flow_cache *fc)

 	for_each_online_cpu(i) {
 		if (flow_cache_cpu_prepare(fc, i))
-			return -ENOMEM;
+			goto err;
 	}
 	fc->hotcpu_notifier = (struct notifier_block){
 		.notifier_call = flow_cache_cpu,
@@ -433,6 +433,23 @@ static int __init flow_cache_init(struct flow_cache *fc)
 	add_timer(&fc->rnd_timer);

 	return 0;
+err:
+	if (fc->percpu) {
+		free_percpu(fc->percpu);
+		fc->percpu = NULL;
+	}
+
+	/*
+	 * Check each possible CPUs rather than online ones because they may be
+	 * offline before the notifier is registered.
+	 */
+	for_each_possible_cpu(i) {
+		struct flow_cache_percpu *fcp = per_cpu_ptr(fc->percpu, i);
+		kfree(fcp->hash_table);
+		fcp->hash_table = NULL;
+	}
+
+	return -ENOMEM;
 }

 static int __init flow_cache_init_global(void)
-- 
1.7.4.1
