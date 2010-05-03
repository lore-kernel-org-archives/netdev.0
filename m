From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: Receive issues with bonding and vlans
Date: Sun, 02 May 2010 20:04:27 -0700
Message-ID: <4BDE3D3B.3030800@intel.com>
References: <20100412221645.8068.71073.stgit@localhost6.localdomain6> <29849.1271113851@death.nxdomain.ibm.com> <20100412233509.GA32302@cleech-lnx.jf.intel.com> <2695.1271117318@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Leech, Christopher" <christopher.leech@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>,
	Patrick McHardy <kaber@trash.net>,
	"bonding-devel@lists.sourceforge.net"
	<bonding-devel@lists.sourceforge.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:11233 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754047Ab0ECDEa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 May 2010 23:04:30 -0400
In-Reply-To: <2695.1271117318@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> Chris Leech <christopher.leech@intel.com> wrote:
> 
>> On Mon, Apr 12, 2010 at 04:10:51PM -0700, Jay Vosburgh wrote:
>>> 	Is the FCoE supposed to run over the inactive bonding slave?  Or
>>> am I misunderstanding what you're saying?  I had thought the LLDP, et
>>> al, special case in bonding was to permit, essentially, path discovery,
>>> not necessarily active use of the inactive slave.
>> That's what I'm trying to do, yes.  Mostly because it's a setup that
>> would work if you removed the FCoE traffic from the network data path,
>> and only converged at the driver level and below.  It's possible that
>> the answer is "don't do that".
> 
> 	So, basically, you want the bond to act like usual for "regular"
> ethernet traffic, but act like the slaves are independent from the bond
> for the magic FCoE traffic, right?
> 
> 	I'm not really sure if that's a "don't do that" or not.
> 
>>> 	Not that this is necessarily bad; the "drop stuff on inactive
>>> slaves" is really there for duplicate suppression, but it also can
>>> uncover network topology issues, e.g., network layouts that won't work
>>> if the devices fail, but appear to work during testing because the
>>> "inactive" slave still receives traffic (it hasn't really failed).
>>>
>>>> The problem is that it doesn't work for hardware accelerated VLAN
>>>> devices, because the VLAN receive paths have their own
>>>> skb_bond_should_drop calls that were not updated.
>>>>
>>> >From what I can tell, VLAN receives always end up going through
>>>> netif_receive_skb anyway, so skb_bond_should_drop gets called twice if
>>>> the frame isn't dropped the first time.  I think the bonding checks in
>>>> __vlan_hwaccel_rx and vlan_gro_common should just be removed.
>>> 	I'm not so sure.  The checks in __vlan_hwaccel_rx are done with
>>> the original receiving device in skb->dev; by the time the packet gets
>>> to netif_receive_skb, the original slave the packet was received on has
>>> been lost (and replaced with the VLAN device).  Various things are
>>> interested in that, in particular the "arp_validate" and the "inactive
>>> slave drop" logic for bonding depend on knowing the real device the
>>> packet arrived on.
>>>
>>> 	I note that the vlan accel logic doesn't change skb_iif to the
>>> VLAN device; it remains as the original device.  I suppose one
>>> alternative would be to convert the bonding drop, et al, logic to use
>>> skb_iif instead of skb->dev; if that works, then I think the VLAN core
>>> would not need to call skb_bond_should_drop, which in turn would be a
>>> bit more complicated as it would have to look up the dev from the
>>> skb_iif.  There's already some code in bonding that takes advantage of
>>> this property of the VLANs, so maybe this is the way to go.
>> Thanks, I'll take another look and see if I can come up with something
>> better.
> 
> 	I looked at the skb_bond_should_drop stuff a bit more after I
> wrote that; it's not as easy as I had suspected.  The big sticking point
> is that currently the test in netif_receive_skb (now __netif_receive_skb
> in net-next-2.6) is on skb->dev->master to identify packets arriving on
> slaves of bonding.  The VLAN skb->dev has ->master set to NULL.  Doing
> that test against skb->skb_iif would be much more expensive, as it would
> require a device lookup for every packet.
> 
> 	So, I suspect that something has to happen in the VLAN
> acceleration path, although I don't know exactly what.  I don't know if
> it would be possible to flag the packets in some special way to indicate
> that they're "bonding slave" packets, or if it's better to keep the
> current structure and just fix the calls somehow.
> 
> 	-J
> 
> 

Jay,

It should be OK to allow packets to be received on the VLAN if it is not 
explicitly in the bond?

Or if we want to be more paranoid deliver packets only to handlers with 
exact matches for the device. For non vlan devices we deliver skb's to 
packet handlers that match exactly even on inactive slaves so doing this 
on vlan devices as well makes sense and shouldn't cause any unexpected 
problems.

Also on a somewhat unrelated note I suspect null_or_orig and 
null_or_bond are not working as expected in __netif_receive_skb().  At 
least the comment 'deliver only exact match' could be inaccurate.

Here's a patch to illustrate what I'm thinking compile tested only.  If 
this sounds reasonable I'll work up an official patch.


[PATCH] net: allow vlans on bonded real net_devices

For converged I/O it is reasonable to use dm_multipathing to provice
failover and load balancing for storage traffic and then use bonding
for the LAN failover and load balancing.

Currently this works if the multipathed devices are using the real
net_device and those devices are enslaved to a bonded device what
does not work is creating a vlan on the real device and trying to
use it outside the bond for multipathing.

This patch adds logic so that if the skb is destined for a vlan
that is not in the bond the skb will not be dropped.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

  net/8021q/vlan_core.c |   31 +++++++++++++++++++++----------
  net/core/dev.c        |   11 ++++++++---
  2 files changed, 29 insertions(+), 13 deletions(-)

diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index c584a0a..3bce0c3 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -8,18 +8,24 @@
  int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
  		      u16 vlan_tci, int polling)
  {
+	struct net_device *vlan_dev;
+
  	if (netpoll_rx(skb))
  		return NET_RX_DROP;

-	if (skb_bond_should_drop(skb, ACCESS_ONCE(skb->dev->master)))
+	vlan_dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
+
+	if (!vlan_dev)
+		goto drop;
+
+	if ((vlan_dev->priv_flags & IFF_BONDING ||
+	    vlan_dev_real_dev(vlan_dev)->flags & IFF_MASTER) &&
+	    skb_bond_should_drop(skb, ACCESS_ONCE(skb->dev->master)))
  		goto drop;

  	skb->skb_iif = skb->dev->ifindex;
  	__vlan_hwaccel_put_tag(skb, vlan_tci);
-	skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
-
-	if (!skb->dev)
-		goto drop;
+	skb->dev = vlan_dev;

  	return (polling ? netif_receive_skb(skb) : netif_rx(skb));

@@ -82,16 +88,21 @@ vlan_gro_common(struct napi_struct *napi, struct 
vlan_group *grp,
  		unsigned int vlan_tci, struct sk_buff *skb)
  {
  	struct sk_buff *p;
+	struct net_device *vlan_dev;

-	if (skb_bond_should_drop(skb, ACCESS_ONCE(skb->dev->master)))
+	vlan_dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
+
+	if (!vlan_dev)
+		goto drop;
+
+	if ((vlan_dev->priv_flags & IFF_BONDING ||
+	    vlan_dev_real_dev(vlan_dev)->flags & IFF_MASTER) &&
+	    skb_bond_should_drop(skb, ACCESS_ONCE(skb->dev->master)))
  		goto drop;

  	skb->skb_iif = skb->dev->ifindex;
  	__vlan_hwaccel_put_tag(skb, vlan_tci);
-	skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
-
-	if (!skb->dev)
-		goto drop;
+	skb->dev = vlan_dev;

  	for (p = napi->gro_list; p; p = p->next) {
  		NAPI_GRO_CB(p)->same_flow =
diff --git a/net/core/dev.c b/net/core/dev.c
index 100dcbd..9ea4550 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2780,6 +2780,7 @@ static int __netif_receive_skb(struct sk_buff *skb)
  	struct net_device *master;
  	struct net_device *null_or_orig;
  	struct net_device *null_or_bond;
+	struct net_device *real_dev;
  	int ret = NET_RX_DROP;
  	__be16 type;

@@ -2853,9 +2854,13 @@ ncls:
  	 * handler may have to adjust skb->dev and orig_dev.
  	 */
  	null_or_bond = NULL;
-	if ((skb->dev->priv_flags & IFF_802_1Q_VLAN) &&
-	    (vlan_dev_real_dev(skb->dev)->priv_flags & IFF_BONDING)) {
-		null_or_bond = vlan_dev_real_dev(skb->dev);
+	if ((skb->dev->priv_flags & IFF_802_1Q_VLAN)) {
+		real_dev = vlan_dev_real_dev(skb->dev);
+		if (real_dev->priv_flags & IFF_BONDING)
+			null_or_bond = vlan_dev_real_dev(skb->dev);
+		if (!(skb->dev->priv_flags & IFF_BONDING) &&
+		    real_dev->priv_flags & IFF_SLAVE_INACTIVE)
+			null_or_orig = skb->dev;
  	}

  	type = skb->protocol;
