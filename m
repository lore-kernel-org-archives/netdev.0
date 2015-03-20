From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH v2] bonding: ban stacked bonding support
Date: Fri, 20 Mar 2015 20:46:38 +0300
Message-ID: <20150320174638.GA2053@p183.telecom.by>
References: <20150220222042.GA15595@p183.telecom.by>
 <22754.1424474040@famine>
 <20150320174308.GA2005@p183.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vfalico@gmail.com, andy@greyhouse.net, netdev@vger.kernel.org,
	jay.vosburgh@canonical.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:34936 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999AbbCTRqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 13:46:37 -0400
Received: by wgdm6 with SMTP id m6so95374522wgd.2
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 10:46:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150320174308.GA2005@p183.telecom.by>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If you add bonding master as a slave, and then release it,
it will no longer be an IFF_BONDING creating problems like described at
https://bugzilla.kernel.org/show_bug.cgi?id=89541

	echo +bond1 >/sys/class/net/bonding_masters
	echo 1 >/sys/class/net/bond1/bonding/mode
	echo +bond2 >/sys/class/net/bonding_masters
	echo +bond2 >/sys/class/net/bond1/bonding/slaves
	echo -bond2 >/sys/class/net/bond1/bonding/slaves
	echo -bond2 >/sys/class/net/bonding_masters

	cat /proc/net/bonding/bond2	# should not exist
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
 
+	if (netif_is_bond_master(slave_dev)) {
+		netdev_err(bond_dev, "device is bond master\n");
+		return -EBUSY;
+	}
+
 	/* already enslaved */
 	if (slave_dev->flags & IFF_SLAVE) {
 		netdev_dbg(bond_dev, "Error: Device was already enslaved\n");
