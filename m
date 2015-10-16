From: Jan Blunck <jblunck@infradead.org>
Subject: [PATCH] ipv6: no addrconf for slave devices
Date: Fri, 16 Oct 2015 12:21:51 +0200
Message-ID: <1444990911-27458-1-git-send-email-jblunck@infradead.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fubar@us.ibm.com, jiri@resnulli.us
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If a device without the IFF_SLAVE flag set (e.g. team, bridge, openvswitch
vport, batman) is enslaved and IPv6 is active then addrconf will be
initiated and a link-local address is added to the slave interface.

This patch alters the behavior so that addrconf will only run on the master
device itself. This is achieved by checking the device tree instead of
checking for a specific flag.

Signed-off-by: Jan Blunck <jblunck@infradead.org>
---
 net/ipv6/addrconf.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 9001133..26d61f0 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3141,8 +3141,12 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 
 	case NETDEV_UP:
 	case NETDEV_CHANGE:
-		if (dev->flags & IFF_SLAVE)
+		/* If a master is set stop IPv6 on this interface */
+		if (netdev_master_upper_dev_get(dev)) {
+			if (idev)
+				addrconf_ifdown(dev, 1);
 			break;
+		}
 
 		if (idev && idev->cnf.disable_ipv6)
 			break;
-- 
2.1.4
