From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH V4 7/8] net/dcb: Add an optional max rate attribute
Date: Thu, 29 Mar 2012 17:03:37 +0200
Message-ID: <1333033418-1669-8-git-send-email-amirv@mellanox.com>
References: <1333033418-1669-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@purestorage.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@dev.mellanox.co.il>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:37909 "HELO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1759463Ab2C2PED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2012 11:04:03 -0400
In-Reply-To: <1333033418-1669-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although not specified in 8021Qaz spec, it could be useful to enable drivers
setting a rate limit for an ETS TC.
This patch add this optional attribute to DCB netlink.
To use it, drivers should implement and register the callbacks ieee_setmaxrate
and ieee_getmaxrate.
Units are 64 bits long and in units of Kbps to enable it to be used both by
slow and very fast networks

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 include/linux/dcbnl.h |    5 +++++
 include/net/dcbnl.h   |    2 ++
 net/dcb/dcbnl.c       |   18 ++++++++++++++++++
 3 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/include/linux/dcbnl.h b/include/linux/dcbnl.h
index 65a2562..ec8e372 100644
--- a/include/linux/dcbnl.h
+++ b/include/linux/dcbnl.h
@@ -67,6 +67,10 @@ struct ieee_ets {
 	__u8	reco_prio_tc[IEEE_8021QAZ_MAX_TCS];
 };
 
+struct ieee_maxrate {
+	__u64	tc_maxrate[IEEE_8021QAZ_MAX_TCS];
+};
+
 /* This structure contains the IEEE 802.1Qaz PFC managed object
  *
  * @pfc_cap: Indicates the number of traffic classes on the local device
@@ -321,6 +325,7 @@ enum ieee_attrs {
 	DCB_ATTR_IEEE_PEER_ETS,
 	DCB_ATTR_IEEE_PEER_PFC,
 	DCB_ATTR_IEEE_PEER_APP,
+	DCB_ATTR_IEEE_MAXRATE,
 	__DCB_ATTR_IEEE_MAX
 };
 #define DCB_ATTR_IEEE_MAX (__DCB_ATTR_IEEE_MAX - 1)
diff --git a/include/net/dcbnl.h b/include/net/dcbnl.h
index f55c980..fc5d5dc 100644
--- a/include/net/dcbnl.h
+++ b/include/net/dcbnl.h
@@ -48,6 +48,8 @@ struct dcbnl_rtnl_ops {
 	/* IEEE 802.1Qaz std */
 	int (*ieee_getets) (struct net_device *, struct ieee_ets *);
 	int (*ieee_setets) (struct net_device *, struct ieee_ets *);
+	int (*ieee_getmaxrate) (struct net_device *, struct ieee_maxrate *);
+	int (*ieee_setmaxrate) (struct net_device *, struct ieee_maxrate *);
 	int (*ieee_getpfc) (struct net_device *, struct ieee_pfc *);
 	int (*ieee_setpfc) (struct net_device *, struct ieee_pfc *);
 	int (*ieee_getapp) (struct net_device *, struct dcb_app *);
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index d860530..77dbc1d 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -178,6 +178,8 @@ static const struct nla_policy dcbnl_ieee_policy[DCB_ATTR_IEEE_MAX + 1] = {
 	[DCB_ATTR_IEEE_ETS]	    = {.len = sizeof(struct ieee_ets)},
 	[DCB_ATTR_IEEE_PFC]	    = {.len = sizeof(struct ieee_pfc)},
 	[DCB_ATTR_IEEE_APP_TABLE]   = {.type = NLA_NESTED},
+	[DCB_ATTR_IEEE_MAXRATE]   = {.len = sizeof(struct ieee_maxrate)},
+
 };
 
 static const struct nla_policy dcbnl_ieee_app[DCB_ATTR_IEEE_APP_MAX + 1] = {
@@ -1243,6 +1245,14 @@ static int dcbnl_ieee_fill(struct sk_buff *skb, struct net_device *netdev)
 			NLA_PUT(skb, DCB_ATTR_IEEE_ETS, sizeof(ets), &ets);
 	}
 
+	if (ops->ieee_getmaxrate) {
+		struct ieee_maxrate maxrate;
+		err = ops->ieee_getmaxrate(netdev, &maxrate);
+		if (!err)
+			NLA_PUT(skb, DCB_ATTR_IEEE_MAXRATE, sizeof(maxrate),
+					&maxrate);
+	}
+
 	if (ops->ieee_getpfc) {
 		struct ieee_pfc pfc;
 		err = ops->ieee_getpfc(netdev, &pfc);
@@ -1589,6 +1599,14 @@ static int dcbnl_ieee_set(struct net_device *netdev, struct nlattr **tb,
 			goto err;
 	}
 
+	if (ieee[DCB_ATTR_IEEE_MAXRATE] && ops->ieee_setmaxrate) {
+		struct ieee_maxrate *maxrate =
+			nla_data(ieee[DCB_ATTR_IEEE_MAXRATE]);
+		err = ops->ieee_setmaxrate(netdev, maxrate);
+		if (err)
+			goto err;
+	}
+
 	if (ieee[DCB_ATTR_IEEE_PFC] && ops->ieee_setpfc) {
 		struct ieee_pfc *pfc = nla_data(ieee[DCB_ATTR_IEEE_PFC]);
 		err = ops->ieee_setpfc(netdev, pfc);
-- 
1.7.8.2
