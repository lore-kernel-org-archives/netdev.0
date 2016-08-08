From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Subject: [PATCH] bonding: Allow tun-interfaces as slaves
Date: Mon, 8 Aug 2016 14:48:12 -0700
Message-ID: <20160808214812.GJ22974@cork>
References: <20160808211530.GH22974@cork>
 <20160808212112.GI22974@cork>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: dingtianhong <dingtianhong@huawei.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33805 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752345AbcHHVsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 17:48:20 -0400
Received: by mail-pa0-f46.google.com with SMTP id fi15so117484268pac.1
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 14:48:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160808212112.GI22974@cork>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Up until 00503b6f702e (part of 3.14-rc1), the bonding driver could be
used to enslave tun-interfaces.  00503b6f702e broke that behaviour,
afaics as an unintended side-effect.

For the purpose of bond-over-tun in balance-rr mode, simply ignoring the
error from dev_set_mac_address() is good enough.  I am not familiar
enough with the code to judge what new problems this patch might
introduce.

Signed-off-by: Joern Engel <joern@purestorage.com>
---
 drivers/net/bonding/bond_main.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 1f276fa30ba6..bc5dba847f50 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1489,11 +1489,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		 */
 		memcpy(addr.sa_data, bond_dev->dev_addr, bond_dev->addr_len);
 		addr.sa_family = slave_dev->type;
-		res = dev_set_mac_address(slave_dev, &addr);
-		if (res) {
-			netdev_dbg(bond_dev, "Error %d calling set_mac_address\n", res);
-			goto err_restore_mtu;
-		}
+		dev_set_mac_address(slave_dev, &addr);
 	}
 
 	/* set slave flag before open to prevent IPv6 addrconf */
@@ -1777,7 +1773,6 @@ err_restore_mac:
 		dev_set_mac_address(slave_dev, &addr);
 	}
 
-err_restore_mtu:
 	dev_set_mtu(slave_dev, new_slave->original_mtu);
 
 err_free:
-- 
2.1.4
