From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH RFC] netns: keep vlan slaves on master netns move
Date: Tue, 14 Sep 2010 19:10:01 -0700
Message-ID: <m1bp7z4v0m.fsf@fess.ebiederm.org>
References: <20100824115056.GA235835@jupiter.n2.diac24.net>
	<20100913114315.GA859019@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Daniel Lezcano <daniel.lezcano@free.fr>,
	Patrick McHardy <kaber@trash.net>,
	David Lamparter <equinox@diac24.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:60490 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751536Ab0IOCKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 22:10:12 -0400
In-Reply-To: <20100913114315.GA859019@jupiter.n2.diac24.net> (David
	Lamparter's message of "Mon, 13 Sep 2010 13:43:15 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Reviewed-by: "Eric W. Biederman" <ebiederm@xmission.com>

My inclination is that the best way to handle this is to would be to
push the device deletion for vlan and macvlan devices into the device
core, where we could get the advantage of batched deletions.  Right
now vlan and macvlan devices are the only devices I know of that cause
other devices to be removed during unregister, so removing that
specialness seems reasonable.

However not being able to move the primary vlan to a different network
namespace is usability bug with no real alternatives.  There are
not any other patches on the table right now, and your patch below
seems obviously correct.  Let's get this merged before we forget about
this, bug fix.

David Lamparter <equinox@diac24.net> writes:

> previously, if a vlan master device was moved from one network namespace
> to another, all 802.1q and macvlan slaves were deleted.
>
> we can use dev->reg_state to figure out whether dev_change_net_namespace
> is happening, since that won't set dev->reg_state NETREG_UNREGISTERING.
> so, this changes 8021q and macvlan to ignore NETDEV_UNREGISTER when
> reg_state is not NETREG_UNREGISTERING.
>
> Signed-off-by: David Lamparter <equinox@diac24.net>
> --
>
> On Tue, Aug 24, 2010 at 01:50:56PM +0200, David Lamparter wrote:
>> attached patch makes it possible to keep macvlan / 802.1q slave devices
>> on moving their master to a different namespace. as the opposite works
>> without problems (moving the slaves into a different namespace), this
>> shouldn't cause problems either.
>
> I would like to resurrect this. After the small excursion into
> NETREG_NETNS_MOVING i've reevaluated my personal opinion and think the
> behaviour is the desired one and this patch is the cleanest way to
> implement it. While it depends on somewhat "fine print" on the reg_state
> state machine, the probability of major screw-ups in this region is
> rather small and it also quite likely makes a nice large boom when it is
> unduly tampered with.
>
>
> -David
>
>
>  drivers/net/macvlan.c |    4 ++++
>  net/8021q/vlan.c      |    4 ++++
>  net/core/dev.c        |    4 ++++
>  3 files changed, 12 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index f15fe2c..f43f8e4 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -754,6 +754,10 @@ static int macvlan_device_event(struct notifier_block *unused,
>  		}
>  		break;
>  	case NETDEV_UNREGISTER:
> +		/* twiddle thumbs on netns device moves */
> +		if (dev->reg_state != NETREG_UNREGISTERING)
> +			break;
> +
>  		list_for_each_entry_safe(vlan, next, &port->vlans, list)
>  			vlan->dev->rtnl_link_ops->dellink(vlan->dev, NULL);
>  		break;
> diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
> index 3c1c8c1..cdc37e8 100644
> --- a/net/8021q/vlan.c
> +++ b/net/8021q/vlan.c
> @@ -516,6 +516,10 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
>  		break;
>  
>  	case NETDEV_UNREGISTER:
> +		/* twiddle thumbs on netns device moves */
> +		if (dev->reg_state != NETREG_UNREGISTERING)
> +			break;
> +
>  		/* Delete all VLANs for this dev. */
>  		grp->killall = 1;
>  
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 1f466e8..b1589bc 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5618,6 +5618,10 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
>  
>  	/* Notify protocols, that we are about to destroy
>  	   this device. They should clean all the things.
> +
> +	   Note that dev->reg_state stays at NETREG_REGISTERED.
> +	   This is wanted because this way 8021q and macvlan know
> +	   the device is just moving and can keep their slaves up.
>  	*/
>  	call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
>  	call_netdevice_notifiers(NETDEV_UNREGISTER_BATCH, dev);
