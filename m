From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH] openvswitch: Fix alignment of struct sw_flow_key.
Date: Thu,  5 Sep 2013 10:41:27 -0700
Message-ID: <1378402887-17331-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Andy Zhou <azhou@nicira.com>,
	Fengguang Wu <fengguan.wu@intel.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog118.obsmtp.com ([74.125.149.244]:45175 "HELO
	na3sys009aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752562Ab3IERld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 13:41:33 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so2111660pdj.22
        for <netdev@vger.kernel.org>; Thu, 05 Sep 2013 10:41:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sw_flow_key alignment was declared as " __aligned(__alignof__(long))".
However, this breaks on the m68k architecture where long is 32 bit in
size but 16 bit aligned by default. This aligns to 8 bytes to ensure
that long is always covered without reducing native alignment. It also
adds an additional build check to catch any reduction in alignment.

CC: Andy Zhou <azhou@nicira.com>
Reported-by: Fengguang Wu <fengguan.wu@intel.com>
Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/flow.c | 1 +
 net/openvswitch/flow.h | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index ad1aeeb..fb36f85 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -1981,6 +1981,7 @@ nla_put_failure:
  * Returns zero if successful or a negative error code. */
 int ovs_flow_init(void)
 {
+	BUILD_BUG_ON(__alignof__(struct sw_flow_key) % __alignof__(long));
 	BUILD_BUG_ON(sizeof(struct sw_flow_key) % sizeof(long));
 
 	flow_cache = kmem_cache_create("sw_flow", sizeof(struct sw_flow), 0,
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index b65f885..3dc3b52 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -125,7 +125,7 @@ struct sw_flow_key {
 			} nd;
 		} ipv6;
 	};
-} __aligned(__alignof__(long));
+} __aligned(8); /* 8 byte alignment ensures this can be accessed as a long */
 
 struct sw_flow {
 	struct rcu_head rcu;
-- 
1.8.1.2
