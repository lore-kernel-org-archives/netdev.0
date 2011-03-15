From: kaber@trash.net
Subject: [PATCH 32/37] netfilter: xt_connlimit: remove connlimit_rnd_inited
Date: Tue, 15 Mar 2011 20:44:12 +0100
Message-ID: <1300218257-26953-33-git-send-email-kaber@trash.net>
References: <1300218257-26953-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1300218257-26953-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Changli Gao <xiaosuo@gmail.com>

A potential race condition when generating connlimit_rnd is also fixed.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/xt_connlimit.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index da56d6e..c6d5a83 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -44,7 +44,6 @@ struct xt_connlimit_data {
 };
 
 static u_int32_t connlimit_rnd __read_mostly;
-static bool connlimit_rnd_inited __read_mostly;
 
 static inline unsigned int connlimit_iphash(__be32 addr)
 {
@@ -226,9 +225,13 @@ static int connlimit_mt_check(const struct xt_mtchk_param *par)
 	unsigned int i;
 	int ret;
 
-	if (unlikely(!connlimit_rnd_inited)) {
-		get_random_bytes(&connlimit_rnd, sizeof(connlimit_rnd));
-		connlimit_rnd_inited = true;
+	if (unlikely(!connlimit_rnd)) {
+		u_int32_t rand;
+
+		do {
+			get_random_bytes(&rand, sizeof(rand));
+		} while (!rand);
+		cmpxchg(&connlimit_rnd, 0, rand);
 	}
 	ret = nf_ct_l3proto_try_module_get(par->family);
 	if (ret < 0) {
-- 
1.7.2.3

