From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCHv2 bluetooth-next 00/10] 6lowpan: introduce basic 6lowpan-nd
Date: Mon, 2 May 2016 16:17:41 -0700
Message-ID: <58926844-0338-4D63-A5B6-DB0EBE903A0E@holtmann.org>
References: <1461140382-4784-1-git-send-email-aar@pengutronix.de> <D212A5BF-A414-403B-A409-1F8C2D279883@holtmann.org> <870fdf5f-82ed-b621-a8d5-625bf9d81d0d@stressinduktion.org>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org,
	Jukka Rissanen <jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Stefan Schmidt <stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>, mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org,
	Werner Almesberger <werner-SEdMjqphH88wryQfseakQg@public.gmane.org>,
	Linux Bluetooth <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
To: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <870fdf5f-82ed-b621-a8d5-625bf9d81d0d-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Hannes,

>>> this patch series introduces a layer for IPv6 neighbour discovery. At first
>>> it introduce the "ndisc_ops" to run a different handling for recv/send of
>>> NA/NS messages. The use case for such ndisc operation is RFC 6775 [0].
>>> Which describes a different neighbour discovery handling for 6LoWPAN networks.
>>> 
>>> I didn't implement RFC 6775 in this patch series, but introduce callback
>>> structure for replace different functions in ndisc implementation might be
>>> the right direction.
>>> 
>>> Another use case would be RFC 7400 [1] which describes a new option field to
>>> getting capabilities of 6LoWPAN next header compression methods.
>>> 
>>> What I implemented is a necessary functionality to handle short address for
>>> 802.15.4 6LoWPAN networks. The L2-Layer "802.15.4" can have two different
>>> link-layer addresses which can be used mixed at the same time inside 802.15.4
>>> networks. To deal with such behaviour in ndisc, it is defined at RFC 4944 [2].
>>> The bad news is, that I saw different handling of such handling. What Linux
>>> will do is to add two source/target address information option fields, each
>>> with different length, if short address is valid (can also not be given).
>>> Example:
>>> 
>>> - WPAN interface address settings
>>> - extended addr (must always be there)
>>> - short addr (0xfffe or 0xffff -> invalid)
>>> 
>>> Will add an extended addr to source/target address information option field.
>>> If short addr is in some valid range, then both address will be added to
>>> the option fields. Indicated are these different address types by the length
>>> field (extended -> length=2, short -> length=1), according to [1].
>>> 
>>> The tested 6LoWPAN implementation (RIOT-OS) allows only one source/target
>>> option field which is short XOR extended, otherwise it will be dropped.
>>> There is some lack of information there [2] and I don't know how do deal with
>>> it right, maybe we need to update the implementation there if it's really
>>> wrong.
>>> 
>>> To save such information for each neighbour we use the already implemented
>>> neighbour private data which some casting strategy for 6LoWPAN and 6LoWPAN
>>> link-layer specific data e.g. 802.15.4 short address handling.
>>> 
>>> Additional I implemented to add 6CO to the is_useropt callback in case of
>>> 6LoWPAN interface. The 6CO option will currently parsed in userspace which
>>> are placed in RA-Messages.
>>> 
>>> The ndisc_ops are not finished yet, of course we need handling for RS messages
>>> to place the 802.15.4 short address there as well and then also processing
>>> of RA messages for the 802.15.4 SLLAO option field.
>>> 
>>> - Alex
>>> 
>>> [0] https://tools.ietf.org/html/rfc6775
>>> [1] https://tools.ietf.org/html/rfc7400#section-3.3
>>> [2] https://tools.ietf.org/html/rfc4944#section-8
>>> 
>>> Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
>>> Cc: Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>
>>> Cc: James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>
>>> Cc: Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>
>>> Cc: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
>>> 
>>> changes since v2:
>>> - replace #ifdef CONFIG_IPV6 to #if IS_ENABLED(...)
>>> - replace #ifdef CONFIG_IEEE802154... to #if IS_ENABLED(...)
>>> - add more #if IS_ENABLED(CONFIG_IPV6) in ndisc.h
>>> 
>>> Alexander Aring (10):
>>> 6lowpan: add private neighbour data
>>> 6lowpan: add 802.15.4 short addr slaac
>>> 6lowpan: remove ipv6 module request
>>> ndisc: add addr_len parameter to ndisc_opt_addr_space
>>> ndisc: add addr_len parameter to ndisc_opt_addr_data
>>> ndisc: add addr_len parameter to ndisc_fill_addr_option
>>> ipv6: introduce neighbour discovery ops
>>> ipv6: export ndisc functions
>>> 6lowpan: introduce 6lowpan-nd
>>> 6lowpan: add support for 802.15.4 short addr handling
>>> 
>>> include/linux/netdevice.h     |   6 +-
>>> include/net/6lowpan.h         |  24 ++
>>> include/net/addrconf.h        |   3 +
>>> include/net/ndisc.h           | 124 ++++++++-
>>> net/6lowpan/6lowpan_i.h       |   2 +
>>> net/6lowpan/Makefile          |   2 +-
>>> net/6lowpan/core.c            |  50 +++-
>>> net/6lowpan/iphc.c            | 167 +++++++++--
>>> net/6lowpan/ndisc.c           | 633 ++++++++++++++++++++++++++++++++++++++++++
>>> net/bluetooth/6lowpan.c       |   2 +
>>> net/ieee802154/6lowpan/core.c |  12 +
>>> net/ieee802154/6lowpan/tx.c   | 107 ++++---
>>> net/ipv6/addrconf.c           |   7 +-
>>> net/ipv6/ndisc.c              | 132 +++++----
>>> net/ipv6/route.c              |   4 +-
>>> 15 files changed, 1117 insertions(+), 158 deletions(-)
>>> create mode 100644 net/6lowpan/ndisc.c
>> 
>> is there a chance that we get input into this patch set? I wonder also if it would be acceptable to take this through bluetooth-next or should it better go straight into net-next?
> 
> My proposal would be that the IPv6 patches go via net-next to reduce
> merge conflicts with maybe upcoming changes. If they are split up, they
> seem very much self contained and easy to review. The rest seems to be
> also very much self contained and can go in via bluetooth-next, then.
> What do you think?

I am actually fine with having this all go via net-next. We only have driver patches pending in bluetooth-next for the next merge window. Which means I can just pull net-next back into bluetooth-next at any time.

Regards

Marcel
