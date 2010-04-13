From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Receive issues with bonding and vlans
Date: Mon, 12 Apr 2010 17:08:38 -0700
Message-ID: <2695.1271117318@death.nxdomain.ibm.com>
References: <20100412221645.8068.71073.stgit@localhost6.localdomain6> <29849.1271113851@death.nxdomain.ibm.com> <20100412233509.GA32302@cleech-lnx.jf.intel.com>
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>,
	Patrick McHardy <kaber@trash.net>,
	"bonding-devel@lists.sourceforge.net"
	<bonding-devel@lists.sourceforge.net>
To: Chris Leech <christopher.leech@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:54807 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754431Ab0DMAIm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 20:08:42 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e5.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o3CNrcQk008684
	for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 19:53:38 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3D08eEt1777870
	for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 20:08:41 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o3D08eFd009447
	for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 21:08:40 -0300
In-reply-to: <20100412233509.GA32302@cleech-lnx.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Leech <christopher.leech@intel.com> wrote:

>On Mon, Apr 12, 2010 at 04:10:51PM -0700, Jay Vosburgh wrote:
>> 	Is the FCoE supposed to run over the inactive bonding slave?  Or
>> am I misunderstanding what you're saying?  I had thought the LLDP, et
>> al, special case in bonding was to permit, essentially, path discovery,
>> not necessarily active use of the inactive slave.
>
>That's what I'm trying to do, yes.  Mostly because it's a setup that
>would work if you removed the FCoE traffic from the network data path,
>and only converged at the driver level and below.  It's possible that
>the answer is "don't do that".

	So, basically, you want the bond to act like usual for "regular"
ethernet traffic, but act like the slaves are independent from the bond
for the magic FCoE traffic, right?

	I'm not really sure if that's a "don't do that" or not.

>> 	Not that this is necessarily bad; the "drop stuff on inactive
>> slaves" is really there for duplicate suppression, but it also can
>> uncover network topology issues, e.g., network layouts that won't work
>> if the devices fail, but appear to work during testing because the
>> "inactive" slave still receives traffic (it hasn't really failed).
>> 
>> >The problem is that it doesn't work for hardware accelerated VLAN
>> >devices, because the VLAN receive paths have their own
>> >skb_bond_should_drop calls that were not updated.
>> >
>> >From what I can tell, VLAN receives always end up going through
>> >netif_receive_skb anyway, so skb_bond_should_drop gets called twice if
>> >the frame isn't dropped the first time.  I think the bonding checks in
>> >__vlan_hwaccel_rx and vlan_gro_common should just be removed.
>> 
>> 	I'm not so sure.  The checks in __vlan_hwaccel_rx are done with
>> the original receiving device in skb->dev; by the time the packet gets
>> to netif_receive_skb, the original slave the packet was received on has
>> been lost (and replaced with the VLAN device).  Various things are
>> interested in that, in particular the "arp_validate" and the "inactive
>> slave drop" logic for bonding depend on knowing the real device the
>> packet arrived on.
>> 
>> 	I note that the vlan accel logic doesn't change skb_iif to the
>> VLAN device; it remains as the original device.  I suppose one
>> alternative would be to convert the bonding drop, et al, logic to use
>> skb_iif instead of skb->dev; if that works, then I think the VLAN core
>> would not need to call skb_bond_should_drop, which in turn would be a
>> bit more complicated as it would have to look up the dev from the
>> skb_iif.  There's already some code in bonding that takes advantage of
>> this property of the VLANs, so maybe this is the way to go.
>
>Thanks, I'll take another look and see if I can come up with something
>better.

	I looked at the skb_bond_should_drop stuff a bit more after I
wrote that; it's not as easy as I had suspected.  The big sticking point
is that currently the test in netif_receive_skb (now __netif_receive_skb
in net-next-2.6) is on skb->dev->master to identify packets arriving on
slaves of bonding.  The VLAN skb->dev has ->master set to NULL.  Doing
that test against skb->skb_iif would be much more expensive, as it would
require a device lookup for every packet.

	So, I suspect that something has to happen in the VLAN
acceleration path, although I don't know exactly what.  I don't know if
it would be possible to flag the packets in some special way to indicate
that they're "bonding slave" packets, or if it's better to keep the
current structure and just fix the calls somehow.

	-J


>> >I haven't quite figured out what I think the correct change for
>> >null_or_bond is.  I suspect it involves not using NULL at all.  I can
>> >see how it addresses the arp_ip_target on a VLAN issue, but this is also
>> >changing the receive matching rules for other traffic in unexpected
>> >ways.
>> 
>> 	I'll hazard a guess that something like this might do it:
>> 
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index b98ddc6..cc665bb 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -2735,7 +2735,7 @@ ncls:
>>  			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
>>  		if (ptype->type == type && (ptype->dev == null_or_orig ||
>>  		     ptype->dev == skb->dev || ptype->dev == orig_dev ||
>> -		     ptype->dev == null_or_bond)) {
>> +		     (null_or_bond && (ptype->dev == null_or_bond))) {
>>  			if (pt_prev)
>>  				ret = deliver_skb(skb, pt_prev, orig_dev);
>>  			pt_prev = ptype;
>> 
>> 
>> 	I haven't tested this, but the theory is to only test against
>> null_or_bond if null_or_bond isn't NULL, which is only the case for VLAN
>> traffic over bonding.
>
>Yes, that should do it.
>
>	- Chris

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
