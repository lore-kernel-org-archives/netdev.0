From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 6/6] vxlan: advertise netns of vxlan dev in fdb msg
Date: Tue, 20 Jan 2015 15:15:47 +0100
Message-ID: <1421763347-4354-7-git-send-email-nicolas.dichtel@6wind.com>
References: <1421763347-4354-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:53815 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752189AbbATOP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 09:15:58 -0500
In-Reply-To: <1421763347-4354-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Netlink FDB messages are sent in the link netns. The header of these messages
contains the ifindex (ndm_ifindex) of the netdevice, but this ifindex is
unusable in case of x-netns vxlan.
I named the new attribute NDA_NDM_IFINDEX_NETNSID, to avoid confusion with
NDA_IFINDEX.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 drivers/net/vxlan.c            | 5 +++++
 include/uapi/linux/neighbour.h | 1 +
 net/core/net_namespace.c       | 1 +
 3 files changed, 7 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 0346eaa6d236..19d3664ab9dd 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -339,6 +339,11 @@ static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
 	ndm->ndm_flags = fdb->flags;
 	ndm->ndm_type = RTN_UNICAST;
 
+	if (!net_eq(dev_net(vxlan->dev), vxlan->net) &&
+	    nla_put_s32(skb, NDA_NDM_IFINDEX_NETNSID,
+			peernet2id(vxlan->net, dev_net(vxlan->dev))))
+		goto nla_put_failure;
+
 	if (send_eth && nla_put(skb, NDA_LLADDR, ETH_ALEN, &fdb->eth_addr))
 		goto nla_put_failure;
 
diff --git a/include/uapi/linux/neighbour.h b/include/uapi/linux/neighbour.h
index f3d77f9f1e0b..38f236853cc0 100644
--- a/include/uapi/linux/neighbour.h
+++ b/include/uapi/linux/neighbour.h
@@ -25,6 +25,7 @@ enum {
 	NDA_VNI,
 	NDA_IFINDEX,
 	NDA_MASTER,
+	NDA_NDM_IFINDEX_NETNSID,
 	__NDA_MAX
 };
 
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 9d1a4cac83b6..b7bde551ef76 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -202,6 +202,7 @@ int peernet2id(struct net *net, struct net *peer)
 
 	return id >= 0 ? id : NETNSA_NSID_NOT_ASSIGNED;
 }
+EXPORT_SYMBOL(peernet2id);
 
 struct net *get_net_ns_by_id(struct net *net, int id)
 {
-- 
2.2.2
