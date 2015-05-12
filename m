From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net v2] rtnl/bond: don't send rtnl msg for unregistered iface
Date: Tue, 12 May 2015 17:03:55 +0200
Message-ID: <1431443035-4265-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20150511175355.GA3130@nanopsycho>
Cc: davem@davemloft.net, netdev@vger.kernel.org, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:34975 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932850AbbELPEH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 11:04:07 -0400
In-Reply-To: <20150511175355.GA3130@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before the patch, the command 'ip link add bond2 type bond mode 802.3ad'
causes the kernel to send a rtnl message for the bond2 interface, with an
ifindex 0.

'ip monitor' shows:
0: bond2: <BROADCAST,MULTICAST,MASTER> mtu 1500 state DOWN group default
    link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
9: bond2@NONE: <BROADCAST,MULTICAST,MASTER> mtu 1500 qdisc noop state DOWN group default
    link/ether ea:3e:1f:53:92:7b brd ff:ff:ff:ff:ff:ff
[snip]

First, nobody seems to care about NETDEV_CHANGEINFODATA (commit
d4261e565000 says that it was put only to notify userspace). Hence, we can
call directly rtmsg_ifinfo().
Secondly, prevent in rtnetlink_event() to send notifications to userspace
about unregistered interfaces.

Fixes: d4261e565000 ("bonding: create netlink event when bonding option is changed")
CC: Jiri Pirko <jiri@resnulli.us>
Reported-by: Julien Meunier <julien.meunier@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

v2: check dev->reg_state instead of ifindex
    call rtmsg_ifinfo() directly in __bond_opt_set()

There is about 20 occurences of "dev->reg_state .= NETREG_REGISTERED".
I will send a patch on net-next to introduce an helper for this when net
will be merged with this patch in net-next.

 drivers/net/bonding/bond_options.c | 4 ++--
 include/linux/netdevice.h          | 3 +--
 net/core/rtnetlink.c               | 3 ++-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 4df28943d222..882e0599e72b 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -624,8 +624,8 @@ int __bond_opt_set(struct bonding *bond,
 out:
 	if (ret)
 		bond_opt_error_interpret(bond, opt, ret, val);
-	else
-		call_netdevice_notifiers(NETDEV_CHANGEINFODATA, bond->dev);
+	else if (bond->dev->reg_state == NETREG_REGISTERED)
+		rtmsg_ifinfo(RTM_NEWLINK, bond->dev, 0, GFP_KERNEL);
 
 	return ret;
 }
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1899c74a7127..c040d48925fd 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2069,8 +2069,7 @@ struct pcpu_sw_netstats {
 #define NETDEV_CHANGEUPPER	0x0015
 #define NETDEV_RESEND_IGMP	0x0016
 #define NETDEV_PRECHANGEMTU	0x0017 /* notify before mtu change happened */
-#define NETDEV_CHANGEINFODATA	0x0018
-#define NETDEV_BONDING_INFO	0x0019
+#define NETDEV_BONDING_INFO	0x0018
 
 int register_netdevice_notifier(struct notifier_block *nb);
 int unregister_netdevice_notifier(struct notifier_block *nb);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 837d30b5ffed..e6e4d7fc863e 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -3273,7 +3273,8 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	case NETDEV_BONDING_INFO:
 		break;
 	default:
-		rtmsg_ifinfo(RTM_NEWLINK, dev, 0, GFP_KERNEL);
+		if (dev->reg_state == NETREG_REGISTERED)
+			rtmsg_ifinfo(RTM_NEWLINK, dev, 0, GFP_KERNEL);
 		break;
 	}
 	return NOTIFY_DONE;
-- 
2.2.2
