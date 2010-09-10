From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH net-2.6] bonding: correctly process LACPDUs in non-linear
	skbs
Date: Fri, 10 Sep 2010 16:38:45 -0400
Message-ID: <20100910203845.GW7497@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	stable@kernel.org
To: netdev@vger.kernel.org, fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42769 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751075Ab0IJUvd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Sep 2010 16:51:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It was recently brought to my attention that 802.3ad mode bonds would no
longer form when using some network hardware after a driver update.
After snooping around I realized that the particular hardware was using
page-based skbs and found that skb->data did not contain a valid LACPDU
as it wasn't stored there.  That explained the inability to form an
802.3ad-based bond.

This patch fixes the issue in my tests and should be applied to 2.6.36
and as far back as anyone cares to add it to stable.

Thanks to Alexander Duyck <alexander.h.duyck@intel.com> and Jesse
Brandeburg <jesse.brandeburg@intel.com> for the suggestions on this one.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
CC: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: stable@kernel.org

---
 drivers/net/bonding/bond_3ad.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 822f586..0ddf4c6 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2466,6 +2466,9 @@ int bond_3ad_lacpdu_recv(struct sk_buff *skb, struct net_device *dev, struct pac
 	if (!(dev->flags & IFF_MASTER))
 		goto out;
 
+	if (!pskb_may_pull(skb, sizeof(struct lacpdu)))
+		goto out;
+
 	read_lock(&bond->lock);
 	slave = bond_get_slave_by_dev((struct bonding *)netdev_priv(dev),
 					orig_dev);
-- 
1.7.0.1

