From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net v2 5/9] macsec: add consistency check to netlink dumps
Date: Fri, 22 Apr 2016 11:28:05 +0200
Message-ID: <dfd8e38b62e2b079a2934ede4a2494492406c8cd.1461315621.git.sd@queasysnail.net>
References: <cover.1461315621.git.sd@queasysnail.net>
Cc: Lance Richardson <lrichard@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33001 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754132AbcDVJ2j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 05:28:39 -0400
In-Reply-To: <cover.1461315621.git.sd@queasysnail.net>
In-Reply-To: <cover.1461315621.git.sd@queasysnail.net>
References: <cover.1461315621.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use genl_dump_check_consistent in dump_secy.

Fixes: c09440f7dcb3 ("macsec: introduce IEEE 802.1AE driver")
Suggested-by: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/macsec.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 1fd2b147fda1..41fbe556ba6d 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -2271,6 +2271,8 @@ static int dump_secy(struct macsec_secy *secy, struct net_device *dev,
 	if (!hdr)
 		return -EMSGSIZE;
 
+	genl_dump_check_consistent(cb, hdr, &macsec_fam);
+
 	if (nla_put_u32(skb, MACSEC_ATTR_IFINDEX, dev->ifindex))
 		goto nla_put_failure;
 
@@ -2439,6 +2441,8 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
+static int macsec_generation = 1; /* protected by RTNL */
+
 static int macsec_dump_txsc(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct net *net = sock_net(skb->sk);
@@ -2449,6 +2453,9 @@ static int macsec_dump_txsc(struct sk_buff *skb, struct netlink_callback *cb)
 
 	d = 0;
 	rtnl_lock();
+
+	cb->seq = macsec_generation;
+
 	for_each_netdev(net, dev) {
 		struct macsec_secy *secy;
 
@@ -2920,6 +2927,8 @@ static void macsec_dellink(struct net_device *dev, struct list_head *head)
 	struct net_device *real_dev = macsec->real_dev;
 	struct macsec_rxh_data *rxd = macsec_data_rtnl(real_dev);
 
+	macsec_generation++;
+
 	unregister_netdevice_queue(dev, head);
 	list_del_rcu(&macsec->secys);
 	if (list_empty(&rxd->secys))
@@ -3066,6 +3075,8 @@ static int macsec_newlink(struct net *net, struct net_device *dev,
 	if (err < 0)
 		goto del_dev;
 
+	macsec_generation++;
+
 	dev_hold(real_dev);
 
 	return 0;
-- 
2.8.0
