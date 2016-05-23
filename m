From: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [RFC 00/12] 6lowpan: introduce 6lowpan-nd
Date: Mon, 23 May 2016 21:21:56 +0200
Message-ID: <1464031328-17524-1-git-send-email-aar@pengutronix.de>
Cc: kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org,
	jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org,
	stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org, mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org, werner-SEdMjqphH88wryQfseakQg@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	"David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
To: linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

this patch series introduces the ndisc ops callback structure to add different
handling for IPv6 neighbour discovery cache functionality. It implements at first
the two following use-cases:

 - 6CO handling as userspace option (For all 6LoWPAN layers, BTLE/802.15.4) [0]
 - short address handling for 802.15.4 6LoWPAN only [1]

Since my last patch series, I completely changed the whole ndisc_ops callback
structure to not replace the whole ndisc functionality at recv/send level of
NS/NA/RS/RA which I send in my previous patch-series "6lowpan: introduce basic
6lowpan-nd". I changed it now to add different handling in a very low-level way
of ndisc functionality.

The ndisc_ops don't must be registered to dev->ndisc_ops anymore, if they are not
set, then no additional ipv6 ndisc handling will be done.

This patch series now introduce a complete handling of short address for
802.15.4 6LoWPAN in case of send/recv of NA/NS/RS and RA. In case of RA
(receive only) and PIO we also need a second prefix + short-address based
address.

This callback structure can be used later (I hope) for RFC 6775 [0]. This RFC
defines some new option fields and messages for 6LoWPAN-ND. This patch series
does not implement RFC 6775 (except we decide now to handle 6CO in userspace).

Additional we can use the current ops for parse/fill ndisc options for kernel
handled ndisc messages to add 6CIO, see [2].

I tested RA/NS/NA/RS messages with short address which seems to work, what I
didn't test is the redirect messages since I don't know how to generate them.
The short address for redirect messages are also some special case here, because
the short address by a L3 target address need to be added.

btw:
According to [3] sending redirect messages should be also disabled by default
on 6lowpan interfaces, but can be activated afterwards. This is maybe
something for the ipv6_devconf structure. There is a "accept_redirects" but
no "disable_redirects".

- Alex

[0] https://tools.ietf.org/html/rfc6775
[1] https://tools.ietf.org/html/rfc4944#section-8
[2] https://tools.ietf.org/html/rfc7400#section-3.3
[3] https://tools.ietf.org/html/rfc6775#section-6.1

Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>
Cc: James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>
Cc: Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>
Cc: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>

changes since "PATCHv2 6lowpan: introduce basic 6lowpan-nd":
 - change EXPORT_SYMBOL to EXPORT_SYMBOL_GPL
 - rework ndisc_ops to be very low-level (not replacing
   full ndisc handling) and add full short address handling
   now.
 - added comments for ndisc_ops.
 - make ndisc_opt_addr_space, ndisc_opt_addr_data and
   ndisc_fill_addr_option completely independent from
   net_device dev argument. Instead add ndisc_dev helpers
   for do it for the normal case.
 - remove lowpan_neigh and add a 802.15.4 6lowpan private data
   for now only.
 - remove empty ndisc_ops inline functions
 - add tmp debugfs UAPI to get 6lowpan short address, necessary
   for e.g. radvd to put short address as sllao in RA.

Alexander Aring (12):
  6lowpan: add private neighbour data
  6lowpan: add 802.15.4 short addr slaac
  6lowpan: remove ipv6 module request
  ndisc: get rid off dev parameter in ndisc_opt_addr_space
  ndisc: get rid off dev parameter in ndisc_opt_addr_data
  ndisc: get rid off dev parameter in ndisc_fill_addr_option
  addrconf: put prefix address add in an own function
  ipv6: introduce neighbour discovery ops
  ipv6: export several functions
  6lowpan: introduce 6lowpan-nd
  6lowpan: add support for getting short address
  6lowpan: add support for 802.15.4 short addr handling

 include/linux/netdevice.h     |   8 +-
 include/net/6lowpan.h         |  10 ++
 include/net/addrconf.h        |  10 ++
 include/net/ndisc.h           | 229 +++++++++++++++++++++++++++++++++++++++---
 net/6lowpan/6lowpan_i.h       |   4 +
 net/6lowpan/Makefile          |   2 +-
 net/6lowpan/core.c            |  50 ++++++++-
 net/6lowpan/debugfs.c         |  35 +++++++
 net/6lowpan/iphc.c            | 167 ++++++++++++++++++++++++------
 net/6lowpan/ndisc.c           | 223 ++++++++++++++++++++++++++++++++++++++++
 net/ieee802154/6lowpan/core.c |  12 +++
 net/ieee802154/6lowpan/tx.c   | 113 ++++++++++-----------
 net/ipv6/addrconf.c           | 204 ++++++++++++++++++++-----------------
 net/ipv6/ndisc.c              | 178 +++++++++++++++++++-------------
 net/ipv6/route.c              |  18 ++--
 15 files changed, 990 insertions(+), 273 deletions(-)
 create mode 100644 net/6lowpan/ndisc.c

-- 
2.8.2
