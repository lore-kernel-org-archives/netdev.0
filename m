From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next V6 02/15] macvlan: add link to upper device
Date: Fri,  4 Jan 2013 09:48:50 +0100
Message-ID: <1357289343-817-3-git-send-email-jiri@resnulli.us>
References: <1357289343-817-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, faisal.latif@intel.com,
	roland@kernel.org, sean.hefty@intel.com, hal.rosenstock@gmail.com,
	fubar@us.ibm.com, andy@greyhouse.net, divy@chelsio.com,
	jitendra.kalsaria@qlogic.com, sony.chacko@qlogic.com,
	linux-driver@qlogic.com, kaber@trash.net, ursula.braun@de.ibm.com,
	blaschka@linux.vnet.ibm.com, linux390@de.ibm.com,
	shemminger@vyatta.com, bhutchings@solarflare.com,
	therbert@google.com, xiyou.wangcong@gmail.com, joe@perches.com,
	gregory.v.rose@intel.com, john.r.fastabend@intel.com,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-s390@vger.kernel.org, bridge@lists.linux-foundation.org,
	fbl@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:60952 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753994Ab3ADItU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 03:49:20 -0500
Received: by mail-ea0-f179.google.com with SMTP id i12so6512289eaa.10
        for <netdev@vger.kernel.org>; Fri, 04 Jan 2013 00:49:19 -0800 (PST)
In-Reply-To: <1357289343-817-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/macvlan.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 68a43fe..b7b614f 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -765,16 +765,22 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 		memcpy(dev->dev_addr, lowerdev->dev_addr, ETH_ALEN);
 	}
 
+	err = netdev_upper_dev_link(lowerdev, dev);
+	if (err)
+		goto destroy_port;
+
 	port->count += 1;
 	err = register_netdevice(dev);
 	if (err < 0)
-		goto destroy_port;
+		goto upper_dev_unlink;
 
 	list_add_tail(&vlan->list, &port->vlans);
 	netif_stacked_transfer_operstate(lowerdev, dev);
 
 	return 0;
 
+upper_dev_unlink:
+	netdev_upper_dev_unlink(lowerdev, dev);
 destroy_port:
 	port->count -= 1;
 	if (!port->count)
@@ -798,6 +804,7 @@ void macvlan_dellink(struct net_device *dev, struct list_head *head)
 
 	list_del(&vlan->list);
 	unregister_netdevice_queue(dev, head);
+	netdev_upper_dev_unlink(vlan->lowerdev, dev);
 }
 EXPORT_SYMBOL_GPL(macvlan_dellink);
 
-- 
1.8.0
