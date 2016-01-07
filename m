From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [PATCH 1/1] bonding: restrict up state in 802.3ad mode
Date: Thu, 7 Jan 2016 15:37:26 +0800
Message-ID: <568E15B6.8010301@gmail.com>
References: <87618083B2453E4A8714035B62D6799250504549@FMSMSX105.amr.corp.intel.com>
 <1452147313-22886-1-git-send-email-zyjzyj2000@gmail.com>
 <20160107065340.GB27753@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: emil.s.tantilov@intel.com, jay.vosburgh@canonical.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org, boris.shteinbock@windriver.com
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34955 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750773AbcAGHhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 02:37:37 -0500
Received: by mail-pa0-f47.google.com with SMTP id qh10so1727643pab.2
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 23:37:37 -0800 (PST)
In-Reply-To: <20160107065340.GB27753@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/2016 02:53 PM, Michal Kubecek wrote:
> On Thu, Jan 07, 2016 at 02:15:13PM +0800, zyjzyj2000@gmail.com wrote:
>> From: Zhu Yanjun <yanjun.zhu@windriver.com>
>>
>> In 802.3ad mode, the speed and duplex is needed. But in some NIC,
>> there is a time span between NIC up state and getting speed and duplex.
>> As such, sometimes a slave in 802.3ad mode is in up state without
>> speed and duplex. This will make bonding in 802.3ad mode can not
>> work well.
>> To make bonding driver be compatible with more NICs, it is
>> necessary to restrict the up state in 802.3ad mode.
>>
>> Signed-off-by: Zhu Yanjun <yanjun.zhu@windriver.com>
>> ---
>>   drivers/net/bonding/bond_main.c |   11 +++++++++++
>>   1 file changed, 11 insertions(+)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 09f8a48..7df8af5 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -1991,6 +1991,17 @@ static int bond_miimon_inspect(struct bonding *bond)
>>   
>>   		link_state = bond_check_dev_link(bond, slave->dev, 0);
>>   
>> +		if ((BMSR_LSTATUS == link_state) &&
>> +		    (BOND_MODE(bond) == BOND_MODE_8023AD)) {
>> +			rtnl_lock();
>> +			bond_update_speed_duplex(slave);
>> +			rtnl_unlock();
>> +			if ((slave->speed == SPEED_UNKNOWN) ||
>> +			    (slave->duplex == DUPLEX_UNKNOWN)) {
>> +				link_state = 0;
>> +				netdev_info(bond->dev, "In 802.3ad mode, it is not enough to up without speed and duplex");
> If I read this right, whenever this state (link up but speed/duplex
> unknown) is entered, you'll keep writing this message into kernel log
> every miimon milliseconds until something changes. I'm not sure how long
> a NIC can stay in such state but it might get quite annoying (even more
> if something really goes wrong and NIC stays that way which can't be
> completely ruled out, IMHO).

Sure, Thanks a lot. I want to confirm link_up without link_speed. It is 
not usual. So I think this only lasts for several seconds.
It is very important to us since it can help us to find the root cause.

Zhu Yanjun

>
>
>> +			}
>> +		}
>>   		switch (slave->link) {
>>   		case BOND_LINK_UP:
>>   			if (link_state)
> BtW, you accidentally submitted this patch twice.
>
>                                                            Michal Kubecek
