From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/7] kobject: copy env blob in one go
Date: Mon, 18 Sep 2017 12:07:28 -0700
Message-ID: <20170918190733.26272-3-edumazet@google.com>
References: <20170918190733.26272-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:44002 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750990AbdIRTHn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 15:07:43 -0400
Received: by mail-pf0-f180.google.com with SMTP id y29so716688pff.0
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 12:07:43 -0700 (PDT)
In-Reply-To: <20170918190733.26272-1-edumazet@google.com>
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
 lib/kobject_uevent.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/lib/kobject_uevent.c b/lib/kobject_uevent.c
index 4f48cc3b11d566e44c4115cc7716bc3b1cdf96df..cb5102d638452ea6c03d12e61ea8c55c9dd72675 100644
--- a/lib/kobject_uevent.c
+++ b/lib/kobject_uevent.c
@@ -317,18 +317,13 @@ static int kobject_uevent_net_broadcast(struct kobject *kobj,
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
+			scratch = skb_put(skb, env->buflen);
+			memcpy(scratch, env->buf, env->buflen);
 
 			NETLINK_CB(skb).dst_group = 1;
 			retval = netlink_broadcast_filtered(uevent_sock, skb,
-- 
2.14.1.690.gbb1197296e-goog
