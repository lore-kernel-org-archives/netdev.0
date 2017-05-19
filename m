From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 1/9] dcb: enforce minimum length on IEEE_APPS attribute
Date: Fri, 19 May 2017 09:55:48 -0700
Message-ID: <20170519165556.483-2-sthemmin@microsoft.com>
References: <20170519165556.483-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35846 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752999AbdESQ4G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 12:56:06 -0400
Received: by mail-pf0-f171.google.com with SMTP id m17so42448457pfg.3
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 09:56:05 -0700 (PDT)
In-Reply-To: <20170519165556.483-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Found by reviewing the warning about unused policy table.
The code implies that it meant to check for size, but since
it unrolled the loop for attribute validation that is never used.
Instead do explicit check for attribute.

Compile tested only. Needs review by original author.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 net/dcb/dcbnl.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 93106120f987..733f523707ac 100644
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
@@ -1463,8 +1459,15 @@ static int dcbnl_ieee_set(struct net_device *netdev, struct nlmsghdr *nlh,
 
 		nla_for_each_nested(attr, ieee[DCB_ATTR_IEEE_APP_TABLE], rem) {
 			struct dcb_app *app_data;
+
 			if (nla_type(attr) != DCB_ATTR_IEEE_APP)
 				continue;
+
+			if (nla_len(attr) < sizeof(struct dcb_app)) {
+				err = -ERANGE;
+				goto err;
+			}
+
 			app_data = nla_data(attr);
 			if (ops->ieee_setapp)
 				err = ops->ieee_setapp(netdev, app_data);
-- 
2.11.0
