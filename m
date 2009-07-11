From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: need help with wireless netns crash
Date: Sat, 11 Jul 2009 11:22:41 +0200
Message-ID: <1247304161.30647.83.camel@johannes.local>
References: <1247302033.30647.72.camel@johannes.local>
	 <m11vonsi1p.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:33781 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454AbZGKJWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jul 2009 05:22:45 -0400
In-Reply-To: <m11vonsi1p.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-07-11 at 02:08 -0700, Eric W. Biederman wrote:

> > And ... should they actually be reparented to init_net anyway? It seems
> > they should go to the parent of the ns if such a concept exists, since
> > namespaces would seem to follow the task hierarchy? If I create a netns
> > and from _within_ that create yet another netns it would seem that the
> > outer netns would get its interfaces back when the inner done goes away,
> > rather than its parent task's netns getting them.
> 
> Reparenting to init_net happens for real network devices because we
> don't know what to do with them and there is no true hierarchy of
> network namespaces.  Virtual network devices at least ones that implement
> rtnl_link_ops->dellink we destroy automatically.

Right, I could try to destroy them too, but not all wireless interfaces
can be destroyed. Seemed easier to just move them all.

As for the hierarchy -- I would think it follows the task hierarchy? Not
that it matters to me at all where they go when the netns dies!

> The code for moving a network device between namespaces during
> exit is in default_device_exit.  If NETIF_F_NETNS_LOCAL is set
> it shouldn't trigger.

Right. I set that flag on my interfaces because we have this kind of
hierarchy:

wireless hw (phy0)
	- interface 1
	- interface 2
	- ...

and we want them all to be in the same netns together -- so I set the
flag to disallow moving, and provide a new tool (iw phy0 set netns pid)
to set the netns for the entire group.

(and each wireless hw only shows up in one netns too, due to the generic
netlink support for that kind of thing I did recently)

> It sounds like you have both network device and subsystem level
> cleanup.
> 
> In which case you probably want to split the code and use both
> register_pernet_device and register_pernet_subsystem.
> 
> As for the initial comment.  Things are setup so that all network
> devices are removed from a network namespace before subsystem level
> cleanup happens.  This prevents all sorts of nasty cleanup races
> with packets flying while a network namespace is being destroyed.
> 
> Hope that helps. If not I will try and take a more indepth look
> in a bit.

Based on that explanation, I think I really should use the device
notifier. The only thing I do is manually do the reparenting:

static void __net_exit cfg80211_pernet_exit(struct net *net)
{
        struct cfg80211_registered_device *rdev;

        rtnl_lock();
        mutex_lock(&cfg80211_mutex);
        list_for_each_entry(rdev, &cfg80211_rdev_list, list) {
                if (net_eq(wiphy_net(&rdev->wiphy), net))
                        WARN_ON(cfg80211_switch_netns(rdev, &init_net));
        }
        mutex_unlock(&cfg80211_mutex);
        rtnl_unlock();
}

cfg80211_switch_netns() moves the entire group of the wireless hw
abstraction and its associated interfaces.

Thanks for the explanation. Now I think I understand the comment too,
but before it wasn't really clear to me. How about the patch below to
the explanation?

johannes

From: Johannes Berg <johannes@sipsolutions.net>
Subject: explain netns notifiers a little better

Eric explained this to me -- and afterwards the comment
made sense, but not before. Add the the critical point
about interfaces having to be gone from the netns before
subsys notifiers are called.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
 include/net/net_namespace.h |   16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

--- wireless-testing.orig/include/net/net_namespace.h	2009-07-11 11:18:20.000000000 +0200
+++ wireless-testing/include/net/net_namespace.h	2009-07-11 11:20:49.000000000 +0200
@@ -239,13 +239,15 @@ struct pernet_operations {
  * needs per network namespace operations use device pernet operations,
  * otherwise use pernet subsys operations.
  *
- * This is critically important.  Most of the network code cleanup
- * runs with the assumption that dev_remove_pack has been called so no
- * new packets will arrive during and after the cleanup functions have
- * been called.  dev_remove_pack is not per namespace so instead the
- * guarantee of no more packets arriving in a network namespace is
- * provided by ensuring that all network devices and all sockets have
- * left the network namespace before the cleanup methods are called.
+ * Network interfaces need to be removed from a dying netns _before_
+ * subsys notifiers can be called, as most of the network code cleanup
+ * (which is done from subsys notifiers) runs with the assumption that
+ * dev_remove_pack has been called so no new packets will arrive during
+ * and after the cleanup functions have been called.  dev_remove_pack
+ * is not per namespace so instead the guarantee of no more packets
+ * arriving in a network namespace is provided by ensuring that all
+ * network devices and all sockets have left the network namespace
+ * before the cleanup methods are called.
  *
  * For the longest time the ipv4 icmp code was registered as a pernet
  * device which caused kernel oops, and panics during network


