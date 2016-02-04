From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: bonding reports interface up with 0 Mbps
Date: Thu, 04 Feb 2016 12:19:28 -0800
Message-ID: <22735.1454617168@famine>
References: <87618083B2453E4A8714035B62D6799250524233@FMSMSX105.amr.corp.intel.com> <16238.1454565446@famine> <87618083B2453E4A8714035B62D67992505247BA@FMSMSX105.amr.corp.intel.com>
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	zhuyj <zyjzyj2000@gmail.com>,
	"jiri@mellanox.com" <jiri@mellanox.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:54116 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755203AbcBDUTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 15:19:34 -0500
In-reply-to: <87618083B2453E4A8714035B62D67992505247BA@FMSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tantilov, Emil S <emil.s.tantilov@intel.com> wrote:
[...]
>Sure, I'll give this a try, but I'm not sure this check applies in this case
>as you can see from the trace link is up and carrier is on.

	From code inspection, I see another possible race, although I'm
not sure if it's relevant for this case.  During enslavement, the speed
and duplex are initially set, and then later the link state is checked,
but if link is up, the code presumes the speed and duplex are valid,
which they may not be.

	I think this patch would narrow (but not totally eliminate) this
race:

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 56b560558884..b8b8a24f92d1 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1591,6 +1591,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	/* check for initial state */
 	if (bond->params.miimon) {
 		if (bond_check_dev_link(bond, slave_dev, 0) == BMSR_LSTATUS) {
+			bond_update_speed_duplex(new_slave);
 			if (bond->params.updelay) {
 				bond_set_slave_link_state(new_slave,
 							  BOND_LINK_BACK,


	I'm not sure it's going to be really possible to completely
close all of these races, as the device can change its link state (and
thus what it reports for speed and duplex) asynchronously.  Even in a
NETDEV_UP or NETDEV_CHANGE notifier callback, the link could go down
between the time of the netif_carrier_on call that triggers the notifier
and when the callback runs.

	But, if the link is really flapping here, bonding should get a
notifier for each flap (up or down).  Once it settles down with carrier
up then the speed and duplex should be valid.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
