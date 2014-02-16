From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH RFC net-next 0/6] 6lowpan:
	reimplementation of fragmentation handling
Date: Sun, 16 Feb 2014 09:34:22 +0100
Message-ID: <1392539668-2349-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

this patch series reimplementation the fragmentation handling of 6lowpan
accroding to rfc4944 [1].

The first big note is, that the current fragmentation behaviour isn't rfc complaint.
The main issue is a wrong datagram_size value which needs to be:
datagram_size = ipv6_payload + ipv6 header + (maybe compressed transport header,
		currently only udp is supported)

but the current datagram_size value is calculated as:
datagram_size = ipv6_payload

So fragmentation works in a linux<->linux communication only.


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
dealing with reassembly, so I based my code on this.



On the sending side to generate the fragments I improved the current code to use
the nearest 8 divided payload. (We can do that, because the mac layer has a
dynamic size, so it depends on mac_header how big we can do the payload).

Of course I make the sending side and reassembly side rfc complaint now.
I sending this as RFC because I added a namespace to hold the fragmentation
information and I am not sure if all these changes are correct (I don't want to
break anything in the net branch). The new fragmentation handling isn't perfect
at the moment. It works and I will work on this later to improve this implementation
(If these patches will be accepted). I have two ideas to speedup the implementation.


Regards
Alexander Aring

[1] http://tools.ietf.org/html/rfc4944
[2] http://tools.ietf.org/html/rfc4944#section-5.3

Alexander Aring (6):
  6lowpan: add frag information struct
  6lowpan: fix fragmentation on sending side
  6lowpan: move 6lowpan.c to 6lowpan_rtnl.c
  6lowpan: fix some checkpatch issues
  net: ns: add ieee802154_6lowpan namespace
  6lowpan: handling 6lowpan fragmentation via inet_frag api

 include/net/ieee802154_netdev.h              |   7 +
 include/net/net_namespace.h                  |   4 +
 include/net/netns/ieee802154_6lowpan.h       |  22 ++
 net/ieee802154/6lowpan.h                     | 112 ++++++
 net/ieee802154/{6lowpan.c => 6lowpan_rtnl.c} | 327 +++++-----------
 net/ieee802154/Makefile                      |   1 +
 net/ieee802154/reassembly.c                  | 565 +++++++++++++++++++++++++++
 net/ieee802154/reassembly.h                  |  66 ++++
 8 files changed, 869 insertions(+), 235 deletions(-)
 create mode 100644 include/net/netns/ieee802154_6lowpan.h
 rename net/ieee802154/{6lowpan.c => 6lowpan_rtnl.c} (70%)
 create mode 100644 net/ieee802154/reassembly.c
 create mode 100644 net/ieee802154/reassembly.h

-- 
1.8.5.4


------------------------------------------------------------------------------
Android apps run on BlackBerry 10
Introducing the new BlackBerry 10.2.1 Runtime for Android apps.
Now with support for Jelly Bean, Bluetooth, Mapview and more.
Get your Android app in front of a whole new audience.  Start now.
http://pubads.g.doubleclick.net/gampad/clk?id=124407151&iu=/4140/ostg.clktrk
