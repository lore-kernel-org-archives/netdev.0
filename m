From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH RFC] netns: keep vlan slaves on master netns move
Date: Tue, 24 Aug 2010 12:14:31 -0700
Message-ID: <m1tymjg6w8.fsf@fess.ebiederm.org>
References: <20100824115056.GA235835@jupiter.n2.diac24.net>
	<4C73FAB8.1090402@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:46742 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755148Ab0HXXuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 19:50:37 -0400
In-Reply-To: <4C73FAB8.1090402@free.fr> (Daniel Lezcano's message of "Tue, 24
	Aug 2010 19:00:40 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Lezcano <daniel.lezcano@free.fr> writes:

> On 08/24/2010 01:50 PM, David Lamparter wrote:
>> Hi everyone,
>>
>> attached patch makes it possible to keep macvlan / 802.1q slave devices
>> on moving their master to a different namespace. as the opposite works
>> without problems (moving the slaves into a different namespace), this
>> shouldn't cause problems either.
>>
>> i've tested this with 802.1q on real ethernet devs and bridges and,
>> well, it works without crashing, but that obviously doesn't mean it is
>> correct :) - therefore input very welcome.
>>
>> RFC,
>>
>> David
>>
>> P.S.: who do i Cc: on netns related stuff?
>
> Definitively the netns is the brain child of:
> Eric W. Biederman <ebiederm@xmission.com>
>
> As I contributed and I am interested by following the changes, that will be nice
> if you can Cc me too.
>
> Daniel Lezcano <daniel.lezcano@free.fr>
>
>> --
>> previously, if a vlan master device was moved from one network namespace
>> to another, all 802.1q and macvlan slaves were deleted.
>>
>> we can use dev->reg_state to figure out whether dev_change_net_namespace
>> is happening, since that won't set dev->reg_state NETREG_UNREGISTERING.
>> so, this changes 8021q and macvlan to ignore NETDEV_UNREGISTER when
>> reg_state is not NETREG_UNREGISTERING.

Agreed.  The new semantics are the desired ones.
>>
>> Signed-off-by: David Lamparter<equinox@diac24.net>
>> ---
>>   drivers/net/macvlan.c |    4 ++++
>>   net/8021q/vlan.c      |    4 ++++
>>   net/core/dev.c        |    4 ++++
>>   3 files changed, 12 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
>> index f15fe2c..f43f8e4 100644
>> --- a/drivers/net/macvlan.c
>> +++ b/drivers/net/macvlan.c
>> @@ -754,6 +754,10 @@ static int macvlan_device_event(struct notifier_block *unused,
>>   		}
>>   		break;
>>   	case NETDEV_UNREGISTER:
>> +		/* twiddle thumbs on netns device moves */
>> +		if (dev->reg_state != NETREG_UNREGISTERING)
>> +			break;
>> +
>
> Hmm, I don't feel comfortable with this change. It is like we are trying to
> catch a transient state, not clearly defined (you need a comment) and that may
> lead to some confusion later.
>
> IMHO, it should be convenient to add a NETREG_NETNS_MOVING and set this state in
> the dev_change_net_namespace.

Interesting.  I thought you were proposing a new notification but then
upon looking down I see you are simply proposing a new device state.
As a clear and minimal set of changes to the current design that seems
like a good way to go.

As a long term direction I suspect we might want to create an ethernet
device abstraction that can transmit and receive packets and move the
vlan, macvlan abstractions into it.  Having them exist as side cars
on the real network device gets us into a number of odd situations.

I was thinking we might want to move the dellink to somewhere else, but
since the list we want to traverse is in the vlan or macvlan specific
data it doesn't look like we can.  It is a real shame those extra
dellink calls cannot participate in batching.  Especially as that is one
of those places where we can expect real gains from batching.

Hmm.. It looks like the vlan devices mostly participate in batching,
although not in the same batch as their parent device, and it is simply
an implementation bug that the macvlan devices don't participate in
batch.

There has got to be a better more general way to handle this and prevent
the unnecessary code duplication and divergence between vlan and macvlan
devices.  Unfortunately I am not seeing it at the moment.

Eric

> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 5c6f519..0214b77 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -924,6 +924,7 @@ struct net_device {
>
>         /* register/unregister state machine */
>         enum { NETREG_UNINITIALIZED=0,
> +              NETREG_NETNS_MOVING,     /* changing netns */
>                NETREG_REGISTERED,       /* completed register_netdevice */
>                NETREG_UNREGISTERING,    /* called unregister_netdevice */
>                NETREG_UNREGISTERED,     /* completed unregister todo */
> diff --git a/net/core/dev.c b/net/core/dev.c
> index e233933..9154123 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5752,6 +5752,8 @@ int dev_change_net_namespace(struct net_device *dev,
> struct net *net, const char
>         err = -ENODEV;
>         unlist_netdevice(dev);
>
> +       dev->reg_state = NETREG_NETNS_MOVING;
> +
>         synchronize_net();
>
>         /* Shutdown queueing discipline. */
> @@ -5786,6 +5788,8 @@ int dev_change_net_namespace(struct net_device *dev,
> struct net *net, const char
>         err = netdev_register_kobject(dev);
>         WARN_ON(err);
>
> +       dev->reg_state = NETREG_REGISTERED;
> +
>         /* Add the device back in the hashes */
>         list_netdevice(dev);
>
>
> Then you can check in macvlan_device_event
>
> 	...
>
> 	if (dev->reg_state != NETREG_NETNS_MOVING)
> 		break;
>
> 	...
>
>
> Does it make sense ?
>
>   -- Daniel
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
