From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH bluetooth-next 0/4] ieee802154: add llsec support over nl802154
Date: Mon, 28 Sep 2015 09:00:22 +0200
Message-ID: <1443423626-3609-1-git-send-email-alex.aring@gmail.com>
Cc: kernel@pengutronix.de, netdev@vger.kernel.org,
	phoebe.buckheister@itwm.fraunhofer.de,
	Alexander Aring <alex.aring@gmail.com>
To: linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:36834 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053AbbI1HCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 03:02:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this patch series will add llsec support for nl802154.

What is "llsec"?

The llsec (I suppose it stands for linklayer security) is part of the SoftMAC
implementation of 802.15.4 "net/mac802154/llsec.c". The 802.15.4 standard
describes an security mechanism over ACL's. The encryption/decryption will do
llsec. To access llsec we need an interface for nl802154. The 802.15.4 standard
describes PHY/MAC layer and we have "possible" similar paradigms like wireless
with SoftMAC and HardMAC drivers. (We don't support HardMAC transceivers right
now, I never had some HardMAC transceivers, are really expensive and there are
only few some which can also run in a "raw" mode.) Anyway the nl802154 should
access SoftMAC/HardMAC drivers to abstract "one interface to userspace".

These ACL's are known as "security tables" inside the mac information base
(MIB) of 802.15.4 standard, security MIB.

The final goal we have to provide these tables in userspace is an "iptables"
handling "store" and "restore", over the userspace application "iwpan" which
contains the general "framework mechanism" like wireless "iw" tool, you can
add/del entries on these security tables, then.

I don't looked right now how iptables userspace application do "exactly" the
store and restore mechanism. The current way is a very KISS handling:

 We add netlink cmd's to add/del the table entries. Over the dump callback
 it's possible to get all information which is printed out as the command
 line string "iwpan dev $WPAN_DEV $TABLE add ...". The restore script will
 simple export $WPAN_DEV variable to restore these configuration for a
 specific interface.

 I will send the userspace patches as well to netdev, maybe somebody wants
 to know what I did there for first support.

This sounds weird but is to support llsec somehow a acceptable use-case. The
final goal is to lookup how iptables works and make a nicer C implementation.
There is currently no "official supported" userspace tool which support
accessing the "llsec".

I added several TODO's to the current implementation and added a new:

CONFIG_IEEE802154_NL802154_EXPERIMENTAL

This config will not build the nl802154 llsec layer and reduce the MAX_ATTR
attribute of nl802154 interface. With this config I explicit say this interface
over nl802154 is still in development and will be changed later.

The 802.15.4 subsystem is still in EXPERIMENTAL state, there was some commit
f4671a90c418b5aae14b61a9fc9d79c629403ca0 ("net/ieee802154: remove depends on
CONFIG_EXPERIMENTAL") which is fine but no maintainer ever said it's not
experimental anymore.

Checkpatch will complain about some above 80-chars width, at these places I
ignore these warning otherwise the code looks awful in my opinion.

My current working repository is still bluetooth-next/master. David if
everything is fine, then please ack patch "[PATCH bluetooth-next 1/4]
netlink: add nla_get for le32 and le64", so Marcel can apply it. Thanks.

- Alex

Alexander Aring (4):
  netlink: add nla_get for le32 and le64
  nl802154: use nla_get_le64 for get extended addr
  nl802154: add support for security layer
  mac802154: add comments for llsec issues

 include/net/cfg802154.h         |  131 ++++
 include/net/ieee802154_netdev.h |   75 ---
 include/net/netlink.h           |   18 +
 include/net/nl802154.h          |  191 ++++++
 net/ieee802154/Kconfig          |    5 +
 net/ieee802154/core.c           |   12 +
 net/ieee802154/core.h           |    1 +
 net/ieee802154/nl802154.c       | 1320 ++++++++++++++++++++++++++++++++++++---
 net/ieee802154/rdev-ops.h       |  109 ++++
 net/mac802154/cfg.c             |  205 ++++++
 net/mac802154/rx.c              |    4 +
 net/mac802154/tx.c              |    4 +
 12 files changed, 1903 insertions(+), 172 deletions(-)

-- 
2.5.3
