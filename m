From: John Eaglesham <linux@8192.net>
Subject: [PATCH v4 0/2] bonding support for IPv6 transmit hashing
Date: Sun,  1 Jul 2012 00:01:37 -0700
Message-ID: <cover.1341125875.git.linux@8192.net>
Cc: John Eaglesham <linux@8192.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp171.dfw.emailsrvr.com ([67.192.241.171]:56370 "EHLO
	smtp171.dfw.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751544Ab2GAHCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 03:02:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the "bonding" driver does not support load balancing outgoing
traffic in LACP mode for IPv6 traffic. IPv4 (and TCP or UDP over IPv4)
are currently supported; this patch adds transmit hashing for IPv6 (and
TCP or UDP over IPv6), bringing IPv6 up to par with IPv4 support in the
bonding driver.

The algorithm chosen (xor'ing the bottom three quads and then xor'ing
the bottom three bytes of that) was chosen after testing almost 400,000
unique IPv6 addresses harvested from server logs. This algorithm had the
most even distribution for both big- and little-endian architectures while
still using few instructions.

The IPv6 flow label was intentionally not included in the hash as it appears
to be unset in the vast majority of IPv6 traffic sampled, and the current
algorithm not using the flow label already offers a very even distribution.

Fragmented IPv6 packets are handled the same way as fragmented IPv4 packets,
ie, they are not balanced based on layer 4 information. Additionally,
IPv6 packets with intermediate headers are not balanced based on layer
4 information. In practice these intermediate headers are not common and
this should not cause any problems, and the alternative (a packet-parsing
loop and look-up table) seemed slow and complicated for little gain.

This is an update to a prior patch I submitted. This version includes
a clarified description, thorough bounds checking, updates functions to
call bond_xmit_hash_policy_l2 rather than re-implement the same logic,
incorporates Jay's style suggestions, and patches against net-next. Patch
has been tested and performs as expected.

John Eaglesham (2):
  Add support for IPv6 and bounds checking to transmit hashing
    functions.
  Update bonding driver documentation to include IPv6 transmit hashing
    algorithm.

 Documentation/networking/bonding.txt | 31 ++++++++++--
 drivers/net/bonding/bond_main.c      | 91 +++++++++++++++++++++++++-----------
 2 files changed, 90 insertions(+), 32 deletions(-)

-- 
1.7.11
