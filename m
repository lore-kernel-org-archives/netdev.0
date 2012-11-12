From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: rlb mode of bond should not alter ARP replies originating via bridge
Date: Mon, 12 Nov 2012 15:40:45 -0800
Message-ID: <29827.1352763645@death.nxdomain>
References: <1352714143-28160-1-git-send-email-zheng.x.li@oracle.com>
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	joe.jin@oracle.com
To: Zheng Li <zheng.x.li@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1352714143-28160-1-git-send-email-zheng.x.li@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Zheng Li <zheng.x.li@oracle.com> wrote:

>ARP traffic passing through a bridge and out via the bond (when the bond is a 
>port of the bridge) should not have its source MAC address adjusted by the 
>receive load balance code in rlb_arp_xmit.
>
>Signed-off-by: Zheng Li <zheng.x.li@oracle.com>
>Cc: Jay Vosburgh <fubar@us.ibm.com>
>Cc: Andy Gospodarek <andy@greyhouse.net>
>Cc: "David S. Miller" <davem@davemloft.net>
>
>---
> drivers/net/bonding/bond_alb.c |   21 ++++++++++++++++++++-
> 1 files changed, 20 insertions(+), 1 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
>index e15cc11..a99e658 100644
>--- a/drivers/net/bonding/bond_alb.c
>+++ b/drivers/net/bonding/bond_alb.c
>@@ -685,6 +685,18 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
> 	return assigned_slave;
> }
>
>+struct slave *bond_slave_has_mac(struct bonding *bond, const u8 *mac)
>+{
>+	int i = 0;
>+	struct slave *tmp;
>+
>+	bond_for_each_slave(bond, tmp, i)
>+		if (ether_addr_equal_64bits(mac, tmp->dev->dev_addr))
>+			return tmp;
>+
>+	return NULL;
>+}

	This should go in bonding.h as a static line, so that other
parts of bonding can use it in the future.  I'll also point out that
this function is one I suggested in a prior email, but did not test.
Presumably you've tested this.

> /* chooses (and returns) transmit channel for arp reply
>  * does not choose channel for other arp types since they are
>  * sent on the curr_active_slave
>@@ -700,7 +712,14 @@ static struct slave *rlb_arp_xmit(struct sk_buff *skb, struct bonding *bond)
> 		*/
> 		tx_slave = rlb_choose_channel(skb, bond);
> 		if (tx_slave) {
>-			memcpy(arp->mac_src,tx_slave->dev->dev_addr, ETH_ALEN);
>+			struct slave *tmp_slave = NULL;

	This does not need to be initialized, as the next line of code
assigns a value to it.

	-J

>+			/* Only modify ARP's MAC if it originates locally;
>+			 * don't change ARPs arriving via a bridge.
>+			 */
>+			tmp_slave = bond_slave_has_mac(bond, arp->mac_src);
>+			if (tmp_slave)
>+				memcpy(arp->mac_src, tx_slave->dev->dev_addr,
>+				       ETH_ALEN);
> 		}
> 		pr_debug("Server sent ARP Reply packet\n");
> 	} else if (arp->op_code == htons(ARPOP_REQUEST)) {
>-- 
>1.7.6.5

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
