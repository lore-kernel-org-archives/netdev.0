From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Tc filtering: broken 802_3 classifier?
Date: Tue, 24 Jul 2007 17:19:20 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903484027@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:15561 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932347AbXGYATy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 20:19:54 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've been trying to use tc filtering to filter on ethertype, among other
things in the MAC layer.  I'm running into multiple issues, and want to
put this out there in case I'm using the filters wrong, or if there
really is a bug in the filter code (I've stared at most of it today, and
my head hurts).

Here's the scenario.  I am running on a recent 2.6.23 GIT tree, and am
using sch_prio with no multiqueue turned on in the qdisc.  The network
interface in question is e1000 (no multiqueue).

# tc qdisc add dev eth0 root handle 1: prio

Now to see the flowid's packet counts incrementing, I add explicit
classful qdiscs to the leaves:

# tc qdisc add dev eth0 parent 1:1 handle 10: pfifo
# tc qdisc add dev eth0 parent 1:2 handle 20: pfifo
# tc qdisc add dev eth0 parent 1:3 handle 30: pfifo

Now packet counts can be seen with:

# tc -s qdisc ls dev eth0

I can add a filter for IP for ssh, and it works as intended:

# tc filter add dev eth0 protocol ip parent 1: prio 1 u32 match ip dport
22 0xffff flowid 1:3

This will shove ssh traffic into the 3rd pfifo queue, where by default
it will flow into flowid 1:1.  This is good.

Now I add a filter for ethernet (802.3), and things aren't as happy:

# tc filter add dev eth0 protocol 802_3 parent 1: prio 2 u32 match u32
<first 4 bytes of dst mac address> 0xffffffff at 0 match u32 <last 2
bytes of dst mac address> 0xffff0000 at 4 flowid 1:1

This should match the destination MAC address of outgoing packets, and
put it into flowid 1:1.  For pings, using the normal priomap, they go
into 1:2, so ping should be a good candidate for seeing if it goes into
1:1.  In this case, it does not filter into 1:1.

If I expand this into 8 flows on a multiqueue NIC, using sch_prio or
sch_rr, adding any 802_3 filter to the chain will cause any traffic that
hits the classifier (i.e. no other filters match first) to go into
flowid 1:1, regardless if it actually matches.  Remove the 802_3 filter
from the chain, and all filtering starts working again.

I'm trying to get state from the classifier code now when it's running,
but it's a really big mess of black magic.  I'm wondering if anyone is
also seeing this behavior, and if they've tried to fix it.  If not, I'll
continue to search for a solution, but I'm just polling the community to
see if this is a known issue, or if I'm doing something wrong.

Thanks,

-PJ Waskiewicz
Intel Corporation
peter.p.waskiewicz.jr@intel.com <mailto:peter.p.waskiewicz.jr@intel.com>
