From: sfeldma@gmail.com
Subject: [PATCH net-next v7 18/24] bridge: revert br_dellink change back to original
Date: Sun, 10 May 2015 09:48:03 -0700
Message-ID: <1431276489-64199-19-git-send-email-sfeldma@gmail.com>
References: <1431276489-64199-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, andrew@lunn.ch, simon.horman@netronome.com,
	joe@perches.com, sridhar.samudrala@intel.com, ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:32897 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751673AbbEJQrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 12:47:20 -0400
Received: by pacwv17 with SMTP id wv17so90862530pac.0
        for <netdev@vger.kernel.org>; Sun, 10 May 2015 09:47:19 -0700 (PDT)
In-Reply-To: <1431276489-64199-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

This is revert of:

commit 68e331c785b8 ("bridge: offload bridge port attributes to switch asic
if feature flag set")

Restore br_dellink back to original and don't call into SELF port driver.
rtnetlink.c:bridge_dellink() already does a call into port driver for SELF.

bridge vlan add/del cmd defaults to MASTER.  From man page for bridge vlan
add/del cmd:

       self   the vlan is configured on the specified physical device.
              Required if the device is the bridge device.

       master the vlan is configured on the software bridge (default).

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 net/bridge/br_netlink.c |   11 +----------
 1 file changed, 1 insertion(+), 10 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index e9b9435..6b67ed3 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -639,7 +639,7 @@ int br_dellink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 {
 	struct nlattr *afspec;
 	struct net_bridge_port *p;
-	int err = 0, ret_offload = 0;
+	int err = 0;
 
 	afspec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_AF_SPEC);
 	if (!afspec)
@@ -658,15 +658,6 @@ int br_dellink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 		 */
 		br_ifinfo_notify(RTM_NEWLINK, p);
 
-	if (p && !(flags & BRIDGE_FLAGS_SELF)) {
-		/* del bridge attributes in hardware
-		 */
-		ret_offload = switchdev_port_bridge_dellink(dev, nlh, flags);
-		if (ret_offload && ret_offload != -EOPNOTSUPP)
-			br_warn(p->br, "error deleting attrs on port %u (%s)\n",
-				(unsigned int)p->port_no, p->dev->name);
-	}
-
 	return err;
 }
 static int br_validate(struct nlattr *tb[], struct nlattr *data[])
-- 
1.7.10.4
