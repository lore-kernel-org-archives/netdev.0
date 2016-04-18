From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH] cls_cgroup: get sk_classid only from full sockets
Date: Mon, 18 Apr 2016 14:37:10 +0300
Message-ID: <146097943086.15300.8997345346172526153.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

skb->sk could point to timewait or request socket which has no sk_classid.
Detected as "BUG: KASAN: slab-out-of-bounds in cls_cgroup_classify".

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 include/net/cls_cgroup.h |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index c0a92e2c286d..74c9693d4941 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -17,6 +17,7 @@
 #include <linux/hardirq.h>
 #include <linux/rcupdate.h>
 #include <net/sock.h>
+#include <net/inet_sock.h>
 
 #ifdef CONFIG_CGROUP_NET_CLASSID
 struct cgroup_cls_state {
@@ -63,11 +64,13 @@ static inline u32 task_get_classid(const struct sk_buff *skb)
 	 * softirqs always disables bh.
 	 */
 	if (in_serving_softirq()) {
+		struct sock *sk = skb_to_full_sk(skb);
+
 		/* If there is an sock_cgroup_classid we'll use that. */
-		if (!skb->sk)
+		if (!sk || !sk_fullsock(sk))
 			return 0;
 
-		classid = sock_cgroup_classid(&skb->sk->sk_cgrp_data);
+		classid = sock_cgroup_classid(&sk->sk_cgrp_data);
 	}
 
 	return classid;
