From: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCHv3 net-next 00/12] 6lowpan: introduce 6lowpan-nd
Date: Tue, 14 Jun 2016 13:52:27 +0200
Message-ID: <20160614115239.17788-1-aar@pengutronix.de>
Cc: kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org,
	jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org,
	stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org, mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org, werner-SEdMjqphH88wryQfseakQg@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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
the short address by a L3 target address lookuped by neighbour cache need to be
added.

btw:
According to [3] sending redirect messages should be also disabled by default
on 6lowpan interfaces, but can be activated afterwards. This is maybe
something for the ipv6_devconf structure. There is a "accept_redirects" but
no "disable_redirects".

- Alex

[0] https://tools.ietf.org/html/rfc7400
[1] https://tools.ietf.org/html/rfc6775
[2] https://tools.ietf.org/html/rfc4944#section-8

changes since RFC:
 - add lowlevel functions __ndisc_opt_addr_space,
   __ndisc_opt_addr_data and __ndisc_fill_addr_option for corresponding
   functions which doesn't requires net_device argument.
 - move ndisc_ops e.g. ndisc_ops_fill_addr_option function call into the
   corresponding device argument function ndisc_fill_addr_option.
   (Introduced a special static inline function for redirect handling).
 - fix error handling in addrconf_prefix_rcv_add_addr.
   (Please see, introduce new API handling that second address registration
    (in case of 802.15.4 6LoWPAN) will still be notified if failed, because
    dev->addr was successful.
 - add ieee802154 sub-directory in short address entry for 6lowpan UAPI.
 - add lowpan_802154_is_valid_src_short_addr, because 802.15.4 6lowpan
   defines the first bit as multicast (don't know how this can be working
   at the end, because some hardware addresses will handle such addresses
   in L2 as unicast. See:
   https://www.iana.org/assignments/_6lowpan-parameters/_6lowpan-parameters.xhtml#_6lowpan-parameters-2

changes since v2:
 - Introduce ndisc_ops to have our own implementation for dealing with NS/NA
   which allows also to support RFC6775 (e.g. ARO).
 - add handling for handling 6CO as userspace option for RA messages in
   case of 6LoWPAN interfaces.
 - change lowpan_is_ll to check on linklayer type only.
 - added some reviewed-by's.
 - move short addr slaac to net/6lowpan instead ipv6 handling.
 - add handling for context based address compression in case for
   short address as link-layer address.
 - change strategy to use short address, a short address will always be used
   when it's available.
 - Handle override flag in NA messages to update short address information or
   not.

Alexander Aring (12):
  6lowpan: add private neighbour data
  6lowpan: add 802.15.4 short addr slaac
  6lowpan: remove ipv6 module request
  ndisc: add __ndisc_opt_addr_space function
  ndisc: add __ndisc_opt_addr_data function
  ndisc: add __ndisc_fill_addr_option function
  addrconf: put prefix address add in an own function
  ipv6: introduce neighbour discovery ops
  ipv6: export several functions
  6lowpan: introduce 6lowpan-nd
  6lowpan: add support for getting short address
  6lowpan: add support for 802.15.4 short addr handling

 include/linux/netdevice.h     |   8 +-
 include/net/6lowpan.h         |  16 +++
 include/net/addrconf.h        |  10 ++
 include/net/ndisc.h           | 248 +++++++++++++++++++++++++++++++++++++++---
 net/6lowpan/6lowpan_i.h       |   4 +
 net/6lowpan/Makefile          |   2 +-
 net/6lowpan/core.c            |  50 ++++++++-
 net/6lowpan/debugfs.c         |  39 +++++++
 net/6lowpan/iphc.c            | 167 +++++++++++++++++++++++-----
 net/6lowpan/ndisc.c           | 234 +++++++++++++++++++++++++++++++++++++++
 net/ieee802154/6lowpan/core.c |  12 ++
 net/ieee802154/6lowpan/tx.c   | 113 +++++++++----------
 net/ipv6/addrconf.c           | 218 +++++++++++++++++++++----------------
 net/ipv6/ndisc.c              | 123 +++++++++++++--------
 net/ipv6/route.c              |   8 +-
 15 files changed, 1004 insertions(+), 248 deletions(-)
 create mode 100644 net/6lowpan/ndisc.c

-- 
2.8.3
