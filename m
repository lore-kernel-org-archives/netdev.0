From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH] veth: Showing peer of veth type dev in ip link (kernel side)
Date: Fri,  4 Oct 2013 13:05:29 +0900
Message-ID: <1380859529-32351-1-git-send-email-yamato@redhat.com>
Cc: yamato@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17996 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750728Ab3JDEFg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Oct 2013 00:05:36 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r9445Zng016495
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 4 Oct 2013 00:05:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip link has ability to show extra information of net work device if
kernel provides sunh information. With this patch veth driver can
provide its peer ifindex information to ip command via netlink
interface.

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 drivers/net/veth.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index eee1f19..54187b9 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -434,6 +434,25 @@ static const struct nla_policy veth_policy[VETH_INFO_MAX + 1] = {
 	[VETH_INFO_PEER]	= { .len = sizeof(struct ifinfomsg) },
 };
 
+static size_t veth_get_size(const struct net_device *dev)
+{
+	return nla_total_size(sizeof(u64)) + /* VETH_INFO_PEER */
+		0;
+}
+
+static int veth_fill_info(struct sk_buff *skb, const struct net_device *dev)
+{
+	struct veth_priv *priv = netdev_priv(dev);
+	struct net_device *peer = rtnl_dereference(priv->peer);
+	u64 peer_ifindex;
+
+	peer_ifindex = peer ? peer->ifindex : 0;
+	if (nla_put_u64(skb, VETH_INFO_PEER, peer_ifindex))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
 static struct rtnl_link_ops veth_link_ops = {
 	.kind		= DRV_NAME,
 	.priv_size	= sizeof(struct veth_priv),
@@ -443,6 +462,8 @@ static struct rtnl_link_ops veth_link_ops = {
 	.dellink	= veth_dellink,
 	.policy		= veth_policy,
 	.maxtype	= VETH_INFO_MAX,
+	.get_size	= veth_get_size,
+	.fill_info	= veth_fill_info,
 };
 
 /*
-- 
1.8.3.1
