From: "Shmulik Ravid" <shmulikr@broadcom.com>
Subject: [net-next-2.6 PATCH] dcbnl: more informed return values for new
 dcbnl routines
Date: Mon, 3 Jan 2011 20:04:59 +0200
Message-ID: <1294077899.29378.110.camel@lb-tlvb-shmulik.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4041 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755421Ab1ACSHk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jan 2011 13:07:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

More accurate return values for the following (new) dcbnl routines:
dcbnl_getdcbx()
dcbnl_setdcbx()
dcbnl_getfeatcfg()
dcbnl_setfeatcfg()

Signed-off-by: Shmulik Ravid <shmulikr@broadcom.com>
---
 net/dcb/dcbnl.c |   81 +++++++++++++++++++++++++------------------------------
 1 files changed, 37 insertions(+), 44 deletions(-)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index ff3c12d..9399af5 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1286,10 +1286,10 @@ nlmsg_failure:
 static int dcbnl_getdcbx(struct net_device *netdev, struct nlattr **tb,
 			 u32 pid, u32 seq, u16 flags)
 {
-	int ret = -EINVAL;
+	int ret;
 
 	if (!netdev->dcbnl_ops->getdcbx)
-		return ret;
+		return -EOPNOTSUPP;
 
 	ret = dcbnl_reply(netdev->dcbnl_ops->getdcbx(netdev), RTM_GETDCB,
 			  DCB_CMD_GDCBX, DCB_ATTR_DCBX, pid, seq, flags);
@@ -1300,11 +1300,14 @@ static int dcbnl_getdcbx(struct net_device *netdev, struct nlattr **tb,
 static int dcbnl_setdcbx(struct net_device *netdev, struct nlattr **tb,
 			 u32 pid, u32 seq, u16 flags)
 {
-	int ret = -EINVAL;
+	int ret;
 	u8 value;
 
-	if (!tb[DCB_ATTR_DCBX] || !netdev->dcbnl_ops->setdcbx)
-		return ret;
+	if (!netdev->dcbnl_ops->setdcbx)
+		return -EOPNOTSUPP;
+
+	if (!tb[DCB_ATTR_DCBX])
+		return -EINVAL;
 
 	value = nla_get_u8(tb[DCB_ATTR_DCBX]);
 
@@ -1323,23 +1326,23 @@ static int dcbnl_getfeatcfg(struct net_device *netdev, struct nlattr **tb,
 	struct dcbmsg *dcb;
 	struct nlattr *data[DCB_FEATCFG_ATTR_MAX + 1], *nest;
 	u8 value;
-	int ret = -EINVAL;
-	int i;
+	int ret, i;
 	int getall = 0;
 
-	if (!tb[DCB_ATTR_FEATCFG] || !netdev->dcbnl_ops->getfeatcfg)
-		return ret;
+	if (!netdev->dcbnl_ops->getfeatcfg)
+		return -EOPNOTSUPP;
+
+	if (!tb[DCB_ATTR_FEATCFG])
+		return -EINVAL;
 
 	ret = nla_parse_nested(data, DCB_FEATCFG_ATTR_MAX, tb[DCB_ATTR_FEATCFG],
 			       dcbnl_featcfg_nest);
-	if (ret) {
-		ret = -EINVAL;
+	if (ret)
 		goto err_out;
-	}
 
 	dcbnl_skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (!dcbnl_skb) {
-		ret = -EINVAL;
+		ret = -ENOBUFS;
 		goto err_out;
 	}
 
@@ -1351,8 +1354,8 @@ static int dcbnl_getfeatcfg(struct net_device *netdev, struct nlattr **tb,
 
 	nest = nla_nest_start(dcbnl_skb, DCB_ATTR_FEATCFG);
 	if (!nest) {
-		ret = -EINVAL;
-		goto err;
+		ret = -EMSGSIZE;
+		goto nla_put_failure;
 	}
 
 	if (data[DCB_FEATCFG_ATTR_ALL])
@@ -1363,30 +1366,22 @@ static int dcbnl_getfeatcfg(struct net_device *netdev, struct nlattr **tb,
 			continue;
 
 		ret = netdev->dcbnl_ops->getfeatcfg(netdev, i, &value);
-		if (!ret) {
+		if (!ret)
 			ret = nla_put_u8(dcbnl_skb, i, value);
 
-			if (ret) {
-				nla_nest_cancel(dcbnl_skb, nest);
-				ret = -EINVAL;
-				goto err;
-			}
-		} else
-			goto err;
+		if (ret) {
+			nla_nest_cancel(dcbnl_skb, nest);
+			goto nla_put_failure;
+		}
 	}
 	nla_nest_end(dcbnl_skb, nest);
 
 	nlmsg_end(dcbnl_skb, nlh);
 
-	ret = rtnl_unicast(dcbnl_skb, &init_net, pid);
-	if (ret) {
-		ret = -EINVAL;
-		goto err_out;
-	}
-
-	return 0;
+	return rtnl_unicast(dcbnl_skb, &init_net, pid);
+nla_put_failure:
+	nlmsg_cancel(dcbnl_skb, nlh);
 nlmsg_failure:
-err:
 	kfree_skb(dcbnl_skb);
 err_out:
 	return ret;
@@ -1396,20 +1391,20 @@ static int dcbnl_setfeatcfg(struct net_device *netdev, struct nlattr **tb,
 			    u32 pid, u32 seq, u16 flags)
 {
 	struct nlattr *data[DCB_FEATCFG_ATTR_MAX + 1];
-	int ret = -EINVAL;
+	int ret, i;
 	u8 value;
-	int i;
 
-	if (!tb[DCB_ATTR_FEATCFG] || !netdev->dcbnl_ops->setfeatcfg)
-		return ret;
+	if (!netdev->dcbnl_ops->setfeatcfg)
+		return -ENOTSUPP;
+
+	if (!tb[DCB_ATTR_FEATCFG])
+		return -EINVAL;
 
 	ret = nla_parse_nested(data, DCB_FEATCFG_ATTR_MAX, tb[DCB_ATTR_FEATCFG],
 			       dcbnl_featcfg_nest);
 
-	if (ret) {
-		ret = -EINVAL;
+	if (ret)
 		goto err;
-	}
 
 	for (i = DCB_FEATCFG_ATTR_ALL+1; i <= DCB_FEATCFG_ATTR_MAX; i++) {
 		if (data[i] == NULL)
@@ -1420,14 +1415,12 @@ static int dcbnl_setfeatcfg(struct net_device *netdev, struct nlattr **tb,
 		ret = netdev->dcbnl_ops->setfeatcfg(netdev, i, value);
 
 		if (ret)
-			goto operr;
+			goto err;
 	}
-
-operr:
-	ret = dcbnl_reply(!!ret, RTM_SETDCB, DCB_CMD_SFEATCFG,
-			  DCB_ATTR_FEATCFG, pid, seq, flags);
-
 err:
+	dcbnl_reply(ret, RTM_SETDCB, DCB_CMD_SFEATCFG, DCB_ATTR_FEATCFG,
+		    pid, seq, flags);
+
 	return ret;
 }
 
-- 
1.7.1




