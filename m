From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 4/4] netfilter: xt_connlimit: remove connlimit_rnd_inited
Date: Mon, 14 Mar 2011 14:50:14 +0800
Message-ID: <1300085414-27275-4-git-send-email-xiaosuo@gmail.com>
References: <1300085414-27275-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:34935 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753755Ab1CNGvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 02:51:53 -0400
In-Reply-To: <1300085414-27275-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A potential race condition when generating connlimit_rnd is also fixed.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/netfilter/xt_connlimit.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)
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
