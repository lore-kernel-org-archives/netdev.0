From: Cong Wang <amwang@redhat.com>
Subject: Re: [v3 PATCH 1/2] bonding: sync netpoll code with bridge
Date: Thu, 09 Dec 2010 15:33:23 +0800
Message-ID: <4D008643.5040500@redhat.com>
References: <20101208075208.5792.45247.sendpatchset@localhost.localdomain> <20101208135746.GD11454@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Neil Horman <nhorman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101208135746.GD11454@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/08/10 21:57, Neil Horman wrote:
> On Wed, Dec 08, 2010 at 02:52:08AM -0500, Amerigo Wang wrote:
>> -	bond_for_each_slave(bond, slave, i) {
>> -		if ((slave->dev->priv_flags&  IFF_DISABLE_NETPOLL) ||
>> -		    !slave->dev->netdev_ops->ndo_poll_controller)
>> -			ret = false;
>> +	np = kmalloc(sizeof(*np), GFP_KERNEL);
>> +	err = -ENOMEM;
>> +	if (!np)
>> +		goto out;
>> +
>> +	np->dev = slave->dev;
>> +	err = __netpoll_setup(np);
> Setting up our own netpoll instance on each slave worries me a bit.  The
> implication here is that, by doing so, some frames will get entirely processed
> by the slave.  Most notably arp frames.  That means anything that gets queued up
> to the arp_tx queue in __netpoll_rx will get processed during that poll event,
> and responded to with the mac of the slave device, rather than with the mac of
> the bond device, which isn't always what you want.  I think if you go with this
> route, you'll need to add code to netpoll_poll_dev, right before the call to
> service_arp_queue, to check if IFF_SLAVE is set in priv_flags, and move the list
> to the master device, or some such.


Good point! Will fix it.

>
> It also seems like you'll want to zero out the other fields in the netpoll
> structure.  Leaving garbage in them will be bad.  Most notably here I'm looking
> at the rx_hook field.  If its non-null we're going to add a bogus pointer to the
> rx_np list and call off into space at some point.
>

Ouch! I remember I really used kzalloc() here, don't know
why kmalloc() gets into the final patch. Odd, I need to double check
the patch. :-/

<...>
>> +static void __bond_netpoll_cleanup(struct bonding *bond)
>> +{
>>   	struct slave *slave;
>>   	int i;
>>
>> -	bond_for_each_slave(bond, slave, i) {
>> -		if (slave->dev&&  IS_UP(slave->dev))
>> -			netpoll_poll_dev(slave->dev);
>> -	}
>> +	bond_for_each_slave(bond, slave, i)
>> +		if (slave->dev)
> Why are you checking slave->dev here?  If the dev pointer has been set to NULL
> here it would seem we're not holding on to dev long enough.  If we enabled
> netpoll with a dev pointer and lost it somewhere along the way, we're going to
> leak that struct netpoll memory that we allocated.
>

Hmm, seems you are right, read_lock should guarantee every slave on the list
has the right ->dev... But I think I should keep that IS_UP() checking...

<...>
>>
>>   	/* close slave before restoring its mac address */
>>   	dev_close(slave_dev);
>> @@ -2061,6 +2098,7 @@ static int  bond_release_and_destroy(struct net_device *bond_dev,
>>
>>   	ret = bond_release(bond_dev, slave_dev);
>>   	if ((ret == 0)&&  (bond->slave_cnt == 0)) {
>> +		bond_dev->priv_flags |= IFF_DISABLE_NETPOLL;
> Why are you setting IFF_DISABLE_NETPOLL here?  That seems unnecessecary
>

It gets removed in patch 2/2. :)

Thanks for review!
