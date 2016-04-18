From: Alexander Aring <aar@pengutronix.de>
Subject: [PATCH bluetooth-next 00/10] 6lowpan: introduce basic 6lowpan-nd
Date: Mon, 18 Apr 2016 12:58:18 +0200
Message-ID: <1460977108-4675-1-git-send-email-aar@pengutronix.de>
Cc: kernel@pengutronix.de, marcel@holtmann.org,
	jukka.rissanen@linux.intel.com, hannes@stressinduktion.org,
	stefan@osg.samsung.com, mcr@sandelman.ca, werner@almesberger.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	Alexander Aring <aar@pengutronix.de>,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:60900 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753784AbcDRK7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 06:59:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this patch series introduces a layer for IPv6 neighbour discovery. At first
it introduce the "ndisc_ops" to run a different handling for recv/send of
NA/NS messages. The use case for such ndisc operation is RFC 6775 [0].
Which describes a different neighbour discovery handling for 6LoWPAN networks.

I didn't implement RFC 6775 in this patch series, but introduce callback
structure for replace different functions in ndisc implementation might be
the right direction.

Another use case would be RFC 7400 [1] which describes a new option field to
getting capabilities of 6LoWPAN next header compression methods.

What I implemented is a necessary functionality to handle short address for
802.15.4 6LoWPAN networks. The L2-Layer "802.15.4" can have two different
link-layer addresses which can be used mixed at the same time inside 802.15.4
networks. To deal with such behaviour in ndisc, it is defined at RFC 4944 [2].
The bad news is, that I saw different handling of such handling. What Linux
will do is to add two source/target address information option fields, each
with different length, if short address is valid (can also not be given).
Example:

- WPAN interface address settings
 - extended addr (must always be there)
 - short addr (0xfffe or 0xffff -> invalid)

Will add an extended addr to source/target address information option field.
If short addr is in some valid range, then both address will be added to
the option fields. Indicated are these different address types by the length
field (extended -> length=2, short -> length=1), according to [1].

The tested 6LoWPAN implementation (RIOT-OS) allows only one source/target
option field which is short XOR extended, otherwise it will be dropped.
There is some lack of information there [2] and I don't know how do deal with
it right, maybe we need to update the implementation there if it's really
wrong.

To save such information for each neighbour we use the already implemented
neighbour private data which some casting strategy for 6LoWPAN and 6LoWPAN
link-layer specific data e.g. 802.15.4 short address handling.

Additional I implemented to add 6CO to the is_useropt callback in case of
6LoWPAN interface. The 6CO option will currently parsed in userspace which
are placed in RA-Messages.

The ndisc_ops are not finished yet, of course we need handling for RS messages
to place the 802.15.4 short address there as well and then also processing
of RA messages for the 802.15.4 SLLAO option field.

- Alex

[0] https://tools.ietf.org/html/rfc6775
[1] https://tools.ietf.org/html/rfc7400#section-3.3
[2] https://tools.ietf.org/html/rfc4944#section-8

Cc: David S. Miller <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>

Alexander Aring (10):
  6lowpan: add private neighbour data
  6lowpan: add 802.15.4 short addr slaac
  6lowpan: remove ipv6 module request
  ndisc: add addr_len parameter to ndisc_opt_addr_space
  ndisc: add addr_len parameter to ndisc_opt_addr_data
  ndisc: add addr_len parameter to ndisc_fill_addr_option
  ipv6: introduce neighbour discovery ops
  ipv6: export ndisc functions
  6lowpan: introduce 6lowpan-nd
  6lowpan: add support for 802.15.4 short addr handling

 include/linux/netdevice.h     |   6 +-
 include/net/6lowpan.h         |  24 ++
 include/net/addrconf.h        |   3 +
 include/net/ndisc.h           | 101 ++++++-
 net/6lowpan/6lowpan_i.h       |   2 +
 net/6lowpan/Makefile          |   2 +-
 net/6lowpan/core.c            |  50 +++-
 net/6lowpan/iphc.c            | 167 +++++++++--
 net/6lowpan/ndisc.c           | 633 ++++++++++++++++++++++++++++++++++++++++++
 net/bluetooth/6lowpan.c       |   2 +
 net/ieee802154/6lowpan/core.c |  12 +
 net/ieee802154/6lowpan/tx.c   | 107 ++++---
 net/ipv6/addrconf.c           |   7 +-
 net/ipv6/ndisc.c              | 132 +++++----
 net/ipv6/route.c              |   4 +-
 15 files changed, 1094 insertions(+), 158 deletions(-)
 create mode 100644 net/6lowpan/ndisc.c

-- 
2.8.0
