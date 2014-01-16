From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next 0/6] bonding: only rely on arp packets if arp
 monitor is used
Date: Thu, 16 Jan 2014 09:41:02 +0100
Message-ID: <20140116084102.GM1867@redhat.com>
References: <1389837916-5377-1-git-send-email-vfalico@redhat.com>
 <15764.1389848997@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21816 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750960AbaAPIoB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 03:44:01 -0500
Content-Disposition: inline
In-Reply-To: <15764.1389848997@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 15, 2014 at 09:09:57PM -0800, Jay Vosburgh wrote:
>Veaceslav Falico <vfalico@redhat.com> wrote:
>
>>Currently, if arp_validate is off (0), slave_last_rx() returns the
>>slave->dev->last_rx, which is always updated on *any* packet received by
>>slave, and not only arps. This means that, if the validation of arps is
>>off, we're treating *any* incoming packet as a proof of slave being up, and
>>not only arps.
>
>	The "any incoming packet" part is intentional.
>
>>This might seem logical at the first glance, however it can cause a lot of
>>troubles and false-positives, one example would be:
>>
>>The arp_ip_target is NOT accessible, however someone in the broadcast domain
>>spams with any broadcast traffic. This way bonding will be tricked that the
>>slave is still up (as in - can access arp_ip_target), while it's not.
>
>	This type of situation is why arp_validate was added.
>
>	The specific situation was when multiple hosts using bonding
>with the ARP monitor were set up behind a common gateway (in the same
>Ethernet broadcast domain).  The arp_ip_target is unreachable for
>whatever reason.  In that case, the various bonding instances on the
>different hosts will each issue broadcast ARP requests, and (in the
>absence of arp_validate) those requests would trick the other bonds into
>believing that they are up.
>
>	I don't think this patch set will resolve that problem, since
>you explicitly permit any incoming ARP to count.

I've said it was tricky at first glance :).

For this situation the arp_validate is *indeed* the cure. I'm not disabling
(or even working with) how arp_validate=1/2 works, I'm working with
arp_validate == 0.

Before the patchset (with arp_validate == 0 ):

*Any* packet (arp and non-arp) will signal us that the slave is up -
because we use slave->dev->last_rx (updated on *every* incoming packet in
bond_handle_frame).

After the patchset (with arp_validate == 0 ):

*ONLY ARP* packets signal us that the slave is up - because we use
slave->last_arp_rx that is updated every time we see an ARP packet.


The way the modes work with arp_validate > 0 don't change :), as we're
updating slave->last_arp_rx the old way in this case - after validation.

So that the scenario you've described still works flawlessly, and now
already we won't be tricked by some weird broadcast traffic even with
arp_validate == 0.

>
>>The documentation for arp_validate also states that *ARPs* will (not) be
>>validated if it's on/off, and that the arp monitoring works on arps as
>>traffic generators.
>
>	I wrote most of that text in the documentation, and the intent
>was not to imply that only ARPs should count for "up-ness" even without
>arp_validate enabled.  The intent was to distinguish it from
>"non-validate," in which any incoming traffic counted for "up-ness."
>
>	The main reason for preserving the non-validate behavior (any
>traffic counts) is for the loadbalance (xor and rr) modes.  In those
>modes, the switch decides which slave receives the incoming traffic, and
>so it's to our advantage to permit any incoming traffic to count for
>"up-ness."  The arp_validate option is not allowed in these modes
>because it won't work.
>
>	With these changes, I suspect that the loadbalance ARP monitor
>will be less reliable with these changes (granted that it's already a
>bit dodgy in its dependence on the switch to hit all slaves with
>incoming packets regularly).  Particularly if the switch ports are
>configured into an Etherchannel ("static link aggregation") group, in
>which case only one slave will receive any given frame (broadcast /
>multicast traffic will not be duplicated across all slaves).

The non-AB modes also gave me a headache, however after thinking a bit I've
decided to change them also (mainly, it's the change of
arp_loadbalance_mon function).

The usual usage, however, is to generate traffic via arps. If we don't see
arp replies - this means that arp_ip_target is down, and thus the slave is
down.

>
>	I'm not sure that this change (the "only count ARPs even without
>arp_validate" bit) won't break existing configurations.  Did you test
>the -rr and -xor modes with ARP monitor after your changes (with and
>without configuring a channel group on the switch ports)?

Sure, all works fine, afaics. Obviously, these were basic tests, and bugs
might exist.

The only possible scenario of breakage for someone, from my POV, is:

1) arp monitor is used with loadbalance mode
2) arp_ip_targets are set but _any_ arp replies are never received
3) the user relies on that every slave will receive at least one packet per
arp_interval

This use case:

1) contradicts with documentation
2) contradicts with logic (arp monitor, arp ip targets etc. are used
without, actually, meaning something)
3) is really unstable

In this case, indeed, it won't work. Two points, though:

1) It shouldn't work in the first place, is unstable etc.
2) Can be easily fixed by the following oneliner (though I *really* woudn't
like to do it, as it's useless and dangerous). Basically, for non-ab mode
we set last_arp_rx for every packet. Again, I wouldn't like to do it, but
if you know any use case scenario for this usage (no working arps but
continuous receive traffic) - I can send it as v2 or 7/6 patch (whatever
suits David better, as he already applied it but didn't push).

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 0f613ae..87358e5 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2286,6 +2286,11 @@ int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
  	__be32 sip, tip;
  	int alen;
  
+	if (!USES_PRIMARY(bond->params.mode)) {
+		slave->last_arp_rx = jiffies;
+		return RX_HANDLER_ANOTHER;
+	}
+
  	if (skb->protocol != __cpu_to_be16(ETH_P_ARP))
  		return RX_HANDLER_ANOTHER;
  

>
>>Also, the net_device->last_rx is already used in a lot of drivers (even
>>though the comment states to NOT do it :)), and it's also ugly to modify it
>>from bonding.
>
>	I didn't check, but I suspect those are mostly leftovers from
>the distant past, when the drivers were expected to update last_rx, or
>perhaps drivers using it for their own purposes.

It's really a mix. Somebody just updates them, somebody uses it for their
own purposes etc.

>
>	I don't really see an issue in decoupling bonding from the
>net_device->last_rx; it's pretty much the same thing that was done for
>trans_start some time ago.

trans_start removal is also in queue :). Though still needs some
polishing...

>
>	-J
>
>---
>	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>
>
>>So, to fix this, remove the last_rx from bonding, *always* call
>>bond_arp_rcv() in slave's rx_handler (bond_handle_frame), and if we spot an
>>arp there - update the slave->last_arp_rx - and use it instead of
>>net_device->last_rx. Finally, rename slave_last_rx() to slave_last_arp_rx()
>>to reflect the changes.
>>
>>As the changes touch really sensitive parts, I've tried to split them as
>>much as possible, for easier debugging/bisecting.
>>
>>CC: Jay Vosburgh <fubar@us.ibm.com>
>>CC: Andy Gospodarek <andy@greyhouse.net>
>>CC: "David S. Miller" <davem@davemloft.net>
>>CC: netdev@vger.kernel.org
>>Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
>>
>>---
>> drivers/net/bonding/bond_main.c    | 18 ++++++++----------
>> drivers/net/bonding/bond_options.c | 12 ++----------
>> drivers/net/bonding/bonding.h      | 16 ++++++----------
>> include/linux/netdevice.h          |  8 +-------
>> 4 files changed, 17 insertions(+), 37 deletions(-)
>>
>
