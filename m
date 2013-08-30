From: Andy Zhou <azhou@nicira.com>
Subject: [PATCH] openvswitch: fix sw_flow_key alignment
Date: Fri, 30 Aug 2013 10:32:20 -0700
Message-ID: <1377883940-8995-1-git-send-email-azhou@nicira.com>
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:47696 "HELO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756919Ab3H3RcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 13:32:21 -0400
Received: by mail-pd0-f170.google.com with SMTP id x10so2150913pdj.1
        for <netdev@vger.kernel.org>; Fri, 30 Aug 2013 10:32:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sw_flow_key alignment was declared as " __aligned(__alignof__(long))"
However, this breaks on m68k architecture where long is 32 bit in size
but 16 bit aligned by default. Use __aligned(sizeof(long) instead.

Reported by: Fengguang Wu <fengguan.wu@intel.com>

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 net/openvswitch/flow.c |    4 +---
 net/openvswitch/flow.h |    2 +-
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index ad1aeeb..fe7524c4 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -1009,9 +1009,6 @@ static u32 ovs_flow_hash(const struct sw_flow_key *key, int key_start,
 	u32 *hash_key = (u32 *)((u8 *)key + key_start);
 	int hash_u32s = (key_end - key_start) >> 2;
 
-	/* Make sure number of hash bytes are multiple of u32. */
-	BUILD_BUG_ON(sizeof(long) % sizeof(u32));
-
 	return jhash2(hash_key, hash_u32s, 0);
 }
 
@@ -1982,6 +1979,7 @@ nla_put_failure:
 int ovs_flow_init(void)
 {
 	BUILD_BUG_ON(sizeof(struct sw_flow_key) % sizeof(long));
+	BUILD_BUG_ON(sizeof(struct sw_flow_key) % __alignof__(long));
 
 	flow_cache = kmem_cache_create("sw_flow", sizeof(struct sw_flow), 0,
 					0, NULL);
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index b65f885..202c4c4 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -125,7 +125,7 @@ struct sw_flow_key {
 			} nd;
 		} ipv6;
 	};
-} __aligned(__alignof__(long));
+} __aligned(sizeof(long));
 
 struct sw_flow {
 	struct rcu_head rcu;
-- 
1.7.9.5
