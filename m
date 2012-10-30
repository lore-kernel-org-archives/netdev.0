From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: fix bond 6 mode change MAC of arp reply from vif to cause Domu's network unreachable intermittently
Date: Tue, 30 Oct 2012 12:39:52 -0700
Message-ID: <10469.1351625992@death.nxdomain>
References: <1351565271-5888-1-git-send-email-zheng.x.li@oracle.com>
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	joe.jin@oracle.com
To: Zheng Li <zheng.x.li@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1351565271-5888-1-git-send-email-zheng.x.li@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Zheng Li <zheng.x.li@oracle.com> wrote:

>This is a fix for a bug in bond_alb.c
>Rate of reproduced:100%
>Scenario: set Dom0 to bond 6 mode, Domu communicate with Dom0 through vif which
>is in bridge mode. The Dom0's bridge of xenbr0 contains vif and bond0, bond0
>contains eth0 and eth1. You can just need to ping a host which is in same LAN on
>Domu, some of packets will be lost intermittently.
>Analyse: When Dom0 set bond mode to 6, the bond alb will change MAC of every arp
>reply in rlb_arp_xmit function to affect receive packets, it is ok for normal
>NIC, but it's wrong to Domu, when Domu send arp reply through vif of Dom0, bond
>of alb replace Domu's MAC in arp reply with NIC's MAC address, that will cause
>remote host send packets to Domu using real NIC's MAC instead of Domu's MAC. Domu
>can't receive the packets whose dst MAC is not Domu's MAC.

	If I understand correctly, the issue really isn't about Dom0 /
Domu specifically, but rather that ARP traffic passing through a bridge
and out via the bond (when the bond is a port of the bridge) should not
have its source MAC address adjusted by the receive load balance code in
rlb_arp_xmit.

	Is my understanding correct?

	If so, then the patch in principle seems reasonable (although it
could be coded without the sentinel; more on that in a minute), but the
subject and description aren't really an accurate description of the
root problem (just one manifestation of it).  A better subject might be
something like "rlb mode should not alter ARP replies originating via
bridge."

>Cc: Jay Vosburgh <fubar@us.ibm.com>
>Cc: Andy Gospodarek <andy@greyhouse.net>
>Cc: "David S. Miller" <davem@davemloft.net>
>Signed-off-by: Zheng Li <zheng.x.li@oracle.com>
>
>---
> drivers/net/bonding/bond_alb.c |   13 ++++++++++++-
> 1 files changed, 12 insertions(+), 1 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
>index e15cc11..d6b134a 100644
>--- a/drivers/net/bonding/bond_alb.c
>+++ b/drivers/net/bonding/bond_alb.c
>@@ -700,7 +700,18 @@ static struct slave *rlb_arp_xmit(struct sk_buff *skb, struct bonding *bond)
> 		*/
> 		tx_slave = rlb_choose_channel(skb, bond);
> 		if (tx_slave) {
>-			memcpy(arp->mac_src,tx_slave->dev->dev_addr, ETH_ALEN);
>+			struct slave *tmp_slave = NULL;
>+			int i = 0, found_mac = 0;
>+			bond_for_each_slave(bond, tmp_slave, i) {
>+				if (ether_addr_equal_64bits(arp->mac_src,
>+						tmp_slave->dev->dev_addr)) {
>+					found_mac = 1;
>+					break;
>+				}
>+			}
>+			if (found_mac)
>+				memcpy(arp->mac_src, tx_slave->dev->dev_addr,
>+					ETH_ALEN);

	I think this could be coded as:

			bond_for_each_slave(bond, tmp_slave, i) {
				if (ether_addr_equal_64bits(arp->mac_src,
						tmp_slave->dev->dev_addr)) {
					memcpy(arp->mac_src,
					       tx_slave->dev->dev_addr,
					       ETH_ALEN);
					break;
				}
			}

	or even create a "bond_slave_has_mac" helper, since this loop is
something done several times in the code, e.g.,

struct slave *bond_slave_has_mac(struct bonding *bond, const u8 *mac)
{
	int i = 0;
	struct slave *tmp;

	bond_for_each_slave(bond, tmp, i)
		if (ether_addr_equal_64bits(mac, tmp->dev->dev_addr))
			return tmp;

	return NULL;
}

	then your code would be

		if (tx_slave) {
			struct slave *tmp;

			/* Only modify ARP's MAC if it originates locally;
			 * don't change ARPs arriving via a bridge.
			 */
			tmp = bond_slave_has_mac(bond, arp->mac_src);
			if (tmp)
				memcpy(arp->mac_src, tx_slave->dev->dev_addr,
				       ETH_ALEN);

	... and so on.  I haven't tested any of the above, I'm just
scribbling it out into email, but it seems reasonable.

> 		}
> 		pr_debug("Server sent ARP Reply packet\n");
> 	} else if (arp->op_code == htons(ARPOP_REQUEST)) {
>-- 
>1.7.6.5

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
