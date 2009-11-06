From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: RFC: ethtool support for n-tuple filter programming
Date: Fri, 06 Nov 2009 10:57:21 -0800
Message-ID: <1257533841.2610.12.camel@ppwaskie-mobl2>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:54700 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759142AbZKFS5P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Nov 2009 13:57:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All,

I'm looking to add support to ethtool that would allow programming of
full n-tuple filters into underlying devices.  Currently, ixgbe has
support for these types of perfect match or mostly match (masked)
filters.  I imagine other hardware exists that also has support for
this, so I'd like to make this interface usable for everyone.

Note that this is similar behavior in the iproute2 tools, but it's
different enough, in my opinion, to warrant being in ethtool.  The
iproute2 tools (specifically tc) manipulate the qdiscs to add filters in
the kernel packet schedulers.  This proposed solution is managing the
hardware in the underlying device, which iproute2 tools currently don't
touch.  Hopefully this is obvious for those reviewing this proposal.

What I currently have as possible inputs to ethtool are:

- src/dst IP address: 32-bits each, 128-bits each for IPv6
- src/dst port: 16-bits each (TCP/UDP)
- VLAN tag: 15-bits
- L4 type: 8-bits (TCP/UDP/SCTP currently, can grow later)
- User specified field: currently 32-bits, can be anything a driver
wants to use
- Action: signed 16-bits (-1 indicates drop, any other value is the Rx
queue to steer the flow to)

Now all of these fields, except action, can also have a mask supplied to
them, but it's not mandatory.

An example ethtool command with this support could be:

# ethtool -F ethX dst-ip 0x0101a8c0 src-ip 0x0001a8c0 0x00ffffff
dst-port 0x1600 src-port 0x0000 0x0000 usr 0x8906 act 5

This will program a filter that will filter traffic coming from
192.168.1.0/24 to 192.168.1.1, port 22, from any source port, and will
place all those matches packets into Rx queue 5.  It also specified a
user-defined field of 0x8906, which a driver can use at its own
discretion (or omit completely).

Then running the ethtool -f ethX command could dump all currently
programmed filters.

Any comments, thoughts, suggestions, or ideas are welcome.

Cheers,
-PJ Waskiewicz

