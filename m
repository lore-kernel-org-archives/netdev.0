From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH] core: Add ioctls to control device unicast hw
 addresses
Date: Tue, 26 Feb 2013 18:07:49 -0800
Message-ID: <20130227020744.GA25063@nitbit.x32>
References: <20130226.150309.1215210522427869530.davem@davemloft.net>
 <512D1A01.9020301@redhat.com>
 <512D300F.20405@intel.com>
 <20130226.171503.1736601811583226926.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john.r.fastabend@intel.com, vyasevic@redhat.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:51387 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758346Ab3B0CKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 21:10:39 -0500
Received: by mail-oa0-f41.google.com with SMTP id i10so135204oag.0
        for <netdev@vger.kernel.org>; Tue, 26 Feb 2013 18:10:39 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20130226.171503.1736601811583226926.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 26, 2013 at 05:15:03PM -0500, David Miller wrote:
> From: John Fastabend <john.r.fastabend@intel.com>
> Date: Tue, 26 Feb 2013 13:58:39 -0800
> 
> > [...]
> > 
> >>>>
> >>>>
> >>>> [RFC PATCH] rtnetlink: Add support for adding/removing additional hw
> >>>> addresses.
> >>>>
> >>>> Add an ability to add and remove HW addresses to the device
> >>>> unicast and multicast address lists.  Right now, we only have
> >>>> an ioctl() to manage the multicast addresses and there is no
> >>>> way the manage the unicast list.
> >>>>
> >>>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> >>>
> >>> This is a step in the right direction, and you're right that there is
> >>> a difficulty in detecting whether support exists or not.
> >>>
> >>> I am so surprised that we've have ->set_rx_mode() support for multiple
> >>> unicast MAC addresses in so many drivers all this time, yet no way
> >>> outside of FDB to make use of it at all.
> >>
> >> And even that is not always available.  In most drivers it requires
> >> module parameters or other explicit configuration steps.  Meanwhile
> >> set_rx_mode() doesn't seem to depend on any of those and just does the
> >> right thing.
> >>
> >> For what I was trying to do ioctl() was a really easy way out for both
> >> kernel and user space implementation, so I gave is shot.
> >>
> >> -vlad
> >>
> > 
> > Don't we already support this with
> 
> The whole point is that these multiple-unicast-address configuration
> facilities are inaccessible without FDB, and there is no reason
> whatsoever for that.

Yes I see now sorry I was behind the thread.

We could just use the fdb hooks and add a dflt routine to handle the
case where the netdev doesn't provide a specific ndo_op for us. This
boils down to calling set_rx_mode anyways through this call chain,

   ndo_fdb_add
	dev_uc_add_excl
		__dev_set_rx_mode
			ndo_set_rx_mode

As long as folks don't think this is too much of an abuse of the fdb
hooks. Here's an example I only compile tested this so take it as
an example only. It probably needs some cleanups and the dump routine
needs some thought not sure you want to dump all MACs always.


[RFC PATCH] net: fdb: generic set support for drivers without ndo_op

If the driver does not support the ndo_op use the generic
handler for it. This should work in the majority of cases.
Eventually the fdb_dflt_add call gets translated into a
__dev_set_rx_mode() call which should handle hardware
support for filtering via the IFF_UNICAST_FLT flag.

Namely IFF_UNICAST_FLT indicates if the hardware can do
unicast address filtering. If no support is available
the device is put into promisc mode.

It looks like we likely also need IFF_MULTICAST_FLT and
also tighten up how drivers handle multicast filters. But
thats another patch.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/core/rtnetlink.c |   80 ++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 74 insertions(+), 6 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d8aa20f..d1c6f71 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2049,6 +2049,37 @@ errout:
 	rtnl_set_sk_err(net, RTNLGRP_NEIGH, err);
 }
 
+/**
+ * ndo_dflt_fdb_add - default netdevice operation to add an FDB entry
+ */
+static int ndo_dflt_fdb_add(struct ndmsg *ndm,
+			    struct nlattr *tb[],
+			    struct net_device *dev,
+			    const unsigned char *addr,
+			    u16 flags)
+{
+	int err = -EINVAL;
+
+	/* If aging addresses are supported device will need to
+	 * implement its own handler for this.
+	 */
+	if (ndm->ndm_state && !(ndm->ndm_state & NUD_PERMANENT)) {
+		pr_info("%s: FDB only supports static addresses\n", dev->name);
+		return err;
+	}
+
+	if (is_unicast_ether_addr(addr) || is_link_local_ether_addr(addr))
+		err = dev_uc_add_excl(dev, addr);
+	else if (is_multicast_ether_addr(addr))
+		err = dev_mc_add_excl(dev, addr);
+
+	/* Only return duplicate errors if NLM_F_EXCL is set */
+	if (err == -EEXIST && !(flags & NLM_F_EXCL))
+		err = 0;
+
+	return err;
+}
+
 static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct net *net = sock_net(skb->sk);
@@ -2101,10 +2132,14 @@ static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	}
 
 	/* Embedded bridge, macvlan, and any other device support */
-	if ((ndm->ndm_flags & NTF_SELF) && dev->netdev_ops->ndo_fdb_add) {
-		err = dev->netdev_ops->ndo_fdb_add(ndm, tb,
-						   dev, addr,
-						   nlh->nlmsg_flags);
+	if ((ndm->ndm_flags & NTF_SELF)) {
+		if (dev->netdev_ops->ndo_fdb_add)
+			err = dev->netdev_ops->ndo_fdb_add(ndm, tb,
+						   	   dev, addr,
+						   	   nlh->nlmsg_flags);
+		else
+			err = ndo_dflt_fdb_add(ndm, tb, dev, addr,
+					       nlh->nlmsg_flags);
 
 		if (!err) {
 			rtnl_fdb_notify(dev, addr, RTM_NEWNEIGH);
@@ -2115,6 +2150,34 @@ out:
 	return err;
 }
 
+/**
+ * ndo_dflt_fdb_del - default netdevice operation to delete an FDB entry
+ */
+static int ndo_dflt_fdb_del(struct ndmsg *ndm,
+			    struct nlattr *tb[],
+			    struct net_device *dev,
+			    const unsigned char *addr)
+{
+	int err = -EOPNOTSUPP;
+
+	/* If aging addresses are supported device will need to
+	 * implement its own handler for this.
+	 */
+	if (ndm->ndm_state & NUD_PERMANENT) {
+		pr_info("%s: FDB only supports static addresses\n", dev->name);
+		return -EINVAL;
+	}
+
+	if (is_unicast_ether_addr(addr))
+		err = dev_uc_del(dev, addr);
+	else if (is_multicast_ether_addr(addr))
+		err = dev_mc_del(dev, addr);
+	else
+		err = -EINVAL;
+
+	return err;
+}
+
 static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct net *net = sock_net(skb->sk);
@@ -2172,8 +2235,11 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	}
 
 	/* Embedded bridge, macvlan, and any other device support */
-	if ((ndm->ndm_flags & NTF_SELF) && dev->netdev_ops->ndo_fdb_del) {
-		err = dev->netdev_ops->ndo_fdb_del(ndm, tb, dev, addr);
+	if (ndm->ndm_flags & NTF_SELF) {
+		if (dev->netdev_ops->ndo_fdb_del)
+			err = dev->netdev_ops->ndo_fdb_del(ndm, tb, dev, addr);
+		else
+			err = ndo_dflt_fdb_del(ndm, tb, dev, addr);
 
 		if (!err) {
 			rtnl_fdb_notify(dev, addr, RTM_DELNEIGH);
@@ -2258,6 +2324,8 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
 
 		if (dev->netdev_ops->ndo_fdb_dump)
 			idx = dev->netdev_ops->ndo_fdb_dump(skb, cb, dev, idx);
+		else
+			ndo_dflt_fdb_dump(skb, cb, dev, idx);
 	}
 	rcu_read_unlock();
 
