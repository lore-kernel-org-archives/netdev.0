From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net v2] bonding: disable arp and enable mii monitoring
 when bond change to no uses arp mode
Date: Fri, 22 Nov 2013 22:12:43 +0800
Message-ID: <528F665B.30307@huawei.com>
References: <528710F7.7050207@huawei.com>	 <1384796682.4774.26.camel@dcbw.foobar.com>	 <20131118.154838.776189725378131169.davem@davemloft.net> <1384815032.4774.55.camel@dcbw.foobar.com> <528ACD8A.1010409@greyhouse.net> <528EBD96.2090706@huawei.com> <528F6247.2080007@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <fubar@us.ibm.com>, <vfalico@redhat.com>, <netdev@vger.kernel.org>
To: Nikolay Aleksandrov <nikolay@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Dan Williams <dcbw@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:28347 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932070Ab3KVON1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 09:13:27 -0500
In-Reply-To: <528F6247.2080007@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/11/22 21:55, Nikolay Aleksandrov wrote:
> On 11/22/2013 03:12 AM, Ding Tianhong wrote:
>> Because the ARP monitoring is not support for 802.3ad, but I still
>> could change the mode to 802.3ad from ab mode while ARP monitoring
>> is running, it is incorrect.
>>
>> So add a check for 802.3ad in bonding_store_mode to fix the problem,
>> and make a new macro BOND_NO_USES_ARP() to simplify the code.
>>
>> v2: according to the Dan Williams's suggestion, bond mode is the most
>>     important bond option, it should override any of the other sub-options.
>>     So when the mode is changed, the conficting values should be cleared
>>     or reset, otherwise the user has to duplicate more operations to modify
>>     the logic. I disable the arp and enable mii monitoring when the bond mode
>>     is changed to AB, TB and 8023AD if the arp interval is true.
>>
>> Suggested-by: Dan Williams <dcbw@redhat.com>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>>  drivers/net/bonding/bond_options.c | 13 +++++++++----
>>  drivers/net/bonding/bonding.h      |  5 +++++
>>  2 files changed, 14 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
>> index 9a5223c..04364f7a 100644
>> --- a/drivers/net/bonding/bond_options.c
>> +++ b/drivers/net/bonding/bond_options.c
>> @@ -45,10 +45,15 @@ int bond_option_mode_set(struct bonding *bond, int mode)
>>  		return -EPERM;
>>  	}
>>  
>> -	if (BOND_MODE_IS_LB(mode) && bond->params.arp_interval) {
>> -		pr_err("%s: %s mode is incompatible with arp monitoring.\n",
>> -		       bond->dev->name, bond_mode_tbl[mode].modename);
>> -		return -EINVAL;
>> +	if (BOND_NO_USES_ARP(mode) && bond->params.arp_interval) {
>> +		pr_info("%s: %s mode is incompatible with arp monitoring, start mii monitoring\n",
>> +			bond->dev->name, bond_mode_tbl[mode].modename);
>> +		/* disable arp monitoring */
>> +		bond->params.arp_interval = 0;
>> +		/* set miimon to default value */
>> +		bond->params.miimon = 100;
>> +		pr_info("%s: Setting MII monitoring interval to %d.\n",
>> +			bond->dev->name, bond->params.miimon);
>>  	}
>>  
> Maybe define the "default" miimon value somewhere ? A value of 100 for miimon is
> used repeatedly in bond_check_params() as well, it'd be nice to give it a name,
> e.g. I had to grep around to see why you chose 100 to be that value.
> 

yes, I get it from bond_check_params(), I think it is time to give it a new name, MIIMON_DEFAULT_VALUE = 100.

>>  	/* don't cache arp_validate between modes */
>> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>> index ca31286..a310fb5 100644
>> --- a/drivers/net/bonding/bonding.h
>> +++ b/drivers/net/bonding/bonding.h
>> @@ -55,6 +55,11 @@
>>  		 ((mode) == BOND_MODE_TLB)          ||	\
>>  		 ((mode) == BOND_MODE_ALB))
>>  
>> +#define BOND_NO_USES_ARP(mode)				\
>> +		(((mode) == BOND_MODE_8023AD)	||	\
>> +		 ((mode) == BOND_MODE_TLB)	||	\
>> +		 ((mode) == BOND_MODE_ALB))
>> +
>>  #define TX_QUEUE_OVERRIDE(mode)				\
>>  			(((mode) == BOND_MODE_ACTIVEBACKUP) ||	\
>>  			 ((mode) == BOND_MODE_ROUNDROBIN))
>>
> One small note, you can save a few lines in bond_sysfs.c if you switch
> the check in bonding_store_arp_interval() to the new macro BOND_NO_USES_ARP()
> as it's identical.
> 
> Cheers,
>  Nik

good idea.

Regards.
Ding

> 
> 
> .
> 
