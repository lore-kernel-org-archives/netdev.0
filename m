From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH RFC 0/3] Support envelope frames (802.3as)
Date: Tue, 27 Sep 2016 17:55:36 +0900
Message-ID: <1474966541-4420-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:60843 "EHLO
        tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753454AbcI0I64 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 04:58:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces software implementation of envelope frames defined
in 802.3as[1], which allows encapsulated packets to be received without
expanding MTU for them.


* Envelope frames

Envelope frames are introduces by IEEE 802.3as[1], which has been
incorpolated in IEEE 802.3-2012.

IEEE 802.3-2012 1.4.184 defines envelope frame as:
	A MAC frame that carries a Length/Type field with the Type
	interpretation that may indicate additional encapsulation
	information within the MAC client data and has a maximum length
	of 2000 octets. The envelope frame is intended to allow inclusion
	of additional prefixes and suffixes required by higher layer
	encapsulation protocols. The encapsulation protocols may use up
	to 482 octets.


* Motivation

The intended customer of this feature is mainly vlan, possibly mpls or
other encapsulation protocols.

Vlan is different than other encapsulation protocols in that the packet
size is generally larger than normal packets by vlan-header size (4 bytes).
Thus, most NICs allow packets the size of which is larger by 4 bytes
than MTU (802.3 calls this vlan-tagged packets "Q-tagged frames", whose
MTU is 1504 including vlan header. Most NICs accept Q-tagged frames).

Similarly, when doubly tagged vlan is used leveraging 802.1ad, the packet
size will be larger by vlan-header size * 2 (8 bytes). This packet size is
needed to provide Ethernet VPN transparent to the users. Thus, hardware
switches support 1508 bytes MTU when using 802.1ad, as suggested by MEF[2].
Also, Linux stacked vlan devices have 1500 bytes MTU, which emit 1508
bytes doubly tagged packets. But unfortunately some NICs don't accept 
1508 bytes packets by default, and they are dropped.

+----+ single tag +-------+ double tag +-------+ double tag +------+
|End | 1504 bytes |802.1ad| 1508 bytes |802.1ad| 1508 bytes |Linux |
|User|----------->|Edge SW|----------->|NNI SW |----------->|Server|
+----+            +-------+            +-------+     *drop* +------+
                                                     on NIC

802.3 calls such encapsulated packets larger than 1504 "envelope frames".
Most NICs lack support for envelope frames. But many of them support jumbo
frames, which can be used to implement envelope frames support in Linux.
I'm proposing this envelope frames support to fix problems described above.


* Implementation

Envelope frames require normal packets to use 1500-sized MTU, while
encapsulation headers can be added to the MTU. If we simply increase MTU
of the physical device, it causes jumbo frames as well as envelope frames
(jumbo frames are non-encapsulated packets whose MTU is larger than 1500).
So what we need here is to increase the max acceptable frame size of NICs
without changing dev->mtu.

In order to achieve this, I add a new function pointer,
.ndo_set_env_hdr_len, in net_device_ops, through which kernel can inform
device drivers of needed additional header size of envelope frames
(env_hdr_len).
Implementation in device drivers is as simple as replacing dev->mtu with
dev->mtu + env_hdr_len. This makes devices recognize dev->mtu + env_hdr_len
as MTU, and allow packets with additional header up to env_hdr_len, while
kernel networking stack recognizes dev->mtu as MTU. Thus no packets larger
than MTU will be sent other than those encapsulated by upper devices. This
effectively supports envelope frames.

Userspace API is netlink, the same as MTU. It will be a parameter which
can be configured through "ip link".


* Q&A

** Why not reducing MTU of VLAN devices?

As written in Motivation, in order to achieve transparency of Ethernet VPN,
MTU of vlan device needs to be 1500. Since this is usual in 802.1ad network,
switches in 802.1ad network send 1508-sized tagged packets. Thus, reducing
MTU of vlan device does not change the situation where Linux receives
packets whose MTU is larger than NICs' acceptable size, and does not fix
the issue.

** Why not increasing MTU of physical devices?

Increasing MTU of physical device indeed resolves the problem that NICs
cannot receive doubly tagged packets. However, this effectively allows
devices to send jumbo frames as well as envelope frames, and could cause
packet drops on network elements which does not accept jumbo frames.

** Why is .ndo_set_env_hdr_len needed?
   Why not modifying drivers to accept envelope frames by default?

Some NICs actually support envelope frames by default. One example is igb,
which always accepts packet size up to 9728.
I however don't think all NICs necessarily be able to do that since some
NICs change their behaviour when changing MTU larger than 1500.
For example, e1000e changes usage of descriptors when its MTU gets larger
than 1500. qlge also looks to change its behaviour as far as I can see from
the source code of the driver.
In order to keep the default behaviour when not using 802.1ad or stacked
vlan, some knob is needed.

** Why are drivers notified of header _length_?
   Why not introducing a knob to simply enable envelope mode?

The reason being the same as the previous question. There can be a NIC that
changes its behaviour when changing MTU larger than a certain value (I don't
know any such NICs though). If we do not notify drivers of length, the NIC
should add 482 bytes to MTU in envelope mode as defined in 802.3as, and this
may change NIC's behaviour. Vlan needs only 8 additional bytes and it may
not change NIC's behaviour. I just wanted to make it flexible to handle such
situation.
Another problem when we do not notify drivers of length is how to handle the
case where NICs partially support envelope frames. If a certain NIC does not
support 482 bytes additional header but some size of header smaller than 482,
how to handle this? If we make the .ndo_set_env_hdr_len fail in such a case,
users cannot use its additional header, even if the max acceptable size is
sufficient for them. If we make the op succeed, we need to add another API
to expose the accepted size so that users can know how long header they can
use.


* Examples

I show current behaviour of some NICs and expected behaviour when
setting env_hdr_len.

As far as I can confirm with actual equipments in our lab, there are
at least four types of drivers/devices.

(Type 1) Devices with extra buffer larger than vlan header

(Type 1-1) Devices with small amount of extra buffer
Devices/drivers that already take into account stacked vlan, or have
more extra room than it should be due to alignment restriction, etc.
This type of NICs does not require any additional operation to make
stacked vlan work.
E.g. mlx4_en, sfc

(Type 1-2) Devices with large amount of extra buffer
Devices/drivers that always accept packets up to the maximum configurable
size of MTU with jumbo frames support. This type of NICs has enough size
of extra buffer for envelope frames, the header size of which is defined
as 482 in 802.3as. They accept various types of protocols in addition to
stacked vlan.
E.g. igb

(Type 2) Devices without extra buffer larger than vlan header

(Type 2-1) Devices with generic 4 bytes extra buffer
Devices/drivers that accept MTU + 4 sized packets.
Any packets not larger than MTU + 4 are acceptable but those larger than
the value are dropped.
E.g. e1000e

(Type 2-2) Devices with 4 bytes extra buffer only for vlan
Devices/drivers that accept MTU + 4 sized packets only if it is vlan
tagged. Other packets are dropped if they exceed MTU, even if their size
is less than MTU + 4.
This type of devices even drops 802.1ad single tagged packets, if they
do not support 802.1ad vlan protocol.
E.g. bnx2x, ixgbe


The problematic NICs with stacked vlan are only type 2, but we should
assume all types of NICs can be configured with env_hdr_len, because
users do not know which NIC is which type.

The expected behaviour when users set 8 bytes env_hdr_len for stacked vlan
is as follows:
(Type 1) As they have more room than 8, do nothing.
(Type 2-1) They have 4 bytes env_hdr_len by default. When users specifies 8,
  drivers increase devices' MTU by 4 bytes.
(Type 2-2) They have 0 bytes env_hdr_len by default. When users specifies 8,
  drivers increase devices' MTU by 8 bytes.


* Recommended operations for users

- Set env_hdr_len of the physical device to 8 when they create a 802.1ad
  vlan device or stacked vlan devices.
- If setting of env_hdr_len fails (due to EOPNOTSUPP), try increasing MTU
  of the physical device.
- If increasing MTU fails, there is no other option than reducing MTU of
  vlan devices, unfortunately.

Note that those operations are not needed for 802.1q single vlan devices
at all, even after adding envelope frame support. Adjustment of MTU in case
of single 802.1q vlan should be cared by drivers as before.


* Future Plan

In the future 802.1ad vlan devices should take care of the MTU problem in
kernel and adjust env_hdr_len automatically. This can be achieved by
notifying drivers of env_hdr_len on creating 802.1ad devices.
This notification, however, does not always succeed because of lack of
.ndo support or jumbo frame feature, so this cannot completely remove
the necessity of userspace operation of env_hdr_len. Nevertheless I'm
thinking this would help users to some extent.


* Note

I submitted the previous patch set with title of "Automatic adjustment of
max frame size"[3]. Now I'm not targetting at automation but infrastracture
for the feature, as I think automation is kind of premature when even
manual operation is not possible.

This problem was discussed in Netdev 0.1:
http://www.netdevconf.org/0.1/docs/netdev01_bof_8021ad_makita_150212.pdf
This topic is also going to be discussed in Netdev 1.2:
http://www.netdevconf.org/1.2/session.html?toshiaki-makita


[1] http://www.ieee802.org/3/as/public/0607/802.3as_overview.pdf
[2] https://wiki.mef.net/display/CESG/ENNI+Attributes
[3] https://marc.info/?t=144583097100001&r=1&w=2
    https://marc.info/?t=144583097100005&r=1&w=2
    https://marc.info/?t=144583097100006&r=1&w=2
    https://marc.info/?t=144583097100004&r=1&w=2
    https://marc.info/?t=144583097100002&r=1&w=2

Toshiaki Makita (3):
  net: Add dev_set_env_hdr_len to accept envelope frames
  net: Support IFLA_ENV_HDR_LEN to configure max envelope header length
  e1000e: Add ndo_set_env_hdr_len

 drivers/net/ethernet/intel/e1000e/netdev.c | 84 +++++++++++++++++++++---------
 include/linux/netdevice.h                  | 21 ++++++++
 include/uapi/linux/if_link.h               |  1 +
 net/core/dev.c                             | 32 ++++++++++++
 net/core/rtnetlink.c                       | 16 +++++-
 5 files changed, 128 insertions(+), 26 deletions(-)

-- 
1.8.3.1
