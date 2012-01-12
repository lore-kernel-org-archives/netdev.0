From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH] net: decrement memcg jump label when limit, not usage, is changed
Date: Thu, 12 Jan 2012 16:16:06 +0400
Message-ID: <1326370566-4286-1-git-send-email-glommer@parallels.com>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The logic of the current code is that whenever we destroy
a cgroup that had its limit set (set meaning different than
maximum), we should decrement the jump_label counter.
Otherwise we assume it was never incremented.

But what the code actually does is test for RES_USAGE
instead of RES_LIMIT. Usage being different than maximum
is likely to be true most of the time.

The effect of this is that the key must become negative,
and since the jump_label test says:

        !!atomic_read(&key->enabled);

we'll have jump_labels still on when no one else is
using this functionality.

Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
CC: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 net/ipv4/tcp_memcontrol.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index 7fed04f..4997878 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -108,7 +108,7 @@ void tcp_destroy_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss)
 	tcp = tcp_from_cgproto(cg_proto);
 	percpu_counter_destroy(&tcp->tcp_sockets_allocated);
 
-	val = res_counter_read_u64(&tcp->tcp_memory_allocated, RES_USAGE);
+	val = res_counter_read_u64(&tcp->tcp_memory_allocated, RES_LIMIT);
 
 	if (val != RESOURCE_MAX)
 		jump_label_dec(&memcg_socket_limit_enabled);
-- 
1.7.7.4
