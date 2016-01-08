From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [PATCH 1/1] bonding: restrict up state in 802.3ad mode
Date: Fri, 8 Jan 2016 10:29:31 +0800
Message-ID: <568F1F0B.4020705@gmail.com>
References: <87618083B2453E4A8714035B62D6799250504549@FMSMSX105.amr.corp.intel.com>
 <1452147313-22886-1-git-send-email-zyjzyj2000@gmail.com>
 <16587.1452148421@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: emil.s.tantilov@intel.com, mkubecek@suse.cz, vfalico@gmail.com,
	gospo@cumulusnetworks.com, netdev@vger.kernel.org,
	boris.shteinbock@windriver.com
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34773 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753801AbcAHC3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 21:29:41 -0500
Received: by mail-pf0-f174.google.com with SMTP id q63so2498633pfb.1
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 18:29:41 -0800 (PST)
In-Reply-To: <16587.1452148421@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/2016 02:33 PM, Jay Vosburgh wrote:
> <zyjzyj2000@gmail.com> wrote:
>
>> From: Zhu Yanjun <yanjun.zhu@windriver.com>
>>
>> In 802.3ad mode, the speed and duplex is needed. But in some NIC,
>> there is a time span between NIC up state and getting speed and duplex.
>> As such, sometimes a slave in 802.3ad mode is in up state without
>> speed and duplex. This will make bonding in 802.3ad mode can not
>> work well.
> 	From my reading of Emil's comments in the discussion, I'm not
> sure the above is an accurate description of the problem.  If I'm
> understanding correctly, the cause is due to link flaps racing with the
> bonding monitor workqueue polling the state.  Is this correct?
The following are from my user. What I have done is based on it.
"
Here's one theory that would seem to match my observations:

It seems that the x540T can sometimes report 'link up' a few moments 
before the speed and duplex are known. If the bond driver reads and 
stores the speed and duplex immediately after the link becomes 'up', it 
may occasionally miss the actual parameters by reading them before they 
are ready. If the parameters are only read when the link state changes, 
the 'unknown' status will stay until next state change happens.

I have attached a file 'test.log' that shows the kernel log and states 
of the relevant interfaces after the problem is hit. It shows that the 
final state has all the links up and speeds are known on individual 
interfaces, but bond0 shows only single interface speed. After 
successful negotiation bond0 shows the aggregate speed i.e. 20000Mb/s. 
In the end of the file there is bunch of ethtool runs that were taken in 
a tight loop during the negotiation. It shows in the end that the link 
becomes up some time before the speed and duplex are actually known. If 
the bond driver only reads the speed and duplex during this window, it 
will get it wrong and it won't be corrected when the real speed becomes 
known since the link state won't change at that time.
"

Zhu Yanjun
>
>> To make bonding driver be compatible with more NICs, it is
>> necessary to restrict the up state in 802.3ad mode.
>>
>> Signed-off-by: Zhu Yanjun <yanjun.zhu@windriver.com>
>> ---
>> drivers/net/bonding/bond_main.c |   11 +++++++++++
>> 1 file changed, 11 insertions(+)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 09f8a48..7df8af5 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -1991,6 +1991,17 @@ static int bond_miimon_inspect(struct bonding *bond)
>>
>> 		link_state = bond_check_dev_link(bond, slave->dev, 0);
>>
>> +		if ((BMSR_LSTATUS == link_state) &&
>> +		    (BOND_MODE(bond) == BOND_MODE_8023AD)) {
>> +			rtnl_lock();
>> +			bond_update_speed_duplex(slave);
>> +			rtnl_unlock();
> 	This will add a round trip on the RTNL mutex for every miimon
> interval when the slave is carrier up.  At common miimon rates (10 - 50
> ms), this will hit RTNL between 20 and 100 times per second.  I do not
> see how this is acceptable.
>
> 	I believe the proper solution here is to supplant the periodic
> miimon polling from bonding with link state detection based on notifiers
> (As Stephen suggested, not for the first time).
>
> 	My suggestion is to have bonding set slave link state based on
> notifiers if miimon is set to zero, and poll as usual if it is not.
> This would preserve any backwards compatibility with any device out
> there that might possibly still be doing netif_carrier_on/off
> incorrectly or not at all.  The only minor complication is synchronizing
> notifier carrier state detection with the ARP monitor.
>
> 	This should have been done a long time ago; I'll work something
> up tomorrow (it's late here right now) and post a patch for testing.
>
> 	-J
>
>> +			if ((slave->speed == SPEED_UNKNOWN) ||
>> +			    (slave->duplex == DUPLEX_UNKNOWN)) {
>> +				link_state = 0;
>> +				netdev_info(bond->dev, "In 802.3ad mode, it is not enough to up without speed and duplex");
>> +			}
>> +		}
>> 		switch (slave->link) {
>> 		case BOND_LINK_UP:
>> 			if (link_state)
>> -- 
>> 1.7.9.5
>>
> ---
> 	-Jay Vosburgh, jay.vosburgh@canonical.com
