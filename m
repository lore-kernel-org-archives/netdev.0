From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] rtnl: don't send rtnl msg for unregistered iface
Date: Mon, 11 May 2015 16:25:46 +0200
Message-ID: <1431354346-4476-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
	gospo@cumulusnetworks.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Jiri Pirko <jiri@resnulli.us>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:46881 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750967AbbEKO0J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 10:26:09 -0400
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

Fixes: d4261e565000 ("bonding: create netlink event when bonding option is changed")
CC: Jiri Pirko <jiri@resnulli.us>
Reported-by: Julien Meunier <julien.meunier@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/core/rtnetlink.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 837d30b5ffed..721ca1b0e734 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -3273,6 +3273,8 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	case NETDEV_BONDING_INFO:
 		break;
 	default:
+		if (!dev->ifindex)
+			break;
 		rtmsg_ifinfo(RTM_NEWLINK, dev, 0, GFP_KERNEL);
 		break;
 	}
-- 
2.2.2
