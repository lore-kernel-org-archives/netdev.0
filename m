From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/2] net: ipv4: handle DSA enabled master network devices
Date: Wed, 14 Jan 2015 09:52:11 -0800
Message-ID: <1421257932-11073-2-git-send-email-f.fainelli@gmail.com>
References: <1421257932-11073-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, stephen@networkplumber.org, kaber@trash.net,
	bridge@lists.linux-foundation.org, buytenh@wantstofly.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:57894 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031AbbANRwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 12:52:21 -0500
Received: by mail-pd0-f177.google.com with SMTP id ft15so11019493pdb.8
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 09:52:21 -0800 (PST)
In-Reply-To: <1421257932-11073-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The logic to configure a network interface for kernel IP
auto-configuration is very simplistic, and does not handle the case
where a device is stacked onto another such as with DSA. This causes the
kernel not to open and configure the master network device in a DSA
switch tree, and therefore slave network devices using this master
network devices as conduit device cannot be open.

This restriction comes from a check in net/dsa/slave.c, which is
basically checking the master netdev flags for IFF_UP and returns
-ENETDOWN if it is not the case.

Automatically bringing-up DSA master network devices allows DSA slave
network devices to be used as valid interfaces for e.g: NFS root booting
by allowing kernel IP autoconfiguration to succeed on these interfaces.

On the reverse path, make sure we do not attempt to close a DSA-enabled
device as this would implicitely prevent the slave DSA network device
from operating.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/ipv4/ipconfig.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 7fa18bc7e47f..d10073d2be0f 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -209,9 +209,9 @@ static int __init ic_open_devs(void)
 	last = &ic_first_dev;
 	rtnl_lock();
 
-	/* bring loopback device up first */
+	/* bring loopback an DSA master network devices up first */
 	for_each_netdev(&init_net, dev) {
-		if (!(dev->flags & IFF_LOOPBACK))
+		if (!(dev->flags & IFF_LOOPBACK) && !netdev_uses_dsa(dev))
 			continue;
 		if (dev_change_flags(dev, dev->flags | IFF_UP) < 0)
 			pr_err("IP-Config: Failed to open %s\n", dev->name);
@@ -228,6 +228,7 @@ static int __init ic_open_devs(void)
 			if (!(dev->flags & IFF_NOARP))
 				able |= IC_RARP;
 			able &= ic_proto_enabled;
+
 			if (ic_proto_enabled && !able)
 				continue;
 			oflags = dev->flags;
@@ -306,7 +307,10 @@ static void __init ic_close_devs(void)
 	while ((d = next)) {
 		next = d->next;
 		dev = d->dev;
-		if (dev != ic_dev) {
+		/* Only bring down unused devices and not DSA enabled master
+		 * devices
+		 */
+		if (dev != ic_dev && !netdev_uses_dsa(dev)) {
 			DBG(("IP-Config: Downing %s\n", dev->name));
 			dev_change_flags(dev, d->flags);
 		}
-- 
2.1.0
