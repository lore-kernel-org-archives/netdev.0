From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 4/5] net_sched: fix use of uninitialized ethertype variable in cls_flower
Date: Fri, 26 Aug 2016 17:25:45 +0200
Message-ID: <20160826152546.604384-5-arnd@arndb.de>
References: <20160826152546.604384-1-arnd@arndb.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Arnd Bergmann <arnd@arndb.de>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.134]:49923 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751584AbcHZP2k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 11:28:40 -0400
In-Reply-To: <20160826152546.604384-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The addition of VLAN support caused a possible use of uninitialized
data if we encounter a zero TCA_FLOWER_KEY_ETH_TYPE key, as pointed
out by "gcc -Wmaybe-uninitialized":

net/sched/cls_flower.c: In function 'fl_change':
net/sched/cls_flower.c:366:22: error: 'ethertype' may be used uninitialized in this function [-Werror=maybe-uninitialized]

This changes the code to only set the ethertype field if it
was nonzero, as before the patch.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 9399ae9a6cb2 ("net_sched: flower: Add vlan support")
Cc: Hadar Hen Zion <hadarh@mellanox.com>
Cc: Jiri Pirko <jiri@mellanox.com>
---
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
 net/sched/cls_flower.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 532ab6751343..cf9ad5b50889 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -353,18 +353,19 @@ static int fl_set_key(struct net *net, struct nlattr **tb,
 		       mask->eth.src, TCA_FLOWER_KEY_ETH_SRC_MASK,
 		       sizeof(key->eth.src));
 
-	if (tb[TCA_FLOWER_KEY_ETH_TYPE])
+	if (tb[TCA_FLOWER_KEY_ETH_TYPE]) {
 		ethertype = nla_get_be16(tb[TCA_FLOWER_KEY_ETH_TYPE]);
 
-	if (ethertype == htons(ETH_P_8021Q)) {
-		fl_set_key_vlan(tb, &key->vlan, &mask->vlan);
-		fl_set_key_val(tb, &key->basic.n_proto,
-			       TCA_FLOWER_KEY_VLAN_ETH_TYPE,
-			       &mask->basic.n_proto, TCA_FLOWER_UNSPEC,
-			       sizeof(key->basic.n_proto));
-	} else {
-		key->basic.n_proto = ethertype;
-		mask->basic.n_proto = cpu_to_be16(~0);
+		if (ethertype == htons(ETH_P_8021Q)) {
+			fl_set_key_vlan(tb, &key->vlan, &mask->vlan);
+			fl_set_key_val(tb, &key->basic.n_proto,
+				       TCA_FLOWER_KEY_VLAN_ETH_TYPE,
+				       &mask->basic.n_proto, TCA_FLOWER_UNSPEC,
+				       sizeof(key->basic.n_proto));
+		} else {
+			key->basic.n_proto = ethertype;
+			mask->basic.n_proto = cpu_to_be16(~0);
+		}
 	}
 
 	if (key->basic.n_proto == htons(ETH_P_IP) ||
-- 
2.9.0
