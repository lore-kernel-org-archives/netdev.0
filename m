From: "Ilya V. Matveychikov" <matvejchikov@gmail.com>
Subject: [RFC PATCH] veth: keep peers MTU values synchronized
Date: Fri, 04 Apr 2014 01:33:04 +0400
Message-ID: <533DD390.6020103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: i.matveychikov@securitycode.ru
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:57075 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753799AbaDCVdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 17:33:08 -0400
Received: by mail-lb0-f176.google.com with SMTP id 10so1777523lbg.7
        for <netdev@vger.kernel.org>; Thu, 03 Apr 2014 14:33:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Keep peers MTU values synchronized. That prevent dropping packets while
forwarding as diffirent MTU values prevent skb moving from one peer's 
device to another (is_skb_forwardable returns false).

Signed-off-by: Ilya V. Matveychikov <i.matveychikov@securitycode.ru>
---
  drivers/net/veth.c | 16 +++++++++++++++-
  1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index c0e7c64..a975226 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -227,10 +227,24 @@ static int is_valid_veth_mtu(int new_mtu)

  static int veth_change_mtu(struct net_device *dev, int new_mtu)
  {
+	int err, old_mtu;
+	struct veth_priv *priv = netdev_priv(dev);
+	struct net_device *peer = rtnl_dereference(priv->peer);
+
+	if (!peer)
+		return -ENOTCONN;
+
  	if (!is_valid_veth_mtu(new_mtu))
  		return -EINVAL;
+
+	old_mtu = dev->mtu;
  	dev->mtu = new_mtu;
-	return 0;
+
+	err = dev_set_mtu(peer, new_mtu);
+	if (err)
+		dev->mtu = old_mtu;
+
+	return err;
  }

  static int veth_dev_init(struct net_device *dev)
-- 
1.8.1.2
