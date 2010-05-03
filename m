From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Receive issues with bonding and vlans
Date: Mon, 03 May 2010 16:17:33 -0700
Message-ID: <12574.1272928653@death.nxdomain.ibm.com>
References: <20100412221645.8068.71073.stgit@localhost6.localdomain6> <29849.1271113851@death.nxdomain.ibm.com> <20100412233509.GA32302@cleech-lnx.jf.intel.com> <2695.1271117318@death.nxdomain.ibm.com> <4BDE3D3B.3030800@intel.com> <11804.1272911110@death.nxdomain.ibm.com> <4BDF3D67.3090906@intel.com>
Cc: "Leech, Christopher" <christopher.leech@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>,
	Patrick McHardy <kaber@trash.net>,
	"bonding-devel@lists.sourceforge.net"
	<bonding-devel@lists.sourceforge.net>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:47674 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932403Ab0ECXRg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 19:17:36 -0400
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e33.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o43NDabi013557
	for <netdev@vger.kernel.org>; Mon, 3 May 2010 17:13:36 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o43NHZ0L133388
	for <netdev@vger.kernel.org>; Mon, 3 May 2010 17:17:35 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o43GHY0s024006
	for <netdev@vger.kernel.org>; Mon, 3 May 2010 10:17:35 -0600
In-reply-to: <4BDF3D67.3090906@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Fastabend <john.r.fastabend@intel.com> wrote:

>Jay Vosburgh wrote:
>> John Fastabend <john.r.fastabend@intel.com> wrote:
>>
[...]
>>> It should be OK to allow packets to be received on the VLAN if it is not
>>> explicitly in the bond?
>>
>>         Lemme see if I have this straight, because all of these special
>> cases are making my brain hurt.  This one is for a configuration like this:
>>
>>         bond0 ----- eth0
>>                    /
>>         vlan.xxx -/
>>
>>         I.e., a VLAN configured directly atop an ethernet device, said
>> ethernet also being a slave to bonding.  Is that correct?
>>
>
>Yes, this is the correct scenario that we are considering.
>
>>         Extrapolating from the ASCII art in a prior message in this
>> discussion, would this configuration really be something like this:
>>
>>         vlan.xxx -\
>>                    \
>>         bond0 ----- eth1
>>         bond0 ----- eth0
>>                    /
>>         vlan.xxx -/
>>
>>         I.e., two slaves to bonding, with VLAN xxx configured atop both
>> of the slaves?  Or would the eth0 and eth1 use discrete VLAN ids?  The
>> reason I ask is in regards to duplicate suppression.  The whole reason
>> the "inactive" slave drops (most) incoming packets is to eliminate
>> duplicates when the switch floods traffic to both slave ports.
>>
>
>These vlan ids could be the same or discrete I think both configurations
>should be valid.
>
>>         This is a bit tricky, because it's not really about broadcasts /
>> multicasts so much, but about traffic that the switch sends to all ports
>> because the switch's MAC address table isn't up to date with the
>> destination MAC of the traffic (which is a transient condition, so this
>> would only happen for perhaps one second or so).  That would result in
>> duplicate unicast packets being received by the bond (back in the day
>> before bonding had the "drop inactive traffic" logic).
>>
>>         So if the same VLAN is configured atop the two slaves, I wonder
>> if that will open a window for the duplicate unicast packet problem.
>
>OK, this does appear to open a window for duplicated unicast packets. By
>only allowing handlers with exact matches at least this issue is less
>obvious and we are assuming the packet handler can deal with this
>duplication.  This seems to be the current assumption made. The same issue
>exists today for real device in the following setup,
>
>vlan --> bond0 --> eth

	I just tested this, and I'm not seeing duplicate packets using
the test that used to show the problem before the "drop dups" logic went
in (clear the switch's mac address-table, ping -c 25 -f [peer on VLAN],
compare "packets transmitted" to "packets received").

	That doesn't mean there isn't a gap in the logic somewhere, just
that the original problem hasn't resurfaced (as far as I can tell).

>Specifically for FCoE we use the san mac address so it wouldn't be an
>issue here.  The expectation being that the switch will only ever use the
>correct san mac on the port.

	The issue arises when the switch does not have the destination
MAC in its address table, and as such is transitory, and only occurs
after sufficiently long periods of no traffic (or a manual flush of the
table).  The packets are sent to all ports until the MAC table updates
(which seems to take place asynchronously), which is usually about 1
second or so (on the midrange Cisco gear I have).

	For example, with the switch's mac address table cleared, when
starting a "ping -f" I can watch as first every port's light blinks,
then all but two stop blinking.  During the time that every port is
blinking, the switch is sending all the packets to every port because
the mac address table hasn't updated the switching logic (however that
works under the covers).



>>         If the VLAN ids are different, then I'll assume this is some
>> kind of device mapper magic, doing the load balancing elsewhere.
>
>Correct device mapper handles load balancing and failover for both cases,
>when the vlan ids are different and when they are the same.
>
>>
>>> Or if we want to be more paranoid deliver packets only to handlers with
>>> exact matches for the device. For non vlan devices we deliver skb's to
>>> packet handlers that match exactly even on inactive slaves so doing this
>>> on vlan devices as well makes sense and shouldn't cause any unexpected
>>> problems.
>>
>>         Yah, the whole concept of "inactive" slave is pretty mutated
>> now; it's kind of become the "active-backup with semi-manual load
>> balance for clever protocols, oh, and duplicate suppression" mode.
>>
>>> Also on a somewhat unrelated note I suspect null_or_orig and null_or_bond
>>> are not working as expected in __netif_receive_skb().  At least the
>>> comment 'deliver only exact match' could be inaccurate.
>>
>>         I don't think this is unrelated at all.  This code (the packet
>> to device lookup stuff in __netif_receive_skb) has been modified pretty
>> extensively lately for various bonding-related special cases, and I
>> think it is getting hard to follow.  Whatever comments are there need to
>> be accurate, and, honestly, I think this code needs comments to explain
>> what exactly is supposed to happen for these special cases.
>>
>
>Agreed.  This should be cleaned up and some explanations added.  The
>current behavior in active-backup mode is receiving packets on the bonded
>real device in active mode fails but putting that same real device in an
>inactive state will cause it to receive packets.  This is an
>inconsistency, which should probably be fixed by initializing null_or_bond
>to orig_dev.  And also renaming it orig_or_bond at that point.
>
>>> Here's a patch to illustrate what I'm thinking compile tested only.  If
>>> this sounds reasonable I'll work up an official patch.
>>>
>>>
>>> [PATCH] net: allow vlans on bonded real net_devices
>>>
>>> For converged I/O it is reasonable to use dm_multipathing to provice
>>> failover and load balancing for storage traffic and then use bonding
>>> for the LAN failover and load balancing.
>>>
>>> Currently this works if the multipathed devices are using the real
>>> net_device and those devices are enslaved to a bonded device what
>>> does not work is creating a vlan on the real device and trying to
>>> use it outside the bond for multipathing.
>>>
>>> This patch adds logic so that if the skb is destined for a vlan
>>> that is not in the bond the skb will not be dropped.
>>>
>>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>>> ---
>>>
>>> net/8021q/vlan_core.c |   31 +++++++++++++++++++++----------
>>> net/core/dev.c        |   11 ++++++++---
>>> 2 files changed, 29 insertions(+), 13 deletions(-)
>>>
>>> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
>>> index c584a0a..3bce0c3 100644
>>> --- a/net/8021q/vlan_core.c
>>> +++ b/net/8021q/vlan_core.c
>>> @@ -8,18 +8,24 @@
>>> int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
>>>                     u16 vlan_tci, int polling)
>>> {
>>> +      struct net_device *vlan_dev;
>>> +
>>>       if (netpoll_rx(skb))
>>>               return NET_RX_DROP;
>>>
>>> -      if (skb_bond_should_drop(skb, ACCESS_ONCE(skb->dev->master)))
>>> +      vlan_dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
>>> +
>>> +      if (!vlan_dev)
>>> +              goto drop;
>>> +
>>> +      if ((vlan_dev->priv_flags & IFF_BONDING ||
>>> +          vlan_dev_real_dev(vlan_dev)->flags & IFF_MASTER) &&
>>> +          skb_bond_should_drop(skb, ACCESS_ONCE(skb->dev->master)))
>>
>>         I'm not sure this will do the right thing if the VLAN device
>> itself is a slave to bonding, e.g., bond0 ---> vlan.xxx ---> eth0.  In
>> that case, eth0's dev->master is NULL, and the vlan_dev (vlan.xxx's dev)
>> doesn't have IFF_MASTER (but does have IFF_SLAVE and IFF_BONDING, I
>> believe).
>>
>
>correct, vlan_dev does have IFF_BONDING and IFF_SLAVE here and doesn't
>have IFF_MASTER.
>
>
>>         I think this will result in all incoming traffic being accepted
>> on such a configuration (leading to duplicates, as described above).
>>
>>         I suspect, but have not tested, that something like this might
>> do what you're looking for:
>>
>>         if ((vlan_dev->priv_flags & IFF_BONDING ||
>>             vlan_dev_real_dev(vlan_dev)->flags & (IFF_MASTER | IFF_SLAVE)) &&
>>             skb_bond_should_drop(skb, ACCESS_ONCE(skb->dev->master)))
>>
>>         I.e., if the VLAN device is either a MASTER (configured above
>> the bond) or a slave (configured below the bond) do the duplicate
>> suppresion.
>
>Here are the three basic cases I see,
>
>#1. vlanx --> bond0 --> ethx
>
>In this case vlanx does not have IFF_BONDING set and real_dev is ethx with
>IFF_SLAVE set.  ethx has master dev->bond0 so this should work. And shows
>why we need the IFF_SLAVE bit as you pointed out and I dropped.
>
>#2. bond  --> vlanx --> ethx
>
>This case is broke, skb->dev->master is NULL so we would never drop this
>pkt.  As it exists today I suspect this is broken as well.

	In the VLAN pass, yes, but the VLAN input path will call into
netif_receive_skb, and at that point the skb->dev is the vlan device,
and it has a dev->master.  I haven't tested this lately, but I'm fairly
sure this works.

>#3 bond0 --> ethx
>   vlanx --> -|
>
>Here is the case where adding the IFF_SLAVE bit doesn't work as I
>hoped. We don't want to run skb_bond_should_drop here.

	Yes, this is tricky because the VLAN device will copy the
dev->flags from the device it's placed atop, so the VLAN will inherit
the ethx's IFF_SLAVE flag.  This happens regardless of the setup order
(enslave ethX, then add VLAN, or vice versa).

	I suspect this case may be testable because the VLAN device has
IFF_SLAVE, but has no dev->master.

>So I think there needs to be a bit of logic here to determine if we need
>to check skb_bond_should_drop with the vlan device or with the
>skb->dev->master. Something like might do:
>
>should_drop_dev = vlan_dev->master ? vlan_dev->master : skb->dev->master
>
>This should fix case #2 without breaking case #1.  And the case I want to
>allow is still not resolved.  I'll think about this some more maybe this
>logic can be fixed for all cases.

	As I said above, I don't think case #2 is really broken now.

>
>>
>>>               goto drop;
>>>
>>>       skb->skb_iif = skb->dev->ifindex;
>>>       __vlan_hwaccel_put_tag(skb, vlan_tci);
>>> -      skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
>>> -
>>> -      if (!skb->dev)
>>> -              goto drop;
>>> +      skb->dev = vlan_dev;
>>>
>>>       return (polling ? netif_receive_skb(skb) : netif_rx(skb));
>>>
>>> @@ -82,16 +88,21 @@ vlan_gro_common(struct napi_struct *napi, struct
>>> vlan_group *grp,
>>>               unsigned int vlan_tci, struct sk_buff *skb)
>>> {
>>>       struct sk_buff *p;
>>> +      struct net_device *vlan_dev;
>>>
>>> -      if (skb_bond_should_drop(skb, ACCESS_ONCE(skb->dev->master)))
>>> +      vlan_dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
>>> +
>>> +      if (!vlan_dev)
>>> +              goto drop;
>>> +
>>> +      if ((vlan_dev->priv_flags & IFF_BONDING ||
>>> +          vlan_dev_real_dev(vlan_dev)->flags & IFF_MASTER) &&
>>> +          skb_bond_should_drop(skb, ACCESS_ONCE(skb->dev->master)))
>>>               goto drop;
>>>
>>>       skb->skb_iif = skb->dev->ifindex;
>>>       __vlan_hwaccel_put_tag(skb, vlan_tci);
>>> -      skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
>>> -
>>> -      if (!skb->dev)
>>> -              goto drop;
>>> +      skb->dev = vlan_dev;
>>>
>>>       for (p = napi->gro_list; p; p = p->next) {
>>>               NAPI_GRO_CB(p)->same_flow =
>>> diff --git a/net/core/dev.c b/net/core/dev.c
>>> index 100dcbd..9ea4550 100644
>>> --- a/net/core/dev.c
>>> +++ b/net/core/dev.c
>>> @@ -2780,6 +2780,7 @@ static int __netif_receive_skb(struct sk_buff *skb)
>>>       struct net_device *master;
>>>       struct net_device *null_or_orig;
>>>       struct net_device *null_or_bond;
>>> +      struct net_device *real_dev;
>>>       int ret = NET_RX_DROP;
>>>       __be16 type;
>>>
>>> @@ -2853,9 +2854,13 @@ ncls:
>>>        * handler may have to adjust skb->dev and orig_dev.
>>>        */
>>>       null_or_bond = NULL;
>>> -      if ((skb->dev->priv_flags & IFF_802_1Q_VLAN) &&
>>> -          (vlan_dev_real_dev(skb->dev)->priv_flags & IFF_BONDING)) {
>>> -              null_or_bond = vlan_dev_real_dev(skb->dev);
>>> +      if ((skb->dev->priv_flags & IFF_802_1Q_VLAN)) {
>>> +              real_dev = vlan_dev_real_dev(skb->dev);
>>> +              if (real_dev->priv_flags & IFF_BONDING)
>>> +                      null_or_bond = vlan_dev_real_dev(skb->dev);
>>> +              if (!(skb->dev->priv_flags & IFF_BONDING) &&
>>> +                  real_dev->priv_flags & IFF_SLAVE_INACTIVE)
>>> +                      null_or_orig = skb->dev;
>>>       }
>>>
>>>       type = skb->protocol;
>>
>>         Is this another way of accomplishing what I had suggested at the
>> end of this message:
>>
>> http://marc.info/?l=linux-netdev&m=127111386702765&w=2
>>
>>         The patch part of my suggestion was as follows:
>>
>
>I think we need the code you suggested either way, or initialize
>null_or_bond to orig_dev as I suggested above.
>
>This logic was to deliver the skb only to exact matches for this case,
>
>bond0 ---> eth0
>vlanx ---> -|
>
>Here vlanx is not in a bond and the real_dev is an inactive slave. I'll
>rethink this, but I believe only delivering this packet to handlers with
>exact matches is a good idea.  At least it is consistent with the non vlan
>case.

	Yes, the intent is that packets arriving on the inactive slaves
should only be delivered to destinations that have explicitly asked for
packets on the "inactive" devices, i.e., have bound directly to the
device, and are prepared to deal with the duplicates they may receive
(in the global sense, if a particular module has bound to multiple
bonding slaves).  Delivering to wildcards I suspect would permit
duplicates to sneak through to unexpecting code.

>>> diff --git a/net/core/dev.c b/net/core/dev.c
>>> index b98ddc6..cc665bb 100644
>>> --- a/net/core/dev.c
>>> +++ b/net/core/dev.c
>>> @@ -2735,7 +2735,7 @@ ncls:
>>>                       &ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
>>>               if (ptype->type == type && (ptype->dev == null_or_orig ||
>>>                    ptype->dev == skb->dev || ptype->dev == orig_dev ||
>>> -                   ptype->dev == null_or_bond)) {
>>> +                   (null_or_bond && (ptype->dev == null_or_bond))) {
>>>                       if (pt_prev)
>>>                               ret = deliver_skb(skb, pt_prev, orig_dev);
>>>                       pt_prev = ptype;
>>>
>>>
>>>       I haven't tested this, but the theory is to only test against
>>> null_or_bond if null_or_bond isn't NULL, which is only the case for VLAN
>>> traffic over bonding.
>>
>>         Chris Leech said "that should do it" but I don't recall seeing
>> if it actually did so in practice.
>>
>>         Or is your change meant to fix something else?
>>
>
>The missing piece with just this bit of code is if its dropped in the
>vlan_gro_common or __vlan_hwaccel_rx it never gets to the
>netif_receive_skb path.

	By this I presume you mean that a drop in the VLAN code won't
ever have the opportunity to be evaluated against null_or_bond or
null_or_orig.

>Also null_or_bond wouldn't be set to the vlan dev that we want so I don't
>think this gets us there.
>
>At this point I think there are two bug fixes that need to be made, one to
>address null_or_bond and another to check the correct net_device in case
>#1 and #2 above.
>
>I'll try to put together another RFC patch series with all your feedback
>this evening.  With good comments to hopefully explain what is going and
>at least make it clear where things will work and not work.  Thanks for
>all the good feedback!

	Hopefully this will be the last futzing around with this, and
won't make it too complicated.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
