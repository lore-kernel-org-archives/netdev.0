From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH RFC] netns: introduce NETREG_NETNS_MOVING reg_state
Date: Wed, 25 Aug 2010 15:03:00 +0200
Message-ID: <4C751484.8030004@free.fr>
References: <20100824115056.GA235835@jupiter.n2.diac24.net> <4C73FAB8.1090402@free.fr> <m1tymjg6w8.fsf@fess.ebiederm.org> <20100825115213.GB235835@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([194.196.100.161]:52055 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752158Ab0HYNDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 09:03:07 -0400
Received: from d06nrmr1707.portsmouth.uk.ibm.com (d06nrmr1707.portsmouth.uk.ibm.com [9.149.39.225])
	by mtagate1.uk.ibm.com (8.13.1/8.13.1) with ESMTP id o7PD342W027759
	for <netdev@vger.kernel.org>; Wed, 25 Aug 2010 13:03:04 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1707.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7PD34W03522580
	for <netdev@vger.kernel.org>; Wed, 25 Aug 2010 14:03:04 +0100
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o7PD33HO007793
	for <netdev@vger.kernel.org>; Wed, 25 Aug 2010 14:03:03 +0100
In-Reply-To: <20100825115213.GB235835@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/25/2010 01:52 PM, David Lamparter wrote:
> previously, if a vlan master device was moved from one network namespace
> to another, all 802.1q and macvlan slaves were deleted.
>
> that deletion is handled through the NETDEV_UNREGISTER notifier, which,
> as such, works well and is probably the right thing to do as a moving
> device really is disappearing for all higher-up users.
>
> now, to allow 8021q and macvlan to keep their slaves, we can tell them
> through dev->reg_state that this is a logical unregister and not a
> physical one. reg_state == NETREG_NETNS_MOVING does exactly this.
>
> Signed-off-by: David Lamparter<equinox@diac24.net>
> ---
>
> Please note that i'm quite unsure about the correctness of this
> patch due to me not having much experience in this kind of
> modification...
>
> In particular, the following might get broken by the new reg_state:
> drivers/net/ixgbe/ixgbe_main.c (hot-unplug)
> drivers/net/wimax/i2400m/driver.c (device reset)
>    

IMHO, that should be ok. NETREG_NETNS_MOVING is a transient state where 
the network device is not registered and not in the netdev list.

I think you should take care of this kind of comparison:

net/core/net-sysfs.c

static inline int dev_isalive(const struct net_device *dev)
{
         return dev->reg_state <= NETREG_REGISTERED;
}

Not sure having NETREG_NETNS_MOVING < NETREG_REGISTERED is right.


> The other users of reg_state should be fine AFAICT.
>
> On Tue, Aug 24, 2010 at 12:14:31PM -0700, Eric W. Biederman wrote:
>    
>>>> --
>>>> previously, if a vlan master device was moved from one network namespace
>>>> to another, all 802.1q and macvlan slaves were deleted.
>>>>
>>>> we can use dev->reg_state to figure out whether dev_change_net_namespace
>>>> is happening, since that won't set dev->reg_state NETREG_UNREGISTERING.
>>>> so, this changes 8021q and macvlan to ignore NETDEV_UNREGISTER when
>>>> reg_state is not NETREG_UNREGISTERING.
>>>>          
>> Agreed.  The new semantics are the desired ones.
>>
>>      
>>> Hmm, I don't feel comfortable with this change. It is like we are trying to
>>> catch a transient state, not clearly defined (you need a comment) and that may
>>> lead to some confusion later.
>>>
>>> IMHO, it should be convenient to add a NETREG_NETNS_MOVING and set this state in
>>> the dev_change_net_namespace.
>>>        
>> Interesting.  I thought you were proposing a new notification but then
>> upon looking down I see you are simply proposing a new device state.
>> As a clear and minimal set of changes to the current design that seems
>> like a good way to go.
>>      
> During creating the patch from my original mail, I had first added a
> NETDEV_NETNS_MOVING notification, but that meant to either change every
> notification user to treat NETNS_MOVING the same as UNREGISTERING (ugh)
> or to send both NETNS_MOVING and UNREGISTER and use some flag to ignore
> the second (ugly...)
>
> What could be done, alternatively, is split the notification:
>   * NETDEV_UNREGISTER - now changed to mean "logical unregister"
>   * NETDEV_UNREGISTER_PHYSICAL - _not_ sent by netns move, means
>      "the device is going for good"
>    

Maybe I miss something but that will have a big impact to all the 
network stacks no ?

>>>          /* register/unregister state machine */
>>>          enum { NETREG_UNINITIALIZED=0,
>>> +              NETREG_NETNS_MOVING,     /* changing netns */
>>>                 NETREG_REGISTERED,       /* completed register_netdevice */
>>>                 NETREG_UNREGISTERING,    /* called unregister_netdevice */
>>>                 NETREG_UNREGISTERED,     /* completed unregister todo */
>>>        
> Patch:
>
>   drivers/net/macvlan.c     |    4 ++++
>   include/linux/netdevice.h |    1 +
>   net/8021q/vlan.c          |    4 ++++
>   net/core/dev.c            |    4 ++++
>   4 files changed, 13 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index 0ef0eb0..a21602e 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -788,6 +788,10 @@ static int macvlan_device_event(struct notifier_block *unused,
>   		}
>   		break;
>   	case NETDEV_UNREGISTER:
> +		/* twiddle thumbs on netns device moves */
> +		if (dev->reg_state == NETREG_NETNS_MOVING)
> +			break;
> +
>   		list_for_each_entry_safe(vlan, next,&port->vlans, list)
>   			vlan->dev->rtnl_link_ops->dellink(vlan->dev, NULL);
>   		break;
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 59962db..df0e1a5 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1016,6 +1016,7 @@ struct net_device {
>
>   	/* register/unregister state machine */
>   	enum { NETREG_UNINITIALIZED=0,
> +	       NETREG_NETNS_MOVING,	/* in dev_change_net_namespace */
>   	       NETREG_REGISTERED,	/* completed register_netdevice */
>   	       NETREG_UNREGISTERING,	/* called unregister_netdevice */
>   	       NETREG_UNREGISTERED,	/* completed unregister todo */
> diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
> index a2ad152..f059110 100644
> --- a/net/8021q/vlan.c
> +++ b/net/8021q/vlan.c
> @@ -525,6 +525,10 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
>   		break;
>
>   	case NETDEV_UNREGISTER:
> +		/* twiddle thumbs on netns device moves */
> +		if (dev->reg_state == NETREG_NETNS_MOVING)
> +			break;
> +
>   		/* Delete all VLANs for this dev. */
>   		grp->killall = 1;
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 859e30f..0d6b8ba 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5664,6 +5664,8 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
>   	err = -ENODEV;
>   	unlist_netdevice(dev);
>
> +	dev->reg_state = NETREG_NETNS_MOVING;
> +
>   	synchronize_net();
>
>   	/* Shutdown queueing discipline. */
> @@ -5696,6 +5698,8 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
>   	err = device_rename(&dev->dev, dev->name);
>   	WARN_ON(err);
>
> +	dev->reg_state = NETREG_REGISTERED;
> +
>   	/* Add the device back in the hashes */
>   	list_netdevice(dev);
>
>    

Looks good for me.

Thanks
   -- Daniel
