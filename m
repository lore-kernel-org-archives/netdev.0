From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next 0/6] bonding: only rely on arp packets if arp monitor is used
Date: Thu, 16 Jan 2014 14:38:59 -0800
Message-ID: <21868.1389911939@death.nxdomain>
References: <1389837916-5377-1-git-send-email-vfalico@redhat.com> <15764.1389848997@death.nxdomain> <20140116084102.GM1867@redhat.com>
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:32911 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775AbaAPWjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 17:39:06 -0500
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 16 Jan 2014 15:39:05 -0700
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id BB42A3E40052
	for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 15:39:02 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp08026.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0GMcoPx10551680
	for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 23:38:50 +0100
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0GMd283013742
	for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 15:39:02 -0700
In-reply-to: <20140116084102.GM1867@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Veaceslav Falico <vfalico@redhat.com> wrote:

>On Wed, Jan 15, 2014 at 09:09:57PM -0800, Jay Vosburgh wrote:
>>Veaceslav Falico <vfalico@redhat.com> wrote:
>>
>>>Currently, if arp_validate is off (0), slave_last_rx() returns the
>>>slave->dev->last_rx, which is always updated on *any* packet received by
>>>slave, and not only arps. This means that, if the validation of arps is
>>>off, we're treating *any* incoming packet as a proof of slave being up, and
>>>not only arps.
>>
>>	The "any incoming packet" part is intentional.
>>
>>>This might seem logical at the first glance, however it can cause a lot of
>>>troubles and false-positives, one example would be:
>>>
>>>The arp_ip_target is NOT accessible, however someone in the broadcast domain
>>>spams with any broadcast traffic. This way bonding will be tricked that the
>>>slave is still up (as in - can access arp_ip_target), while it's not.
>>
>>	This type of situation is why arp_validate was added.
>>
>>	The specific situation was when multiple hosts using bonding
>>with the ARP monitor were set up behind a common gateway (in the same
>>Ethernet broadcast domain).  The arp_ip_target is unreachable for
>>whatever reason.  In that case, the various bonding instances on the
>>different hosts will each issue broadcast ARP requests, and (in the
>>absence of arp_validate) those requests would trick the other bonds into
>>believing that they are up.
>>
>>	I don't think this patch set will resolve that problem, since
>>you explicitly permit any incoming ARP to count.
>
>I've said it was tricky at first glance :).
>
>For this situation the arp_validate is *indeed* the cure. I'm not disabling
>(or even working with) how arp_validate=1/2 works, I'm working with
>arp_validate == 0.
>
>Before the patchset (with arp_validate == 0 ):
>
>*Any* packet (arp and non-arp) will signal us that the slave is up -
>because we use slave->dev->last_rx (updated on *every* incoming packet in
>bond_handle_frame).
>
>After the patchset (with arp_validate == 0 ):
>
>*ONLY ARP* packets signal us that the slave is up - because we use
>slave->last_arp_rx that is updated every time we see an ARP packet.

	But that's effectively making arp_validate the only setting if
the host is on a quiet network segment without much other host ARP
traffic.  This may not be an issue for the active-backup mode, but the
load balance modes will have serious issues (more on that below).

	Actually, thinking about it, for active-backup, if a backup
slave is in a different Ethernet broadcast domain than the active slave,
your change will likely break those configurations.  With arp_validate
enabled or your change applied, the backup slaves in active-backup
depend on the ARP request broadcasts to be forwarded by the switch to
the backup slave.  Currently, without arp_validate, that dependency is
not there; the backup slave can receive any traffic (although in most
configurations, the ARP broadcast is what it will receive).

	That would be a legal (if very odd) bonding configuration.  I'm
not aware of anybody seting things up that way.

>The way the modes work with arp_validate > 0 don't change :), as we're
>updating slave->last_arp_rx the old way in this case - after validation.
>
>So that the scenario you've described still works flawlessly, and now
>already we won't be tricked by some weird broadcast traffic even with
>arp_validate == 0.

	So why not just enable arp_validate and get the same effect?

>>>The documentation for arp_validate also states that *ARPs* will (not) be
>>>validated if it's on/off, and that the arp monitoring works on arps as
>>>traffic generators.
>>
>>	I wrote most of that text in the documentation, and the intent
>>was not to imply that only ARPs should count for "up-ness" even without
>>arp_validate enabled.  The intent was to distinguish it from
>>"non-validate," in which any incoming traffic counted for "up-ness."
>>
>>	The main reason for preserving the non-validate behavior (any
>>traffic counts) is for the loadbalance (xor and rr) modes.  In those
>>modes, the switch decides which slave receives the incoming traffic, and
>>so it's to our advantage to permit any incoming traffic to count for
>>"up-ness."  The arp_validate option is not allowed in these modes
>>because it won't work.
>>
>>	With these changes, I suspect that the loadbalance ARP monitor
>>will be less reliable with these changes (granted that it's already a
>>bit dodgy in its dependence on the switch to hit all slaves with
>>incoming packets regularly).  Particularly if the switch ports are
>>configured into an Etherchannel ("static link aggregation") group, in
>>which case only one slave will receive any given frame (broadcast /
>>multicast traffic will not be duplicated across all slaves).
>
>The non-AB modes also gave me a headache, however after thinking a bit I've
>decided to change them also (mainly, it's the change of
>arp_loadbalance_mon function).

	I had that same headache when I was implementing the
arp_validate stuff.  But I disagree with changing this.

>The usual usage, however, is to generate traffic via arps. If we don't see
>arp replies - this means that arp_ip_target is down, and thus the slave is
>down.

	The issue with the loadbalance (-xor and -rr) modes is that the
incoming ARPs will be balanced by the switch, and won't be delivered to
all slaves, or at least not at a rate such that each slave sees an ARP
every arp_interval or so.

	Currently, the loadbalance modes will work with the ARP monitor
as long as sufficient traffic volume (of any kind) flows across the
slaves; with your change, that will no longer be true.

	In this case, the ARP monitor currently is essentially using
"slave can send and receive packets" as the test for availability.

>>	I'm not sure that this change (the "only count ARPs even without
>>arp_validate" bit) won't break existing configurations.  Did you test
>>the -rr and -xor modes with ARP monitor after your changes (with and
>>without configuring a channel group on the switch ports)?
>
>Sure, all works fine, afaics. Obviously, these were basic tests, and bugs
>might exist.

	I set up bonding to run some tests.  I used three slaves,
connected to a switch with those ports set for Etherchannel, balancing
according to source IP (Cisco port-channel load-balance src-ip).  For
non-IP packets (like ARP), this will balance by source MAC.  I set
arp_interval to 1000 (1 second), and used one arp_ip_target.

	Without your patches, I can get all slaves to stay up with a
sufficient traffic load (ping, netperf, etc).  This is dependent upon
the switch distributing the packets egressing the switch to all ports of
the Etherchannel.  This is not by any means an ideal situation, but has
been the state for some time now.

	With your patches, one slave stays up (it is receiving the ARP
replies from the arp_ip_target).  Regular traffic of any kind does not
keep the second and third slaves up.  In my opinion, this is a
regression from previous behavior.

	How did you test this such that all slaves stayed up?  My
suspicion is that you did not configure the switch ports for
Etherchannel (static link aggregation), and thus all broadcast ARP
requests were flooded to all slaves.  This would mark all slaves up, but
not have any real reliance on ARP replies coming from the arp_ip_target
(i.e., if there were no ARP replies, the slaves would still remain up
due to the broadcast ARPs generated by the bond itself).

>The only possible scenario of breakage for someone, from my POV, is:
>
>1) arp monitor is used with loadbalance mode
>2) arp_ip_targets are set but _any_ arp replies are never received
>3) the user relies on that every slave will receive at least one packet per
>arp_interval

	For 2, above, the issue is that, after your changes, each slave
must receive an ARP during each arp_interval.

>This use case:
>
>1) contradicts with documentation
>2) contradicts with logic (arp monitor, arp ip targets etc. are used
>without, actually, meaning something)
>3) is really unstable

	On 1, I'll grant that the documentation is ambiguous, but the
acceptance of any incoming packet for the non-validate ARP monitor is
functioning as designed.  At worst, this means the documentation should
be updated to be clearer, not that the code is functioning incorrectly
because it can be shown to contradict a reading of the documentation.

	Heck, looking at the bonding.txt documentation, it still says
that device drivers have to update ->last_rx and ->trans_start, which
isn't true.  So, yah, the documentation needs some work.

	On 2, sure they mean something; (without arp_validate or this
change) the ARP request / replies are one source, but not the only
source, of traffic to determine slave state.

	On 3, that is, indeed, the case, and this is mentioned in the
documentation somewhere (that a continuous flow of traffic is necessary
to maintain correct up/down status for the slaves).  The whole point of
accepting any incoming frame (not just ARPs) is to permit this very
scenario to function at maximum efficiency, even if that's not 100%
reliable in all cases.

>In this case, indeed, it won't work. Two points, though:
>
>1) It shouldn't work in the first place, is unstable etc.
>2) Can be easily fixed by the following oneliner (though I *really* woudn't
>like to do it, as it's useless and dangerous). Basically, for non-ab mode
>we set last_arp_rx for every packet. Again, I wouldn't like to do it, but
>if you know any use case scenario for this usage (no working arps but
>continuous receive traffic) - I can send it as v2 or 7/6 patch (whatever
>suits David better, as he already applied it but didn't push).

	It's not useless and dangerous, it's preserving the intended
behavior for backwards compatibility with existing configurations.
Further, the current behavior is what allows ARP monitor for the
loadbalance modes (-xor and -rr) to work at all.

	The use case is any -xor or -rr bond using ARP monitor against a
switch configured for Etherchannel (static link aggregation) on the
bonded ports.  In those cases, the incoming ARP replies from an ARP
target will be delivered to only one slave (because switches generally
do load balancing by hash), and the other slaves will not see any
incoming ARP traffic from the arp_target.  Even if the switch did round
robin, the slaves still won't see enough ARPs coming in to reliably keep
the slaves up, even if there is lots of regular traffic.

	The fact that "accept only ARP" does not work at all for the
loadbalance modes is the reason that arp_validate is not permitted for
those modes.

	I think the bottom line here is pretty simple:

	Using the ARP monitor with the loadbalance modes is not a common
configuration in my experience, and making it work is tricky.  However,
anyone using it today will be relying on the current behavior, which we
therefore must not change.

	-J


>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 0f613ae..87358e5 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -2286,6 +2286,11 @@ int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
> 	__be32 sip, tip;
> 	int alen;
> +	if (!USES_PRIMARY(bond->params.mode)) {
>+		slave->last_arp_rx = jiffies;
>+		return RX_HANDLER_ANOTHER;
>+	}
>+
> 	if (skb->protocol != __cpu_to_be16(ETH_P_ARP))
> 		return RX_HANDLER_ANOTHER;
> 
>
>>
>>>Also, the net_device->last_rx is already used in a lot of drivers (even
>>>though the comment states to NOT do it :)), and it's also ugly to modify it
>>>from bonding.
>>
>>	I didn't check, but I suspect those are mostly leftovers from
>>the distant past, when the drivers were expected to update last_rx, or
>>perhaps drivers using it for their own purposes.
>
>It's really a mix. Somebody just updates them, somebody uses it for their
>own purposes etc.
>
>>
>>	I don't really see an issue in decoupling bonding from the
>>net_device->last_rx; it's pretty much the same thing that was done for
>>trans_start some time ago.
>
>trans_start removal is also in queue :). Though still needs some
>polishing...
>
>>
>>	-J
>>
>>---
>>	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>>
>>
>>>So, to fix this, remove the last_rx from bonding, *always* call
>>>bond_arp_rcv() in slave's rx_handler (bond_handle_frame), and if we spot an
>>>arp there - update the slave->last_arp_rx - and use it instead of
>>>net_device->last_rx. Finally, rename slave_last_rx() to slave_last_arp_rx()
>>>to reflect the changes.
>>>
>>>As the changes touch really sensitive parts, I've tried to split them as
>>>much as possible, for easier debugging/bisecting.
>>>
>>>CC: Jay Vosburgh <fubar@us.ibm.com>
>>>CC: Andy Gospodarek <andy@greyhouse.net>
>>>CC: "David S. Miller" <davem@davemloft.net>
>>>CC: netdev@vger.kernel.org
>>>Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
>>>
>>>---
>>> drivers/net/bonding/bond_main.c    | 18 ++++++++----------
>>> drivers/net/bonding/bond_options.c | 12 ++----------
>>> drivers/net/bonding/bonding.h      | 16 ++++++----------
>>> include/linux/netdevice.h          |  8 +-------
>>> 4 files changed, 17 insertions(+), 37 deletions(-)

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
