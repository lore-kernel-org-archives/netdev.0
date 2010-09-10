From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-2.6 v2] bonding: correctly process non-linear skbs
Date: Fri, 10 Sep 2010 17:43:20 -0400
Message-ID: <20100910214320.GX7497@gospo.rdu.redhat.com>
References: <20100910203845.GW7497@gospo.rdu.redhat.com> <22437.1284152640@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	stable@kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37157 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751011Ab0IJVn3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Sep 2010 17:43:29 -0400
Content-Disposition: inline
In-Reply-To: <22437.1284152640@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 10, 2010 at 02:04:00PM -0700, Jay Vosburgh wrote:
> Andy Gospodarek <andy@greyhouse.net> wrote:
> 
> >
> >It was recently brought to my attention that 802.3ad mode bonds would no
> >longer form when using some network hardware after a driver update.
> >After snooping around I realized that the particular hardware was using
> >page-based skbs and found that skb->data did not contain a valid LACPDU
> >as it wasn't stored there.  That explained the inability to form an
> >802.3ad-based bond.
> >
> >This patch fixes the issue in my tests and should be applied to 2.6.36
> >and as far back as anyone cares to add it to stable.
> >
> >Thanks to Alexander Duyck <alexander.h.duyck@intel.com> and Jesse
> >Brandeburg <jesse.brandeburg@intel.com> for the suggestions on this one.
> >
> >Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> >CC: Alexander Duyck <alexander.h.duyck@intel.com>
> >CC: Jesse Brandeburg <jesse.brandeburg@intel.com>
> >CC: stable@kernel.org
> 
> 	Did you by any chance also test balance-alb mode?  Inspection
> suggests that rlb_arp_recv may suffer from the same problem.
> 
> 	If you agree, could you add that to the patch and resubmit it?
> 
> 	Either way, the patch looks good.
> 

You are correct, Jay.  I did a quick test and confirmed that ARPs might
not be properly processed when using balance-ALB too.  Below is a patch
to fix both spots:


[PATCH net-2.6 v2] bonding: correctly process non-linear skbs

It was recently brought to my attention that 802.3ad mode bonds would no
longer form when using some network hardware after a driver update.
After snooping around I realized that the particular hardware was using
page-based skbs and found that skb->data did not contain a valid LACPDU
as it was not stored there.  That explained the inability to form an
802.3ad-based bond.  For balance-alb mode bonds this was also an issue
as ARPs would not be properly processed.

This patch fixes the issue in my tests and should be applied to 2.6.36
and as far back as anyone cares to add it to stable.

Thanks to Alexander Duyck <alexander.h.duyck@intel.com> and Jesse
Brandeburg <jesse.brandeburg@intel.com> for the suggestions on this one.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
CC: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: stable@kerne.org

---
 drivers/net/bonding/bond_3ad.c |    3 +++
 drivers/net/bonding/bond_alb.c |    3 +++
 2 files changed, 6 insertions(+), 0 deletions(-)

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
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index c746b33..26bb118 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -362,6 +362,9 @@ static int rlb_arp_recv(struct sk_buff *skb, struct net_device *bond_dev, struct
 		goto out;
 	}
 
+	if (!pskb_may_pull(skb, arp_hdr_len(bond_dev)))
+		goto out;
+
 	if (skb->len < sizeof(struct arp_pkt)) {
 		pr_debug("Packet is too small to be an ARP\n");
 		goto out;

-- 
1.7.0.1

