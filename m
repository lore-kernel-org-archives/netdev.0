From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 4/8] dcbnl: Use dcbnl_newmsg() where possible
Date: Wed, 13 Jun 2012 14:54:57 +0200
Message-ID: <f0ecc91c2e315583a96909b8940f274068a4500d.1339591572.git.tgraf@suug.ch>
References: <cover.1339591572.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, lucy.liu@intel.com,
	john.r.fastabend@intel.com, alexander.h.duyck@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5616 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753308Ab2FMMzK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2012 08:55:10 -0400
In-Reply-To: <cover.1339591572.git.tgraf@suug.ch>
In-Reply-To: <cover.1339591572.git.tgraf@suug.ch>
References: <cover.1339591572.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/dcb/dcbnl.c |   16 ++--------------
 1 files changed, 2 insertions(+), 14 deletions(-)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 5ed7167..4d9e0ef 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1328,27 +1328,16 @@ static int dcbnl_notify(struct net_device *dev, int event, int cmd,
 	struct net *net = dev_net(dev);
 	struct sk_buff *skb;
 	struct nlmsghdr *nlh;
-	struct dcbmsg *dcb;
 	const struct dcbnl_rtnl_ops *ops = dev->dcbnl_ops;
 	int err;
 
 	if (!ops)
 		return -EOPNOTSUPP;
 
-	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	skb = dcbnl_newmsg(event, cmd, pid, seq, 0, &nlh);
 	if (!skb)
 		return -ENOBUFS;
 
-	nlh = nlmsg_put(skb, pid, 0, event, sizeof(*dcb), 0);
-	if (nlh == NULL) {
-		nlmsg_free(skb);
-		return -EMSGSIZE;
-	}
-
-	dcb = NLMSG_DATA(nlh);
-	dcb->dcb_family = AF_UNSPEC;
-	dcb->cmd = cmd;
-
 	if (dcbx_ver == DCB_CAP_DCBX_VER_IEEE)
 		err = dcbnl_ieee_fill(skb, dev);
 	else
@@ -1356,8 +1345,7 @@ static int dcbnl_notify(struct net_device *dev, int event, int cmd,
 
 	if (err < 0) {
 		/* Report error to broadcast listeners */
-		nlmsg_cancel(skb, nlh);
-		kfree_skb(skb);
+		nlmsg_free(skb);
 		rtnl_set_sk_err(net, RTNLGRP_DCB, err);
 	} else {
 		/* End nlmsg and notify broadcast listeners */
-- 
1.7.7.6
