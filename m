From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH RFC] netns: introduce NETREG_NETNS_MOVING reg_state
Date: Wed, 25 Aug 2010 13:52:13 +0200
Message-ID: <20100825115213.GB235835@jupiter.n2.diac24.net>
References: <20100824115056.GA235835@jupiter.n2.diac24.net>
 <4C73FAB8.1090402@free.fr>
 <m1tymjg6w8.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Lezcano <daniel.lezcano@free.fr>,
	David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:56768 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753021Ab0HYLw0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Aug 2010 07:52:26 -0400
Content-Disposition: inline
In-Reply-To: <m1tymjg6w8.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

previously, if a vlan master device was moved from one network namespace
to another, all 802.1q and macvlan slaves were deleted.

that deletion is handled through the NETDEV_UNREGISTER notifier, which,
as such, works well and is probably the right thing to do as a moving
device really is disappearing for all higher-up users.

now, to allow 8021q and macvlan to keep their slaves, we can tell them
through dev->reg_state that this is a logical unregister and not a
physical one. reg_state == NETREG_NETNS_MOVING does exactly this.

Signed-off-by: David Lamparter <equinox@diac24.net>
---

Please note that i'm quite unsure about the correctness of this
patch due to me not having much experience in this kind of
modification...

In particular, the following might get broken by the new reg_state:
drivers/net/ixgbe/ixgbe_main.c (hot-unplug)
drivers/net/wimax/i2400m/driver.c (device reset)

The other users of reg_state should be fine AFAICT.

On Tue, Aug 24, 2010 at 12:14:31PM -0700, Eric W. Biederman wrote:
> >> --
> >> previously, if a vlan master device was moved from one network namespace
> >> to another, all 802.1q and macvlan slaves were deleted.
> >>
> >> we can use dev->reg_state to figure out whether dev_change_net_namespace
> >> is happening, since that won't set dev->reg_state NETREG_UNREGISTERING.
> >> so, this changes 8021q and macvlan to ignore NETDEV_UNREGISTER when
> >> reg_state is not NETREG_UNREGISTERING.
> 
> Agreed.  The new semantics are the desired ones.
>
> > Hmm, I don't feel comfortable with this change. It is like we are trying to
> > catch a transient state, not clearly defined (you need a comment) and that may
> > lead to some confusion later.
> >
> > IMHO, it should be convenient to add a NETREG_NETNS_MOVING and set this state in
> > the dev_change_net_namespace.
> 
> Interesting.  I thought you were proposing a new notification but then
> upon looking down I see you are simply proposing a new device state.
> As a clear and minimal set of changes to the current design that seems
> like a good way to go.

During creating the patch from my original mail, I had first added a
NETDEV_NETNS_MOVING notification, but that meant to either change every
notification user to treat NETNS_MOVING the same as UNREGISTERING (ugh)
or to send both NETNS_MOVING and UNREGISTER and use some flag to ignore
the second (ugly...)

What could be done, alternatively, is split the notification:
 * NETDEV_UNREGISTER - now changed to mean "logical unregister"
 * NETDEV_UNREGISTER_PHYSICAL - _not_ sent by netns move, means
    "the device is going for good"

> >         /* register/unregister state machine */
> >         enum { NETREG_UNINITIALIZED=0,
> > +              NETREG_NETNS_MOVING,     /* changing netns */
> >                NETREG_REGISTERED,       /* completed register_netdevice */
> >                NETREG_UNREGISTERING,    /* called unregister_netdevice */
> >                NETREG_UNREGISTERED,     /* completed unregister todo */

Patch:

 drivers/net/macvlan.c     |    4 ++++
 include/linux/netdevice.h |    1 +
 net/8021q/vlan.c          |    4 ++++
 net/core/dev.c            |    4 ++++
 4 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 0ef0eb0..a21602e 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -788,6 +788,10 @@ static int macvlan_device_event(struct notifier_block *unused,
 		}
 		break;
 	case NETDEV_UNREGISTER:
+		/* twiddle thumbs on netns device moves */
+		if (dev->reg_state == NETREG_NETNS_MOVING)
+			break;
+
 		list_for_each_entry_safe(vlan, next, &port->vlans, list)
 			vlan->dev->rtnl_link_ops->dellink(vlan->dev, NULL);
 		break;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 59962db..df0e1a5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1016,6 +1016,7 @@ struct net_device {
 
 	/* register/unregister state machine */
 	enum { NETREG_UNINITIALIZED=0,
+	       NETREG_NETNS_MOVING,	/* in dev_change_net_namespace */
 	       NETREG_REGISTERED,	/* completed register_netdevice */
 	       NETREG_UNREGISTERING,	/* called unregister_netdevice */
 	       NETREG_UNREGISTERED,	/* completed unregister todo */
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index a2ad152..f059110 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -525,6 +525,10 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 		break;
 
 	case NETDEV_UNREGISTER:
+		/* twiddle thumbs on netns device moves */
+		if (dev->reg_state == NETREG_NETNS_MOVING)
+			break;
+
 		/* Delete all VLANs for this dev. */
 		grp->killall = 1;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 859e30f..0d6b8ba 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5664,6 +5664,8 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	err = -ENODEV;
 	unlist_netdevice(dev);
 
+	dev->reg_state = NETREG_NETNS_MOVING;
+
 	synchronize_net();
 
 	/* Shutdown queueing discipline. */
@@ -5696,6 +5698,8 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	err = device_rename(&dev->dev, dev->name);
 	WARN_ON(err);
 
+	dev->reg_state = NETREG_REGISTERED;
+
 	/* Add the device back in the hashes */
 	list_netdevice(dev);
 
-- 
1.7.0.4


