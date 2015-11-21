From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next v2 1/9] net: ipmr: move the tbl id check in ipmr_new_table
Date: Sat, 21 Nov 2015 15:57:24 +0100
Message-ID: <1448117852-4254-2-git-send-email-razor@blackwall.org>
References: <1448117852-4254-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:33552 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760573AbbKUO70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2015 09:59:26 -0500
Received: by wmec201 with SMTP id c201so107650636wme.0
        for <netdev@vger.kernel.org>; Sat, 21 Nov 2015 06:59:25 -0800 (PST)
In-Reply-To: <1448117852-4254-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Move the table id check in ipmr_new_table and make it return error
pointer. We need this change for the upcoming netlink table manipulation
support in order to avoid code duplication and a race condition.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/ipv4/ipmr.c | 28 +++++++++++++++++-----------
 1 file changed, 17 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 92dd4b74d513..5271e2eee110 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -252,8 +252,8 @@ static int __net_init ipmr_rules_init(struct net *net)
 	INIT_LIST_HEAD(&net->ipv4.mr_tables);
 
 	mrt = ipmr_new_table(net, RT_TABLE_DEFAULT);
-	if (!mrt) {
-		err = -ENOMEM;
+	if (IS_ERR(mrt)) {
+		err = PTR_ERR(mrt);
 		goto err1;
 	}
 
@@ -301,8 +301,13 @@ static int ipmr_fib_lookup(struct net *net, struct flowi4 *flp4,
 
 static int __net_init ipmr_rules_init(struct net *net)
 {
-	net->ipv4.mrt = ipmr_new_table(net, RT_TABLE_DEFAULT);
-	return net->ipv4.mrt ? 0 : -ENOMEM;
+	struct mr_table *mrt;
+
+	mrt = ipmr_new_table(net, RT_TABLE_DEFAULT);
+	if (IS_ERR(mrt))
+		return PTR_ERR(mrt);
+	net->ipv4.mrt = mrt;
+	return 0;
 }
 
 static void __net_exit ipmr_rules_exit(struct net *net)
@@ -319,13 +324,17 @@ static struct mr_table *ipmr_new_table(struct net *net, u32 id)
 	struct mr_table *mrt;
 	unsigned int i;
 
+	/* "pimreg%u" should not exceed 16 bytes (IFNAMSIZ) */
+	if (id != RT_TABLE_DEFAULT && id >= 1000000000)
+		return ERR_PTR(-EINVAL);
+
 	mrt = ipmr_get_table(net, id);
 	if (mrt)
 		return mrt;
 
 	mrt = kzalloc(sizeof(*mrt), GFP_KERNEL);
 	if (!mrt)
-		return NULL;
+		return ERR_PTR(-ENOMEM);
 	write_pnet(&mrt->net, net);
 	mrt->id = id;
 
@@ -1407,17 +1416,14 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 		if (get_user(v, (u32 __user *)optval))
 			return -EFAULT;
 
-		/* "pimreg%u" should not exceed 16 bytes (IFNAMSIZ) */
-		if (v != RT_TABLE_DEFAULT && v >= 1000000000)
-			return -EINVAL;
-
 		rtnl_lock();
 		ret = 0;
 		if (sk == rtnl_dereference(mrt->mroute_sk)) {
 			ret = -EBUSY;
 		} else {
-			if (!ipmr_new_table(net, v))
-				ret = -ENOMEM;
+			mrt = ipmr_new_table(net, v);
+			if (IS_ERR(mrt))
+				ret = PTR_ERR(mrt);
 			else
 				raw_sk(sk)->ipmr_table = v;
 		}
-- 
2.4.3
