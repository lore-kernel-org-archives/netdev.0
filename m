From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/8] dcbnl: Shorten all command handling functions
Date: Wed, 13 Jun 2012 14:54:55 +0200
Message-ID: <3fea99383d5ee98b51bd8b0088bed38cdb59f375.1339591572.git.tgraf@suug.ch>
References: <cover.1339591572.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, lucy.liu@intel.com,
	john.r.fastabend@intel.com, alexander.h.duyck@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7810 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753525Ab2FMMzI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2012 08:55:08 -0400
In-Reply-To: <cover.1339591572.git.tgraf@suug.ch>
In-Reply-To: <cover.1339591572.git.tgraf@suug.ch>
References: <cover.1339591572.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allocating and sending the skb in dcb_doit() allows for much
shorter and cleaner command handling functions.

The huge switch statement is replaced with an array based definition
of the handling function and reply message type.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/dcb/dcbnl.c |  722 +++++++++++++------------------------------------------
 1 files changed, 172 insertions(+), 550 deletions(-)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 5520e43..5e392b8 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -261,27 +261,20 @@ err:
 	return ret;
 }
 
-static int dcbnl_getstate(struct net_device *netdev, struct nlattr **tb,
-                          u32 pid, u32 seq, u16 flags)
+static int dcbnl_getstate(struct net_device *netdev, struct nlmsghdr *nlh,
+			  u32 seq, struct nlattr **tb, struct sk_buff *skb)
 {
-	int ret = -EINVAL;
-
 	/* if (!tb[DCB_ATTR_STATE] || !netdev->dcbnl_ops->getstate) */
 	if (!netdev->dcbnl_ops->getstate)
-		return ret;
-
-	ret = dcbnl_reply(netdev->dcbnl_ops->getstate(netdev), RTM_GETDCB,
-	                  DCB_CMD_GSTATE, DCB_ATTR_STATE, pid, seq, flags);
+		return -EINVAL;
 
-	return ret;
+	return nla_put_u8(skb, DCB_ATTR_STATE,
+			  netdev->dcbnl_ops->getstate(netdev));
 }
 
-static int dcbnl_getpfccfg(struct net_device *netdev, struct nlattr **tb,
-                           u32 pid, u32 seq, u16 flags)
+static int dcbnl_getpfccfg(struct net_device *netdev, struct nlmsghdr *nlh,
+			   u32 seq, struct nlattr **tb, struct sk_buff *skb)
 {
-	struct sk_buff *dcbnl_skb;
-	struct nlmsghdr *nlh;
-	struct dcbmsg *dcb;
 	struct nlattr *data[DCB_PFC_UP_ATTR_MAX + 1], *nest;
 	u8 value;
 	int ret = -EINVAL;
@@ -295,19 +288,9 @@ static int dcbnl_getpfccfg(struct net_device *netdev, struct nlattr **tb,
 	                       tb[DCB_ATTR_PFC_CFG],
 	                       dcbnl_pfc_up_nest);
 	if (ret)
-		goto err_out;
-
-	dcbnl_skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
-	if (!dcbnl_skb)
-		goto err_out;
-
-	nlh = NLMSG_NEW(dcbnl_skb, pid, seq, RTM_GETDCB, sizeof(*dcb), flags);
-
-	dcb = NLMSG_DATA(nlh);
-	dcb->dcb_family = AF_UNSPEC;
-	dcb->cmd = DCB_CMD_PFC_GCFG;
+		goto err;
 
-	nest = nla_nest_start(dcbnl_skb, DCB_ATTR_PFC_CFG);
+	nest = nla_nest_start(skb, DCB_ATTR_PFC_CFG);
 	if (!nest)
 		goto err;
 
@@ -320,76 +303,35 @@ static int dcbnl_getpfccfg(struct net_device *netdev, struct nlattr **tb,
 
 		netdev->dcbnl_ops->getpfccfg(netdev, i - DCB_PFC_UP_ATTR_0,
 		                             &value);
-		ret = nla_put_u8(dcbnl_skb, i, value);
-
+		ret = nla_put_u8(skb, i, value);
 		if (ret) {
-			nla_nest_cancel(dcbnl_skb, nest);
+			nla_nest_cancel(skb, nest);
 			goto err;
 		}
 	}
-	nla_nest_end(dcbnl_skb, nest);
-
-	nlmsg_end(dcbnl_skb, nlh);
-
-	ret = rtnl_unicast(dcbnl_skb, &init_net, pid);
-	if (ret)
-		goto err_out;
+	nla_nest_end(skb, nest);
 
 	return 0;
-nlmsg_failure:
 err:
-	kfree_skb(dcbnl_skb);
-err_out:
 	return -EINVAL;
 }
 
-static int dcbnl_getperm_hwaddr(struct net_device *netdev, struct nlattr **tb,
-                                u32 pid, u32 seq, u16 flags)
+static int dcbnl_getperm_hwaddr(struct net_device *netdev, struct nlmsghdr *nlh,
+				u32 seq, struct nlattr **tb, struct sk_buff *skb)
 {
-	struct sk_buff *dcbnl_skb;
-	struct nlmsghdr *nlh;
-	struct dcbmsg *dcb;
 	u8 perm_addr[MAX_ADDR_LEN];
-	int ret = -EINVAL;
 
 	if (!netdev->dcbnl_ops->getpermhwaddr)
-		return ret;
-
-	dcbnl_skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
-	if (!dcbnl_skb)
-		goto err_out;
-
-	nlh = NLMSG_NEW(dcbnl_skb, pid, seq, RTM_GETDCB, sizeof(*dcb), flags);
-
-	dcb = NLMSG_DATA(nlh);
-	dcb->dcb_family = AF_UNSPEC;
-	dcb->cmd = DCB_CMD_GPERM_HWADDR;
+		return -EINVAL;
 
 	netdev->dcbnl_ops->getpermhwaddr(netdev, perm_addr);
 
-	ret = nla_put(dcbnl_skb, DCB_ATTR_PERM_HWADDR, sizeof(perm_addr),
-	              perm_addr);
-
-	nlmsg_end(dcbnl_skb, nlh);
-
-	ret = rtnl_unicast(dcbnl_skb, &init_net, pid);
-	if (ret)
-		goto err_out;
-
-	return 0;
-
-nlmsg_failure:
-	kfree_skb(dcbnl_skb);
-err_out:
-	return -EINVAL;
+	return nla_put(skb, DCB_ATTR_PERM_HWADDR, sizeof(perm_addr), perm_addr);
 }
 
-static int dcbnl_getcap(struct net_device *netdev, struct nlattr **tb,
-                        u32 pid, u32 seq, u16 flags)
+static int dcbnl_getcap(struct net_device *netdev, struct nlmsghdr *nlh,
+			u32 seq, struct nlattr **tb, struct sk_buff *skb)
 {
-	struct sk_buff *dcbnl_skb;
-	struct nlmsghdr *nlh;
-	struct dcbmsg *dcb;
 	struct nlattr *data[DCB_CAP_ATTR_MAX + 1], *nest;
 	u8 value;
 	int ret = -EINVAL;
@@ -404,19 +346,9 @@ static int dcbnl_getcap(struct net_device *netdev, struct nlattr **tb,
 	if (ret)
 		goto err_out;
 
-	dcbnl_skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
-	if (!dcbnl_skb)
-		goto err_out;
-
-	nlh = NLMSG_NEW(dcbnl_skb, pid, seq, RTM_GETDCB, sizeof(*dcb), flags);
-
-	dcb = NLMSG_DATA(nlh);
-	dcb->dcb_family = AF_UNSPEC;
-	dcb->cmd = DCB_CMD_GCAP;
-
-	nest = nla_nest_start(dcbnl_skb, DCB_ATTR_CAP);
+	nest = nla_nest_start(skb, DCB_ATTR_CAP);
 	if (!nest)
-		goto err;
+		goto err_out;
 
 	if (data[DCB_CAP_ATTR_ALL])
 		getall = 1;
@@ -426,36 +358,23 @@ static int dcbnl_getcap(struct net_device *netdev, struct nlattr **tb,
 			continue;
 
 		if (!netdev->dcbnl_ops->getcap(netdev, i, &value)) {
-			ret = nla_put_u8(dcbnl_skb, i, value);
-
+			ret = nla_put_u8(skb, i, value);
 			if (ret) {
-				nla_nest_cancel(dcbnl_skb, nest);
-				goto err;
+				nla_nest_cancel(skb, nest);
+				goto err_out;
 			}
 		}
 	}
-	nla_nest_end(dcbnl_skb, nest);
-
-	nlmsg_end(dcbnl_skb, nlh);
-
-	ret = rtnl_unicast(dcbnl_skb, &init_net, pid);
-	if (ret)
-		goto err_out;
+	nla_nest_end(skb, nest);
 
 	return 0;
-nlmsg_failure:
-err:
-	kfree_skb(dcbnl_skb);
 err_out:
 	return -EINVAL;
 }
 
-static int dcbnl_getnumtcs(struct net_device *netdev, struct nlattr **tb,
-                           u32 pid, u32 seq, u16 flags)
+static int dcbnl_getnumtcs(struct net_device *netdev, struct nlmsghdr *nlh,
+			   u32 seq, struct nlattr **tb, struct sk_buff *skb)
 {
-	struct sk_buff *dcbnl_skb;
-	struct nlmsghdr *nlh;
-	struct dcbmsg *dcb;
 	struct nlattr *data[DCB_NUMTCS_ATTR_MAX + 1], *nest;
 	u8 value;
 	int ret = -EINVAL;
@@ -472,22 +391,10 @@ static int dcbnl_getnumtcs(struct net_device *netdev, struct nlattr **tb,
 		goto err_out;
 	}
 
-	dcbnl_skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
-	if (!dcbnl_skb) {
-		ret = -EINVAL;
-		goto err_out;
-	}
-
-	nlh = NLMSG_NEW(dcbnl_skb, pid, seq, RTM_GETDCB, sizeof(*dcb), flags);
-
-	dcb = NLMSG_DATA(nlh);
-	dcb->dcb_family = AF_UNSPEC;
-	dcb->cmd = DCB_CMD_GNUMTCS;
-
-	nest = nla_nest_start(dcbnl_skb, DCB_ATTR_NUMTCS);
+	nest = nla_nest_start(skb, DCB_ATTR_NUMTCS);
 	if (!nest) {
 		ret = -EINVAL;
-		goto err;
+		goto err_out;
 	}
 
 	if (data[DCB_NUMTCS_ATTR_ALL])
@@ -499,37 +406,25 @@ static int dcbnl_getnumtcs(struct net_device *netdev, struct nlattr **tb,
 
 		ret = netdev->dcbnl_ops->getnumtcs(netdev, i, &value);
 		if (!ret) {
-			ret = nla_put_u8(dcbnl_skb, i, value);
-
+			ret = nla_put_u8(skb, i, value);
 			if (ret) {
-				nla_nest_cancel(dcbnl_skb, nest);
+				nla_nest_cancel(skb, nest);
 				ret = -EINVAL;
-				goto err;
+				goto err_out;
 			}
 		} else {
-			goto err;
+			goto err_out;
 		}
 	}
-	nla_nest_end(dcbnl_skb, nest);
-
-	nlmsg_end(dcbnl_skb, nlh);
-
-	ret = rtnl_unicast(dcbnl_skb, &init_net, pid);
-	if (ret) {
-		ret = -EINVAL;
-		goto err_out;
-	}
+	nla_nest_end(skb, nest);
 
 	return 0;
-nlmsg_failure:
-err:
-	kfree_skb(dcbnl_skb);
 err_out:
 	return ret;
 }
 
-static int dcbnl_setnumtcs(struct net_device *netdev, struct nlattr **tb,
-                           u32 pid, u32 seq, u16 flags)
+static int dcbnl_setnumtcs(struct net_device *netdev, struct nlmsghdr *nlh,
+			   u32 seq, struct nlattr **tb, struct sk_buff *skb)
 {
 	struct nlattr *data[DCB_NUMTCS_ATTR_MAX + 1];
 	int ret = -EINVAL;
@@ -542,10 +437,8 @@ static int dcbnl_setnumtcs(struct net_device *netdev, struct nlattr **tb,
 	ret = nla_parse_nested(data, DCB_NUMTCS_ATTR_MAX, tb[DCB_ATTR_NUMTCS],
 	                       dcbnl_numtcs_nest);
 
-	if (ret) {
-		ret = -EINVAL;
-		goto err;
-	}
+	if (ret)
+		return -EINVAL;
 
 	for (i = DCB_NUMTCS_ATTR_ALL+1; i <= DCB_NUMTCS_ATTR_MAX; i++) {
 		if (data[i] == NULL)
@@ -554,59 +447,41 @@ static int dcbnl_setnumtcs(struct net_device *netdev, struct nlattr **tb,
 		value = nla_get_u8(data[i]);
 
 		ret = netdev->dcbnl_ops->setnumtcs(netdev, i, value);
-
 		if (ret)
-			goto operr;
+			break;
 	}
 
-operr:
-	ret = dcbnl_reply(!!ret, RTM_SETDCB, DCB_CMD_SNUMTCS,
-	                  DCB_ATTR_NUMTCS, pid, seq, flags);
-
-err:
-	return ret;
+	return nla_put_u8(skb, DCB_ATTR_NUMTCS, !!ret);
 }
 
-static int dcbnl_getpfcstate(struct net_device *netdev, struct nlattr **tb,
-                             u32 pid, u32 seq, u16 flags)
+static int dcbnl_getpfcstate(struct net_device *netdev, struct nlmsghdr *nlh,
+			     u32 seq, struct nlattr **tb, struct sk_buff *skb)
 {
-	int ret = -EINVAL;
-
 	if (!netdev->dcbnl_ops->getpfcstate)
-		return ret;
-
-	ret = dcbnl_reply(netdev->dcbnl_ops->getpfcstate(netdev), RTM_GETDCB,
-	                  DCB_CMD_PFC_GSTATE, DCB_ATTR_PFC_STATE,
-	                  pid, seq, flags);
+		return -EINVAL;
 
-	return ret;
+	return nla_put_u8(skb, DCB_ATTR_PFC_STATE,
+			  netdev->dcbnl_ops->getpfcstate(netdev));
 }
 
-static int dcbnl_setpfcstate(struct net_device *netdev, struct nlattr **tb,
-                             u32 pid, u32 seq, u16 flags)
+static int dcbnl_setpfcstate(struct net_device *netdev, struct nlmsghdr *nlh,
+			     u32 seq, struct nlattr **tb, struct sk_buff *skb)
 {
-	int ret = -EINVAL;
 	u8 value;
 
 	if (!tb[DCB_ATTR_PFC_STATE] || !netdev->dcbnl_ops->setpfcstate)
-		return ret;
+		return -EINVAL;
 
 	value = nla_get_u8(tb[DCB_ATTR_PFC_STATE]);
 
 	netdev->dcbnl_ops->setpfcstate(netdev, value);
 
-	ret = dcbnl_reply(0, RTM_SETDCB, DCB_CMD_PFC_SSTATE, DCB_ATTR_PFC_STATE,
-	                  pid, seq, flags);
-
-	return ret;
+	return nla_put_u8(skb, DCB_ATTR_PFC_STATE, 0);
 }
 
-static int dcbnl_getapp(struct net_device *netdev, struct nlattr **tb,
-                        u32 pid, u32 seq, u16 flags)
+static int dcbnl_getapp(struct net_device *netdev, struct nlmsghdr *nlh,
+			u32 seq, struct nlattr **tb, struct sk_buff *skb)
 {
-	struct sk_buff *dcbnl_skb;
-	struct nlmsghdr *nlh;
-	struct dcbmsg *dcb;
 	struct nlattr *app_nest;
 	struct nlattr *app_tb[DCB_APP_ATTR_MAX + 1];
 	u16 id;
@@ -645,51 +520,34 @@ static int dcbnl_getapp(struct net_device *netdev, struct nlattr **tb,
 		up = dcb_getapp(netdev, &app);
 	}
 
-	/* send this back */
-	dcbnl_skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
-	if (!dcbnl_skb)
-		goto out;
-
-	nlh = NLMSG_NEW(dcbnl_skb, pid, seq, RTM_GETDCB, sizeof(*dcb), flags);
-	dcb = NLMSG_DATA(nlh);
-	dcb->dcb_family = AF_UNSPEC;
-	dcb->cmd = DCB_CMD_GAPP;
-
-	app_nest = nla_nest_start(dcbnl_skb, DCB_ATTR_APP);
+	app_nest = nla_nest_start(skb, DCB_ATTR_APP);
 	if (!app_nest)
-		goto out_cancel;
+		goto out;
 
-	ret = nla_put_u8(dcbnl_skb, DCB_APP_ATTR_IDTYPE, idtype);
+	ret = nla_put_u8(skb, DCB_APP_ATTR_IDTYPE, idtype);
 	if (ret)
 		goto out_cancel;
 
-	ret = nla_put_u16(dcbnl_skb, DCB_APP_ATTR_ID, id);
+	ret = nla_put_u16(skb, DCB_APP_ATTR_ID, id);
 	if (ret)
 		goto out_cancel;
 
-	ret = nla_put_u8(dcbnl_skb, DCB_APP_ATTR_PRIORITY, up);
+	ret = nla_put_u8(skb, DCB_APP_ATTR_PRIORITY, up);
 	if (ret)
 		goto out_cancel;
 
-	nla_nest_end(dcbnl_skb, app_nest);
-	nlmsg_end(dcbnl_skb, nlh);
-
-	ret = rtnl_unicast(dcbnl_skb, &init_net, pid);
-	if (ret)
-		goto nlmsg_failure;
+	nla_nest_end(skb, app_nest);
 
 	goto out;
 
 out_cancel:
-	nla_nest_cancel(dcbnl_skb, app_nest);
-nlmsg_failure:
-	kfree_skb(dcbnl_skb);
+	nla_nest_cancel(skb, app_nest);
 out:
 	return ret;
 }
 
-static int dcbnl_setapp(struct net_device *netdev, struct nlattr **tb,
-                        u32 pid, u32 seq, u16 flags)
+static int dcbnl_setapp(struct net_device *netdev, struct nlmsghdr *nlh,
+			u32 seq, struct nlattr **tb, struct sk_buff *skb)
 {
 	int err, ret = -EINVAL;
 	u16 id;
@@ -730,19 +588,15 @@ static int dcbnl_setapp(struct net_device *netdev, struct nlattr **tb,
 		err = dcb_setapp(netdev, &app);
 	}
 
-	ret = dcbnl_reply(err, RTM_SETDCB, DCB_CMD_SAPP, DCB_ATTR_APP,
-			  pid, seq, flags);
+	ret = nla_put_u8(skb, DCB_ATTR_APP, ret);
 	dcbnl_cee_notify(netdev, RTM_SETDCB, DCB_CMD_SAPP, seq, 0);
 out:
 	return ret;
 }
 
-static int __dcbnl_pg_getcfg(struct net_device *netdev, struct nlattr **tb,
-                             u32 pid, u32 seq, u16 flags, int dir)
+static int __dcbnl_pg_getcfg(struct net_device *netdev, struct nlmsghdr *nlh,
+			     struct nlattr **tb, struct sk_buff *skb, int dir)
 {
-	struct sk_buff *dcbnl_skb;
-	struct nlmsghdr *nlh;
-	struct dcbmsg *dcb;
 	struct nlattr *pg_nest, *param_nest, *data;
 	struct nlattr *pg_tb[DCB_PG_ATTR_MAX + 1];
 	struct nlattr *param_tb[DCB_TC_ATTR_PARAM_MAX + 1];
@@ -764,19 +618,9 @@ static int __dcbnl_pg_getcfg(struct net_device *netdev, struct nlattr **tb,
 	if (ret)
 		goto err_out;
 
-	dcbnl_skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
-	if (!dcbnl_skb)
-		goto err_out;
-
-	nlh = NLMSG_NEW(dcbnl_skb, pid, seq, RTM_GETDCB, sizeof(*dcb), flags);
-
-	dcb = NLMSG_DATA(nlh);
-	dcb->dcb_family = AF_UNSPEC;
-	dcb->cmd = (dir) ? DCB_CMD_PGRX_GCFG : DCB_CMD_PGTX_GCFG;
-
-	pg_nest = nla_nest_start(dcbnl_skb, DCB_ATTR_PG_CFG);
+	pg_nest = nla_nest_start(skb, DCB_ATTR_PG_CFG);
 	if (!pg_nest)
-		goto err;
+		goto err_out;
 
 	if (pg_tb[DCB_PG_ATTR_TC_ALL])
 		getall = 1;
@@ -794,7 +638,7 @@ static int __dcbnl_pg_getcfg(struct net_device *netdev, struct nlattr **tb,
 		if (ret)
 			goto err_pg;
 
-		param_nest = nla_nest_start(dcbnl_skb, i);
+		param_nest = nla_nest_start(skb, i);
 		if (!param_nest)
 			goto err_pg;
 
@@ -817,33 +661,33 @@ static int __dcbnl_pg_getcfg(struct net_device *netdev, struct nlattr **tb,
 
 		if (param_tb[DCB_TC_ATTR_PARAM_PGID] ||
 		    param_tb[DCB_TC_ATTR_PARAM_ALL]) {
-			ret = nla_put_u8(dcbnl_skb,
+			ret = nla_put_u8(skb,
 			                 DCB_TC_ATTR_PARAM_PGID, pgid);
 			if (ret)
 				goto err_param;
 		}
 		if (param_tb[DCB_TC_ATTR_PARAM_UP_MAPPING] ||
 		    param_tb[DCB_TC_ATTR_PARAM_ALL]) {
-			ret = nla_put_u8(dcbnl_skb,
+			ret = nla_put_u8(skb,
 			                 DCB_TC_ATTR_PARAM_UP_MAPPING, up_map);
 			if (ret)
 				goto err_param;
 		}
 		if (param_tb[DCB_TC_ATTR_PARAM_STRICT_PRIO] ||
 		    param_tb[DCB_TC_ATTR_PARAM_ALL]) {
-			ret = nla_put_u8(dcbnl_skb,
+			ret = nla_put_u8(skb,
 			                 DCB_TC_ATTR_PARAM_STRICT_PRIO, prio);
 			if (ret)
 				goto err_param;
 		}
 		if (param_tb[DCB_TC_ATTR_PARAM_BW_PCT] ||
 		    param_tb[DCB_TC_ATTR_PARAM_ALL]) {
-			ret = nla_put_u8(dcbnl_skb, DCB_TC_ATTR_PARAM_BW_PCT,
+			ret = nla_put_u8(skb, DCB_TC_ATTR_PARAM_BW_PCT,
 			                 tc_pct);
 			if (ret)
 				goto err_param;
 		}
-		nla_nest_end(dcbnl_skb, param_nest);
+		nla_nest_end(skb, param_nest);
 	}
 
 	if (pg_tb[DCB_PG_ATTR_BW_ID_ALL])
@@ -866,66 +710,53 @@ static int __dcbnl_pg_getcfg(struct net_device *netdev, struct nlattr **tb,
 			netdev->dcbnl_ops->getpgbwgcfgtx(netdev,
 					i - DCB_PG_ATTR_BW_ID_0, &tc_pct);
 		}
-		ret = nla_put_u8(dcbnl_skb, i, tc_pct);
+		ret = nla_put_u8(skb, i, tc_pct);
 
 		if (ret)
 			goto err_pg;
 	}
 
-	nla_nest_end(dcbnl_skb, pg_nest);
-
-	nlmsg_end(dcbnl_skb, nlh);
-
-	ret = rtnl_unicast(dcbnl_skb, &init_net, pid);
-	if (ret)
-		goto err_out;
+	nla_nest_end(skb, pg_nest);
 
 	return 0;
 
 err_param:
-	nla_nest_cancel(dcbnl_skb, param_nest);
+	nla_nest_cancel(skb, param_nest);
 err_pg:
-	nla_nest_cancel(dcbnl_skb, pg_nest);
-nlmsg_failure:
-err:
-	kfree_skb(dcbnl_skb);
+	nla_nest_cancel(skb, pg_nest);
 err_out:
 	ret  = -EINVAL;
 	return ret;
 }
 
-static int dcbnl_pgtx_getcfg(struct net_device *netdev, struct nlattr **tb,
-                             u32 pid, u32 seq, u16 flags)
+static int dcbnl_pgtx_getcfg(struct net_device *netdev, struct nlmsghdr *nlh,
+			     u32 seq, struct nlattr **tb, struct sk_buff *skb)
 {
-	return __dcbnl_pg_getcfg(netdev, tb, pid, seq, flags, 0);
+	return __dcbnl_pg_getcfg(netdev, nlh, tb, skb, 0);
 }
 
-static int dcbnl_pgrx_getcfg(struct net_device *netdev, struct nlattr **tb,
-                             u32 pid, u32 seq, u16 flags)
+static int dcbnl_pgrx_getcfg(struct net_device *netdev, struct nlmsghdr *nlh,
+			     u32 seq, struct nlattr **tb, struct sk_buff *skb)
 {
-	return __dcbnl_pg_getcfg(netdev, tb, pid, seq, flags, 1);
+	return __dcbnl_pg_getcfg(netdev, nlh, tb, skb, 1);
 }
 
-static int dcbnl_setstate(struct net_device *netdev, struct nlattr **tb,
-                          u32 pid, u32 seq, u16 flags)
+static int dcbnl_setstate(struct net_device *netdev, struct nlmsghdr *nlh,
+			  u32 seq, struct nlattr **tb, struct sk_buff *skb)
 {
-	int ret = -EINVAL;
 	u8 value;
 
 	if (!tb[DCB_ATTR_STATE] || !netdev->dcbnl_ops->setstate)
-		return ret;
+		return -EINVAL;
 
 	value = nla_get_u8(tb[DCB_ATTR_STATE]);
 
-	ret = dcbnl_reply(netdev->dcbnl_ops->setstate(netdev, value),
-	                  RTM_SETDCB, DCB_CMD_SSTATE, DCB_ATTR_STATE,
-	                  pid, seq, flags);
-
-	return ret;
+	return nla_put_u8(skb, DCB_ATTR_STATE,
+			  netdev->dcbnl_ops->setstate(netdev, value));
 }
 
-static int dcbnl_setpfccfg(struct net_device *netdev, struct nlattr **tb,
-                           u32 pid, u32 seq, u16 flags)
+static int dcbnl_setpfccfg(struct net_device *netdev, struct nlmsghdr *nlh,
+			   u32 seq, struct nlattr **tb, struct sk_buff *skb)
 {
 	struct nlattr *data[DCB_PFC_UP_ATTR_MAX + 1];
 	int i;
@@ -949,29 +780,29 @@ static int dcbnl_setpfccfg(struct net_device *netdev, struct nlattr **tb,
 			data[i]->nla_type - DCB_PFC_UP_ATTR_0, value);
 	}
 
-	ret = dcbnl_reply(0, RTM_SETDCB, DCB_CMD_PFC_SCFG, DCB_ATTR_PFC_CFG,
-	                  pid, seq, flags);
+	return nla_put_u8(skb, DCB_ATTR_PFC_CFG, 0);
 err:
 	return ret;
 }
 
-static int dcbnl_setall(struct net_device *netdev, struct nlattr **tb,
-                        u32 pid, u32 seq, u16 flags)
+static int dcbnl_setall(struct net_device *netdev, struct nlmsghdr *nlh,
+			u32 seq, struct nlattr **tb, struct sk_buff *skb)
 {
 	int ret = -EINVAL;
 
 	if (!tb[DCB_ATTR_SET_ALL] || !netdev->dcbnl_ops->setall)
 		return ret;
 
-	ret = dcbnl_reply(netdev->dcbnl_ops->setall(netdev), RTM_SETDCB,
-	                  DCB_CMD_SET_ALL, DCB_ATTR_SET_ALL, pid, seq, flags);
+	ret = nla_put_u8(skb, DCB_ATTR_SET_ALL,
+			 netdev->dcbnl_ops->setall(netdev));
 	dcbnl_cee_notify(netdev, RTM_SETDCB, DCB_CMD_SET_ALL, seq, 0);
 
 	return ret;
 }
 
-static int __dcbnl_pg_setcfg(struct net_device *netdev, struct nlattr **tb,
-                             u32 pid, u32 seq, u16 flags, int dir)
+static int __dcbnl_pg_setcfg(struct net_device *netdev, struct nlmsghdr *nlh,
+			     u32 seq, struct nlattr **tb, struct sk_buff *skb,
+			     int dir)
 {
 	struct nlattr *pg_tb[DCB_PG_ATTR_MAX + 1];
 	struct nlattr *param_tb[DCB_TC_ATTR_PARAM_MAX + 1];
@@ -1054,32 +885,27 @@ static int __dcbnl_pg_setcfg(struct net_device *netdev, struct nlattr **tb,
 		}
 	}
 
-	ret = dcbnl_reply(0, RTM_SETDCB,
-			  (dir ? DCB_CMD_PGRX_SCFG : DCB_CMD_PGTX_SCFG),
-			  DCB_ATTR_PG_CFG, pid, seq, flags);
+	ret = nla_put_u8(skb, (dir ? DCB_CMD_PGRX_SCFG : DCB_CMD_PGTX_SCFG), 0);
 
 err:
 	return ret;
 }
 
-static int dcbnl_pgtx_setcfg(struct net_device *netdev, struct nlattr **tb,
-                             u32 pid, u32 seq, u16 flags)
+static int dcbnl_pgtx_setcfg(struct net_device *netdev, struct nlmsghdr *nlh,
+			     u32 seq, struct nlattr **tb, struct sk_buff *skb)
 {
-	return __dcbnl_pg_setcfg(netdev, tb, pid, seq, flags, 0);
+	return __dcbnl_pg_setcfg(netdev, nlh, seq, tb, skb, 0);
 }
 
-static int dcbnl_pgrx_setcfg(struct net_device *netdev, struct nlattr **tb,
-                             u32 pid, u32 seq, u16 flags)
+static int dcbnl_pgrx_setcfg(struct net_device *netdev, struct nlmsghdr *nlh,
+			     u32 seq, struct nlattr **tb, struct sk_buff *skb)
 {
-	return __dcbnl_pg_setcfg(netdev, tb, pid, seq, flags, 1);
+	return __dcbnl_pg_setcfg(netdev, nlh, seq, tb, skb, 1);
 }
 
-static int dcbnl_bcn_getcfg(struct net_device *netdev, struct nlattr **tb,
-                            u32 pid, u32 seq, u16 flags)
+static int dcbnl_bcn_getcfg(struct net_device *netdev, struct nlmsghdr *nlh,
+			    u32 seq, struct nlattr **tb, struct sk_buff *skb)
 {
-	struct sk_buff *dcbnl_skb;
-	struct nlmsghdr *nlh;
-	struct dcbmsg *dcb;
 	struct nlattr *bcn_nest;
 	struct nlattr *bcn_tb[DCB_BCN_ATTR_MAX + 1];
 	u8 value_byte;
@@ -1098,19 +924,9 @@ static int dcbnl_bcn_getcfg(struct net_device *netdev, struct nlattr **tb,
 	if (ret)
 		goto err_out;
 
-	dcbnl_skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
-	if (!dcbnl_skb)
-		goto err_out;
-
-	nlh = NLMSG_NEW(dcbnl_skb, pid, seq, RTM_GETDCB, sizeof(*dcb), flags);
-
-	dcb = NLMSG_DATA(nlh);
-	dcb->dcb_family = AF_UNSPEC;
-	dcb->cmd = DCB_CMD_BCN_GCFG;
-
-	bcn_nest = nla_nest_start(dcbnl_skb, DCB_ATTR_BCN);
+	bcn_nest = nla_nest_start(skb, DCB_ATTR_BCN);
 	if (!bcn_nest)
-		goto err;
+		goto err_out;
 
 	if (bcn_tb[DCB_BCN_ATTR_ALL])
 		getall = true;
@@ -1121,7 +937,7 @@ static int dcbnl_bcn_getcfg(struct net_device *netdev, struct nlattr **tb,
 
 		netdev->dcbnl_ops->getbcnrp(netdev, i - DCB_BCN_ATTR_RP_0,
 		                            &value_byte);
-		ret = nla_put_u8(dcbnl_skb, i, value_byte);
+		ret = nla_put_u8(skb, i, value_byte);
 		if (ret)
 			goto err_bcn;
 	}
@@ -1132,33 +948,24 @@ static int dcbnl_bcn_getcfg(struct net_device *netdev, struct nlattr **tb,
 
 		netdev->dcbnl_ops->getbcncfg(netdev, i,
 		                             &value_integer);
-		ret = nla_put_u32(dcbnl_skb, i, value_integer);
+		ret = nla_put_u32(skb, i, value_integer);
 		if (ret)
 			goto err_bcn;
 	}
 
-	nla_nest_end(dcbnl_skb, bcn_nest);
-
-	nlmsg_end(dcbnl_skb, nlh);
-
-	ret = rtnl_unicast(dcbnl_skb, &init_net, pid);
-	if (ret)
-		goto err_out;
+	nla_nest_end(skb, bcn_nest);
 
 	return 0;
 
 err_bcn:
-	nla_nest_cancel(dcbnl_skb, bcn_nest);
-nlmsg_failure:
-err:
-	kfree_skb(dcbnl_skb);
+	nla_nest_cancel(skb, bcn_nest);
 err_out:
 	ret  = -EINVAL;
 	return ret;
 }
 
-static int dcbnl_bcn_setcfg(struct net_device *netdev, struct nlattr **tb,
-                            u32 pid, u32 seq, u16 flags)
+static int dcbnl_bcn_setcfg(struct net_device *netdev, struct nlmsghdr *nlh,
+			    u32 seq, struct nlattr **tb, struct sk_buff *skb)
 {
 	struct nlattr *data[DCB_BCN_ATTR_MAX + 1];
 	int i;
@@ -1192,8 +999,7 @@ static int dcbnl_bcn_setcfg(struct net_device *netdev, struct nlattr **tb,
 	                                     i, value_int);
 	}
 
-	ret = dcbnl_reply(0, RTM_SETDCB, DCB_CMD_BCN_SCFG, DCB_ATTR_BCN,
-	                  pid, seq, flags);
+	ret = nla_put_u8(skb, DCB_ATTR_BCN, 0);
 err:
 	return ret;
 }
@@ -1618,8 +1424,8 @@ EXPORT_SYMBOL(dcbnl_cee_notify);
  * No attempt is made to reconcile the case where only part of the
  * cmd can be completed.
  */
-static int dcbnl_ieee_set(struct net_device *netdev, struct nlattr **tb,
-			  u32 pid, u32 seq, u16 flags)
+static int dcbnl_ieee_set(struct net_device *netdev, struct nlmsghdr *nlh,
+			  u32 seq, struct nlattr **tb, struct sk_buff *skb)
 {
 	const struct dcbnl_rtnl_ops *ops = netdev->dcbnl_ops;
 	struct nlattr *ieee[DCB_ATTR_IEEE_MAX + 1];
@@ -1677,54 +1483,24 @@ static int dcbnl_ieee_set(struct net_device *netdev, struct nlattr **tb,
 	}
 
 err:
-	dcbnl_reply(err, RTM_SETDCB, DCB_CMD_IEEE_SET, DCB_ATTR_IEEE,
-		    pid, seq, flags);
+	err = nla_put_u8(skb, DCB_ATTR_IEEE, err);
 	dcbnl_ieee_notify(netdev, RTM_SETDCB, DCB_CMD_IEEE_SET, seq, 0);
 	return err;
 }
 
-static int dcbnl_ieee_get(struct net_device *netdev, struct nlattr **tb,
-			  u32 pid, u32 seq, u16 flags)
+static int dcbnl_ieee_get(struct net_device *netdev, struct nlmsghdr *nlh,
+			  u32 seq, struct nlattr **tb, struct sk_buff *skb)
 {
-	struct net *net = dev_net(netdev);
-	struct sk_buff *skb;
-	struct nlmsghdr *nlh;
-	struct dcbmsg *dcb;
 	const struct dcbnl_rtnl_ops *ops = netdev->dcbnl_ops;
-	int err;
 
 	if (!ops)
 		return -EOPNOTSUPP;
 
-	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
-	if (!skb)
-		return -ENOBUFS;
-
-	nlh = nlmsg_put(skb, pid, seq, RTM_GETDCB, sizeof(*dcb), flags);
-	if (nlh == NULL) {
-		nlmsg_free(skb);
-		return -EMSGSIZE;
-	}
-
-	dcb = NLMSG_DATA(nlh);
-	dcb->dcb_family = AF_UNSPEC;
-	dcb->cmd = DCB_CMD_IEEE_GET;
-
-	err = dcbnl_ieee_fill(skb, netdev);
-
-	if (err < 0) {
-		nlmsg_cancel(skb, nlh);
-		kfree_skb(skb);
-	} else {
-		nlmsg_end(skb, nlh);
-		err = rtnl_unicast(skb, net, pid);
-	}
-
-	return err;
+	return dcbnl_ieee_fill(skb, netdev);
 }
 
-static int dcbnl_ieee_del(struct net_device *netdev, struct nlattr **tb,
-			  u32 pid, u32 seq, u16 flags)
+static int dcbnl_ieee_del(struct net_device *netdev, struct nlmsghdr *nlh,
+			  u32 seq, struct nlattr **tb, struct sk_buff *skb)
 {
 	const struct dcbnl_rtnl_ops *ops = netdev->dcbnl_ops;
 	struct nlattr *ieee[DCB_ATTR_IEEE_MAX + 1];
@@ -1761,32 +1537,26 @@ static int dcbnl_ieee_del(struct net_device *netdev, struct nlattr **tb,
 	}
 
 err:
-	dcbnl_reply(err, RTM_SETDCB, DCB_CMD_IEEE_DEL, DCB_ATTR_IEEE,
-		    pid, seq, flags);
+	err = nla_put_u8(skb, DCB_ATTR_IEEE, err);
 	dcbnl_ieee_notify(netdev, RTM_SETDCB, DCB_CMD_IEEE_DEL, seq, 0);
 	return err;
 }
 
 
 /* DCBX configuration */
-static int dcbnl_getdcbx(struct net_device *netdev, struct nlattr **tb,
-			 u32 pid, u32 seq, u16 flags)
+static int dcbnl_getdcbx(struct net_device *netdev, struct nlmsghdr *nlh,
+			 u32 seq, struct nlattr **tb, struct sk_buff *skb)
 {
-	int ret;
-
 	if (!netdev->dcbnl_ops->getdcbx)
 		return -EOPNOTSUPP;
 
-	ret = dcbnl_reply(netdev->dcbnl_ops->getdcbx(netdev), RTM_GETDCB,
-			  DCB_CMD_GDCBX, DCB_ATTR_DCBX, pid, seq, flags);
-
-	return ret;
+	return nla_put_u8(skb, DCB_ATTR_DCBX,
+			  netdev->dcbnl_ops->getdcbx(netdev));
 }
 
-static int dcbnl_setdcbx(struct net_device *netdev, struct nlattr **tb,
-			 u32 pid, u32 seq, u16 flags)
+static int dcbnl_setdcbx(struct net_device *netdev, struct nlmsghdr *nlh,
+			 u32 seq, struct nlattr **tb, struct sk_buff *skb)
 {
-	int ret;
 	u8 value;
 
 	if (!netdev->dcbnl_ops->setdcbx)
@@ -1797,19 +1567,13 @@ static int dcbnl_setdcbx(struct net_device *netdev, struct nlattr **tb,
 
 	value = nla_get_u8(tb[DCB_ATTR_DCBX]);
 
-	ret = dcbnl_reply(netdev->dcbnl_ops->setdcbx(netdev, value),
-			  RTM_SETDCB, DCB_CMD_SDCBX, DCB_ATTR_DCBX,
-			  pid, seq, flags);
-
-	return ret;
+	return nla_put_u8(skb, DCB_ATTR_DCBX,
+			  netdev->dcbnl_ops->setdcbx(netdev, value));
 }
 
-static int dcbnl_getfeatcfg(struct net_device *netdev, struct nlattr **tb,
-			    u32 pid, u32 seq, u16 flags)
+static int dcbnl_getfeatcfg(struct net_device *netdev, struct nlmsghdr *nlh,
+			    u32 seq, struct nlattr **tb, struct sk_buff *skb)
 {
-	struct sk_buff *dcbnl_skb;
-	struct nlmsghdr *nlh;
-	struct dcbmsg *dcb;
 	struct nlattr *data[DCB_FEATCFG_ATTR_MAX + 1], *nest;
 	u8 value;
 	int ret, i;
@@ -1824,25 +1588,11 @@ static int dcbnl_getfeatcfg(struct net_device *netdev, struct nlattr **tb,
 	ret = nla_parse_nested(data, DCB_FEATCFG_ATTR_MAX, tb[DCB_ATTR_FEATCFG],
 			       dcbnl_featcfg_nest);
 	if (ret)
-		goto err_out;
-
-	dcbnl_skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
-	if (!dcbnl_skb) {
-		ret = -ENOBUFS;
-		goto err_out;
-	}
-
-	nlh = NLMSG_NEW(dcbnl_skb, pid, seq, RTM_GETDCB, sizeof(*dcb), flags);
-
-	dcb = NLMSG_DATA(nlh);
-	dcb->dcb_family = AF_UNSPEC;
-	dcb->cmd = DCB_CMD_GFEATCFG;
+		return ret;
 
-	nest = nla_nest_start(dcbnl_skb, DCB_ATTR_FEATCFG);
-	if (!nest) {
-		ret = -EMSGSIZE;
-		goto nla_put_failure;
-	}
+	nest = nla_nest_start(skb, DCB_ATTR_FEATCFG);
+	if (!nest)
+		return -EMSGSIZE;
 
 	if (data[DCB_FEATCFG_ATTR_ALL])
 		getall = 1;
@@ -1853,28 +1603,21 @@ static int dcbnl_getfeatcfg(struct net_device *netdev, struct nlattr **tb,
 
 		ret = netdev->dcbnl_ops->getfeatcfg(netdev, i, &value);
 		if (!ret)
-			ret = nla_put_u8(dcbnl_skb, i, value);
+			ret = nla_put_u8(skb, i, value);
 
 		if (ret) {
-			nla_nest_cancel(dcbnl_skb, nest);
+			nla_nest_cancel(skb, nest);
 			goto nla_put_failure;
 		}
 	}
-	nla_nest_end(dcbnl_skb, nest);
-
-	nlmsg_end(dcbnl_skb, nlh);
+	nla_nest_end(skb, nest);
 
-	return rtnl_unicast(dcbnl_skb, &init_net, pid);
 nla_put_failure:
-	nlmsg_cancel(dcbnl_skb, nlh);
-nlmsg_failure:
-	kfree_skb(dcbnl_skb);
-err_out:
 	return ret;
 }
 
-static int dcbnl_setfeatcfg(struct net_device *netdev, struct nlattr **tb,
-			    u32 pid, u32 seq, u16 flags)
+static int dcbnl_setfeatcfg(struct net_device *netdev, struct nlmsghdr *nlh,
+			    u32 seq, struct nlattr **tb, struct sk_buff *skb)
 {
 	struct nlattr *data[DCB_FEATCFG_ATTR_MAX + 1];
 	int ret, i;
@@ -1904,50 +1647,21 @@ static int dcbnl_setfeatcfg(struct net_device *netdev, struct nlattr **tb,
 			goto err;
 	}
 err:
-	dcbnl_reply(ret, RTM_SETDCB, DCB_CMD_SFEATCFG, DCB_ATTR_FEATCFG,
-		    pid, seq, flags);
+	ret = nla_put_u8(skb, DCB_ATTR_FEATCFG, ret);
 
 	return ret;
 }
 
 /* Handle CEE DCBX GET commands. */
-static int dcbnl_cee_get(struct net_device *netdev, struct nlattr **tb,
-			 u32 pid, u32 seq, u16 flags)
+static int dcbnl_cee_get(struct net_device *netdev, struct nlmsghdr *nlh,
+			 u32 seq, struct nlattr **tb, struct sk_buff *skb)
 {
-	struct net *net = dev_net(netdev);
-	struct sk_buff *skb;
-	struct nlmsghdr *nlh;
-	struct dcbmsg *dcb;
 	const struct dcbnl_rtnl_ops *ops = netdev->dcbnl_ops;
-	int err;
 
 	if (!ops)
 		return -EOPNOTSUPP;
 
-	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
-	if (!skb)
-		return -ENOBUFS;
-
-	nlh = nlmsg_put(skb, pid, seq, RTM_GETDCB, sizeof(*dcb), flags);
-	if (nlh == NULL) {
-		nlmsg_free(skb);
-		return -EMSGSIZE;
-	}
-
-	dcb = NLMSG_DATA(nlh);
-	dcb->dcb_family = AF_UNSPEC;
-	dcb->cmd = DCB_CMD_CEE_GET;
-
-	err = dcbnl_cee_fill(skb, netdev);
-
-	if (err < 0) {
-		nlmsg_cancel(skb, nlh);
-		nlmsg_free(skb);
-	} else {
-		nlmsg_end(skb, nlh);
-		err = rtnl_unicast(skb, net, pid);
-	}
-	return err;
+	return dcbnl_cee_fill(skb, netdev);
 }
 
 struct reply_func {
@@ -1960,7 +1674,33 @@ struct reply_func {
 };
 
 static const struct reply_func reply_funcs[DCB_CMD_MAX+1] = {
-	/* FIXME: add reply defs */
+	[DCB_CMD_GSTATE]	= { RTM_GETDCB, dcbnl_getstate },
+	[DCB_CMD_SSTATE]	= { RTM_SETDCB, dcbnl_setstate },
+	[DCB_CMD_PFC_GCFG]	= { RTM_GETDCB, dcbnl_getpfccfg },
+	[DCB_CMD_PFC_SCFG]	= { RTM_SETDCB, dcbnl_setpfccfg },
+	[DCB_CMD_GPERM_HWADDR]	= { RTM_GETDCB, dcbnl_getperm_hwaddr },
+	[DCB_CMD_GCAP]		= { RTM_GETDCB, dcbnl_getcap },
+	[DCB_CMD_GNUMTCS]	= { RTM_GETDCB, dcbnl_getnumtcs },
+	[DCB_CMD_SNUMTCS]	= { RTM_SETDCB, dcbnl_setnumtcs },
+	[DCB_CMD_PFC_GSTATE]	= { RTM_GETDCB, dcbnl_getpfcstate },
+	[DCB_CMD_PFC_SSTATE]	= { RTM_SETDCB, dcbnl_setpfcstate },
+	[DCB_CMD_GAPP]		= { RTM_GETDCB, dcbnl_getapp },
+	[DCB_CMD_SAPP]		= { RTM_SETDCB, dcbnl_setapp },
+	[DCB_CMD_PGTX_GCFG]	= { RTM_GETDCB, dcbnl_pgtx_getcfg },
+	[DCB_CMD_PGTX_SCFG]	= { RTM_SETDCB, dcbnl_pgtx_setcfg },
+	[DCB_CMD_PGRX_GCFG]	= { RTM_GETDCB, dcbnl_pgrx_getcfg },
+	[DCB_CMD_PGRX_SCFG]	= { RTM_SETDCB, dcbnl_pgrx_setcfg },
+	[DCB_CMD_SET_ALL]	= { RTM_SETDCB, dcbnl_setall },
+	[DCB_CMD_BCN_GCFG]	= { RTM_GETDCB, dcbnl_bcn_getcfg },
+	[DCB_CMD_BCN_SCFG]	= { RTM_SETDCB, dcbnl_bcn_setcfg },
+	[DCB_CMD_IEEE_GET]	= { RTM_GETDCB, dcbnl_ieee_get },
+	[DCB_CMD_IEEE_SET]	= { RTM_SETDCB, dcbnl_ieee_set },
+	[DCB_CMD_IEEE_DEL]	= { RTM_SETDCB, dcbnl_ieee_del },
+	[DCB_CMD_GDCBX]		= { RTM_GETDCB, dcbnl_getdcbx },
+	[DCB_CMD_SDCBX]		= { RTM_SETDCB, dcbnl_setdcbx },
+	[DCB_CMD_GFEATCFG]	= { RTM_GETDCB, dcbnl_getfeatcfg },
+	[DCB_CMD_SFEATCFG]	= { RTM_SETDCB, dcbnl_setfeatcfg },
+	[DCB_CMD_CEE_GET]	= { RTM_GETDCB, dcbnl_cee_get },
 };
 
 static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
@@ -2017,124 +1757,6 @@ static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	nlmsg_end(reply_skb, reply_nlh);
 
 	ret = rtnl_unicast(reply_skb, &init_net, pid);
-	if (ret)
-		goto out;
-
-	switch (dcb->cmd) {
-	case DCB_CMD_GSTATE:
-		ret = dcbnl_getstate(netdev, tb, pid, nlh->nlmsg_seq,
-		                     nlh->nlmsg_flags);
-		goto out;
-	case DCB_CMD_PFC_GCFG:
-		ret = dcbnl_getpfccfg(netdev, tb, pid, nlh->nlmsg_seq,
-		                      nlh->nlmsg_flags);
-		goto out;
-	case DCB_CMD_GPERM_HWADDR:
-		ret = dcbnl_getperm_hwaddr(netdev, tb, pid, nlh->nlmsg_seq,
-		                           nlh->nlmsg_flags);
-		goto out;
-	case DCB_CMD_PGTX_GCFG:
-		ret = dcbnl_pgtx_getcfg(netdev, tb, pid, nlh->nlmsg_seq,
-		                        nlh->nlmsg_flags);
-		goto out;
-	case DCB_CMD_PGRX_GCFG:
-		ret = dcbnl_pgrx_getcfg(netdev, tb, pid, nlh->nlmsg_seq,
-		                        nlh->nlmsg_flags);
-		goto out;
-	case DCB_CMD_BCN_GCFG:
-		ret = dcbnl_bcn_getcfg(netdev, tb, pid, nlh->nlmsg_seq,
-		                       nlh->nlmsg_flags);
-		goto out;
-	case DCB_CMD_SSTATE:
-		ret = dcbnl_setstate(netdev, tb, pid, nlh->nlmsg_seq,
-		                     nlh->nlmsg_flags);
-		goto out;
-	case DCB_CMD_PFC_SCFG:
-		ret = dcbnl_setpfccfg(netdev, tb, pid, nlh->nlmsg_seq,
-		                      nlh->nlmsg_flags);
-		goto out;
-
-	case DCB_CMD_SET_ALL:
-		ret = dcbnl_setall(netdev, tb, pid, nlh->nlmsg_seq,
-		                   nlh->nlmsg_flags);
-		goto out;
-	case DCB_CMD_PGTX_SCFG:
-		ret = dcbnl_pgtx_setcfg(netdev, tb, pid, nlh->nlmsg_seq,
-		                        nlh->nlmsg_flags);
-		goto out;
-	case DCB_CMD_PGRX_SCFG:
-		ret = dcbnl_pgrx_setcfg(netdev, tb, pid, nlh->nlmsg_seq,
-		                        nlh->nlmsg_flags);
-		goto out;
-	case DCB_CMD_GCAP:
-		ret = dcbnl_getcap(netdev, tb, pid, nlh->nlmsg_seq,
-		                   nlh->nlmsg_flags);
-		goto out;
-	case DCB_CMD_GNUMTCS:
-		ret = dcbnl_getnumtcs(netdev, tb, pid, nlh->nlmsg_seq,
-		                      nlh->nlmsg_flags);
-		goto out;
-	case DCB_CMD_SNUMTCS:
-		ret = dcbnl_setnumtcs(netdev, tb, pid, nlh->nlmsg_seq,
-		                      nlh->nlmsg_flags);
-		goto out;
-	case DCB_CMD_PFC_GSTATE:
-		ret = dcbnl_getpfcstate(netdev, tb, pid, nlh->nlmsg_seq,
-		                        nlh->nlmsg_flags);
-		goto out;
-	case DCB_CMD_PFC_SSTATE:
-		ret = dcbnl_setpfcstate(netdev, tb, pid, nlh->nlmsg_seq,
-		                        nlh->nlmsg_flags);
-		goto out;
-	case DCB_CMD_BCN_SCFG:
-		ret = dcbnl_bcn_setcfg(netdev, tb, pid, nlh->nlmsg_seq,
-		                       nlh->nlmsg_flags);
-		goto out;
-	case DCB_CMD_GAPP:
-		ret = dcbnl_getapp(netdev, tb, pid, nlh->nlmsg_seq,
-		                   nlh->nlmsg_flags);
-		goto out;
-	case DCB_CMD_SAPP:
-		ret = dcbnl_setapp(netdev, tb, pid, nlh->nlmsg_seq,
-		                   nlh->nlmsg_flags);
-		goto out;
-	case DCB_CMD_IEEE_SET:
-		ret = dcbnl_ieee_set(netdev, tb, pid, nlh->nlmsg_seq,
-				     nlh->nlmsg_flags);
-		goto out;
-	case DCB_CMD_IEEE_GET:
-		ret = dcbnl_ieee_get(netdev, tb, pid, nlh->nlmsg_seq,
-				     nlh->nlmsg_flags);
-		goto out;
-	case DCB_CMD_IEEE_DEL:
-		ret = dcbnl_ieee_del(netdev, tb, pid, nlh->nlmsg_seq,
-				     nlh->nlmsg_flags);
-		goto out;
-	case DCB_CMD_GDCBX:
-		ret = dcbnl_getdcbx(netdev, tb, pid, nlh->nlmsg_seq,
-				    nlh->nlmsg_flags);
-		goto out;
-	case DCB_CMD_SDCBX:
-		ret = dcbnl_setdcbx(netdev, tb, pid, nlh->nlmsg_seq,
-				    nlh->nlmsg_flags);
-		goto out;
-	case DCB_CMD_GFEATCFG:
-		ret = dcbnl_getfeatcfg(netdev, tb, pid, nlh->nlmsg_seq,
-				       nlh->nlmsg_flags);
-		goto out;
-	case DCB_CMD_SFEATCFG:
-		ret = dcbnl_setfeatcfg(netdev, tb, pid, nlh->nlmsg_seq,
-				       nlh->nlmsg_flags);
-		goto out;
-	case DCB_CMD_CEE_GET:
-		ret = dcbnl_cee_get(netdev, tb, pid, nlh->nlmsg_seq,
-				    nlh->nlmsg_flags);
-		goto out;
-	default:
-		goto errout;
-	}
-errout:
-	ret = -EINVAL;
 out:
 	dev_put(netdev);
 	return ret;
-- 
1.7.7.6
