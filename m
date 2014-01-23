From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 1/3] bonding: Set the correct value to fail_over_mac
 at enslavement
Date: Thu, 23 Jan 2014 10:50:01 +0800
Message-ID: <52E08359.4020903@huawei.com>
References: <52DF8DB8.9000006@huawei.com> <26505.1390423887@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:10040 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbaAWCug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 21:50:36 -0500
In-Reply-To: <26505.1390423887@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/1/23 4:51, Jay Vosburgh wrote:
> Ding Tianhong <dingtianhong@huawei.com> wrote:
> 
>> If the new slave don't support setting the MAC address, there are
>> two ways to handle this situation:
>>
>> 1). If the new slave is the first slave, set bond to the new slave's
>>    MAC address, if the mode is active-backup, set fail_over_mac to
>>    active, otherwise set fail_over_mac to none.
> 
> 	This should be "if the mode is active-backup, set fail_over_mac
> to active, otherwise do not change fail_over_mac."  Setting to none here
> would undo any setting of fail_over_mac that the user had set prior to
> adding the first slave.
> 
I thought about this question for a long time, I still can not think clearly.
ex: the first slave did not support setting MAC, and mode is RR, fail_over_mac=1(user set it
    when load the driver), so the after the enslavement, the fail_over_mac is still 1,
    then the second slave added, if the second slave did not support setting MAC, it will pass
    the check and go ahead, until the dev_set_mac_address(), and return error, so
    I think set it to none may cause the second slave return early, but no substance logic change.
    I will modify this place as your opinion.

>> 2). If the new slave is not the first slave and the fail_over_mac is
>>    active, it means that the slave could work normally in active-backup
>>    mode, otherwise if the fail_over_mac is none, the slave could not
>>    work normally for no active-backup mode, so bond could not ensalve
>>    the new dev.
> 
> 	This (#2) is not a code change, correct?  You're just restating
> the existing behavior of the code, right?
> 
> 	Also, I don't see where this patch set updates the slave removal
> processing where the slave's original MAC is restored.  At present, this
> is done by a test against fail_over_mac, but should be tested against
> the mode and fail_over_mac.
> 
> 	My comment to the prior version of this patchset, again:
> 
> 	The correct way to fix this in general is to permit setting an
> option at any time, but only have it take effect in active-backup mode.
> This minimizes ordering requirements when setting options.
> 
> 	I would instead modify the bond enslave and removal processing
> to check the mode in addition to fail_over_mac when setting a slave's
> MAC during enslavement.  The change active slave processing already only
> calls the fail_over_mac function when in active-backup mode.  This
> should also be a simpler change set.
> 
> 	These comments still apply to this version of the patchset.
> 
> 	-J
> 

OK.

Regards
Ding

>> Cc: Jay Vosburgh <fubar@us.ibm.com>
>> Cc: Veaceslav Falico <vfalico@redhat.com>
>> Cc: Andy Gospodarek <andy@greyhouse.net>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>> drivers/net/bonding/bond_main.c | 12 ++++++++++--
>> 1 file changed, 10 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 3220b48..598f100 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -1334,9 +1334,17 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>>
>> 	if (slave_ops->ndo_set_mac_address == NULL) {
>> 		if (!bond_has_slaves(bond)) {
>> -			pr_warning("%s: Warning: The first slave device specified does not support setting the MAC address. Setting fail_over_mac to active.",
>> +			pr_warning("%s: Warning: The first slave device specified does not support setting the MAC address.\n",
>> 				   bond_dev->name);
>> -			bond->params.fail_over_mac = BOND_FOM_ACTIVE;
>> +			if (bond->params.mode == BOND_MODE_ACTIVEBACKUP) {
>> +				bond->params.fail_over_mac = BOND_FOM_ACTIVE;
>> +				pr_warning("%s: Setting fail_over_mac to active for active-backup mode.\n",
>> +					   bond_dev->name);
>> +			} else {
>> +				bond->params.fail_over_mac = BOND_FOM_NONE;
>> +				pr_warning("%s: Setting fail_over_mac to none for no active-backup modes",
>> +					   bond_dev->name);
>> +			}
>> 		} else if (bond->params.fail_over_mac != BOND_FOM_ACTIVE) {
>> 			pr_err("%s: Error: The slave device specified does not support setting the MAC address, but fail_over_mac is not set to active.\n",
>> 			       bond_dev->name);
>> -- 
>> 1.8.0
> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
> 
> 
> .
> 
