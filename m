From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 1/2] vxlan: call peernet2id() in fdb notification
Date: Thu,  1 Sep 2016 21:53:44 -0700
Message-ID: <1472792025-14702-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1472792025-14702-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:35712 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751098AbcIBEyy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 00:54:54 -0400
Received: by mail-pa0-f67.google.com with SMTP id cf3so5070133pad.2
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 21:53:56 -0700 (PDT)
In-Reply-To: <1472792025-14702-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netns id should be already allocated each time we change
netns, that is, in dev_change_net_namespace() (more precisely
in rtnl_fill_ifinfo()). It is safe to just call peernet2id() here.

Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 drivers/net/vxlan.c      | 2 +-
 net/core/net_namespace.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index f605a36..9735059 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -287,7 +287,7 @@ static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
 
 	if (!net_eq(dev_net(vxlan->dev), vxlan->net) &&
 	    nla_put_s32(skb, NDA_LINK_NETNSID,
-			peernet2id_alloc(dev_net(vxlan->dev), vxlan->net)))
+			peernet2id(dev_net(vxlan->dev), vxlan->net)))
 		goto nla_put_failure;
 
 	if (send_eth && nla_put(skb, NDA_LLADDR, ETH_ALEN, &fdb->eth_addr))
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 7a77dca..f3fa435 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -227,7 +227,6 @@ int peernet2id_alloc(struct net *net, struct net *peer)
 		rtnl_net_notifyid(net, RTM_NEWNSID, id);
 	return id;
 }
-EXPORT_SYMBOL(peernet2id_alloc);
 
 /* This function returns, if assigned, the id of a peer netns. */
 int peernet2id(struct net *net, struct net *peer)
@@ -240,6 +239,7 @@ int peernet2id(struct net *net, struct net *peer)
 	spin_unlock_irqrestore(&net->nsid_lock, flags);
 	return id;
 }
+EXPORT_SYMBOL(peernet2id);
 
 /* This function returns true is the peer netns has an id assigned into the
  * current netns.
-- 
2.1.0
