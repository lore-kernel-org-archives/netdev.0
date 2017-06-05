From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net] net: bridge: fix a null pointer dereference in br_afspec
Date: Tue,  6 Jun 2017 01:26:24 +0300
Message-ID: <1496701584-26855-1-git-send-email-nikolay@cumulusnetworks.com>
References: <840022de-3d31-4f62-aaaf-ba83d5c78ad7@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
        stephen@networkplumber.org, garsilva@embeddedor.com,
        bridge@lists.linux-foundation.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f172.google.com ([209.85.128.172]:35069 "EHLO
        mail-wr0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751180AbdFEW0k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 18:26:40 -0400
Received: by mail-wr0-f172.google.com with SMTP id q97so45335938wrb.2
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 15:26:40 -0700 (PDT)
In-Reply-To: <840022de-3d31-4f62-aaaf-ba83d5c78ad7@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We might call br_afspec() with p == NULL which is a valid use case if
the action is on the bridge device itself, but the bridge tunnel code
dereferences the p pointer without checking, so check if p is null
first.

Reported-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
Fixes: efa5356b0d97 ("bridge: per vlan dst_metadata netlink support")
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_netlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 1e63ec466d7c..3bcda556971e 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -595,7 +595,7 @@ static int br_afspec(struct net_bridge *br,
 		err = 0;
 		switch (nla_type(attr)) {
 		case IFLA_BRIDGE_VLAN_TUNNEL_INFO:
-			if (!(p->flags & BR_VLAN_TUNNEL))
+			if (!p || !(p->flags & BR_VLAN_TUNNEL))
 				return -EINVAL;
 			err = br_parse_vlan_tunnel_info(attr, &tinfo_curr);
 			if (err)
-- 
2.1.4
