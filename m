From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 3/7] kobject: factorize skb setup in kobject_uevent_net_broadcast()
Date: Mon, 18 Sep 2017 12:07:29 -0700
Message-ID: <20170918190733.26272-4-edumazet@google.com>
References: <20170918190733.26272-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:56448 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751024AbdIRTHo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 15:07:44 -0400
Received: by mail-pg0-f42.google.com with SMTP id 7so643672pgd.13
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 12:07:44 -0700 (PDT)
In-Reply-To: <20170918190733.26272-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can build one skb and let it be cloned in netlink.

This is much faster, and use less memory (all clones will
share the same skb->head)

Tested:

time perf record (for f in `seq 1 3000` ; do ip netns add tast$f; done)
[ perf record: Woken up 1 times to write data ]
[ perf record: Captured and wrote 4.110 MB perf.data (~179584 samples) ]

real    0m24.227s # instead of 0m52.554s
user    0m0.329s
sys 0m23.753s # instead of 0m51.375s

    14.77%       ip  [kernel.kallsyms]  [k] __ip6addrlbl_add
    14.56%       ip  [kernel.kallsyms]  [k] netlink_broadcast_filtered
    11.65%       ip  [kernel.kallsyms]  [k] netlink_has_listeners
     6.19%       ip  [kernel.kallsyms]  [k] _raw_spin_lock_irqsave
     5.66%       ip  [kernel.kallsyms]  [k] kobject_uevent_env
     4.97%       ip  [kernel.kallsyms]  [k] memset_erms
     4.67%       ip  [kernel.kallsyms]  [k] refcount_sub_and_test
     4.41%       ip  [kernel.kallsyms]  [k] _raw_read_lock
     3.59%       ip  [kernel.kallsyms]  [k] refcount_inc_not_zero
     3.13%       ip  [kernel.kallsyms]  [k] _raw_spin_unlock_irqrestore
     1.55%       ip  [kernel.kallsyms]  [k] __wake_up
     1.20%       ip  [kernel.kallsyms]  [k] strlen
     1.03%       ip  [kernel.kallsyms]  [k] __wake_up_common
     0.93%       ip  [kernel.kallsyms]  [k] consume_skb
     0.92%       ip  [kernel.kallsyms]  [k] netlink_trim
     0.87%       ip  [kernel.kallsyms]  [k] insert_header
     0.63%       ip  [kernel.kallsyms]  [k] unmap_page_range

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 lib/kobject_uevent.c | 34 +++++++++++++++++++---------------
 1 file changed, 19 insertions(+), 15 deletions(-)

diff --git a/lib/kobject_uevent.c b/lib/kobject_uevent.c
index cb5102d638452ea6c03d12e61ea8c55c9dd72675..05166f3a2528f2aa915405675c6662579e67de52 100644
--- a/lib/kobject_uevent.c
+++ b/lib/kobject_uevent.c
@@ -301,23 +301,26 @@ static int kobject_uevent_net_broadcast(struct kobject *kobj,
 {
 	int retval = 0;
 #if defined(CONFIG_NET)
+	struct sk_buff *skb = NULL;
 	struct uevent_sock *ue_sk;
 
 	/* send netlink message */
 	list_for_each_entry(ue_sk, &uevent_sock_list, list) {
 		struct sock *uevent_sock = ue_sk->sk;
-		struct sk_buff *skb;
-		size_t len;
 
 		if (!netlink_has_listeners(uevent_sock, 1))
 			continue;
 
-		/* allocate message with the maximum possible size */
-		len = strlen(action_string) + strlen(devpath) + 2;
-		skb = alloc_skb(len + env->buflen, GFP_KERNEL);
-		if (skb) {
+		if (!skb) {
+			/* allocate message with the maximum possible size */
+			size_t len = strlen(action_string) + strlen(devpath) + 2;
 			char *scratch;
 
+			retval = -ENOMEM;
+			skb = alloc_skb(len + env->buflen, GFP_KERNEL);
+			if (!skb)
+				continue;
+
 			/* add header */
 			scratch = skb_put(skb, len);
 			sprintf(scratch, "%s@%s", action_string, devpath);
@@ -326,16 +329,17 @@ static int kobject_uevent_net_broadcast(struct kobject *kobj,
 			memcpy(scratch, env->buf, env->buflen);
 
 			NETLINK_CB(skb).dst_group = 1;
-			retval = netlink_broadcast_filtered(uevent_sock, skb,
-							    0, 1, GFP_KERNEL,
-							    kobj_bcast_filter,
-							    kobj);
-			/* ENOBUFS should be handled in userspace */
-			if (retval == -ENOBUFS || retval == -ESRCH)
-				retval = 0;
-		} else
-			retval = -ENOMEM;
+		}
+
+		retval = netlink_broadcast_filtered(uevent_sock, skb_get(skb),
+						    0, 1, GFP_KERNEL,
+						    kobj_bcast_filter,
+						    kobj);
+		/* ENOBUFS should be handled in userspace */
+		if (retval == -ENOBUFS || retval == -ESRCH)
+			retval = 0;
 	}
+	consume_skb(skb);
 #endif
 	return retval;
 }
-- 
2.14.1.690.gbb1197296e-goog
