From: "Sokolowski, Hubert" <hubert.sokolowski@intel.com>
Subject: [PATCH net-next] net: Pass ndm_state to route netlink FDB
 notifications.
Date: Tue, 15 Dec 2015 13:20:30 +0000
Message-ID: <C039B2B452EFF24BA495644ED973419132ACE538@IRSMSX108.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:58277 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932176AbbLONYC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 08:24:02 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before this change applications monitoring FDB notifications
were not able to determine whether a new FDB entry is permament
or not:
bridge fdb add f1:f2:f3:f4:f5:f8 dev sw0p1 temp self
bridge fdb add f1:f2:f3:f4:f5:f9 dev sw0p1 self

bridge monitor fdb

f1:f2:f3:f4:f5:f8 dev sw0p1 self permanent
f1:f2:f3:f4:f5:f9 dev sw0p1 self permanent

With this change ndm_state from the original netlink message
is passed to the new netlink message sent as notification.

bridge fdb add f1:f2:f3:f4:f5:f6 dev sw0p1 self
bridge fdb add f1:f2:f3:f4:f5:f7 dev sw0p1 temp self

bridge monitor fdb
f1:f2:f3:f4:f5:f6 dev sw0p1 self permanent
f1:f2:f3:f4:f5:f7 dev sw0p1 self static

Signed-off-by: Hubert Sokolowski <hubert.sokolowski@intel.com>
---
 net/core/rtnetlink.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 34ba7a0..3974a9a 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2563,7 +2563,7 @@ static int nlmsg_populate_fdb_fill(struct sk_buff *skb,
 				   struct net_device *dev,
 				   u8 *addr, u16 vid, u32 pid, u32 seq,
 				   int type, unsigned int flags,
-				   int nlflags)
+				   int nlflags, u16 ndm_state)
 {
 	struct nlmsghdr *nlh;
 	struct ndmsg *ndm;
@@ -2579,7 +2579,7 @@ static int nlmsg_populate_fdb_fill(struct sk_buff *skb,
 	ndm->ndm_flags	 = flags;
 	ndm->ndm_type	 = 0;
 	ndm->ndm_ifindex = dev->ifindex;
-	ndm->ndm_state   = NUD_PERMANENT;
+	ndm->ndm_state   = ndm_state;
 
 	if (nla_put(skb, NDA_LLADDR, ETH_ALEN, addr))
 		goto nla_put_failure;
@@ -2600,7 +2600,8 @@ static inline size_t rtnl_fdb_nlmsg_size(void)
 	return NLMSG_ALIGN(sizeof(struct ndmsg)) + nla_total_size(ETH_ALEN);
 }
 
-static void rtnl_fdb_notify(struct net_device *dev, u8 *addr, u16 vid, int type)
+static void rtnl_fdb_notify(struct net_device *dev, u8 *addr, u16 vid, int type,
+			    u16 ndm_state)
 {
 	struct net *net = dev_net(dev);
 	struct sk_buff *skb;
@@ -2611,7 +2612,7 @@ static void rtnl_fdb_notify(struct net_device *dev, u8 *addr, u16 vid, int type)
 		goto errout;
 
 	err = nlmsg_populate_fdb_fill(skb, dev, addr, vid,
-				      0, 0, type, NTF_SELF, 0);
+				      0, 0, type, NTF_SELF, 0, ndm_state);
 	if (err < 0) {
 		kfree_skb(skb);
 		goto errout;
@@ -2746,7 +2747,8 @@ static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh)
 					       nlh->nlmsg_flags);
 
 		if (!err) {
-			rtnl_fdb_notify(dev, addr, vid, RTM_NEWNEIGH);
+			rtnl_fdb_notify(dev, addr, vid, RTM_NEWNEIGH,
+					ndm->ndm_state);
 			ndm->ndm_flags &= ~NTF_SELF;
 		}
 	}
@@ -2847,7 +2849,8 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh)
 			err = ndo_dflt_fdb_del(ndm, tb, dev, addr, vid);
 
 		if (!err) {
-			rtnl_fdb_notify(dev, addr, vid, RTM_DELNEIGH);
+			rtnl_fdb_notify(dev, addr, vid, RTM_DELNEIGH,
+					ndm->ndm_state);
 			ndm->ndm_flags &= ~NTF_SELF;
 		}
 	}
@@ -2875,7 +2878,7 @@ static int nlmsg_populate_fdb(struct sk_buff *skb,
 		err = nlmsg_populate_fdb_fill(skb, dev, ha->addr, 0,
 					      portid, seq,
 					      RTM_NEWNEIGH, NTF_SELF,
-					      NLM_F_MULTI);
+					      NLM_F_MULTI, NUD_PERMANENT);
 		if (err < 0)
 			return err;
 skip:
-- 
2.1.0

-- 
Hubert Sokolowski                  Intel Corporation
