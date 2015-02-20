From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] bonding: ban stacked bonding support
Date: Sat, 21 Feb 2015 01:20:42 +0300
Message-ID: <20150220222042.GA15595@p183.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f181.google.com ([74.125.82.181]:40355 "EHLO
	mail-we0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754617AbbBTWUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 17:20:46 -0500
Received: by wesx3 with SMTP id x3so8069743wes.7
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2015 14:20:45 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Does Linux support it at all?

In short: if you add bonding master as a slave, and then release it,
it will no longer be a IFF_BONDING creating problems like described at
https://bugzilla.kernel.org/show_bug.cgi?id=89541

	echo +bond1 >/sys/class/net/bonding_masters
	echo 1 >/sys/class/net/bond1/bonding/mode
	echo +bond2 >/sys/class/net/bonding_masters
	echo +bond2 >/sys/class/net/bond1/bonding/slaves
	echo -bond2 >/sys/class/net/bond1/bonding/slaves
	echo -bond2 >/sys/class/net/bonding_masters

	cat /proc/net/bonding/bond2		# should not exist
		[oops]

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/net/bonding/bond_main.c |    5 +++++
 1 file changed, 5 insertions(+)

--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1248,6 +1248,11 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 			    slave_dev->name);
 	}
 
+	if (slave_dev->flags & IFF_MASTER) {
+		netdev_dbg(bond_dev, "stacked bonding not supported\n");
+		return -EBUSY;
+	}
+
 	/* already enslaved */
 	if (slave_dev->flags & IFF_SLAVE) {
 		netdev_dbg(bond_dev, "Error: Device was already enslaved\n");
