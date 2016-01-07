From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [PATCH 1/1] bonding: restrict up state in 802.3ad mode
Date: Thu, 7 Jan 2016 15:27:02 +0000
Message-ID: <87618083B2453E4A8714035B62D679925050462F@FMSMSX105.amr.corp.intel.com>
References: <87618083B2453E4A8714035B62D6799250504549@FMSMSX105.amr.corp.intel.com>
 <1452147313-22886-1-git-send-email-zyjzyj2000@gmail.com>
 <16587.1452148421@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "mkubecek@suse.cz" <mkubecek@suse.cz>,
	"vfalico@gmail.com" <vfalico@gmail.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Shteinbock, Boris (Wind River)" <boris.shteinbock@windriver.com>
To: Jay Vosburgh <jay.vosburgh@canonical.com>,
	"zyjzyj2000@gmail.com" <zyjzyj2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:27497 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751651AbcAGP1E convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 10:27:04 -0500
In-Reply-To: <16587.1452148421@famine>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Jay Vosburgh [mailto:jay.vosburgh@canonical.com]
>Sent: Wednesday, January 06, 2016 10:34 PM
>To: zyjzyj2000@gmail.com
>Cc: Tantilov, Emil S; mkubecek@suse.cz; vfalico@gmail.com;
>gospo@cumulusnetworks.com; netdev@vger.kernel.org; Shteinbock, Boris (Wind
>River)
>Subject: Re: [PATCH 1/1] bonding: restrict up state in 802.3ad mode
>
><zyjzyj2000@gmail.com> wrote:
>
>>From: Zhu Yanjun <yanjun.zhu@windriver.com>
>>
>>In 802.3ad mode, the speed and duplex is needed. But in some NIC,
>>there is a time span between NIC up state and getting speed and duplex.
>>As such, sometimes a slave in 802.3ad mode is in up state without
>>speed and duplex. This will make bonding in 802.3ad mode can not
>>work well.
>
>	From my reading of Emil's comments in the discussion, I'm not
>sure the above is an accurate description of the problem.  If I'm
>understanding correctly, the cause is due to link flaps racing with the
>bonding monitor workqueue polling the state.  Is this correct?

That is correct.

>>To make bonding driver be compatible with more NICs, it is
>>necessary to restrict the up state in 802.3ad mode.
>>
>>Signed-off-by: Zhu Yanjun <yanjun.zhu@windriver.com>
>>---
>> drivers/net/bonding/bond_main.c |   11 +++++++++++
>> 1 file changed, 11 insertions(+)
>>
>>diff --git a/drivers/net/bonding/bond_main.c
>b/drivers/net/bonding/bond_main.c
>>index 09f8a48..7df8af5 100644
>>--- a/drivers/net/bonding/bond_main.c
>>+++ b/drivers/net/bonding/bond_main.c
>>@@ -1991,6 +1991,17 @@ static int bond_miimon_inspect(struct bonding
>*bond)
>>
>> 		link_state = bond_check_dev_link(bond, slave->dev, 0);
>>
>>+		if ((BMSR_LSTATUS == link_state) &&
>>+		    (BOND_MODE(bond) == BOND_MODE_8023AD)) {
>>+			rtnl_lock();
>>+			bond_update_speed_duplex(slave);
>>+			rtnl_unlock();
>
>	This will add a round trip on the RTNL mutex for every miimon
>interval when the slave is carrier up.  At common miimon rates (10 - 50
>ms), this will hit RTNL between 20 and 100 times per second.  I do not
>see how this is acceptable.
>
>	I believe the proper solution here is to supplant the periodic
>miimon polling from bonding with link state detection based on notifiers
>(As Stephen suggested, not for the first time).
>
>	My suggestion is to have bonding set slave link state based on
>notifiers if miimon is set to zero, and poll as usual if it is not.
>This would preserve any backwards compatibility with any device out
>there that might possibly still be doing netif_carrier_on/off
>incorrectly or not at all.  The only minor complication is synchronizing
>notifier carrier state detection with the ARP monitor.
>
>	This should have been done a long time ago; I'll work something
>up tomorrow (it's late here right now) and post a patch for testing.

That would be awesome. Looking forward to it.

Thanks,
Emil
