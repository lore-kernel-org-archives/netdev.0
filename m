From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH 1/1] bonding: restrict up state in 802.3ad mode
Date: Wed, 06 Jan 2016 22:33:41 -0800
Message-ID: <16587.1452148421@famine>
References: <87618083B2453E4A8714035B62D6799250504549@FMSMSX105.amr.corp.intel.com> <1452147313-22886-1-git-send-email-zyjzyj2000@gmail.com>
Cc: emil.s.tantilov@intel.com, mkubecek@suse.cz, vfalico@gmail.com,
	gospo@cumulusnetworks.com, netdev@vger.kernel.org,
	boris.shteinbock@windriver.com
To: zyjzyj2000@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:36795 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745AbcAGGdt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 01:33:49 -0500
In-reply-to: <1452147313-22886-1-git-send-email-zyjzyj2000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

<zyjzyj2000@gmail.com> wrote:

>From: Zhu Yanjun <yanjun.zhu@windriver.com>
>
>In 802.3ad mode, the speed and duplex is needed. But in some NIC,
>there is a time span between NIC up state and getting speed and duplex.
>As such, sometimes a slave in 802.3ad mode is in up state without
>speed and duplex. This will make bonding in 802.3ad mode can not
>work well.

	From my reading of Emil's comments in the discussion, I'm not
sure the above is an accurate description of the problem.  If I'm
understanding correctly, the cause is due to link flaps racing with the
bonding monitor workqueue polling the state.  Is this correct?

>To make bonding driver be compatible with more NICs, it is
>necessary to restrict the up state in 802.3ad mode.
>
>Signed-off-by: Zhu Yanjun <yanjun.zhu@windriver.com>
>---
> drivers/net/bonding/bond_main.c |   11 +++++++++++
> 1 file changed, 11 insertions(+)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 09f8a48..7df8af5 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -1991,6 +1991,17 @@ static int bond_miimon_inspect(struct bonding *bond)
> 
> 		link_state = bond_check_dev_link(bond, slave->dev, 0);
> 
>+		if ((BMSR_LSTATUS == link_state) &&
>+		    (BOND_MODE(bond) == BOND_MODE_8023AD)) {
>+			rtnl_lock();
>+			bond_update_speed_duplex(slave);
>+			rtnl_unlock();

	This will add a round trip on the RTNL mutex for every miimon
interval when the slave is carrier up.  At common miimon rates (10 - 50
ms), this will hit RTNL between 20 and 100 times per second.  I do not
see how this is acceptable.

	I believe the proper solution here is to supplant the periodic
miimon polling from bonding with link state detection based on notifiers
(As Stephen suggested, not for the first time).

	My suggestion is to have bonding set slave link state based on
notifiers if miimon is set to zero, and poll as usual if it is not.
This would preserve any backwards compatibility with any device out
there that might possibly still be doing netif_carrier_on/off
incorrectly or not at all.  The only minor complication is synchronizing
notifier carrier state detection with the ARP monitor.

	This should have been done a long time ago; I'll work something
up tomorrow (it's late here right now) and post a patch for testing.

	-J

>+			if ((slave->speed == SPEED_UNKNOWN) ||
>+			    (slave->duplex == DUPLEX_UNKNOWN)) {
>+				link_state = 0;
>+				netdev_info(bond->dev, "In 802.3ad mode, it is not enough to up without speed and duplex");
>+			}
>+		}
> 		switch (slave->link) {
> 		case BOND_LINK_UP:
> 			if (link_state)
>-- 
>1.7.9.5
>

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
