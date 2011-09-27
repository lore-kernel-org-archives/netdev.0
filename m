From: Huajun Li <huajun.li.lee@gmail.com>
Subject: [PATCH v2] net/flow: Fix potential memory leak
Date: Tue, 27 Sep 2011 18:34:33 +0800
Message-ID: <CA+v9cxZMwTPXw-_pWc-SRsTs5GqmqK2-46Mr06HxhVN4aH93Yg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Huajun Li <huajun.li.lee@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:42378 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752878Ab1I0Kef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 06:34:35 -0400
Received: by fxe4 with SMTP id 4so6957878fxe.19
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2011 03:34:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While preparing net flow caches, once fail may cause potential memory
leak , fix it.

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Huajun Li <huajun.li.lee@gmail.com>
---
 net/core/flow.c |   16 +++++++++++++++-
 1 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/net/core/flow.c b/net/core/flow.c
index 555a456..4e60fce 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -413,7 +413,7 @@ static int __init flow_cache_init(struct flow_cache *fc)

 	for_each_online_cpu(i) {
 		if (flow_cache_cpu_prepare(fc, i))
-			return -ENOMEM;
+			goto err;
 	}
 	fc->hotcpu_notifier = (struct notifier_block){
 		.notifier_call = flow_cache_cpu,
@@ -426,6 +426,20 @@ static int __init flow_cache_init(struct flow_cache *fc)
 	add_timer(&fc->rnd_timer);

 	return 0;
+
+err:
+	for_each_possible_cpu(i) {
+		struct flow_cache_percpu *fcp = per_cpu_ptr(fc->percpu, i);
+		kfree(fcp->hash_table);
+		fcp->hash_table = NULL;
+	}
+
+	if (fc->percpu) {
+		free_percpu(fc->percpu);
+		fc->percpu = NULL;
+	}
+
+	return -ENOMEM;
 }

 static int __init flow_cache_init_global(void)
-- 
1.7.4.1
