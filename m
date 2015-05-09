From: sfeldma@gmail.com
Subject: [PATCH net-next v6 14/23] bridge: restore br_setlink back to original
Date: Sat,  9 May 2015 10:40:16 -0700
Message-ID: <1431193225-807-15-git-send-email-sfeldma@gmail.com>
References: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, andrew@lunn.ch, simon.horman@netronome.com,
	joe@perches.com, sridhar.samudrala@intel.com, ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34865 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751671AbbEIRnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 13:43:32 -0400
Received: by pabtp1 with SMTP id tp1so75743754pab.2
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 10:43:31 -0700 (PDT)
In-Reply-To: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Restore br_setlink back to original and don't call into SELF port driver.
rtnetlink.c:bridge_setlink() already does a call into port driver for SELF.

bridge set link cmd defaults to MASTER.  From man page for bridge link set
cmd:

       self   link setting is configured on specified physical device

       master link setting is configured on the software bridge (default)

The link setting has two values: the device-side value and the software
bridge-side value.  These are independent and settable using the bridge
link set cmd by specifying some combination of [master] | [self].
Futhermore, the device-side and bridge-side settings have their own initial
value, viewable from bridge -d link show cmd.

Restoring br_setlink back to original makes rocker (the only in-kernel user
of SELF link settings) work as first implement: two-sided values.

It's true that when both MASTER and SELF are specified from the command,
two netlink notifications are generated, one for each side of the settings.
The user-space app can distiquish between the two notifications by
observing the MASTER or SELF flag.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 net/bridge/br_netlink.c |   11 +----------
 1 file changed, 1 insertion(+), 10 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index dc23453..e9b9435 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -586,7 +586,7 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 	struct nlattr *afspec;
 	struct net_bridge_port *p;
 	struct nlattr *tb[IFLA_BRPORT_MAX + 1];
-	int err = 0, ret_offload = 0;
+	int err = 0;
 
 	protinfo = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_PROTINFO);
 	afspec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_AF_SPEC);
@@ -628,15 +628,6 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 				afspec, RTM_SETLINK);
 	}
 
-	if (p && !(flags & BRIDGE_FLAGS_SELF)) {
-		/* set bridge attributes in hardware if supported
-		 */
-		ret_offload = switchdev_port_bridge_setlink(dev, nlh, flags);
-		if (ret_offload && ret_offload != -EOPNOTSUPP)
-			br_warn(p->br, "error setting attrs on port %u(%s)\n",
-				(unsigned int)p->port_no, p->dev->name);
-	}
-
 	if (err == 0)
 		br_ifinfo_notify(RTM_NEWLINK, p);
 out:
-- 
1.7.10.4
