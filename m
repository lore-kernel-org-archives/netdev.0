From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 4/7] dcb: validate netlink attribute link
Date: Tue, 10 Jan 2017 10:18:13 -0800
Message-ID: <20170110181816.18991-5-sthemmin@microsoft.com>
References: <20170110181816.18991-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:34956 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S939984AbdAJSS3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 13:18:29 -0500
Received: by mail-pf0-f172.google.com with SMTP id f144so41277774pfa.2
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 10:18:29 -0800 (PST)
In-Reply-To: <20170110181816.18991-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dcb netlink code was not validating that the IEEE_APP netlink
element was correctly formed.  Initially discovered because of the
warning ‘dcbnl_ieee_app’ defined but not used.
This indicated that the message was not being fully validated.

Compile tested only. Do not have DCB setup.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 net/dcb/dcbnl.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 3202d75329b5..52f0f2fc0a51 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -178,10 +178,6 @@ static const struct nla_policy dcbnl_ieee_policy[DCB_ATTR_IEEE_MAX + 1] = {
 	[DCB_ATTR_IEEE_QCN_STATS]   = {.len = sizeof(struct ieee_qcn_stats)},
 };
 
-static const struct nla_policy dcbnl_ieee_app[DCB_ATTR_IEEE_APP_MAX + 1] = {
-	[DCB_ATTR_IEEE_APP]	    = {.len = sizeof(struct dcb_app)},
-};
-
 /* DCB number of traffic classes nested attributes. */
 static const struct nla_policy dcbnl_featcfg_nest[DCB_FEATCFG_ATTR_MAX + 1] = {
 	[DCB_FEATCFG_ATTR_ALL]      = {.type = NLA_FLAG},
@@ -1466,8 +1462,15 @@ static int dcbnl_ieee_set(struct net_device *netdev, struct nlmsghdr *nlh,
 
 		nla_for_each_nested(attr, ieee[DCB_ATTR_IEEE_APP_TABLE], rem) {
 			struct dcb_app *app_data;
+
 			if (nla_type(attr) != DCB_ATTR_IEEE_APP)
 				continue;
+
+			if (nla_len(attr) != sizeof(struct dcb_app)) {
+				err = -ERANGE;
+				goto err;
+			}
+
 			app_data = nla_data(attr);
 			if (ops->ieee_setapp)
 				err = ops->ieee_setapp(netdev, app_data);
-- 
2.11.0
