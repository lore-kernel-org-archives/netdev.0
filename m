From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-2.6 PATCH 2/2] dcbnl: make get_app handling symmetric for IEEE
	and CEE DCBx
Date: Fri, 21 Jan 2011 18:35:18 -0800
Message-ID: <20110122023518.4239.3464.stgit@jf-dev1-dcblab>
References: <20110122023512.4239.40379.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, shmulikr@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:54264 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753900Ab1AVCkB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jan 2011 21:40:01 -0500
In-Reply-To: <20110122023512.4239.40379.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The IEEE get/set app handlers use generic routines and do not
require the net_device to implement the dcbnl_ops routines. This
patch makes it symmetric so user space and drivers do not have
to handle the CEE version and IEEE DCBx versions differently.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 net/dcb/dcbnl.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index d900ab9..6b03f56 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -583,7 +583,7 @@ static int dcbnl_getapp(struct net_device *netdev, struct nlattr **tb,
 	u8 up, idtype;
 	int ret = -EINVAL;
 
-	if (!tb[DCB_ATTR_APP] || !netdev->dcbnl_ops->getapp)
+	if (!tb[DCB_ATTR_APP])
 		goto out;
 
 	ret = nla_parse_nested(app_tb, DCB_APP_ATTR_MAX, tb[DCB_ATTR_APP],
@@ -604,7 +604,16 @@ static int dcbnl_getapp(struct net_device *netdev, struct nlattr **tb,
 		goto out;
 
 	id = nla_get_u16(app_tb[DCB_APP_ATTR_ID]);
-	up = netdev->dcbnl_ops->getapp(netdev, idtype, id);
+
+	if (netdev->dcbnl_ops->getapp) {
+		up = netdev->dcbnl_ops->getapp(netdev, idtype, id);
+	} else {
+		struct dcb_app app = {
+					.selector = idtype,
+					.protocol = id,
+				     };
+		up = dcb_getapp(netdev, &app);
+	}
 
 	/* send this back */
 	dcbnl_skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);

