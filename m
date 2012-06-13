From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 5/8] dcbnl: Return consistent error codes
Date: Wed, 13 Jun 2012 14:54:58 +0200
Message-ID: <862f07acd525d3c6d4f8f0c5229f0ea89a4e68e7.1339591572.git.tgraf@suug.ch>
References: <cover.1339591572.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, lucy.liu@intel.com,
	john.r.fastabend@intel.com, alexander.h.duyck@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58936 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753229Ab2FMMzN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2012 08:55:13 -0400
In-Reply-To: <cover.1339591572.git.tgraf@suug.ch>
In-Reply-To: <cover.1339591572.git.tgraf@suug.ch>
References: <cover.1339591572.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

EMSGSIZE - ran out of space while constructing message
EOPNOTSUPP - driver/hardware does not support operation
ENODEV - network device not found
EINVAL - invalid message

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/dcb/dcbnl.c |  273 ++++++++++++++++++++++++++++---------------------------
 1 files changed, 138 insertions(+), 135 deletions(-)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 4d9e0ef..5a5bc25 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -229,7 +229,7 @@ static int dcbnl_getstate(struct net_device *netdev, struct nlmsghdr *nlh,
 {
 	/* if (!tb[DCB_ATTR_STATE] || !netdev->dcbnl_ops->getstate) */
 	if (!netdev->dcbnl_ops->getstate)
-		return -EINVAL;
+		return -EOPNOTSUPP;
 
 	return nla_put_u8(skb, DCB_ATTR_STATE,
 			  netdev->dcbnl_ops->getstate(netdev));
@@ -240,22 +240,25 @@ static int dcbnl_getpfccfg(struct net_device *netdev, struct nlmsghdr *nlh,
 {
 	struct nlattr *data[DCB_PFC_UP_ATTR_MAX + 1], *nest;
 	u8 value;
-	int ret = -EINVAL;
+	int ret;
 	int i;
 	int getall = 0;
 
-	if (!tb[DCB_ATTR_PFC_CFG] || !netdev->dcbnl_ops->getpfccfg)
-		return ret;
+	if (!tb[DCB_ATTR_PFC_CFG])
+		return -EINVAL;
+
+	if (!netdev->dcbnl_ops->getpfccfg)
+		return -EOPNOTSUPP;
 
 	ret = nla_parse_nested(data, DCB_PFC_UP_ATTR_MAX,
 	                       tb[DCB_ATTR_PFC_CFG],
 	                       dcbnl_pfc_up_nest);
 	if (ret)
-		goto err;
+		return ret;
 
 	nest = nla_nest_start(skb, DCB_ATTR_PFC_CFG);
 	if (!nest)
-		goto err;
+		return -EMSGSIZE;
 
 	if (data[DCB_PFC_UP_ATTR_ALL])
 		getall = 1;
@@ -269,14 +272,12 @@ static int dcbnl_getpfccfg(struct net_device *netdev, struct nlmsghdr *nlh,
 		ret = nla_put_u8(skb, i, value);
 		if (ret) {
 			nla_nest_cancel(skb, nest);
-			goto err;
+			return ret;
 		}
 	}
 	nla_nest_end(skb, nest);
 
 	return 0;
-err:
-	return -EINVAL;
 }
 
 static int dcbnl_getperm_hwaddr(struct net_device *netdev, struct nlmsghdr *nlh,
@@ -285,7 +286,7 @@ static int dcbnl_getperm_hwaddr(struct net_device *netdev, struct nlmsghdr *nlh,
 	u8 perm_addr[MAX_ADDR_LEN];
 
 	if (!netdev->dcbnl_ops->getpermhwaddr)
-		return -EINVAL;
+		return -EOPNOTSUPP;
 
 	netdev->dcbnl_ops->getpermhwaddr(netdev, perm_addr);
 
@@ -297,21 +298,24 @@ static int dcbnl_getcap(struct net_device *netdev, struct nlmsghdr *nlh,
 {
 	struct nlattr *data[DCB_CAP_ATTR_MAX + 1], *nest;
 	u8 value;
-	int ret = -EINVAL;
+	int ret;
 	int i;
 	int getall = 0;
 
-	if (!tb[DCB_ATTR_CAP] || !netdev->dcbnl_ops->getcap)
-		return ret;
+	if (!tb[DCB_ATTR_CAP])
+		return -EINVAL;
+
+	if (!netdev->dcbnl_ops->getcap)
+		return -EOPNOTSUPP;
 
 	ret = nla_parse_nested(data, DCB_CAP_ATTR_MAX, tb[DCB_ATTR_CAP],
 	                       dcbnl_cap_nest);
 	if (ret)
-		goto err_out;
+		return ret;
 
 	nest = nla_nest_start(skb, DCB_ATTR_CAP);
 	if (!nest)
-		goto err_out;
+		return -EMSGSIZE;
 
 	if (data[DCB_CAP_ATTR_ALL])
 		getall = 1;
@@ -324,15 +328,13 @@ static int dcbnl_getcap(struct net_device *netdev, struct nlmsghdr *nlh,
 			ret = nla_put_u8(skb, i, value);
 			if (ret) {
 				nla_nest_cancel(skb, nest);
-				goto err_out;
+				return ret;
 			}
 		}
 	}
 	nla_nest_end(skb, nest);
 
 	return 0;
-err_out:
-	return -EINVAL;
 }
 
 static int dcbnl_getnumtcs(struct net_device *netdev, struct nlmsghdr *nlh,
@@ -340,25 +342,24 @@ static int dcbnl_getnumtcs(struct net_device *netdev, struct nlmsghdr *nlh,
 {
 	struct nlattr *data[DCB_NUMTCS_ATTR_MAX + 1], *nest;
 	u8 value;
-	int ret = -EINVAL;
+	int ret;
 	int i;
 	int getall = 0;
 
-	if (!tb[DCB_ATTR_NUMTCS] || !netdev->dcbnl_ops->getnumtcs)
-		return ret;
+	if (!tb[DCB_ATTR_NUMTCS])
+		return -EINVAL;
+
+	if (!netdev->dcbnl_ops->getnumtcs)
+		return -EOPNOTSUPP;
 
 	ret = nla_parse_nested(data, DCB_NUMTCS_ATTR_MAX, tb[DCB_ATTR_NUMTCS],
 	                       dcbnl_numtcs_nest);
-	if (ret) {
-		ret = -EINVAL;
-		goto err_out;
-	}
+	if (ret)
+		return ret;
 
 	nest = nla_nest_start(skb, DCB_ATTR_NUMTCS);
-	if (!nest) {
-		ret = -EINVAL;
-		goto err_out;
-	}
+	if (!nest)
+		return -EMSGSIZE;
 
 	if (data[DCB_NUMTCS_ATTR_ALL])
 		getall = 1;
@@ -372,36 +373,34 @@ static int dcbnl_getnumtcs(struct net_device *netdev, struct nlmsghdr *nlh,
 			ret = nla_put_u8(skb, i, value);
 			if (ret) {
 				nla_nest_cancel(skb, nest);
-				ret = -EINVAL;
-				goto err_out;
+				return ret;
 			}
-		} else {
-			goto err_out;
-		}
+		} else
+			return -EINVAL;
 	}
 	nla_nest_end(skb, nest);
 
 	return 0;
-err_out:
-	return ret;
 }
 
 static int dcbnl_setnumtcs(struct net_device *netdev, struct nlmsghdr *nlh,
 			   u32 seq, struct nlattr **tb, struct sk_buff *skb)
 {
 	struct nlattr *data[DCB_NUMTCS_ATTR_MAX + 1];
-	int ret = -EINVAL;
+	int ret;
 	u8 value;
 	int i;
 
-	if (!tb[DCB_ATTR_NUMTCS] || !netdev->dcbnl_ops->setnumtcs)
-		return ret;
+	if (!tb[DCB_ATTR_NUMTCS])
+		return -EINVAL;
+
+	if (!netdev->dcbnl_ops->setnumtcs)
+		return -EOPNOTSUPP;
 
 	ret = nla_parse_nested(data, DCB_NUMTCS_ATTR_MAX, tb[DCB_ATTR_NUMTCS],
 	                       dcbnl_numtcs_nest);
-
 	if (ret)
-		return -EINVAL;
+		return ret;
 
 	for (i = DCB_NUMTCS_ATTR_ALL+1; i <= DCB_NUMTCS_ATTR_MAX; i++) {
 		if (data[i] == NULL)
@@ -421,7 +420,7 @@ static int dcbnl_getpfcstate(struct net_device *netdev, struct nlmsghdr *nlh,
 			     u32 seq, struct nlattr **tb, struct sk_buff *skb)
 {
 	if (!netdev->dcbnl_ops->getpfcstate)
-		return -EINVAL;
+		return -EOPNOTSUPP;
 
 	return nla_put_u8(skb, DCB_ATTR_PFC_STATE,
 			  netdev->dcbnl_ops->getpfcstate(netdev));
@@ -432,9 +431,12 @@ static int dcbnl_setpfcstate(struct net_device *netdev, struct nlmsghdr *nlh,
 {
 	u8 value;
 
-	if (!tb[DCB_ATTR_PFC_STATE] || !netdev->dcbnl_ops->setpfcstate)
+	if (!tb[DCB_ATTR_PFC_STATE])
 		return -EINVAL;
 
+	if (!netdev->dcbnl_ops->setpfcstate)
+		return -EOPNOTSUPP;
+
 	value = nla_get_u8(tb[DCB_ATTR_PFC_STATE]);
 
 	netdev->dcbnl_ops->setpfcstate(netdev, value);
@@ -449,27 +451,26 @@ static int dcbnl_getapp(struct net_device *netdev, struct nlmsghdr *nlh,
 	struct nlattr *app_tb[DCB_APP_ATTR_MAX + 1];
 	u16 id;
 	u8 up, idtype;
-	int ret = -EINVAL;
+	int ret;
 
 	if (!tb[DCB_ATTR_APP])
-		goto out;
+		return -EINVAL;
 
 	ret = nla_parse_nested(app_tb, DCB_APP_ATTR_MAX, tb[DCB_ATTR_APP],
 	                       dcbnl_app_nest);
 	if (ret)
-		goto out;
+		return ret;
 
-	ret = -EINVAL;
 	/* all must be non-null */
 	if ((!app_tb[DCB_APP_ATTR_IDTYPE]) ||
 	    (!app_tb[DCB_APP_ATTR_ID]))
-		goto out;
+		return -EINVAL;
 
 	/* either by eth type or by socket number */
 	idtype = nla_get_u8(app_tb[DCB_APP_ATTR_IDTYPE]);
 	if ((idtype != DCB_APP_IDTYPE_ETHTYPE) &&
 	    (idtype != DCB_APP_IDTYPE_PORTNUM))
-		goto out;
+		return -EINVAL;
 
 	id = nla_get_u16(app_tb[DCB_APP_ATTR_ID]);
 
@@ -485,7 +486,7 @@ static int dcbnl_getapp(struct net_device *netdev, struct nlmsghdr *nlh,
 
 	app_nest = nla_nest_start(skb, DCB_ATTR_APP);
 	if (!app_nest)
-		goto out;
+		return -EMSGSIZE;
 
 	ret = nla_put_u8(skb, DCB_APP_ATTR_IDTYPE, idtype);
 	if (ret)
@@ -501,59 +502,57 @@ static int dcbnl_getapp(struct net_device *netdev, struct nlmsghdr *nlh,
 
 	nla_nest_end(skb, app_nest);
 
-	goto out;
+	return 0;
 
 out_cancel:
 	nla_nest_cancel(skb, app_nest);
-out:
 	return ret;
 }
 
 static int dcbnl_setapp(struct net_device *netdev, struct nlmsghdr *nlh,
 			u32 seq, struct nlattr **tb, struct sk_buff *skb)
 {
-	int err, ret = -EINVAL;
+	int ret;
 	u16 id;
 	u8 up, idtype;
 	struct nlattr *app_tb[DCB_APP_ATTR_MAX + 1];
 
 	if (!tb[DCB_ATTR_APP])
-		goto out;
+		return -EINVAL;
 
 	ret = nla_parse_nested(app_tb, DCB_APP_ATTR_MAX, tb[DCB_ATTR_APP],
 	                       dcbnl_app_nest);
 	if (ret)
-		goto out;
+		return ret;
 
-	ret = -EINVAL;
 	/* all must be non-null */
 	if ((!app_tb[DCB_APP_ATTR_IDTYPE]) ||
 	    (!app_tb[DCB_APP_ATTR_ID]) ||
 	    (!app_tb[DCB_APP_ATTR_PRIORITY]))
-		goto out;
+		return -EINVAL;
 
 	/* either by eth type or by socket number */
 	idtype = nla_get_u8(app_tb[DCB_APP_ATTR_IDTYPE]);
 	if ((idtype != DCB_APP_IDTYPE_ETHTYPE) &&
 	    (idtype != DCB_APP_IDTYPE_PORTNUM))
-		goto out;
+		return -EINVAL;
 
 	id = nla_get_u16(app_tb[DCB_APP_ATTR_ID]);
 	up = nla_get_u8(app_tb[DCB_APP_ATTR_PRIORITY]);
 
 	if (netdev->dcbnl_ops->setapp) {
-		err = netdev->dcbnl_ops->setapp(netdev, idtype, id, up);
+		ret = netdev->dcbnl_ops->setapp(netdev, idtype, id, up);
 	} else {
 		struct dcb_app app;
 		app.selector = idtype;
 		app.protocol = id;
 		app.priority = up;
-		err = dcb_setapp(netdev, &app);
+		ret = dcb_setapp(netdev, &app);
 	}
 
 	ret = nla_put_u8(skb, DCB_ATTR_APP, ret);
 	dcbnl_cee_notify(netdev, RTM_SETDCB, DCB_CMD_SAPP, seq, 0);
-out:
+
 	return ret;
 }
 
@@ -564,26 +563,27 @@ static int __dcbnl_pg_getcfg(struct net_device *netdev, struct nlmsghdr *nlh,
 	struct nlattr *pg_tb[DCB_PG_ATTR_MAX + 1];
 	struct nlattr *param_tb[DCB_TC_ATTR_PARAM_MAX + 1];
 	u8 prio, pgid, tc_pct, up_map;
-	int ret  = -EINVAL;
+	int ret;
 	int getall = 0;
 	int i;
 
-	if (!tb[DCB_ATTR_PG_CFG] ||
-	    !netdev->dcbnl_ops->getpgtccfgtx ||
+	if (!tb[DCB_ATTR_PG_CFG])
+		return -EINVAL;
+
+	if (!netdev->dcbnl_ops->getpgtccfgtx ||
 	    !netdev->dcbnl_ops->getpgtccfgrx ||
 	    !netdev->dcbnl_ops->getpgbwgcfgtx ||
 	    !netdev->dcbnl_ops->getpgbwgcfgrx)
-		return ret;
+		return -EOPNOTSUPP;
 
 	ret = nla_parse_nested(pg_tb, DCB_PG_ATTR_MAX,
 	                       tb[DCB_ATTR_PG_CFG], dcbnl_pg_nest);
-
 	if (ret)
-		goto err_out;
+		return ret;
 
 	pg_nest = nla_nest_start(skb, DCB_ATTR_PG_CFG);
 	if (!pg_nest)
-		goto err_out;
+		return -EMSGSIZE;
 
 	if (pg_tb[DCB_PG_ATTR_TC_ALL])
 		getall = 1;
@@ -674,7 +674,6 @@ static int __dcbnl_pg_getcfg(struct net_device *netdev, struct nlmsghdr *nlh,
 					i - DCB_PG_ATTR_BW_ID_0, &tc_pct);
 		}
 		ret = nla_put_u8(skb, i, tc_pct);
-
 		if (ret)
 			goto err_pg;
 	}
@@ -687,9 +686,8 @@ err_param:
 	nla_nest_cancel(skb, param_nest);
 err_pg:
 	nla_nest_cancel(skb, pg_nest);
-err_out:
-	ret  = -EINVAL;
-	return ret;
+
+	return -EMSGSIZE;
 }
 
 static int dcbnl_pgtx_getcfg(struct net_device *netdev, struct nlmsghdr *nlh,
@@ -709,9 +707,12 @@ static int dcbnl_setstate(struct net_device *netdev, struct nlmsghdr *nlh,
 {
 	u8 value;
 
-	if (!tb[DCB_ATTR_STATE] || !netdev->dcbnl_ops->setstate)
+	if (!tb[DCB_ATTR_STATE])
 		return -EINVAL;
 
+	if (!netdev->dcbnl_ops->setstate)
+		return -EOPNOTSUPP;
+
 	value = nla_get_u8(tb[DCB_ATTR_STATE]);
 
 	return nla_put_u8(skb, DCB_ATTR_STATE,
@@ -723,17 +724,20 @@ static int dcbnl_setpfccfg(struct net_device *netdev, struct nlmsghdr *nlh,
 {
 	struct nlattr *data[DCB_PFC_UP_ATTR_MAX + 1];
 	int i;
-	int ret = -EINVAL;
+	int ret;
 	u8 value;
 
-	if (!tb[DCB_ATTR_PFC_CFG] || !netdev->dcbnl_ops->setpfccfg)
-		return ret;
+	if (!tb[DCB_ATTR_PFC_CFG])
+		return -EINVAL;
+
+	if (!netdev->dcbnl_ops->setpfccfg)
+		return -EOPNOTSUPP;
 
 	ret = nla_parse_nested(data, DCB_PFC_UP_ATTR_MAX,
 	                       tb[DCB_ATTR_PFC_CFG],
 	                       dcbnl_pfc_up_nest);
 	if (ret)
-		goto err;
+		return ret;
 
 	for (i = DCB_PFC_UP_ATTR_0; i <= DCB_PFC_UP_ATTR_7; i++) {
 		if (data[i] == NULL)
@@ -744,17 +748,18 @@ static int dcbnl_setpfccfg(struct net_device *netdev, struct nlmsghdr *nlh,
 	}
 
 	return nla_put_u8(skb, DCB_ATTR_PFC_CFG, 0);
-err:
-	return ret;
 }
 
 static int dcbnl_setall(struct net_device *netdev, struct nlmsghdr *nlh,
 			u32 seq, struct nlattr **tb, struct sk_buff *skb)
 {
-	int ret = -EINVAL;
+	int ret;
 
-	if (!tb[DCB_ATTR_SET_ALL] || !netdev->dcbnl_ops->setall)
-		return ret;
+	if (!tb[DCB_ATTR_SET_ALL])
+		return -EINVAL;
+
+	if (!netdev->dcbnl_ops->setall)
+		return -EOPNOTSUPP;
 
 	ret = nla_put_u8(skb, DCB_ATTR_SET_ALL,
 			 netdev->dcbnl_ops->setall(netdev));
@@ -769,24 +774,26 @@ static int __dcbnl_pg_setcfg(struct net_device *netdev, struct nlmsghdr *nlh,
 {
 	struct nlattr *pg_tb[DCB_PG_ATTR_MAX + 1];
 	struct nlattr *param_tb[DCB_TC_ATTR_PARAM_MAX + 1];
-	int ret = -EINVAL;
+	int ret;
 	int i;
 	u8 pgid;
 	u8 up_map;
 	u8 prio;
 	u8 tc_pct;
 
-	if (!tb[DCB_ATTR_PG_CFG] ||
-	    !netdev->dcbnl_ops->setpgtccfgtx ||
+	if (!tb[DCB_ATTR_PG_CFG])
+		return -EINVAL;
+
+	if (!netdev->dcbnl_ops->setpgtccfgtx ||
 	    !netdev->dcbnl_ops->setpgtccfgrx ||
 	    !netdev->dcbnl_ops->setpgbwgcfgtx ||
 	    !netdev->dcbnl_ops->setpgbwgcfgrx)
-		return ret;
+		return -EOPNOTSUPP;
 
 	ret = nla_parse_nested(pg_tb, DCB_PG_ATTR_MAX,
 	                       tb[DCB_ATTR_PG_CFG], dcbnl_pg_nest);
 	if (ret)
-		goto err;
+		return ret;
 
 	for (i = DCB_PG_ATTR_TC_0; i <= DCB_PG_ATTR_TC_7; i++) {
 		if (!pg_tb[i])
@@ -795,7 +802,7 @@ static int __dcbnl_pg_setcfg(struct net_device *netdev, struct nlmsghdr *nlh,
 		ret = nla_parse_nested(param_tb, DCB_TC_ATTR_PARAM_MAX,
 		                       pg_tb[i], dcbnl_tc_param_nest);
 		if (ret)
-			goto err;
+			return ret;
 
 		pgid = DCB_ATTR_VALUE_UNDEFINED;
 		prio = DCB_ATTR_VALUE_UNDEFINED;
@@ -848,10 +855,8 @@ static int __dcbnl_pg_setcfg(struct net_device *netdev, struct nlmsghdr *nlh,
 		}
 	}
 
-	ret = nla_put_u8(skb, (dir ? DCB_CMD_PGRX_SCFG : DCB_CMD_PGTX_SCFG), 0);
-
-err:
-	return ret;
+	return nla_put_u8(skb,
+			  (dir ? DCB_CMD_PGRX_SCFG : DCB_CMD_PGTX_SCFG), 0);
 }
 
 static int dcbnl_pgtx_setcfg(struct net_device *netdev, struct nlmsghdr *nlh,
@@ -873,23 +878,25 @@ static int dcbnl_bcn_getcfg(struct net_device *netdev, struct nlmsghdr *nlh,
 	struct nlattr *bcn_tb[DCB_BCN_ATTR_MAX + 1];
 	u8 value_byte;
 	u32 value_integer;
-	int ret  = -EINVAL;
+	int ret;
 	bool getall = false;
 	int i;
 
-	if (!tb[DCB_ATTR_BCN] || !netdev->dcbnl_ops->getbcnrp ||
+	if (!tb[DCB_ATTR_BCN])
+		return -EINVAL;
+
+	if (!netdev->dcbnl_ops->getbcnrp ||
 	    !netdev->dcbnl_ops->getbcncfg)
-		return ret;
+		return -EOPNOTSUPP;
 
 	ret = nla_parse_nested(bcn_tb, DCB_BCN_ATTR_MAX,
 	                       tb[DCB_ATTR_BCN], dcbnl_bcn_nest);
-
 	if (ret)
-		goto err_out;
+		return ret;
 
 	bcn_nest = nla_nest_start(skb, DCB_ATTR_BCN);
 	if (!bcn_nest)
-		goto err_out;
+		return -EMSGSIZE;
 
 	if (bcn_tb[DCB_BCN_ATTR_ALL])
 		getall = true;
@@ -922,8 +929,6 @@ static int dcbnl_bcn_getcfg(struct net_device *netdev, struct nlmsghdr *nlh,
 
 err_bcn:
 	nla_nest_cancel(skb, bcn_nest);
-err_out:
-	ret  = -EINVAL;
 	return ret;
 }
 
@@ -932,19 +937,22 @@ static int dcbnl_bcn_setcfg(struct net_device *netdev, struct nlmsghdr *nlh,
 {
 	struct nlattr *data[DCB_BCN_ATTR_MAX + 1];
 	int i;
-	int ret = -EINVAL;
+	int ret;
 	u8 value_byte;
 	u32 value_int;
 
-	if (!tb[DCB_ATTR_BCN] || !netdev->dcbnl_ops->setbcncfg ||
+	if (!tb[DCB_ATTR_BCN])
+		return -EINVAL;
+
+	if (!netdev->dcbnl_ops->setbcncfg ||
 	    !netdev->dcbnl_ops->setbcnrp)
-		return ret;
+		return -EOPNOTSUPP;
 
 	ret = nla_parse_nested(data, DCB_BCN_ATTR_MAX,
 	                       tb[DCB_ATTR_BCN],
 	                       dcbnl_pfc_up_nest);
 	if (ret)
-		goto err;
+		return ret;
 
 	for (i = DCB_BCN_ATTR_RP_0; i <= DCB_BCN_ATTR_RP_7; i++) {
 		if (data[i] == NULL)
@@ -962,9 +970,7 @@ static int dcbnl_bcn_setcfg(struct net_device *netdev, struct nlmsghdr *nlh,
 	                                     i, value_int);
 	}
 
-	ret = nla_put_u8(skb, DCB_ATTR_BCN, 0);
-err:
-	return ret;
+	return nla_put_u8(skb, DCB_ATTR_BCN, 0);
 }
 
 static int dcbnl_build_peer_app(struct net_device *netdev, struct sk_buff* skb,
@@ -1030,20 +1036,21 @@ static int dcbnl_ieee_fill(struct sk_buff *skb, struct net_device *netdev)
 	struct dcb_app_type *itr;
 	const struct dcbnl_rtnl_ops *ops = netdev->dcbnl_ops;
 	int dcbx;
-	int err = -EMSGSIZE;
+	int err;
 
 	if (nla_put_string(skb, DCB_ATTR_IFNAME, netdev->name))
-		goto nla_put_failure;
+		return -EMSGSIZE;
+
 	ieee = nla_nest_start(skb, DCB_ATTR_IEEE);
 	if (!ieee)
-		goto nla_put_failure;
+		return -EMSGSIZE;
 
 	if (ops->ieee_getets) {
 		struct ieee_ets ets;
 		err = ops->ieee_getets(netdev, &ets);
 		if (!err &&
 		    nla_put(skb, DCB_ATTR_IEEE_ETS, sizeof(ets), &ets))
-			goto nla_put_failure;
+			return -EMSGSIZE;
 	}
 
 	if (ops->ieee_getmaxrate) {
@@ -1053,7 +1060,7 @@ static int dcbnl_ieee_fill(struct sk_buff *skb, struct net_device *netdev)
 			err = nla_put(skb, DCB_ATTR_IEEE_MAXRATE,
 				      sizeof(maxrate), &maxrate);
 			if (err)
-				goto nla_put_failure;
+				return -EMSGSIZE;
 		}
 	}
 
@@ -1062,12 +1069,12 @@ static int dcbnl_ieee_fill(struct sk_buff *skb, struct net_device *netdev)
 		err = ops->ieee_getpfc(netdev, &pfc);
 		if (!err &&
 		    nla_put(skb, DCB_ATTR_IEEE_PFC, sizeof(pfc), &pfc))
-			goto nla_put_failure;
+			return -EMSGSIZE;
 	}
 
 	app = nla_nest_start(skb, DCB_ATTR_IEEE_APP_TABLE);
 	if (!app)
-		goto nla_put_failure;
+		return -EMSGSIZE;
 
 	spin_lock(&dcb_lock);
 	list_for_each_entry(itr, &dcb_app_list, list) {
@@ -1076,7 +1083,7 @@ static int dcbnl_ieee_fill(struct sk_buff *skb, struct net_device *netdev)
 					 &itr->app);
 			if (err) {
 				spin_unlock(&dcb_lock);
-				goto nla_put_failure;
+				return -EMSGSIZE;
 			}
 		}
 	}
@@ -1095,7 +1102,7 @@ static int dcbnl_ieee_fill(struct sk_buff *skb, struct net_device *netdev)
 		err = ops->ieee_peer_getets(netdev, &ets);
 		if (!err &&
 		    nla_put(skb, DCB_ATTR_IEEE_PEER_ETS, sizeof(ets), &ets))
-			goto nla_put_failure;
+			return -EMSGSIZE;
 	}
 
 	if (ops->ieee_peer_getpfc) {
@@ -1103,7 +1110,7 @@ static int dcbnl_ieee_fill(struct sk_buff *skb, struct net_device *netdev)
 		err = ops->ieee_peer_getpfc(netdev, &pfc);
 		if (!err &&
 		    nla_put(skb, DCB_ATTR_IEEE_PEER_PFC, sizeof(pfc), &pfc))
-			goto nla_put_failure;
+			return -EMSGSIZE;
 	}
 
 	if (ops->peer_getappinfo && ops->peer_getapptable) {
@@ -1112,20 +1119,17 @@ static int dcbnl_ieee_fill(struct sk_buff *skb, struct net_device *netdev)
 					   DCB_ATTR_IEEE_APP_UNSPEC,
 					   DCB_ATTR_IEEE_APP);
 		if (err)
-			goto nla_put_failure;
+			return -EMSGSIZE;
 	}
 
 	nla_nest_end(skb, ieee);
 	if (dcbx >= 0) {
 		err = nla_put_u8(skb, DCB_ATTR_DCBX, dcbx);
 		if (err)
-			goto nla_put_failure;
+			return -EMSGSIZE;
 	}
 
 	return 0;
-
-nla_put_failure:
-	return err;
 }
 
 static int dcbnl_cee_pg_fill(struct sk_buff *skb, struct net_device *dev,
@@ -1137,13 +1141,13 @@ static int dcbnl_cee_pg_fill(struct sk_buff *skb, struct net_device *dev,
 	struct nlattr *pg = nla_nest_start(skb, i);
 
 	if (!pg)
-		goto nla_put_failure;
+		return -EMSGSIZE;
 
 	for (i = DCB_PG_ATTR_TC_0; i <= DCB_PG_ATTR_TC_7; i++) {
 		struct nlattr *tc_nest = nla_nest_start(skb, i);
 
 		if (!tc_nest)
-			goto nla_put_failure;
+			return -EMSGSIZE;
 
 		pgid = DCB_ATTR_VALUE_UNDEFINED;
 		prio = DCB_ATTR_VALUE_UNDEFINED;
@@ -1161,7 +1165,7 @@ static int dcbnl_cee_pg_fill(struct sk_buff *skb, struct net_device *dev,
 		    nla_put_u8(skb, DCB_TC_ATTR_PARAM_UP_MAPPING, up_map) ||
 		    nla_put_u8(skb, DCB_TC_ATTR_PARAM_STRICT_PRIO, prio) ||
 		    nla_put_u8(skb, DCB_TC_ATTR_PARAM_BW_PCT, tc_pct))
-			goto nla_put_failure;
+			return -EMSGSIZE;
 		nla_nest_end(skb, tc_nest);
 	}
 
@@ -1175,13 +1179,10 @@ static int dcbnl_cee_pg_fill(struct sk_buff *skb, struct net_device *dev,
 			ops->getpgbwgcfgtx(dev, i - DCB_PG_ATTR_BW_ID_0,
 					   &tc_pct);
 		if (nla_put_u8(skb, i, tc_pct))
-			goto nla_put_failure;
+			return -EMSGSIZE;
 	}
 	nla_nest_end(skb, pg);
 	return 0;
-
-nla_put_failure:
-	return -EMSGSIZE;
 }
 
 static int dcbnl_cee_fill(struct sk_buff *skb, struct net_device *netdev)
@@ -1380,10 +1381,10 @@ static int dcbnl_ieee_set(struct net_device *netdev, struct nlmsghdr *nlh,
 {
 	const struct dcbnl_rtnl_ops *ops = netdev->dcbnl_ops;
 	struct nlattr *ieee[DCB_ATTR_IEEE_MAX + 1];
-	int err = -EOPNOTSUPP;
+	int err;
 
 	if (!ops)
-		return err;
+		return -EOPNOTSUPP;
 
 	if (!tb[DCB_ATTR_IEEE])
 		return -EINVAL;
@@ -1455,7 +1456,7 @@ static int dcbnl_ieee_del(struct net_device *netdev, struct nlmsghdr *nlh,
 {
 	const struct dcbnl_rtnl_ops *ops = netdev->dcbnl_ops;
 	struct nlattr *ieee[DCB_ATTR_IEEE_MAX + 1];
-	int err = -EOPNOTSUPP;
+	int err;
 
 	if (!ops)
 		return -EOPNOTSUPP;
@@ -1687,10 +1688,12 @@ static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 
 	netdev = dev_get_by_name(&init_net, nla_data(tb[DCB_ATTR_IFNAME]));
 	if (!netdev)
-		return -EINVAL;
+		return -ENODEV;
 
-	if (!netdev->dcbnl_ops)
-		goto errout;
+	if (!netdev->dcbnl_ops) {
+		ret = -EOPNOTSUPP;
+		goto out;
+	}
 
 	reply_skb = dcbnl_newmsg(fn->type, dcb->cmd, pid, nlh->nlmsg_seq,
 				 nlh->nlmsg_flags, &reply_nlh);
-- 
1.7.7.6
