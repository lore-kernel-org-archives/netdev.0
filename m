From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: ipconfig: handle DSA enabled network devices
Date: Fri, 30 May 2014 11:08:46 -0700
Message-ID: <1401473326-21828-2-git-send-email-f.fainelli@gmail.com>
References: <1401473326-21828-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, buytenh@wantstofly.org, jiri@resnulli.us,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:45760 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753306AbaE3SJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 14:09:13 -0400
Received: by mail-ie0-f182.google.com with SMTP id x19so2090065ier.27
        for <netdev@vger.kernel.org>; Fri, 30 May 2014 11:09:13 -0700 (PDT)
In-Reply-To: <1401473326-21828-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The logic to configure a network interface for kernel IP
auto-configuration is very simplistic, and does not handle the case
where a device is stacked onto another such as with DSA. This causes the
kernel not to open and configure e.g: eth0 which is the master network
device for its slave network devices.

DSA slave devices do check whether their master device is UP in their
ndo_open() callback, and will return an error if it is not the case,
thus preventing them from being usable.

On the reverse path, make sure we do not attempt to close a DSA-enabled
device as this would implicitely prevent the slave DSA network device
from operating.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/ipv4/ipconfig.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index b3e86ea7b71b..c06430270482 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -211,9 +211,9 @@ static int __init ic_open_devs(void)
 	last = &ic_first_dev;
 	rtnl_lock();
 
-	/* bring loopback device up first */
+	/* bring loopback and DSA master devices up first */
 	for_each_netdev(&init_net, dev) {
-		if (!(dev->flags & IFF_LOOPBACK))
+		if (!(dev->flags & IFF_LOOPBACK) && !dev->dsa_ptr)
 			continue;
 		if (dev_change_flags(dev, dev->flags | IFF_UP) < 0)
 			pr_err("IP-Config: Failed to open %s\n", dev->name);
@@ -307,7 +307,8 @@ static void __init ic_close_devs(void)
 	while ((d = next)) {
 		next = d->next;
 		dev = d->dev;
-		if (dev != ic_dev) {
+		/* Bring down non-DSA master and unused devices */
+		if (dev != ic_dev && !dev->dsa_ptr) {
 			DBG(("IP-Config: Downing %s\n", dev->name));
 			dev_change_flags(dev, d->flags);
 		}
-- 
1.9.1
