From: David Miller <davem@davemloft.net>
Subject: [PATCH 13/25] ipv4: Use flowi4 in FIB layer.
Date: Sat, 12 Mar 2011 15:28:08 -0800 (PST)
Message-ID: <20110312.152808.70194109.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37594
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756024Ab1CLX1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2011 18:27:30 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 43B3B24C088
	for <netdev@vger.kernel.org>; Sat, 12 Mar 2011 15:28:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/fib_frontend.c  |   40 ++++++++++++++++++++--------------------
 net/ipv4/fib_rules.c     |    7 ++++---
 net/ipv4/fib_semantics.c |   14 +++++++-------
 3 files changed, 31 insertions(+), 30 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 48125d5..a373a25 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -140,7 +140,7 @@ static inline unsigned __inet_dev_addr_type(struct net *net,
 					    const struct net_device *dev,
 					    __be32 addr)
 {
-	struct flowi		fl = { .fl4_dst = addr };
+	struct flowi4		fl4 = { .daddr = addr };
 	struct fib_result	res;
 	unsigned ret = RTN_BROADCAST;
 	struct fib_table *local_table;
@@ -158,7 +158,7 @@ static inline unsigned __inet_dev_addr_type(struct net *net,
 	if (local_table) {
 		ret = RTN_UNICAST;
 		rcu_read_lock();
-		if (!fib_table_lookup(local_table, &fl.u.ip4, &res, FIB_LOOKUP_NOREF)) {
+		if (!fib_table_lookup(local_table, &fl4, &res, FIB_LOOKUP_NOREF)) {
 			if (!dev || dev == res.fi->fib_dev)
 				ret = res.type;
 		}
@@ -193,20 +193,20 @@ int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 			u32 *itag, u32 mark)
 {
 	struct in_device *in_dev;
-	struct flowi fl;
+	struct flowi4 fl4;
 	struct fib_result res;
 	int no_addr, rpf, accept_local;
 	bool dev_match;
 	int ret;
 	struct net *net;
 
-	fl.flowi_oif = 0;
-	fl.flowi_iif = oif;
-	fl.flowi_mark = mark;
-	fl.fl4_dst = src;
-	fl.fl4_src = dst;
-	fl.fl4_tos = tos;
-	fl.fl4_scope = RT_SCOPE_UNIVERSE;
+	fl4.flowi4_oif = 0;
+	fl4.flowi4_iif = oif;
+	fl4.flowi4_mark = mark;
+	fl4.daddr = src;
+	fl4.saddr = dst;
+	fl4.flowi4_tos = tos;
+	fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
 
 	no_addr = rpf = accept_local = 0;
 	in_dev = __in_dev_get_rcu(dev);
@@ -215,14 +215,14 @@ int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 		rpf = IN_DEV_RPFILTER(in_dev);
 		accept_local = IN_DEV_ACCEPT_LOCAL(in_dev);
 		if (mark && !IN_DEV_SRC_VMARK(in_dev))
-			fl.flowi_mark = 0;
+			fl4.flowi4_mark = 0;
 	}
 
 	if (in_dev == NULL)
 		goto e_inval;
 
 	net = dev_net(dev);
-	if (fib_lookup(net, &fl.u.ip4, &res))
+	if (fib_lookup(net, &fl4, &res))
 		goto last_resort;
 	if (res.type != RTN_UNICAST) {
 		if (res.type != RTN_LOCAL || !accept_local)
@@ -253,10 +253,10 @@ int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 		goto last_resort;
 	if (rpf == 1)
 		goto e_rpf;
-	fl.flowi_oif = dev->ifindex;
+	fl4.flowi4_oif = dev->ifindex;
 
 	ret = 0;
-	if (fib_lookup(net, &fl.u.ip4, &res) == 0) {
+	if (fib_lookup(net, &fl4, &res) == 0) {
 		if (res.type == RTN_UNICAST) {
 			*spec_dst = FIB_RES_PREFSRC(res);
 			ret = FIB_RES_NH(res).nh_scope >= RT_SCOPE_HOST;
@@ -796,11 +796,11 @@ static void nl_fib_lookup(struct fib_result_nl *frn, struct fib_table *tb)
 {
 
 	struct fib_result       res;
-	struct flowi            fl = {
-		.flowi_mark = frn->fl_mark,
-		.fl4_dst = frn->fl_addr,
-		.fl4_tos = frn->fl_tos,
-		.fl4_scope = frn->fl_scope,
+	struct flowi4           fl4 = {
+		.flowi4_mark = frn->fl_mark,
+		.daddr = frn->fl_addr,
+		.flowi4_tos = frn->fl_tos,
+		.flowi4_scope = frn->fl_scope,
 	};
 
 #ifdef CONFIG_IP_MULTIPLE_TABLES
@@ -813,7 +813,7 @@ static void nl_fib_lookup(struct fib_result_nl *frn, struct fib_table *tb)
 
 		frn->tb_id = tb->tb_id;
 		rcu_read_lock();
-		frn->err = fib_table_lookup(tb, &fl.u.ip4, &res, FIB_LOOKUP_NOREF);
+		frn->err = fib_table_lookup(tb, &fl4, &res, FIB_LOOKUP_NOREF);
 
 		if (!frn->err) {
 			frn->prefixlen = res.prefixlen;
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 0c63c4a..a53bb1b 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -106,14 +106,15 @@ errout:
 static int fib4_rule_match(struct fib_rule *rule, struct flowi *fl, int flags)
 {
 	struct fib4_rule *r = (struct fib4_rule *) rule;
-	__be32 daddr = fl->fl4_dst;
-	__be32 saddr = fl->fl4_src;
+	struct flowi4 *fl4 = &fl->u.ip4;
+	__be32 daddr = fl4->daddr;
+	__be32 saddr = fl4->saddr;
 
 	if (((saddr ^ r->src) & r->srcmask) ||
 	    ((daddr ^ r->dst) & r->dstmask))
 		return 0;
 
-	if (r->tos && (r->tos != fl->fl4_tos))
+	if (r->tos && (r->tos != fl4->flowi4_tos))
 		return 0;
 
 	return 1;
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index a721013..622ac4c 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -560,16 +560,16 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 		}
 		rcu_read_lock();
 		{
-			struct flowi fl = {
-				.fl4_dst = nh->nh_gw,
-				.fl4_scope = cfg->fc_scope + 1,
-				.flowi_oif = nh->nh_oif,
+			struct flowi4 fl4 = {
+				.daddr = nh->nh_gw,
+				.flowi4_scope = cfg->fc_scope + 1,
+				.flowi4_oif = nh->nh_oif,
 			};
 
 			/* It is not necessary, but requires a bit of thinking */
-			if (fl.fl4_scope < RT_SCOPE_LINK)
-				fl.fl4_scope = RT_SCOPE_LINK;
-			err = fib_lookup(net, &fl.u.ip4, &res);
+			if (fl4.flowi4_scope < RT_SCOPE_LINK)
+				fl4.flowi4_scope = RT_SCOPE_LINK;
+			err = fib_lookup(net, &fl4, &res);
 			if (err) {
 				rcu_read_unlock();
 				return err;
-- 
1.7.4.1

