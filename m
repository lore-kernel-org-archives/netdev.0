From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 02/16] macvlan: add link to upper device
Date: Mon, 13 Aug 2012 17:27:01 +0200
Message-ID: <1344871635-1052-3-git-send-email-jiri@resnulli.us>
References: <1344871635-1052-1-git-send-email-jiri@resnulli.us>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344871635-1052-1-git-send-email-jiri@resnulli.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/macvlan.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 66a9bfe..f5bd8a2 100644
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
1.7.10.4
