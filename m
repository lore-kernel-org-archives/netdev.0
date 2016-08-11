From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH] bonding: Allow tun-interfaces as slaves
Date: Thu, 11 Aug 2016 09:37:19 +0800
Message-ID: <57ABD6CF.40104@huawei.com>
References: <CAD=hENd01nGdvB9GseG+CrWn3f0PXyGgwOmf=+MVAfuW7Hv9Nw@mail.gmail.com>
 <57A9DA8D.3010407@huawei.com> <20160809180830.GM22974@cork>
 <20160809.120636.2039586307820412288.davem@davemloft.net>
 <20160809211058.GP22974@cork> <20075.1470786664@famine>
 <20160810212649.GD5019@cork> <20160810220055.GE5019@cork>
 <935.1470877118@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, <zyjzyj2000@gmail.com>,
	<andy@greyhouse.net>, <netdev@vger.kernel.org>
To: Jay Vosburgh <jay.vosburgh@canonical.com>,
	=?UTF-8?Q?J=c3=b6rn_Engel?= <joern@purestorage.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:29609 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752008AbcHKBiB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 21:38:01 -0400
In-Reply-To: <935.1470877118@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016/8/11 8:58, Jay Vosburgh wrote:
> Jörn Engel <joern@purestorage.com> wrote:
> 
>> On Wed, Aug 10, 2016 at 02:26:49PM -0700, Jörn Engel wrote:
>>>
>>> Having to set one more parameter is a bit annoying.  It would have to be
>>> documented in a prominent place and people would still often miss it.
>>> So I wonder if we can make the interface a little nicer.
>>>
>>> Options:
>>> - If there are no slaves yet and the first slave added is tun, we trust
>>>   the users to know what they are doing.  Automatically set
>>>   bond->params.fail_over_mac = BOND_FOM_KEEPMAC
>>>   Maybe do a printk to inform the user in case of a mistake.
> 
> 	I don't think this is feasible, as I don't see a reliable way to
> test for a slave being a tun device (ARPHRD_NONE is not just tun, and we
> cannot check the ops as they are not statically built into the kernel).
> I'm also not sure that heuristics are the proper way to enable this
> functionality in general.
> 
>>> - If we get an error and the slave device is tun, do a printk giving the
>>>   user enough information to find this parameter.
> 
> 	This could probably be done as a change the existing logic, e.g.,
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 1f276fa30ba6..019c1a689aae 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1443,6 +1443,9 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>  				res = -EOPNOTSUPP;
>  				goto err_undo_flags;
>  			}
> +		} else if (BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP &&
> +			   bond->params.fail_over_mac != BOND_FOM_KEEPMAC) {
> +				netdev_err(bond_dev, "The slave device specified does not support setting the MAC address, but fail_over_mac is not set to keepmac\n");
>  		}
>  	}
>  
> 	I haven't tested this, and I'm not sure it will get all corner
> cases correct, but this should basically cover it.
> 

Looks fine to cover the case, but if we still let it pass, I am not sure it is suitable.

> 	-J
> 
>>> I'm leaning towards the former, but you probably know a reason why I am
>>> wrong again.
>>
>> Patch below is an implementation of the former.  Not sure if something
>> like this is worth considering.
>>
>> Jörn
>>
>> --
>> To announce that there must be no criticism of the President, or that we
>> are to stand by the President, right or wrong, is not only unpatriotic
>> and servile, but is morally treasonable to the American public.
>> -- Theodore Roosevelt, Kansas City Star, 1918
>>
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 1f276fa30ba6..306909a44fab 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -1482,8 +1482,9 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>> 	 */
>> 	ether_addr_copy(new_slave->perm_hwaddr, slave_dev->dev_addr);
>>
>> -	if (!bond->params.fail_over_mac ||
>> -	    BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP) {
>> +	if (bond_dev->type != ARPHRD_NONE &&
>> +	    (!bond->params.fail_over_mac ||
>> +	     BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP)) {
>> 		/* Set slave to master's mac address.  The application already
>> 		 * set the master's mac address to that of the first slave
>> 		 */
>> -- 
>> 2.1.4
>>
> 
> ---
> 	-Jay Vosburgh, jay.vosburgh@canonical.com
> 
> .
> 
