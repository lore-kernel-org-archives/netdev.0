From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] bonding: set device in RLB ARP packet handler
Date: Fri, 23 Jul 2010 15:34:56 -0400
Message-ID: <20100723193456.GS7497@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	bonding-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Greg Edwards <greg.edwards@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42065 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752694Ab0GWTfm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jul 2010 15:35:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 22, 2010 at 3:52 PM, Greg Edwards <greg.edwards@hp.com> wrote:
> With commit 6146b1a4, the dev field in the RLB ARP packet handler was
> set to NULL to wildcard and accommodate balancing VLANs on top of
> bonds.
>
> This has the side-effect of the packet handler being called against
> other, non RLB-enabled bonds, and a kernel oops results when it tries
> to
> dereference rx_hashtbl in rlb_update_entry_from_arp(), which won't be
> set for those bonds, e.g. active-backup.
>
> With the __netif_receive_skb() changes from commit 1f3c8804, frames
> received on VLANs correctly make their way to the bond's handler,
> so we no longer need to wildcard the device.
>

I see this problem as well, but I would propose to fix it another way to
not alter the receive path so close to the release of 2.6.35 and to
catch this for 802.3ad bonds as well.

> Signed-off-by: Greg Edwards <greg.edwards@hp.com>
> ---
> Jay,
>
> The oops can be reproduced by:
>
> modprobe bonding
>
> echo active-backup > /sys/class/net/bond0/bonding/mode
> echo 100 > /sys/class/net/bond0/bonding/miimon
> ifconfig bond0 xxx.xxx.xxx.xxx netmask xxx.xxx.xxx.xxx
> echo +eth0 > /sys/class/net/bond0/bonding/slaves
> echo +eth1 > /sys/class/net/bond0/bonding/slaves
>
> echo +bond1 > /sys/class/net/bonding_masters
> echo balance-alb > /sys/class/net/bond1/bonding/mode
> echo 100 > /sys/class/net/bond1/bonding/miimon
> ifconfig bond1 xxx.xxx.xxx.xxx netmask xxx.xxx.xxx.xxx
> echo +eth2 > /sys/class/net/bond1/bonding/slaves
> echo +eth3 > /sys/class/net/bond1/bonding/slaves
>
> Pass some traffic on bond0.  Boom.
>

bonding: make sure mode-specific handlers handle appropriate frames

This patch will exit out of rlb_arp_recv and bond_3ad_lacpdu_recv early
if the bond receiving the frame isn't using that mode.

Fixes problem reported by Greg Edwards <greg.edwards@hp.com>.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

---
 drivers/net/bonding/bond_3ad.c |    3 ++-
 drivers/net/bonding/bond_alb.c |    6 +++---
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 822f586..cf7b08d 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2463,7 +2463,8 @@ int bond_3ad_lacpdu_recv(struct sk_buff *skb, struct net_device *dev, struct pac
 	struct slave *slave = NULL;
 	int ret = NET_RX_DROP;
 
-	if (!(dev->flags & IFF_MASTER))
+	if (!(dev->flags & IFF_MASTER) ||
+	    (bond->params.mode != BOND_MODE_8023AD))
 		goto out;
 
 	read_lock(&bond->lock);
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index df48307..a82e38c 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -353,7 +353,7 @@ static void rlb_update_entry_from_arp(struct bonding *bond, struct arp_pkt *arp)
 
 static int rlb_arp_recv(struct sk_buff *skb, struct net_device *bond_dev, struct packet_type *ptype, struct net_device *orig_dev)
 {
-	struct bonding *bond;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct arp_pkt *arp = (struct arp_pkt *)skb->data;
 	int res = NET_RX_DROP;
 
@@ -361,7 +361,8 @@ static int rlb_arp_recv(struct sk_buff *skb, struct net_device *bond_dev, struct
 		bond_dev = vlan_dev_real_dev(bond_dev);
 
 	if (!(bond_dev->priv_flags & IFF_BONDING) ||
-	    !(bond_dev->flags & IFF_MASTER))
+	    !(bond_dev->flags & IFF_MASTER) ||
+	    (bond->params.mode != BOND_MODE_ALB))
 		goto out;
 
 	if (!arp) {
@@ -376,7 +377,6 @@ static int rlb_arp_recv(struct sk_buff *skb, struct net_device *bond_dev, struct
 
 	if (arp->op_code == htons(ARPOP_REPLY)) {
 		/* update rx hash table for this ARP */
-		bond = netdev_priv(bond_dev);
 		rlb_update_entry_from_arp(bond, arp);
 		pr_debug("Server received an ARP Reply from client\n");
 	}
-- 
1.6.2.5



