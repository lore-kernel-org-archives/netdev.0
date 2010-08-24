From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH RFC] netns: keep vlan slaves on master netns move
Date: Tue, 24 Aug 2010 19:00:40 +0200
Message-ID: <4C73FAB8.1090402@free.fr>
References: <20100824115056.GA235835@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.17.166]:56716 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755372Ab0HXRAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 13:00:43 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.1/8.13.1) with ESMTP id o7OH0gLx027155
	for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 17:00:42 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7OH0fm93977470
	for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 19:00:41 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o7OH0fKm027819
	for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 19:00:41 +0200
In-Reply-To: <20100824115056.GA235835@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/2010 01:50 PM, David Lamparter wrote:
> Hi everyone,
>
> attached patch makes it possible to keep macvlan / 802.1q slave devices
> on moving their master to a different namespace. as the opposite works
> without problems (moving the slaves into a different namespace), this
> shouldn't cause problems either.
>
> i've tested this with 802.1q on real ethernet devs and bridges and,
> well, it works without crashing, but that obviously doesn't mean it is
> correct :) - therefore input very welcome.
>
> RFC,
>
> David
>
> P.S.: who do i Cc: on netns related stuff?

Definitively the netns is the brain child of:
Eric W. Biederman <ebiederm@xmission.com>

As I contributed and I am interested by following the changes, that will 
be nice if you can Cc me too.

Daniel Lezcano <daniel.lezcano@free.fr>

> --
> previously, if a vlan master device was moved from one network namespace
> to another, all 802.1q and macvlan slaves were deleted.
>
> we can use dev->reg_state to figure out whether dev_change_net_namespace
> is happening, since that won't set dev->reg_state NETREG_UNREGISTERING.
> so, this changes 8021q and macvlan to ignore NETDEV_UNREGISTER when
> reg_state is not NETREG_UNREGISTERING.
>
> Signed-off-by: David Lamparter<equinox@diac24.net>
> ---
>   drivers/net/macvlan.c |    4 ++++
>   net/8021q/vlan.c      |    4 ++++
>   net/core/dev.c        |    4 ++++
>   3 files changed, 12 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index f15fe2c..f43f8e4 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -754,6 +754,10 @@ static int macvlan_device_event(struct notifier_block *unused,
>   		}
>   		break;
>   	case NETDEV_UNREGISTER:
> +		/* twiddle thumbs on netns device moves */
> +		if (dev->reg_state != NETREG_UNREGISTERING)
> +			break;
> +

Hmm, I don't feel comfortable with this change. It is like we are trying 
to catch a transient state, not clearly defined (you need a comment) and 
that may lead to some confusion later.

IMHO, it should be convenient to add a NETREG_NETNS_MOVING and set this 
state in the dev_change_net_namespace.

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5c6f519..0214b77 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -924,6 +924,7 @@ struct net_device {

         /* register/unregister state machine */
         enum { NETREG_UNINITIALIZED=0,
+              NETREG_NETNS_MOVING,     /* changing netns */
                NETREG_REGISTERED,       /* completed register_netdevice */
                NETREG_UNREGISTERING,    /* called unregister_netdevice */
                NETREG_UNREGISTERED,     /* completed unregister todo */
diff --git a/net/core/dev.c b/net/core/dev.c
index e233933..9154123 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5752,6 +5752,8 @@ int dev_change_net_namespace(struct net_device 
*dev, struct net *net, const char
         err = -ENODEV;
         unlist_netdevice(dev);

+       dev->reg_state = NETREG_NETNS_MOVING;
+
         synchronize_net();

         /* Shutdown queueing discipline. */
@@ -5786,6 +5788,8 @@ int dev_change_net_namespace(struct net_device 
*dev, struct net *net, const char
         err = netdev_register_kobject(dev);
         WARN_ON(err);

+       dev->reg_state = NETREG_REGISTERED;
+
         /* Add the device back in the hashes */
         list_netdevice(dev);


Then you can check in macvlan_device_event

	...

	if (dev->reg_state != NETREG_NETNS_MOVING)
		break;

	...


Does it make sense ?

   -- Daniel
