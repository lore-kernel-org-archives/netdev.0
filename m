From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: Simplifying the 802.15.4 stack
Date: Fri, 7 Mar 2014 13:39:24 +0100
Message-ID: <20140307133924.21165955@zoidberg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: linux-zigbee-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:60739 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752545AbaCGMjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 07:39:40 -0500
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s27Cdcmx014401
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 7 Mar 2014 13:39:38 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(resent because I forgot CCs at first)

Hi,

the 802.15.4/6LoWPAN stack on Linux is pretty usable as it is now, much
due to the recent 6lowpan fixes by Alex. We can drive different radio
chips on different frequencies, IPv6 works well and we interoperate
just fine with RFC compliant stacks like the one implemented in Contiki.

There are, however, also a number of sore points, which I want to
outline in this message and for which I want to propose possible
solutions. These sore points range anywhere from minor annoyances to
what I view as major integrity problems. I'll list what comes to my
mind here, in no particular order. If you have any idea how to fix
something, if you have something to add to the list or merely want to
tell me where and why I am mistaken, please do so.

1) header handling in the stack

We currently have three points in the stack that parse or create
802.15.4 headers, where two of those are already duplicated code - in
the same source file no less. Header handling for mac802154 is
cumbersome, and for upper layers entirely impossible without
duplicating more code at the moment. I have a patch that attempts to
rectify this by adding structs for the 802.15.4 header and its
components, but that was shot down by davem due to some endianness
issues. I am reworking the patch to fix all of this and will resend it
soon, but it doesn't end with that.

2) endianness in the stack

In fact, that patch was consistent with how the mac802154 stack
currently handles endianness - which is, pretty much, not at all. For
example we have __le16 fields that the PAN ID of a given netdevice,
which is filled with data in host byte order and only happens to work
out because it's written to the header with explicit mask-shift
operations. Short addresses for nodes are given in host byte order,
extended addresses are however always held in big endian 8-byte arrays.
We really never use network byte order on purpose, and inside of the
stack we should really change that. Ideally we'd also change it in the
userspace API if we ever got the chance to do that, because
AF_IEEE802154 is the *only* protocol i know that uses all byte orders
in it's sockaddr struct *except* network byte order.

3) the mac802154_priv slave list

This is one of the biggest problems I think the current stack has. For
HardMAC, every netdevice corresponds to one specific WPAN (made up of
PAN ID, channel, and page) and it is pretty much guaranteed that
multiple HardMAC netdevs will always function as intended, even if they
are backed by the same piece of hardware.

SoftMAC, on the other hand, takes a single PHY chip and adds an
*arbitrary* number of specific WPANs on top of that PHY. No real
hardware can support an arbitrary number of specific WPANs, and no chip
I have yet come across can even support more than one. As far as I've
been told and was able to reconstruct from documentation and standards
documents, this was implemented to allow for ZigBee frequency agility,
but that was never implemented. What we have, though, is a means for
unprivileged users that can run socket(), write() and ip(8) to
effectively DoS a node that uses this feature.

Here's why: if somebody configures the stack with one PHY and two
specific WPANs on that PHY, an packet sent through one of those
specific WPAN netdevs will activate that specific WPAN and deactivate
all others on that PHY. This only holds when the specific WPANs differ
in channel or page, since we do not reconfigure the PHY addresses or
address filters on on the switch, which will most certainly yield
wildly incorrect behaviour if anybody were to ever use multiple
specific WPANs per PHY.

I thus propose to remove this feature entirely and instead have a 1:1
correspondence between PHYs and netdevs. If a driver can support
multiple specific WPANs per chip, it can register multiple PHYs. If
anybody actually needs to reconfigure the device to a different
specific WPAN, we already have an interface for that: the netlink API.
The netlink API also has the benefit that it does not impose arbitrary
delays before the switch, as switching by sending a packet does when
reordering/shaping Qdiscs are configured on the WPAN.

If we were to remove the slave list, the entire netlink API specific to
PHYs and adding/removing slaves would have to go. Listing PHYs would no
longer be necessary, instead we'd need an API to query PHY/MAC
parameters by netdev name. What is currently SET_PHYPARAMS (and my
fault) would also have to be split into commands that set PHY and MAC
params for consistency.

I propose a flag day to remove this feature entirely, as it will break
userspace, but it will do so to provide much better service,
semantically correct netdevs and it will remove the DoS path for
unprivileged users. And if we do that, we might as well think about
whether or not we should also change endianness of network-facing
fields exposed to userspace for consistency with all other protocols
implemented in Linux.

4) our *drivers* are expected to *sleep*

This is just wrong. Our RX/TX path invokes the scheduler at least once
for every packet on the assumption that drivers might sleep, which may
entail arbitrary delays even after the Qdiscs of the system have run.
Especially when somebody wanted to use latency sensitive Qdiscs, this
is a disaster, but also for general system throughput once you have a
certain number of packets going through your node.

I think this should also be reworked completely. Network packet
reception/transmission is inherently asynchronous, and the current
stack goes out of its way to make it a synchronous matter.
Interestingly, once a driver has received a packet, most if not all of
the RX path might actually be softirq-safe as it is now, without the
workqueue deferral. We don't fundamentally need the RX workqueue, and
the TX workqueue could also be dropped if we gave a PHY driver a
function pointer to call once transmission is complete. That would also
simplify the stack quite a bit, not introduce unnecessary latencies,
and generally be an improvement on drivers that invoke the scheduler.


Any thoughts/ideas?
