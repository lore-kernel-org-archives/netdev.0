From: Vincent Bernat <vincent@bernat.im>
Subject: [net-next v3] bridge: trigger RTM_NEWLINK when interface is modified by bridge ioctl
Date: Thu, 21 Sep 2017 12:05:25 +0200
Message-ID: <20170921100525.20395-1-vincent@bernat.im>
References: <20170920162140.369bb198@xeon-e3>
Cc: Vincent Bernat <vincent@bernat.im>
To: Stephen Hemminger <stephen@networkplumber.org>,
        David Ahern <dsahern@gmail.com>,
        David Miller <davem@davemloft.net>,
        bridge@lists.linux-foundation.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:59387 "EHLO bart.luffy.cx"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751709AbdIUKFs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 21 Sep 2017 06:05:48 -0400
In-Reply-To: <20170920162140.369bb198@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, there is a difference in netlink events received when an
interface is modified through bridge ioctl() or through netlink. This
patch generates additional events when an interface is added to or
removed from a bridge via ioctl().

When adding then removing an interface from a bridge with netlink, we
get:

5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue master bridge0 state UNKNOWN group default
    link/ether 9e:da:60:ee:cf:c8 brd ff:ff:ff:ff:ff:ff
5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 state UNKNOWN
    link/ether 9e:da:60:ee:cf:c8
5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 state UNKNOWN
    link/ether 9e:da:60:ee:cf:c8
5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 state UNKNOWN
    link/ether 9e:da:60:ee:cf:c8
5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 state UNKNOWN
    link/ether 9e:da:60:ee:cf:c8
5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue master bridge0 state UNKNOWN group default
    link/ether 9e:da:60:ee:cf:c8 brd ff:ff:ff:ff:ff:ff

5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue master bridge0 state UNKNOWN group default
    link/ether 9e:da:60:ee:cf:c8 brd ff:ff:ff:ff:ff:ff
5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 state UNKNOWN
    link/ether 9e:da:60:ee:cf:c8
Deleted 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 state UNKNOWN
    link/ether 9e:da:60:ee:cf:c8
5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default
    link/ether 9e:da:60:ee:cf:c8 brd ff:ff:ff:ff:ff:ff

When using ioctl():

5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue master bridge0 state UNKNOWN group default
    link/ether 9e:da:60:ee:cf:c8 brd ff:ff:ff:ff:ff:ff
5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 state UNKNOWN
    link/ether 9e:da:60:ee:cf:c8
5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 state UNKNOWN
    link/ether 9e:da:60:ee:cf:c8
5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 state UNKNOWN
    link/ether 9e:da:60:ee:cf:c8
5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue master bridge0 state UNKNOWN group default
    link/ether 9e:da:60:ee:cf:c8 brd ff:ff:ff:ff:ff:ff

5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue master bridge0 state UNKNOWN group default
    link/ether 9e:da:60:ee:cf:c8 brd ff:ff:ff:ff:ff:ff
5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 state UNKNOWN
    link/ether 9e:da:60:ee:cf:c8
Deleted 5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master bridge0 state UNKNOWN
    link/ether 9e:da:60:ee:cf:c8
5: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default
    link/ether 9e:da:60:ee:cf:c8 brd ff:ff:ff:ff:ff:ff

Without this patch, the last netlink notification is not sent.

Signed-off-by: Vincent Bernat <vincent@bernat.im>
---
 net/bridge/br_ioctl.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
index 7970f8540cbb..66cd98772051 100644
--- a/net/bridge/br_ioctl.c
+++ b/net/bridge/br_ioctl.c
@@ -102,6 +102,9 @@ static int add_del_if(struct net_bridge *br, int ifindex, int isadd)
 	else
 		ret = br_del_if(br, dev);
 
+	if (!ret)
+		rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_MASTER, GFP_KERNEL);
+
 	return ret;
 }
 
-- 
2.14.1
