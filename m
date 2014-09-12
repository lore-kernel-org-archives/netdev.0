From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net] bonding: fix div by zero while enslaving and transmitting
Date: Fri, 12 Sep 2014 15:33:55 +0200
Message-ID: <5412F643.10007@redhat.com>
References: <1410524556-27128-1-git-send-email-nikolay@redhat.com> <1410527381.7106.81.camel@edumazet-glaptop2.roam.corp.google.com> <5412F4D5.3070101@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@resnulli.us>,
	Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2668 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753927AbaILNeN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Sep 2014 09:34:13 -0400
In-Reply-To: <5412F4D5.3070101@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/12/2014 03:27 PM, Nikolay Aleksandrov wrote:
> On 09/12/2014 03:09 PM, Eric Dumazet wrote:
>> On Fri, 2014-09-12 at 14:22 +0200, Nikolay Aleksandrov wrote:
>> ...
>>>
>>> CC: Jiri Pirko <jiri@resnulli.us>
>>> CC: Andy Gospodarek <andy@greyhouse.net>
>>> CC: Jay Vosburgh <j.vosburgh@gmail.com>
>>> CC: Veaceslav Falico <vfalico@gmail.com>
>>> Fixes: 5378c2e6ea236d ("bonding: move bond-specific init after enslave happens")
>>> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
>>> ---
>>>  drivers/net/bonding/bond_main.c | 6 +++++-
>>>  1 file changed, 5 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>>> index 57912ee231cb..10ad434ea184 100644
>>> --- a/drivers/net/bonding/bond_main.c
>>> +++ b/drivers/net/bonding/bond_main.c
>>> @@ -1552,6 +1552,10 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>>>  		goto err_detach;
>>>  	}
>>>  
>>> +	/* Increment slave_cnt before linking in the slave so we won't end up in
>>> +	 * bond_start_xmit with bond_has_slaves() true and slave_cnt == 0.
>>> +	 */
>>> +	bond->slave_cnt++;
>>
>> It looks like explicit barriers are missing.
>>
One more thing, netdev_master_upper_dev_link_private() which is called
after the increment uses list_add_rcu() (i.e. rcu_assign_pointer) to insert
the slave, so there's a barrier there to ensure this is visible before the
slave is linked.

>> #define bond_has_slaves(bond) !list_empty(bond_slave_list(bond)) 
>>
>> So your increment into slave_cnt must be committed into memory before
>> any change to slave_list. But you need to check how removal of a slave
>> is handled.
>>
> That is handled by decrementing slave_cnt after executing synchronize_rcu()
> after unlinking the last slave thus making the list empty and all xmitters
> entering will see bond_has_slaves() as empty before they see slave_cnt as 0.
> In every other case the worst that could happen is that a few packets will
> see wrong slave_cnt, but that is not a problem since we walk the list to
> find the slave with the id.
> 
>> Now I wonder why bond_has_slaves(bond) is not a test against
>> bond->slave_cnt
>>
> It used to be once, I don't remember the reason it's not anymore.
> 
>> Note that even if this would be the case, bond xmit seems racy :
>>
>> if (bond_has_slaves(bond))
>> 	ret = __bond_start_xmit(skb, dev);
>>
> Yes, true but we make sure it doesn't see slave_cnt as 0 with
> bond_has_slaves() evaluating to true.
> 
>> As slave_cnt could change (and eventually reach 0) between the two
>> places.
> This shouldn't be possible because of the synchronize_rcu() after unlinking
> the slave. slave_cnt is decremented only after that so every reader will
> see the list empty before they see slave_cnt as 0.
> 
>>
>> My feeling is that RCU conversion is not properly done in this driver.
>>
>> Either bond->slave_cnt should be read _once_ for the whole duration of
>> bond_start_xmit() call, _OR_, be stored in a real Read Copy structure,
>> so that struct->slave_cnt _cannot_ change during bond_start_xmit()
>>
>>>  	res = bond_master_upper_dev_link(bond_dev, slave_dev, new_slave);
>>>  	if (res) {
>>>  		netdev_dbg(bond_dev, "Error %d calling bond_master_upper_dev_link\n", res);
>>> @@ -1564,7 +1568,6 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>>>  		goto err_upper_unlink;
>>>  	}
>>>  
>>> -	bond->slave_cnt++;
>>>  	bond_compute_features(bond);
>>>  	bond_set_carrier(bond);
>>>  
>>> @@ -1590,6 +1593,7 @@ err_upper_unlink:
>>>  
>>>  err_unregister:
>>>  	netdev_rx_handler_unregister(slave_dev);
>>> +	bond->slave_cnt--;
>>>  
>>>  err_detach:
>>>  	if (!bond_uses_primary(bond))
>>
>>
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
