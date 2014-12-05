From: roopa@cumulusnetworks.com
Subject: [PATCH 2/3] bridge: offload bridge port attributes to switch asic if feature flag set
Date: Thu,  4 Dec 2014 18:26:40 -0800
Message-ID: <1417746401-8140-3-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	nhorman@tuxdriver.com, nicolas.dichtel@6wind.com,
	vyasevic@redhat.com, f.fainelli@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:38173 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932378AbaLEC0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 21:26:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This allows offloading to switch asic without having the user to set
any flag. And this is done in the bridge driver to rollback kernel settings
on hw offload failure if required in the future.

With this, it also makes sure a notification goes out only after the
attributes are set both in the kernel and hw.
---
 net/bridge/br_netlink.c |   27 ++++++++++++++++++++++++++-
 1 file changed, 26 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 9f5eb55..ce173f0 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -407,9 +407,21 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh)
 				afspec, RTM_SETLINK);
 	}
 
+	if ((dev->features & NETIF_F_HW_SWITCH_OFFLOAD) &&
+			dev->netdev_ops->ndo_bridge_setlink) {
+		int ret = dev->netdev_ops->ndo_bridge_setlink(dev, nlh);
+		if (ret && ret != -EOPNOTSUPP) {
+			/* XXX Fix this in the future to rollback
+			 * kernel settings and return error
+			 */
+			br_warn(p->br, "error offloading bridge attributes " 
+					"on port %u(%s)\n", (unsigned int) p->port_no,
+					p->dev->name);
+		}
+	}
+
 	if (err == 0)
 		br_ifinfo_notify(RTM_NEWLINK, p);
-
 out:
 	return err;
 }
@@ -433,6 +445,19 @@ int br_dellink(struct net_device *dev, struct nlmsghdr *nlh)
 	err = br_afspec((struct net_bridge *)netdev_priv(dev), p,
 			afspec, RTM_DELLINK);
 
+	if (dev->features & NETIF_F_HW_SWITCH_OFFLOAD
+			&& dev->netdev_ops->ndo_bridge_setlink) {
+		int ret = dev->netdev_ops->ndo_bridge_dellink(dev, nlh);
+		if (ret && ret != -EOPNOTSUPP) {
+			/* XXX Fix this in the future to rollback
+			 * kernel settings and return error
+			 */
+			br_warn(p->br, "error offloading bridge attributes " 
+					"on port %u(%s)\n", (unsigned int) p->port_no,
+					p->dev->name);
+		}
+	}
+
 	return err;
 }
 static int br_validate(struct nlattr *tb[], struct nlattr *data[])
-- 
1.7.10.4
