From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 2/7] kobject: copy env blob in one go
Date: Tue, 19 Sep 2017 16:27:04 -0700
Message-ID: <20170919232709.14690-3-edumazet@google.com>
References: <20170919232709.14690-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:47873 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751619AbdISX1S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 19:27:18 -0400
Received: by mail-pg0-f41.google.com with SMTP id d8so675490pgt.4
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 16:27:17 -0700 (PDT)
In-Reply-To: <20170919232709.14690-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to iterate over strings, just copy in one efficient memcpy() call.

Tested:
time perf record "(for f in `seq 1 3000` ; do ip netns add tast$f; done)"
[ perf record: Woken up 10 times to write data ]
[ perf record: Captured and wrote 8.224 MB perf.data (~359301 samples) ]

real    0m52.554s  # instead of 1m7.492s
user    0m0.309s
sys 0m51.375s # instead of 1m6.875s

     9.88%       ip  [kernel.kallsyms]  [k] netlink_broadcast_filtered
     8.86%       ip  [kernel.kallsyms]  [k] string
     7.37%       ip  [kernel.kallsyms]  [k] __ip6addrlbl_add
     5.68%       ip  [kernel.kallsyms]  [k] netlink_has_listeners
     5.52%       ip  [kernel.kallsyms]  [k] memcpy_erms
     4.76%       ip  [kernel.kallsyms]  [k] __alloc_skb
     4.54%       ip  [kernel.kallsyms]  [k] vsnprintf
     3.94%       ip  [kernel.kallsyms]  [k] format_decode
     3.80%       ip  [kernel.kallsyms]  [k] kmem_cache_alloc_node_trace
     3.71%       ip  [kernel.kallsyms]  [k] kmem_cache_alloc_node
     3.66%       ip  [kernel.kallsyms]  [k] kobject_uevent_env
     3.38%       ip  [kernel.kallsyms]  [k] strlen
     2.65%       ip  [kernel.kallsyms]  [k] _raw_spin_lock_irqsave
     2.20%       ip  [kernel.kallsyms]  [k] kfree
     2.09%       ip  [kernel.kallsyms]  [k] memset_erms
     2.07%       ip  [kernel.kallsyms]  [k] ___cache_free
     1.95%       ip  [kernel.kallsyms]  [k] kmem_cache_free
     1.91%       ip  [kernel.kallsyms]  [k] _raw_read_lock
     1.45%       ip  [kernel.kallsyms]  [k] ksize
     1.25%       ip  [kernel.kallsyms]  [k] _raw_spin_unlock_irqrestore
     1.00%       ip  [kernel.kallsyms]  [k] widen_string

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 lib/kobject_uevent.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/lib/kobject_uevent.c b/lib/kobject_uevent.c
index 4f48cc3b11d566e44c4115cc7716bc3b1cdf96df..78b2a7e378c0deda3b32b1178d7f44203702c3f2 100644
--- a/lib/kobject_uevent.c
+++ b/lib/kobject_uevent.c
@@ -317,18 +317,12 @@ static int kobject_uevent_net_broadcast(struct kobject *kobj,
 		skb = alloc_skb(len + env->buflen, GFP_KERNEL);
 		if (skb) {
 			char *scratch;
-			int i;
 
 			/* add header */
 			scratch = skb_put(skb, len);
 			sprintf(scratch, "%s@%s", action_string, devpath);
 
-			/* copy keys to our continuous event payload buffer */
-			for (i = 0; i < env->envp_idx; i++) {
-				len = strlen(env->envp[i]) + 1;
-				scratch = skb_put(skb, len);
-				strcpy(scratch, env->envp[i]);
-			}
+			skb_put_data(skb, env->buf, env->buflen);
 
 			NETLINK_CB(skb).dst_group = 1;
 			retval = netlink_broadcast_filtered(uevent_sock, skb,
-- 
2.14.1.690.gbb1197296e-goog
