From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: bonding reports interface up with 0 Mbps
Date: Thu, 04 Feb 2016 16:37:14 -0800
Message-ID: <27926.1454632634@famine>
References: <87618083B2453E4A8714035B62D6799250524233@FMSMSX105.amr.corp.intel.com> <22896.1454617773@famine>
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	zhuyj <zyjzyj2000@gmail.com>,
	"jiri@mellanox.com" <jiri@mellanox.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:55953 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750731AbcBEAhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 19:37:21 -0500
In-reply-to: <22896.1454617773@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh <jay.vosburgh@canonical.com> wrote:
[...]
>	Thinking about the trace again... Emil: what happens in the
>trace before this?  Is there ever a call to the ixgbe_get_settings?
>Does a NETDEV_UP or NETDEV_CHANGE event ever hit the bond_netdev_event
>function?

	Emil kindly sent me the trace offline, and I think I see what's
going on.  It looks like the sequence of events is:

bond_enslave ->
	bond_update_speed_duplex (device is down, thus DUPLEX/SPEED_UNKNOWN)
	[ do rest of enslavement, start miimon periodic work ]

	[ time passes, device goes carrier up ]

ixgbe_service_task: eth1: NIC Link is Up 10 Gbps ->
	netif_carrier_on (arranges for NETDEV_CHANGE notifier out of line)

	[ a few microseconds later ]

bond_mii_monitor ->
	bond_check_dev_link	(now is carrier up)
	bond_miimon_commit ->	(emits "0 Mbps full duplex" message)
		bond_lower_state_changed ->
			bond_netdev_event (NETDEV_CHANGELOWERSTATE, is ignored)
		bond_3ad_handle_link_change	(sees DUPLEX/SPEED_UNKNOWN)

	[ a few microseconds later, in response to ixgbe's netif_carrier_on ]

notifier_call_chain ->
	bond_netdev_event NETDEV_CHANGE ->
		bond_update_speed_duplex (sees correct SPEED_10000/FULL) ->
			bond_3ad_adapter_speed_duplex_changed (updates 802.3ad)

	Basically, the race is that the periodic bond_mii_monitor is
squeezing in between the link going up and bonding's update of the speed
and duplex in response to the NETDEV_CHANGE triggered by the driver's
netif_carrier_on call.  bonding ends up using the stale duplex and speed
information obtained at enslavement time.

	I think that, nowadays, the initial speed and duplex will pretty
much always be UNKNOWN, at least for real Ethernet devices, because it
will take longer to autoneg than the time between the dev_open and
bond_update_speed_duplex calls in bond_enslave.

	Adding a case to bond_netdev_event for CHANGELOWERSTATE works
because it's a synchronous call from bonding.  For purposes of fixing
this, it's more or less equivalent to calling bond_update_speed_duplex
from bond_miimon_commit (which is part of a test patch I posted earlier
today).

	If the above analysis is correct, then I would expect this patch
to make the problem go away:

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 56b560558884..cabaeb61333d 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2127,6 +2127,7 @@ static void bond_miimon_commit(struct bonding *bond)
 			continue;
 
 		case BOND_LINK_UP:
+			bond_update_speed_duplex(slave);
 			bond_set_slave_link_state(slave, BOND_LINK_UP,
 						  BOND_SLAVE_NOTIFY_NOW);
 			slave->last_link_up = jiffies;


	Emil, can you give just the above a test?

	I don't see in the trace that there's evidence that ixgbe's link
is rapidly flapping, so I don't think it's necessary to do more than the
above.

	Now, separately, bonding really should obey the NETDEV_CHANGE /
NETDEV_UP events instead of polling for carrier state, but if the above
patch works it's a simple fix that is easily backported, which the
CHANGELOWERSTATE method isn't, and the new way (notifier driven) can be
net-next material.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
