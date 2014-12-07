From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v3 2/2] rocker: remove swdev mode
Date: Sat,  6 Dec 2014 22:54:27 -0800
Message-ID: <1417935267-6000-3-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:45755 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752447AbaLGGyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Dec 2014 01:54:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 drivers/net/ethernet/rocker/rocker.c |   18 +-----------------
 include/linux/rtnetlink.h            |    2 +-
 net/core/rtnetlink.c                 |   12 +++++++++---
 3 files changed, 11 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index fded127..9f1d256 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3700,27 +3700,11 @@ static int rocker_port_bridge_setlink(struct net_device *dev,
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	struct nlattr *protinfo;
-	struct nlattr *afspec;
 	struct nlattr *attr;
-	u16 mode;
 	int err;
 
 	protinfo = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg),
 				   IFLA_PROTINFO);
-	afspec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_AF_SPEC);
-
-	if (afspec) {
-		attr = nla_find_nested(afspec, IFLA_BRIDGE_MODE);
-		if (attr) {
-			if (nla_len(attr) < sizeof(mode))
-				return -EINVAL;
-
-			mode = nla_get_u16(attr);
-			if (mode != BRIDGE_MODE_SWDEV)
-				return -EINVAL;
-		}
-	}
-
 	if (protinfo) {
 		attr = nla_find_nested(protinfo, IFLA_BRPORT_LEARNING);
 		if (attr) {
@@ -3755,7 +3739,7 @@ static int rocker_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 				      u32 filter_mask)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
-	u16 mode = BRIDGE_MODE_SWDEV;
+	u16 mode = -1;
 	u32 mask = BR_LEARNING | BR_LEARNING_SYNC;
 
 	return ndo_dflt_bridge_getlink(skb, pid, seq, dev, mode,
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 3b04190..dcfa06b 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -103,6 +103,6 @@ extern int ndo_dflt_fdb_del(struct ndmsg *ndm,
 			    u16 vid);
 
 extern int ndo_dflt_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
-				   struct net_device *dev, u16 mode,
+				   struct net_device *dev, s16 mode,
 				   u32 flags, u32 mask);
 #endif	/* __LINUX_RTNETLINK_H */
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 61cb7e7..b4e04b9 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2696,7 +2696,7 @@ static int brport_nla_put_flag(struct sk_buff *skb, u32 flags, u32 mask,
 }
 
 int ndo_dflt_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
-			    struct net_device *dev, u16 mode,
+			    struct net_device *dev, s16 mode,
 			    u32 flags, u32 mask)
 {
 	struct nlmsghdr *nlh;
@@ -2734,11 +2734,17 @@ int ndo_dflt_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 	if (!br_afspec)
 		goto nla_put_failure;
 
-	if (nla_put_u16(skb, IFLA_BRIDGE_FLAGS, BRIDGE_FLAGS_SELF) ||
-	    nla_put_u16(skb, IFLA_BRIDGE_MODE, mode)) {
+	if (nla_put_u16(skb, IFLA_BRIDGE_FLAGS, BRIDGE_FLAGS_SELF)) {
 		nla_nest_cancel(skb, br_afspec);
 		goto nla_put_failure;
 	}
+
+	if (mode >= 0) {
+		if (nla_put_u16(skb, IFLA_BRIDGE_MODE, mode)) {
+			nla_nest_cancel(skb, br_afspec);
+			goto nla_put_failure;
+		}
+	}
 	nla_nest_end(skb, br_afspec);
 
 	protinfo = nla_nest_start(skb, IFLA_PROTINFO | NLA_F_NESTED);
-- 
1.7.10.4
