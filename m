From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH] bonding: Allow tun-interfaces as slaves
Date: Tue, 09 Aug 2016 16:51:04 -0700
Message-ID: <20075.1470786664@famine>
References: <CAD=hENd01nGdvB9GseG+CrWn3f0PXyGgwOmf=+MVAfuW7Hv9Nw@mail.gmail.com> <57A9DA8D.3010407@huawei.com> <20160809180830.GM22974@cork> <20160809.120636.2039586307820412288.davem@davemloft.net> <20160809211058.GP22974@cork>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>, dingtianhong@huawei.com,
	zyjzyj2000@gmail.com, andy@greyhouse.net, netdev@vger.kernel.org
To: =?us-ascii?Q?=3D=3Fiso-8859-1=3FQ=3FJ=3DF6rn=3F=3D?= Engel
	<joern@purestorage.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:56466 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909AbcHIXvR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 19:51:17 -0400
In-reply-to: <20160809211058.GP22974@cork>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jörn Engel <joern@purestorage.com> wrote:

>On Tue, Aug 09, 2016 at 12:06:36PM -0700, David Miller wrote:
>> > On Tue, Aug 09, 2016 at 09:28:45PM +0800, Ding Tianhong wrote:
>> > 
>> > Simply not checking errors when setting the mac address solves the
>> > problem for me.  No new features needed.
>> 
>> But it only works in certain modes.
>> 
>> So the best we can do is enforce the MAC address setting in the
>> modes that absolutely require it.  We cannot ignore the MAC
>> address setting unilaterally.
>
>Something like this?
>
>[PATCH] bonding: Allow tun-interfaces as slaves in balance-rr mode
>
>Up until 00503b6f702e (part of 3.14-rc1), the bonding driver could be
>used to enslave tun-interfaces.  00503b6f702e broke that behaviour,
>afaics as an unintended side-effect.
>
>For the purpose of bond-over-tun in balance-rr mode, simply ignoring the
>error from dev_set_mac_address() is good enough.
>
>Signed-off-by: Joern Engel <joern@purestorage.com>
>---
> drivers/net/bonding/bond_main.c | 3 ++-
> 1 file changed, 2 insertions(+), 1 deletion(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 1f276fa30ba6..2f686bfe4304 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -1490,7 +1490,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
> 		memcpy(addr.sa_data, bond_dev->dev_addr, bond_dev->addr_len);
> 		addr.sa_family = slave_dev->type;
> 		res = dev_set_mac_address(slave_dev, &addr);
>-		if (res) {
>+		/* round-robin mode works fine without a mac address */
>+		if (res && BOND_MODE(bond) != BOND_MODE_ROUNDROBIN) {

	This will cause balance-rr to add the slave to the bond if any
device's dev_set_mac_address call fails.

	If a bond of regular Ethernet devices is connected to a static
link aggregation (Etherchannel channel group), a set_mac failure would
result in that slave having a different MAC address than the bond, which
in turn would cause traffic inbound from the switch to that slave to be
dropped (as the destination MAC would not pass the device MAC filters).

	The failure check for the set_mac call serves a legitimate
purpose, and I don't believe we should bypass it without making the
bypass an option that is explicitly enabled for those special cases that
need it.

	E.g., something like the following (which I have not tested);
this would also need documentation and iproute2 updates to go with it.
This would be enabled with "fail_over_mac=keepmac".

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 1f276fa30ba6..d2283fc23b16 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1483,7 +1483,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	ether_addr_copy(new_slave->perm_hwaddr, slave_dev->dev_addr);
 
 	if (!bond->params.fail_over_mac ||
-	    BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP) {
+	    (BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP &&
+	     bond->params.fail_over_mac != BOND_FOM_KEEPMAC)) {
 		/* Set slave to master's mac address.  The application already
 		 * set the master's mac address to that of the first slave
 		 */
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 577e57cad1dc..f9653fe4d622 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -125,6 +125,7 @@ static const struct bond_opt_value bond_fail_over_mac_tbl[] = {
 	{ "none",   BOND_FOM_NONE,   BOND_VALFLAG_DEFAULT},
 	{ "active", BOND_FOM_ACTIVE, 0},
 	{ "follow", BOND_FOM_FOLLOW, 0},
+	{ "keepmac", BOND_FOM_KEEPMAC, 0},
 	{ NULL,     -1,              0},
 };
 
diff --git a/include/net/bonding.h b/include/net/bonding.h
index 6360c259da6d..ec3442b3aa83 100644
--- a/include/net/bonding.h
+++ b/include/net/bonding.h
@@ -420,6 +420,7 @@ static inline bool bond_slave_can_tx(struct slave *slave)
 #define BOND_FOM_NONE			0
 #define BOND_FOM_ACTIVE			1
 #define BOND_FOM_FOLLOW			2
+#define BOND_FOM_KEEPMAC		3
 
 #define BOND_ARP_TARGETS_ANY		0
 #define BOND_ARP_TARGETS_ALL		1


	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
