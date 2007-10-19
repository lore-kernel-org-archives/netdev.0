From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [IFGROUPv3 1/3] rtnetlink: setlink changes atomic with single notification
Date: Fri, 19 Oct 2007 18:29:59 +0200
Message-ID: <80da3aa904080a33dd4645a8390c96133268a512.1192810837.git.panther__30539.4699368209$1192811467$gmane$org@balabit.hu>
References: <11928114032187-git-send-email-panther@balabit.hu>
Cc: Laszlo Attila Toth <panther@balabit.hu>
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:53292 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757711AbXJSQaN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 12:30:13 -0400
In-Reply-To: <11928114032187-git-send-email-panther@balabit.hu>
Message-Id: <80da3aa904080a33dd4645a8390c96133268a512.1192810837.git.panther@balabit.hu>
In-Reply-To: <20071019-181844-1192810724.panther@balabit.hu>
References: <20071019-181844-1192810724.panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In do_setlink the device changes are atomic and notifications will be sent
at the end of the function once if any modification occured and once if
address has been changed.

Signed-off-by: Laszlo Attila Toth <panther@balabit.hu>
---
 net/core/rtnetlink.c |   23 ++++++++++++++++++++---
 1 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 4756d58..53af13f 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -819,6 +819,7 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 	if (tb[IFLA_BROADCAST]) {
 		nla_memcpy(dev->broadcast, tb[IFLA_BROADCAST], dev->addr_len);
 		send_addr_notify = 1;
+		modified = 1;
 	}
 
 	if (ifm->ifi_flags || ifm->ifi_change) {
@@ -829,21 +830,35 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 			flags = (flags & ifm->ifi_change) |
 				(dev->flags & ~ifm->ifi_change);
 		dev_change_flags(dev, flags);
+		modified = 1;
 	}
 
-	if (tb[IFLA_TXQLEN])
+	if (tb[IFLA_TXQLEN]) {
+		write_lock_bh(&dev_base_lock);
 		dev->tx_queue_len = nla_get_u32(tb[IFLA_TXQLEN]);
+		write_unlock_bh(&dev_base_lock);
+		modified = 1;
+	}
 
-	if (tb[IFLA_WEIGHT])
+	if (tb[IFLA_WEIGHT]) {
+		write_lock_bh(&dev_base_lock);
 		dev->weight = nla_get_u32(tb[IFLA_WEIGHT]);
+		write_unlock_bh(&dev_base_lock);
+		modified = 1;
+	}
 
-	if (tb[IFLA_OPERSTATE])
+	if (tb[IFLA_OPERSTATE]) {
+		write_lock_bh(&dev_base_lock);
 		set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]));
+		write_unlock_bh(&dev_base_lock);
+		modified = 1;
+	}
 
 	if (tb[IFLA_LINKMODE]) {
 		write_lock_bh(&dev_base_lock);
 		dev->link_mode = nla_get_u8(tb[IFLA_LINKMODE]);
 		write_unlock_bh(&dev_base_lock);
+		modified = 1;
 	}
 
 	err = 0;
@@ -857,6 +872,8 @@ errout:
 
 	if (send_addr_notify)
 		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
+	if (modified)
+		rtmsg_ifinfo(RTM_NEWLINK, dev, 0);
 	return err;
 }
 
-- 
1.5.2.5

