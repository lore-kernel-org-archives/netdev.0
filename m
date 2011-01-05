From: Dan Carpenter <error27@gmail.com>
Subject: [patch 1/2] dcb: unlock on error in dcbnl_ieee_get()
Date: Wed, 5 Jan 2011 10:03:12 +0300
Message-ID: <20110105070312.GA24847@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Shmulik Ravid <shmulikr@broadcom.com>,
	"David S. Miller" <davem@davemloft.net>,
	kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:47802 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751298Ab1AEHDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 02:03:35 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a "goto nla_put_failure" hidden inside the NLA_PUT() macro, but
we're holding the dcb_lock so we need to unlock first.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index ff3c12d..8881cb5 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1264,9 +1264,14 @@ static int dcbnl_ieee_get(struct net_device *netdev, struct nlattr **tb,
 
 	spin_lock(&dcb_lock);
 	list_for_each_entry(itr, &dcb_app_list, list) {
-		if (strncmp(itr->name, netdev->name, IFNAMSIZ) == 0)
-			NLA_PUT(skb, DCB_ATTR_IEEE_APP,
-				sizeof(itr->app), &itr->app);
+		if (strncmp(itr->name, netdev->name, IFNAMSIZ) == 0) {
+			err = nla_put(skb, DCB_ATTR_IEEE_APP, sizeof(itr->app),
+					 &itr->app);
+			if (err) {
+				spin_unlock(&dcb_lock);
+				goto nla_put_failure;
+			}
+		}
 	}
 	spin_unlock(&dcb_lock);
 	nla_nest_end(skb, app);
