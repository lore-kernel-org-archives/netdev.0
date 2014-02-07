From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH v3 net 0/9] bridge: Fix corner case problems around local fdb entries
Date: Fri,  7 Feb 2014 16:48:17 +0900
Message-ID: <1391759306-24956-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:39809 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751549AbaBGHso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 02:48:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are so many corner cases that are not handled properly around local
fdb entries.
- We might fail to delete the old entry and might delete an arbitrary local
  entry when changing mac address of a bridge port.
- We always fail to delete the old entry when changing mac address of the
  bridge device.
- We might incorrectly delete a necessary entry when detaching a bridge port.
- We might incorrectly delete a necessary entry when deleting a vlan.
and so on.

This is a patch series to fix these issues.

v3:
- Handle NTF_USE case in patch 1/9, commented by Vlad Yasevich.

- Tested port detach/attach and didn't find any problem with patch 5/9,
  suggested by Stephen Hemminger.

- Add comments about possible inconsistent state in current implementation
  into commit log of patch 5/9, found by the above test.

- Reword unintensive changelog of patch 7/9, commented by Vlad Yasevich.

v2:
- Change the way to find the old entry in br_fdb_changeaddr() from memorizing
  previous port address to introducing a new flag indicating whether a fdb
  entry is added by user or not, commented by Stephen Hemminger.

- Add a fix for the way to insert a new address in br_fdb_changeaddr().

- Prevent creating an entry such that its dst is NULL in br_add_if() to
  preserve old behavior, commented by Vlad Yasevich.

- Add more comments about slight behavior change, where the bridge device
  come to be able to receive traffic to an address it has during short
  window, to changelogs, commented by Vlad Yasevich.

- Add a fix for possible race in br_fdb_change_mac_address().

Toshiaki Makita (9):
  bridge: Fix the way to find old local fdb entries in br_fdb_changeaddr
  bridge: Fix the way to insert new local fdb entries in
    br_fdb_changeaddr
  bridge: Fix the way to find old local fdb entries in
    br_fdb_change_mac_address
  bridge: Change local fdb entries whenever mac address of bridge device
    changes
  bridge: Fix the way to check if a local fdb entry can be deleted
  bridge: Properly check if local fdb entry can be deleted in
    br_fdb_change_mac_address
  bridge: Properly check if local fdb entry can be deleted in
    br_fdb_delete_by_port
  bridge: Properly check if local fdb entry can be deleted when deleting
    vlan
  bridge: Prevent possible race condition in br_fdb_change_mac_address

 net/bridge/br_device.c  |   3 +-
 net/bridge/br_fdb.c     | 137 +++++++++++++++++++++++++++++++-----------------
 net/bridge/br_if.c      |   6 +--
 net/bridge/br_input.c   |   4 +-
 net/bridge/br_private.h |  13 ++++-
 net/bridge/br_stp_if.c  |   2 +
 net/bridge/br_vlan.c    |  27 +++++++---
 7 files changed, 129 insertions(+), 63 deletions(-)

-- 
1.8.1.2
