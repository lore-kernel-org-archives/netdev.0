From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] mlx5: avoid unused variable warning
Date: Wed, 18 May 2016 16:21:07 +0200
Message-ID: <1463581293-1069553-1-git-send-email-arnd@arndb.de>
Cc: Jiri Pirko <jiri@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Amir Vadai <amirva@mellanox.com>,
	Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When CONFIG_NET_CLS_ACT is disabled, we get a new warning in the mlx5
ethernet driver because the tc_for_each_action() loop never references
the iterator:

mellanox/mlx5/core/en_tc.c: In function 'mlx5e_stats_flower':
mellanox/mlx5/core/en_tc.c:431:20: error: unused variable 'a' [-Werror=unused-variable]
  struct tc_action *a;

This changes the dummy tc_for_each_action() macro by adding a
cast to void, letting the compiler know that the variable is
intentionally declared but not used here. I could not come up
with a nicer workaround, but this seems to do the trick.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: aad7e08d39bd ("net/mlx5e: Hardware offloaded flower filter statistics support")
Fixes: 00175aec941e ("net/sched: Macro instead of CONFIG_NET_CLS_ACT ifdef")
---
 include/net/act_api.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 2cd9e9bb059a..9a9a8edc138f 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -192,7 +192,7 @@ static inline void tcf_action_stats_update(struct tc_action *a, u64 bytes,
 #else /* CONFIG_NET_CLS_ACT */
 
 #define tc_no_actions(_exts) true
-#define tc_for_each_action(_a, _exts) while (0)
+#define tc_for_each_action(_a, _exts) while ((void)(_a), 0)
 #define tcf_action_stats_update(a, bytes, packets, lastuse)
 
 #endif /* CONFIG_NET_CLS_ACT */
-- 
2.7.0
