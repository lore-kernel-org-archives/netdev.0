From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next 0/6] bonding: only rely on arp packets if arp monitor is used
Date: Wed, 15 Jan 2014 21:09:57 -0800
Message-ID: <15764.1389848997@death.nxdomain>
References: <1389837916-5377-1-git-send-email-vfalico@redhat.com>
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:51270 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750736AbaAPFKC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 00:10:02 -0500
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 16 Jan 2014 00:10:02 -0500
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 321B46E803F
	for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 00:09:56 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp22036.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0G59xE47274924
	for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 05:09:59 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0G59xPw007554
	for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 00:09:59 -0500
In-reply-to: <1389837916-5377-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Veaceslav Falico <vfalico@redhat.com> wrote:

>Currently, if arp_validate is off (0), slave_last_rx() returns the
>slave->dev->last_rx, which is always updated on *any* packet received by
>slave, and not only arps. This means that, if the validation of arps is
>off, we're treating *any* incoming packet as a proof of slave being up, and
>not only arps.

	The "any incoming packet" part is intentional.

>This might seem logical at the first glance, however it can cause a lot of
>troubles and false-positives, one example would be:
>
>The arp_ip_target is NOT accessible, however someone in the broadcast domain
>spams with any broadcast traffic. This way bonding will be tricked that the
>slave is still up (as in - can access arp_ip_target), while it's not.

	This type of situation is why arp_validate was added.

	The specific situation was when multiple hosts using bonding
with the ARP monitor were set up behind a common gateway (in the same
Ethernet broadcast domain).  The arp_ip_target is unreachable for
whatever reason.  In that case, the various bonding instances on the
different hosts will each issue broadcast ARP requests, and (in the
absence of arp_validate) those requests would trick the other bonds into
believing that they are up.

	I don't think this patch set will resolve that problem, since
you explicitly permit any incoming ARP to count.

>The documentation for arp_validate also states that *ARPs* will (not) be
>validated if it's on/off, and that the arp monitoring works on arps as
>traffic generators.

	I wrote most of that text in the documentation, and the intent
was not to imply that only ARPs should count for "up-ness" even without
arp_validate enabled.  The intent was to distinguish it from
"non-validate," in which any incoming traffic counted for "up-ness."

	The main reason for preserving the non-validate behavior (any
traffic counts) is for the loadbalance (xor and rr) modes.  In those
modes, the switch decides which slave receives the incoming traffic, and
so it's to our advantage to permit any incoming traffic to count for
"up-ness."  The arp_validate option is not allowed in these modes
because it won't work.

	With these changes, I suspect that the loadbalance ARP monitor
will be less reliable with these changes (granted that it's already a
bit dodgy in its dependence on the switch to hit all slaves with
incoming packets regularly).  Particularly if the switch ports are
configured into an Etherchannel ("static link aggregation") group, in
which case only one slave will receive any given frame (broadcast /
multicast traffic will not be duplicated across all slaves).

	I'm not sure that this change (the "only count ARPs even without
arp_validate" bit) won't break existing configurations.  Did you test
the -rr and -xor modes with ARP monitor after your changes (with and
without configuring a channel group on the switch ports)?

>Also, the net_device->last_rx is already used in a lot of drivers (even
>though the comment states to NOT do it :)), and it's also ugly to modify it
>from bonding.

	I didn't check, but I suspect those are mostly leftovers from
the distant past, when the drivers were expected to update last_rx, or
perhaps drivers using it for their own purposes.

	I don't really see an issue in decoupling bonding from the
net_device->last_rx; it's pretty much the same thing that was done for
trans_start some time ago.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com


>So, to fix this, remove the last_rx from bonding, *always* call
>bond_arp_rcv() in slave's rx_handler (bond_handle_frame), and if we spot an
>arp there - update the slave->last_arp_rx - and use it instead of
>net_device->last_rx. Finally, rename slave_last_rx() to slave_last_arp_rx()
>to reflect the changes.
>
>As the changes touch really sensitive parts, I've tried to split them as
>much as possible, for easier debugging/bisecting.
>
>CC: Jay Vosburgh <fubar@us.ibm.com>
>CC: Andy Gospodarek <andy@greyhouse.net>
>CC: "David S. Miller" <davem@davemloft.net>
>CC: netdev@vger.kernel.org
>Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
>
>---
> drivers/net/bonding/bond_main.c    | 18 ++++++++----------
> drivers/net/bonding/bond_options.c | 12 ++----------
> drivers/net/bonding/bonding.h      | 16 ++++++----------
> include/linux/netdevice.h          |  8 +-------
> 4 files changed, 17 insertions(+), 37 deletions(-)
>
