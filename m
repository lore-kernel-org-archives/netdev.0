From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net 2/2] net/bonding: correctly proxy slave neigh param
 setup ndo function
Date: Wed, 4 Apr 2012 11:03:41 +0300
Message-ID: <4F7C005D.60709@mellanox.com>
References: <1333383430-17456-1-git-send-email-ogerlitz@mellanox.com> <1333383430-17456-3-git-send-email-ogerlitz@mellanox.com> <10209.1333493626@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <roland@kernel.org>,
	<netdev@vger.kernel.org>, Shlomo Pongratz <shlomop@mellanox.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:45933 "HELO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753834Ab2DDIEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 04:04:11 -0400
In-Reply-To: <10209.1333493626@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/4/2012 1:53 AM, Jay Vosburgh wrote:
> Or Gerlitz<ogerlitz@mellanox.com>  wrote:
>
>> From: Shlomo Pongratz<shlomop@mellanox.com>
>>
>> The current implemenation was buggy for slaves who use ndo_neigh_setup,
>> since the networking stack invokes the bonding device ndo entry (from
>> neigh_params_alloc) before any devices are enslaved, and the bonding
>> driver can't further delegate the call at that point in time. As a
>> result when bonding IPoIB devices, the neigh_cleanup hasn't been called.
>>
>> Fix that by deferring the actual call into the slave ndo_neigh_setup
> >from the time the bonding neigh_setup is called.
>>
>> Signed-off-by: Shlomo Pongratz<shlomop@mellanox.com>
>> ---
>> drivers/net/bonding/bond_main.c |   51 ++++++++++++++++++++++++++++++++------
>> 1 files changed, 43 insertions(+), 8 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index b0a278d..2eed155 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -3707,17 +3707,52 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
>> 	read_unlock(&bond->lock);
>> }
>>
>> -static int bond_neigh_setup(struct net_device *dev, struct neigh_parms *parms)
>> +static int bond_neigh_init(struct neighbour *n)
>> {
>> -	struct bonding *bond = netdev_priv(dev);
>> +	struct bonding *bond = netdev_priv(n->dev);
>> 	struct slave *slave = bond->first_slave;
>> +	const struct net_device_ops *slave_ops;
>> +	struct neigh_parms parms;
>> +	int ret;
>> +
>> +	if (!slave)
>> +		return 0;
>> +
>> +	slave_ops = slave->dev->netdev_ops;
>> +
>> +	if (!slave_ops->ndo_neigh_setup)
>> +		return 0;
>> +
>> +	parms.neigh_setup = NULL;
>> +	parms.neigh_cleanup = NULL;
>> +	ret = slave_ops->ndo_neigh_setup(slave->dev,&parms);
>> +	if (ret)
>> +		return ret;
>> +
>> +	/*
>> +	 * must bind here to the slave clenaup. Since when last slave is removed
>> +	 * there will be no slave device to dereference in a bonding
>> +	 * neigh_cleanup function that we have could add.
>> +	 */
>> +	n->parms->neigh_cleanup = parms.neigh_cleanup;
>
> 	I'd write this comment as:
>
> 	/* Assign slave's neigh_cleanup to neighbour in case cleanup is
> 	 * called after bond has been destroyed.  Assumes that all slaves
> 	 * utilize the same neigh_cleanup (true at this writing as only user
> 	 * is ipoib).
> 	 */
>
> 	I.e., this logic works only because there cannot currently be a
> situation wherein two slaves have different neigh_cleanup functions
> (including one slave with a neigh_cleanup, and another without).

Jay, we do need that proxy-ing for the specific case of deleting the 
last slave, since in bond_release
the address change and the event emission happen --after-- calling 
bond_detach_slave. Still, will pick
your phrasing for the comment and replace "after bond has been 
destroyed" with "after last slave has been detached"

>
> +	/* Does slave implement neigh_setup ? */
> +	if (!parms.neigh_setup)
> +		return 0;
>
> 	I don't think this comment is necessary.

okay, will remove

Or.
