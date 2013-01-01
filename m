From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/7] rtnl: use dev_set_mac_address() instead of plain ndo_
Date: Tue,  1 Jan 2013 14:30:13 +0100
Message-ID: <1357047019-1037-2-git-send-email-jiri@resnulli.us>
References: <1357047019-1037-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	sassmann@redhat.com, kaber@trash.net, richard@nod.at
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:33552 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752239Ab3AANa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jan 2013 08:30:29 -0500
Received: by mail-ee0-f42.google.com with SMTP id c41so6382672eek.1
        for <netdev@vger.kernel.org>; Tue, 01 Jan 2013 05:30:27 -0800 (PST)
In-Reply-To: <1357047019-1037-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benefit from existence of dev_set_mac_address() and remove duplicate
code.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/core/rtnetlink.c | 20 ++------------------
 1 file changed, 2 insertions(+), 18 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 2ef7a56..78d05a9 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1310,7 +1310,6 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 		      struct nlattr **tb, char *ifname, int modified)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
-	int send_addr_notify = 0;
 	int err;
 
 	if (tb[IFLA_NET_NS_PID] || tb[IFLA_NET_NS_FD]) {
@@ -1363,16 +1362,6 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 		struct sockaddr *sa;
 		int len;
 
-		if (!ops->ndo_set_mac_address) {
-			err = -EOPNOTSUPP;
-			goto errout;
-		}
-
-		if (!netif_device_present(dev)) {
-			err = -ENODEV;
-			goto errout;
-		}
-
 		len = sizeof(sa_family_t) + dev->addr_len;
 		sa = kmalloc(len, GFP_KERNEL);
 		if (!sa) {
@@ -1382,13 +1371,11 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 		sa->sa_family = dev->type;
 		memcpy(sa->sa_data, nla_data(tb[IFLA_ADDRESS]),
 		       dev->addr_len);
-		err = ops->ndo_set_mac_address(dev, sa);
+		err = dev_set_mac_address(dev, sa);
 		kfree(sa);
 		if (err)
 			goto errout;
-		send_addr_notify = 1;
 		modified = 1;
-		add_device_randomness(dev->dev_addr, dev->addr_len);
 	}
 
 	if (tb[IFLA_MTU]) {
@@ -1425,7 +1412,7 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 
 	if (tb[IFLA_BROADCAST]) {
 		nla_memcpy(dev->broadcast, tb[IFLA_BROADCAST], dev->addr_len);
-		send_addr_notify = 1;
+		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
 	}
 
 	if (ifm->ifi_flags || ifm->ifi_change) {
@@ -1546,9 +1533,6 @@ errout:
 		net_warn_ratelimited("A link change request failed with some changes committed already. Interface %s may have been left with an inconsistent configuration, please check.\n",
 				     dev->name);
 
-	if (send_addr_notify)
-		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
-
 	return err;
 }
 
-- 
1.8.0
