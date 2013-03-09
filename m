From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 3/3] dcbnl: fix various netlink info leaks
Date: Sat,  9 Mar 2013 16:52:21 +0100
Message-ID: <1362844341-12591-4-git-send-email-minipli@googlemail.com>
References: <1362844341-12591-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f44.google.com ([209.85.214.44]:42624 "EHLO
	mail-bk0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932429Ab3CIPwq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Mar 2013 10:52:46 -0500
Received: by mail-bk0-f44.google.com with SMTP id j4so1146301bkw.31
        for <netdev@vger.kernel.org>; Sat, 09 Mar 2013 07:52:44 -0800 (PST)
In-Reply-To: <1362844341-12591-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dcb netlink interface leaks stack memory in various places:
* perm_addr[] buffer is only filled at max with 12 of the 32 bytes but
  copied completely,
* no in-kernel driver fills all fields of an IEEE 802.1Qaz subcommand,
  so we're leaking up to 58 bytes for ieee_ets structs, up to 136 bytes
  for ieee_pfc structs, etc.,
* the same is true for CEE -- no in-kernel driver fills the whole
  struct,

Prevent all of the above stack info leaks by properly initializing the
buffers/structures involved.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/dcb/dcbnl.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 1b588e2..21291f1 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -284,6 +284,7 @@ static int dcbnl_getperm_hwaddr(struct net_device *netdev, struct nlmsghdr *nlh,
 	if (!netdev->dcbnl_ops->getpermhwaddr)
 		return -EOPNOTSUPP;
 
+	memset(perm_addr, 0, sizeof(perm_addr));
 	netdev->dcbnl_ops->getpermhwaddr(netdev, perm_addr);
 
 	return nla_put(skb, DCB_ATTR_PERM_HWADDR, sizeof(perm_addr), perm_addr);
@@ -1042,6 +1043,7 @@ static int dcbnl_ieee_fill(struct sk_buff *skb, struct net_device *netdev)
 
 	if (ops->ieee_getets) {
 		struct ieee_ets ets;
+		memset(&ets, 0, sizeof(ets));
 		err = ops->ieee_getets(netdev, &ets);
 		if (!err &&
 		    nla_put(skb, DCB_ATTR_IEEE_ETS, sizeof(ets), &ets))
@@ -1050,6 +1052,7 @@ static int dcbnl_ieee_fill(struct sk_buff *skb, struct net_device *netdev)
 
 	if (ops->ieee_getmaxrate) {
 		struct ieee_maxrate maxrate;
+		memset(&maxrate, 0, sizeof(maxrate));
 		err = ops->ieee_getmaxrate(netdev, &maxrate);
 		if (!err) {
 			err = nla_put(skb, DCB_ATTR_IEEE_MAXRATE,
@@ -1061,6 +1064,7 @@ static int dcbnl_ieee_fill(struct sk_buff *skb, struct net_device *netdev)
 
 	if (ops->ieee_getpfc) {
 		struct ieee_pfc pfc;
+		memset(&pfc, 0, sizeof(pfc));
 		err = ops->ieee_getpfc(netdev, &pfc);
 		if (!err &&
 		    nla_put(skb, DCB_ATTR_IEEE_PFC, sizeof(pfc), &pfc))
@@ -1094,6 +1098,7 @@ static int dcbnl_ieee_fill(struct sk_buff *skb, struct net_device *netdev)
 	/* get peer info if available */
 	if (ops->ieee_peer_getets) {
 		struct ieee_ets ets;
+		memset(&ets, 0, sizeof(ets));
 		err = ops->ieee_peer_getets(netdev, &ets);
 		if (!err &&
 		    nla_put(skb, DCB_ATTR_IEEE_PEER_ETS, sizeof(ets), &ets))
@@ -1102,6 +1107,7 @@ static int dcbnl_ieee_fill(struct sk_buff *skb, struct net_device *netdev)
 
 	if (ops->ieee_peer_getpfc) {
 		struct ieee_pfc pfc;
+		memset(&pfc, 0, sizeof(pfc));
 		err = ops->ieee_peer_getpfc(netdev, &pfc);
 		if (!err &&
 		    nla_put(skb, DCB_ATTR_IEEE_PEER_PFC, sizeof(pfc), &pfc))
@@ -1280,6 +1286,7 @@ static int dcbnl_cee_fill(struct sk_buff *skb, struct net_device *netdev)
 	/* peer info if available */
 	if (ops->cee_peer_getpg) {
 		struct cee_pg pg;
+		memset(&pg, 0, sizeof(pg));
 		err = ops->cee_peer_getpg(netdev, &pg);
 		if (!err &&
 		    nla_put(skb, DCB_ATTR_CEE_PEER_PG, sizeof(pg), &pg))
@@ -1288,6 +1295,7 @@ static int dcbnl_cee_fill(struct sk_buff *skb, struct net_device *netdev)
 
 	if (ops->cee_peer_getpfc) {
 		struct cee_pfc pfc;
+		memset(&pfc, 0, sizeof(pfc));
 		err = ops->cee_peer_getpfc(netdev, &pfc);
 		if (!err &&
 		    nla_put(skb, DCB_ATTR_CEE_PEER_PFC, sizeof(pfc), &pfc))
-- 
1.7.10.4
