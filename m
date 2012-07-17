From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] bonding: refine IFF_XMIT_DST_RELEASE capability
Date: Wed, 18 Jul 2012 00:19:48 +0200
Message-ID: <1342563588.2626.1224.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:44302 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516Ab2GQWTz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 18:19:55 -0400
Received: by qaas11 with SMTP id s11so650339qaa.19
        for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 15:19:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Some workloads greatly benefit of IFF_XMIT_DST_RELEASE capability
on output net device, avoiding dirtying dst refcount.

bonding currently disables IFF_XMIT_DST_RELEASE unconditionally.

If all slaves have the IFF_XMIT_DST_RELEASE bit set, then
bonding master can also have it in its priv_flags

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Cc: Tom Herbert <therbert@google.com>
---
 drivers/net/bonding/bond_main.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 1eb3979..3960b1b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1382,6 +1382,7 @@ static void bond_compute_features(struct bonding *bond)
 	netdev_features_t vlan_features = BOND_VLAN_FEATURES;
 	unsigned short max_hard_header_len = ETH_HLEN;
 	int i;
+	unsigned int flags, dst_release_flag = IFF_XMIT_DST_RELEASE;
 
 	read_lock(&bond->lock);
 
@@ -1392,6 +1393,7 @@ static void bond_compute_features(struct bonding *bond)
 		vlan_features = netdev_increment_features(vlan_features,
 			slave->dev->vlan_features, BOND_VLAN_FEATURES);
 
+		dst_release_flag &= slave->dev->priv_flags;
 		if (slave->dev->hard_header_len > max_hard_header_len)
 			max_hard_header_len = slave->dev->hard_header_len;
 	}
@@ -1400,6 +1402,9 @@ done:
 	bond_dev->vlan_features = vlan_features;
 	bond_dev->hard_header_len = max_hard_header_len;
 
+	flags = bond_dev->priv_flags & ~IFF_XMIT_DST_RELEASE;
+	bond_dev->priv_flags = flags | dst_release_flag;
+
 	read_unlock(&bond->lock);
 
 	netdev_change_features(bond_dev);
