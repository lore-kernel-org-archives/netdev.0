From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 02/15] macvlan: add link to upper device
Date: Sat, 29 Dec 2012 11:38:29 +0100
Message-ID: <1356777522-19652-3-git-send-email-jiri@resnulli.us>
References: <1356777522-19652-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, faisal.latif@intel.com,
	shemminger@vyatta.com, fbl@redhat.com, roland@kernel.org,
	sean.hefty@intel.com, hal.rosenstock@gmail.com, fubar@us.ibm.com,
	andy@greyhouse.net, divy@chelsio.com, jitendra.kalsaria@qlogic.com,
	sony.chacko@qlogic.com, linux-driver@qlogic.com, kaber@trash.net,
	ursula.braun@de.ibm.com, blaschka@linux.vnet.ibm.com,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	ebiederm@xmission.com, joe@perches.com, amwang@redhat.com,
	nhorman@tuxdriver.com, john.r.fastabend@intel.com,
	pablo@netfilter.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:43423 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751321Ab2L2Ki4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2012 05:38:56 -0500
Received: by mail-ee0-f42.google.com with SMTP id c41so5417353eek.1
        for <netdev@vger.kernel.org>; Sat, 29 Dec 2012 02:38:55 -0800 (PST)
In-Reply-To: <1356777522-19652-1-git-send-email-jiri@resnulli.us>
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
