From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net-next v2 0/8] ieee802154: fix endianness and header handling
Date: Fri, 14 Mar 2014 21:23:56 +0100
Message-ID: <1394828644-19898-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from selenium.quasiparticle.net ([188.40.96.248]:52603 "EHLO
	quasiparticle.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754470AbaCNUYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 16:24:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set enforces network byte order on all internal operations and
fields of the 802.15.4 stack and adds a general representation of 802.15.4
headers with operations to create and parse those headers. This reduces code
duplication in the current stack and also allows for upper layers to read
headers of packets they have just received; it is also necessary for 802.15.4
link layer security, which requires header mangling.

---

Changes since v1:
 * fixed lowpan packet rx after reassembly. Control blocks were used to
   retrieve source/dest addresses, but the CB is clobbered by reassembly.
   Instead, parse the header anew in lowpan.

---

What this patch set does *not* do is change endianness of the netlink/socket
API. I would very much wish to change that as well. My research has uncovered
two projects that use the stack, both of which extensively copy kernel headers
that were never part of uapi and were also never installed as userspace headers
before the uapi split. One of those projects is lowpan-tools[1], which is
easily changed, and IBR-DTN[2], which does not seem to make much use of the
stack either. In fact, the near uselessness of 6lowpan until a few weeks ago
and a number of minor problems with datagram sockets suggests that nobody has
ever used the stack for more than cursory experiments. Moreover, most projects
on the internet that run on Linux and make some use of 802.15.4 radios even
include their own drivers and often implement their own version of the protocol
stack.

The fact that the only users I could find copy private headers to get their
definitions would have me assume that it's okay to change those headers and the
definitions, since the were never actually exposed. Is this correct, does it
allow us to change the netlink/socket API that already exists?

[1] http://sourceforge.net/apps/trac/linux-zigbee/wiki
[2] http://trac.ibr.cs.tu-bs.de/project-cm-2012-ibrdtn/

---


Phoebe Buckheister (8):
      ieee802154: rename struct ieee802154_addr to *_sa
      ieee802154: add address struct with proper endiannes and some operations
      ieee802154: enforce consistent endianness in the 802.15.4 stack
      ieee802154: add header structs with endiannes and operations
      mac802154: use header operations to create/parse headers
      ieee802154: use ieee802154_addr instead of *_sa variants
      6lowpan: move lowpan frag_info out of 802.15.4 headers
      ieee802154: add proper length checks to header creations


 drivers/net/ieee802154/at86rf230.c |  25 +--
 drivers/net/ieee802154/fakehard.c  |  22 +--
 drivers/net/ieee802154/mrf24j40.c  |  17 +-
 include/net/af_ieee802154.h        |   4 +-
 include/net/ieee802154.h           |  28 ++-
 include/net/ieee802154_netdev.h    | 181 ++++++++++++++++--
 include/net/mac802154.h            |   6 +-
 include/net/nl802154.h             |   6 +-
 net/ieee802154/6lowpan_rtnl.c      |  58 +++---
 net/ieee802154/Makefile            |   5 +-
 net/ieee802154/af802154.h          |   5 +-
 net/ieee802154/af_ieee802154.c     |  20 +-
 net/ieee802154/dgram.c             |  56 +++---
 net/ieee802154/header_ops.c        | 287 ++++++++++++++++++++++++++++
 net/ieee802154/nl-mac.c            | 102 ++++++----
 net/ieee802154/raw.c               |  14 +-
 net/ieee802154/reassembly.c        |  40 ++--
 net/ieee802154/reassembly.h        |  31 +--
 net/mac802154/Makefile             |   2 +
 net/mac802154/ieee802154_dev.c     |   5 +-
 net/mac802154/mac802154.h          |   9 +-
 net/mac802154/mac_cmd.c            |   2 +-
 net/mac802154/mib.c                |  22 ++-
 net/mac802154/wpan.c               | 376 ++++++++++++-------------------------
 24 files changed, 841 insertions(+), 482 deletions(-)
