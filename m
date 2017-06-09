From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH net] net/flow: fix fc->percpu NULL pointer dereference
Date: Fri,  9 Jun 2017 16:13:56 +0800
Message-ID: <1496996036-22077-1-git-send-email-liuhangbin@gmail.com>
Cc: David Miller <davem@davemloft.net>,
        Xin Long <lucien.xin@gmail.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33849 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751516AbdFIIOh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 04:14:37 -0400
Received: by mail-pg0-f68.google.com with SMTP id v14so7051889pgn.1
        for <netdev@vger.kernel.org>; Fri, 09 Jun 2017 01:14:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now we will force to do garbage collection if any policy removed in
xfrm_policy_flush(). But during xfrm_net_exit(). We call flow_cache_fini()
first and set set fc->percpu to NULL. Then after we call xfrm_policy_fini()
-> frxm_policy_flush() -> flow_cache_flush(), we will get NULL pointer
dereference when check percpu_empty. The code path looks like:

flow_cache_fini()
  - fc->percpu = NULL
xfrm_policy_fini()
  - xfrm_policy_flush()
    - xfrm_garbage_collect()
      - flow_cache_flush()
        - flow_cache_percpu_empty()
	  - fcp = per_cpu_ptr(fc->percpu, cpu)

To reproduce, just add ipsec in netns and then remove the netns.

Fixes: 35db06912189 ("xfrm: do the garbage collection after flushing policy")
Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 net/core/flow.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/core/flow.c b/net/core/flow.c
index f7f5d19..321fc53 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -332,10 +332,13 @@ static int flow_cache_percpu_empty(struct flow_cache *fc, int cpu)
 	struct flow_cache_percpu *fcp;
 	unsigned int i;
 
-	fcp = per_cpu_ptr(fc->percpu, cpu);
-	for (i = 0; i < flow_cache_hash_size(fc); i++)
-		if (!hlist_empty(&fcp->hash_table[i]))
-			return 0;
+	if (fc->percpu) {
+		fcp = per_cpu_ptr(fc->percpu, cpu);
+		for (i = 0; i < flow_cache_hash_size(fc); i++)
+			if (!hlist_empty(&fcp->hash_table[i]))
+				return 0;
+	}
+
 	return 1;
 }
 
-- 
2.5.5
