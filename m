From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH v4 net-next] bonding: extend bond_arp_send_all to bridge devices
Date: Thu, 08 Nov 2012 16:58:56 -0800
Message-ID: <9296.1352422736@death.nxdomain>
References: <1352210205-24558-1-git-send-email-chris.j.arges@canonical.com>
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chris J Arges <chris.j.arges@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1352210205-24558-1-git-send-email-chris.j.arges@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris J Arges <chris.j.arges@canonical.com> wrote:

>ARP monitoring does not work when we have a network in the
>following configuration:
>
>eth0----+ +----bond0.100----br0-100---{+virtual machines
>          | |
>          +----bond0----+----br0---(fixed IP)->--{LAN arp_ip_target}
>          | |
>eth1----+ +----bond0.200----br0-200---{+virtual machines
>
>This patch extends bond_arp_send_all to check if a device
>is also in a bridge.

	I did some testing with this.  The required network
configuration to show the problem is much simpler than this.  I tested
with something of the form:

eth0 -> bond0 -> {bond0.123, br0} br0 is 10.0.9.1/16, arp_ip_target is
10.0.1.1

	br0 has the only assigned IP address, and the arp_ip_target is
something on that same subnet.  In this case, merely having 8021q loaded
would induce the problem, as that would add a VLAN (VID 0) to the bond
even without explicitly adding a VLAN to the bond.

	The patch does resolve the immediate problem that with the VLAN,
the bond would not send the ARP queries out via eth0.

	However, it misses one corner case, because the new test does
not validate that the bond is actually a port of the bridge that's found
via the route.  In this case, a configuration like:

eth0 -> bond0 -> bond0.123 IP address 10.99.0.1/16, arp_ip_target 10.0.1.1
eth1 -> br0 IP address 10.0.9.1/16

	would cause the bond to issue the ARP probe request for 10.0.1.1
on eth0, even though it really shouldn't (and currently wouldn't).  If,
say, eth0 and eth1 are parallel subnets, it's possible that the host
with 10.0.1.1 (multihomed to both subnets) may answer on the "wrong"
subnet even if regular traffic routed via the correct subnet can't get
through for some reason.

	I don't see an easy way to find out if device X is a port of
bridge Y, either, although we can easily check if the bond is a bridge
port (priv_flags & IFF_BRIDGE_PORT) before doing the new check.  That
doesn't completely fix the problem, but does require that the bond be a
port of a different bridge to cause a misbehavior.

	-J

>This is related to the following issues:
>http://launchpad.net/bugs/736226
>http://bugzilla.kernel.org/show_bug.cgi?id=31822
>
>Thanks to help from Andy Gospodarek <andy@greyhouse.net>.
>
>Signed-off-by: Chris J Arges <chris.j.arges@canonical.com>
>---
> drivers/net/bonding/bond_main.c |    8 ++++++++
> 1 file changed, 8 insertions(+)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index b2530b0..62931b0 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -2708,6 +2708,14 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
> 			continue;
> 		}
>
>+		/* Check if the target is part of a bridge.
>+		 */
>+		if (rt->dst.dev->priv_flags & IFF_EBRIDGE) {
>+			addr = bond_confirm_addr(rt->dst.dev, targets[i], 0);
>+			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i], addr, 0);
>+			continue;
>+		}
>+
> 		if (net_ratelimit()) {
> 			pr_warning("%s: no path to arp_ip_target %pI4 via rt.dev %s\n",
> 				   bond->dev->name, &targets[i],
>-- 
>1.7.9.5
>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
