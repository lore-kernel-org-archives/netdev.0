From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v5 2/3] rocker: remove swdev mode
Date: Mon,  8 Dec 2014 14:04:20 -0800
Message-ID: <1418076261-24593-3-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:45240 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754589AbaLHWE2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 17:04:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Remove use of 'swdev' mode in rocker. rocker dev offloads
can use the BRIDGE_FLAGS_SELF to indicate offload to hardware.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 drivers/net/ethernet/rocker/rocker.c |   18 +-----------------
 net/core/rtnetlink.c                 |   10 ++++++++--
 2 files changed, 9 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index fded127..a841f7a 100644
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
+	u16 mode = BRIDGE_MODE_UNDEF;
 	u32 mask = BR_LEARNING | BR_LEARNING_SYNC;
 
 	return ndo_dflt_bridge_getlink(skb, pid, seq, dev, mode,
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 61cb7e7..3863e3b 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
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
+	if (mode != BRIDGE_MODE_UNDEF) {
+		if (nla_put_u16(skb, IFLA_BRIDGE_MODE, mode)) {
+			nla_nest_cancel(skb, br_afspec);
+			goto nla_put_failure;
+		}
+	}
 	nla_nest_end(skb, br_afspec);
 
 	protinfo = nla_nest_start(skb, IFLA_PROTINFO | NLA_F_NESTED);
-- 
1.7.10.4
