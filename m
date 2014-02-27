From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next v5 0/8] 6lowpan: reimplementation of fragmentation handling
Date: Thu, 27 Feb 2014 09:06:14 +0100
Message-ID: <1393488382-1250-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	martin.townsend@xsilon.com, Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:34121 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742AbaB0IGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 03:06:42 -0500
Received: by mail-ea0-f182.google.com with SMTP id b10so637775eae.13
        for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 00:06:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this patch series reimplementation the fragmentation handling of 6lowpan
accroding to rfc4944 [1].

The first big note is, that the current fragmentation behaviour isn't rfc
complaint. The main issue is a wrong datagram_size value which needs to be:
datagram_size = ipv6_payload + ipv6 header + (maybe compressed transport header,
                currently only udp is supported)

but the current datagram_size value is calculated as:
datagram_size = ipv6_payload

Fragmentation work in a linux<->linux communication only.


Why reimplementation?

I reimplemted the reassembly side only. The current behaviour is to allocate a
skb with the reassembled size and hold all fragments in a list, protected by a
spinlock. After we received all fragments (detected by the sum of all fragments,
it begins to place all fragments into the allocated skb).

This reassembly implementation has some race condition. Additional I make it more
rfc complaint. The current implementation match on the tag value inside the frag
header only, but rfc4944 says we need to match on dst addr(mac), src addr(mac),
tag value, datagram_size value. [2]

The new reassembly handling use the inet_frag api (I mean the callback interface
of ipv6 and ipv4 reassembly). I looked into ipv6 and wanted to see how ipv6 is
dealing with reassembly, so I based my code on this implementation.



On the sending side to generate the fragments I improved the current code to use
the nearest 8 divided payload. (We can do that, because the mac layer has a
dynamic size, so it depends on mac_header how big we can do the payload).

Of course I fix also the reassembly/sending side to be rfc complaint now.

Regards
Alexander Aring

[1] http://tools.ietf.org/html/rfc4944
[2] http://tools.ietf.org/html/rfc4944#section-5.3

changes since v2:
 - rework checkpatch code style issue patch.
   Merge two pr_debugs into one pr_debug.

changes since v3:
 - rename 6lowpan.ko to 6lowpan_rtnl.c in commit msg of patch 5/8.

changes since v4:
 - Add a new patch 2/8 to introduce lowpan_uncompress_size function. Also
   improving this function a little bit.
 - Add a new patch 4/8 to change tag value to __be16.
 - use skb_header_reset function on FRAG1 only, which should have the
   lowpan header. See lowpan_get_frag_info function. (slightly improving
   of fragmentation header parsing).
 - changes types of variables to u16 in lowpan_skb_fragmentation.
 - use lowpan_uncompress_size instead of storing necessary information
   in skb control block, this can be destroyed after dev_queue_xmit call.
   Thanks David for this hint.
 - remove Tested-by: Martin Townsend <martin.townsend@xsilon.com>, because
   too many funcionality change.

changes since v5:
 - handle lowpan_addr_mode_size with lookup table.

Alexander Aring (8):
  6lowpan: add frag information struct
  6lowpan: add uncompress header size function
  6lowpan: fix fragmentation on sending side
  6lowpan: change tag type to __be16
  6lowpan: move 6lowpan.c to 6lowpan_rtnl.c
  6lowpan: fix some checkpatch issues
  net: ns: add ieee802154_6lowpan namespace
  6lowpan: handling 6lowpan fragmentation via inet_frag api

 include/net/ieee802154_netdev.h              |   7 +
 include/net/net_namespace.h                  |   4 +
 include/net/netns/ieee802154_6lowpan.h       |  22 ++
 net/ieee802154/6lowpan.h                     | 113 ++++++
 net/ieee802154/{6lowpan.c => 6lowpan_rtnl.c} | 323 +++++----------
 net/ieee802154/Makefile                      |   1 +
 net/ieee802154/reassembly.c                  | 565 +++++++++++++++++++++++++++
 net/ieee802154/reassembly.h                  |  66 ++++
 8 files changed, 865 insertions(+), 236 deletions(-)
 create mode 100644 include/net/netns/ieee802154_6lowpan.h
 rename net/ieee802154/{6lowpan.c => 6lowpan_rtnl.c} (70%)
 create mode 100644 net/ieee802154/reassembly.c
 create mode 100644 net/ieee802154/reassembly.h

-- 
1.9.0
