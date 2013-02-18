From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net 2/3] bonding: Fix initialize after use for 3ad machine
 state spinlock
Date: Mon, 18 Feb 2013 22:51:20 +0100
Message-ID: <5122A258.9000707@redhat.com>
References: <1361210344-14907-1-git-send-email-nikolay@redhat.com> <1361210344-14907-2-git-send-email-nikolay@redhat.com> <21258.1361223190@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44724 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756399Ab3BRVvo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2013 16:51:44 -0500
In-Reply-To: <21258.1361223190@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/02/13 22:33, Jay Vosburgh wrote:
> Nikolay Aleksandrov <nikolay@redhat.com> wrote:
> 
>> The 3ad machine state spinlock can be used before it is inititialized
>> while doing bond_enslave() (and the port is being initialized) since
>> port->slave is set before the lock is prepared, thus causing soft
>> lock-ups and a multitude of other nasty bugs.
> 
> 	Does this change cause the "uninitialized port" warnings in
> bond_3ad_state_machine_handler and bond_3ad_rx_indication to
> intermittently print during the enslavement process?  If so (and it
> looks to me like it will), I think the warnings should be removed, since
> after this change, port->slave being NULL isn't really an error
> condition that needs a warning to the log.
> 
This change couldn't cause that, it only initializes the spin lock
before the slave is set, currently after the first patch of this series
this is no longer a requirement as far as I can tell the only code that
can access the lock before the slave is set was that one, but it still
is a bug that can manifest later. I don't think it has anything to do
with the warnings, the only change is that the spin lock is initialized
prior to setting the slave to the port.
Am I missing something here ?

>> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
>> ---
>> drivers/net/bonding/bond_3ad.c | 9 ++++-----
>> 1 file changed, 4 insertions(+), 5 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>> index 1720742..96d471e 100644
>> --- a/drivers/net/bonding/bond_3ad.c
>> +++ b/drivers/net/bonding/bond_3ad.c
>> @@ -389,13 +389,13 @@ static u8 __get_duplex(struct port *port)
>>
>> /**
>>  * __initialize_port_locks - initialize a port's STATE machine spinlock
>> - * @port: the port we're looking at
>> + * @port: the slave of the port we're looking at
>>  *
>>  */
>> -static inline void __initialize_port_locks(struct port *port)
>> +static inline void __initialize_port_locks(struct slave *port)
>> {
>> 	// make sure it isn't called twice
>> -	spin_lock_init(&(SLAVE_AD_INFO(port->slave).state_machine_lock));
>> +	spin_lock_init(&(SLAVE_AD_INFO(port).state_machine_lock));
> 
> 	Change the name of the variable here, too, not just the type.
> This is confusing.
> 
> 	-J
Thanks, I saw that after posting, I have prepared this change already.
> 
>> }
>>
>> //conversions
>> @@ -1910,6 +1910,7 @@ int bond_3ad_bind_slave(struct slave *slave)
>>
>> 		ad_initialize_port(port, bond->params.lacp_fast);
>>
>> +		__initialize_port_locks(slave);
>> 		port->slave = slave;
>> 		port->actor_port_number = SLAVE_AD_INFO(slave).id;
>> 		// key is determined according to the link speed, duplex and user key(which is yet not supported)
>> @@ -1932,8 +1933,6 @@ int bond_3ad_bind_slave(struct slave *slave)
>> 		port->next_port_in_aggregator = NULL;
>>
>> 		__disable_port(port);
>> -		__initialize_port_locks(port);
>> -
>>
>> 		// aggregator initialization
>> 		aggregator = &(SLAVE_AD_INFO(slave).aggregator);
>> -- 
>> 1.7.11.7
>>
> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
> 
