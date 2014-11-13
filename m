From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv10 ovs 00/15] Revalidate flows with unique identifiers.
Date: Thu, 13 Nov 2014 11:17:40 -0800
Message-ID: <1415906275-3172-1-git-send-email-joestringer@nicira.com>
Cc: netdev@vger.kernel.org
To: dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog039.obsmtp.com ([74.125.150.113]:49706 "HELO
	na6sys009bog039.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933571AbaKMThG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 14:37:06 -0500
Received: by mail-pd0-f169.google.com with SMTP id y10so15152852pdj.0
        for <netdev@vger.kernel.org>; Thu, 13 Nov 2014 11:37:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series modifies the dpif interface for flow commands to use 128-bit unique
identifiers as an alternative to the netlink-formatted flow key, and caches the
mask/actions in the udpif_key. This significantly reduces the cost of
assembling messages between revalidators and the datapath, improving
revalidation performance by 40% or more. In a test environment of many
short-lived flows constantly being set up in the datapath, this increases the
number of flows that can be maintained in the linux datapath from around
130-140K up to 190-200K. For the userspace datapath, this decreases the time
spent revalidating 160K flows from 250ms to 150ms.

The core of the changes sits in the handler and revalidator code. Handlers take
responsibility for creating udpif_key cache entries which now include a copy of
the flow mask and actions. Revalidators request datapaths to dump flows using
only the unique identifier and stats, rather than the full set of
netlink-formatted flow key, mask and actions.

In cases where full revalidation is required, revalidators will use the
udpif_key cache of the key/mask/acts to validate the flow. The dpif will
detect datapath support for the unique identifer "UFID" feature, and omit flow
keys from netlink transactions if it is supported. For backwards compatibility,
flow keys will always be serialised if UFID support is not detected in the
datapath.

Patches 1,2,3,15 are unreviewed. Patch 12 needs further review.

This series is also made available here to assist review:
https://github.com/joestringer/openvswitch/tree/submit/ufid_v10

CC: netdev@vger.kernel.org

v10:
- New patch allowing datapath to serialize masked keys
- New patch providing commandline parsing of UFIDs
- New patch to fix IP fragment testsuite failure
- Simplify datapath interface by accepting UFID or flow_key, but not both
- Flows set up with UFID must be queried/deleted using UFID
- Reduce sw_flow memory usage for UFID
- Don't periodically rehash UFID table in linux datapath
- Remove kernel_only UFID in linux datapath
- Track whether UFIDs are present in datapath in udpif_key

v9:
- New patch to enable verbose flow-dumping in ovs-bugtool
- Don't print UFIDs by default in ovs-dpctl, ovs-appctl dump-flows output
- Userspace datapath performance and correctness improvements

v8:
- Rename UID -> UFID
- Clarify dpif interface descriptions
- Remove 'struct odputil_uidbuf'
- Simplify dpif-netlink UFID marshalling
- 32-bit build fix
- Fix null dereference in datapath when paired with older userspace
- Don't generate UFIDs for feature probes or ovs-dpctl usage
- Rebase
- All patches are reviewed/acked except datapath changes.

v7:
- Remove OVS_DP_F_INDEX_BY_UID
- Rework datapath UID serialization for variable length UIDs
- Create ukeys from revalidator threads in corner cases
- Hide "terse" flags from flow_get,flow_del dpif interface
- Scattered replacements of memcpy with u128_equal()
- Rebase

v6:
- Address feedback from Ben
- Split out "dpif: Add Unique flow identifiers." into three patches
- Reduce netlink conversions for all datapaths
- Reduce udpif_key footprint
- Added x64 version of murmurhash3
- Added hash function tests
- Various bugfixes
- Rebase

v5:
- Rebase
- Various bugfixes
- Improve logging

v4:
- Datapath memory leak fixes
- Enable UID-based terse dumping and deleting by default
- Shifted UID generation down to dpif
- Log flow UIDs in more places
- Various fixes

RFCv3:
- Add datapath implementation
- Minor fixes
- Rebased

RFCv2:
- Revised early patches from v1 feedback
- Add Acks from Ben
- Rebased

Joe Stringer (15):
  tests: Add command to purge revalidators of flows.
  ovs-bugtool: Log more detail for dumped flows.
  datapath: Add 'is_mask' to ovs_nla_put_flow().
  revalidator: Use 'cmap' for storing ukeys.
  revalidator: Protect ukeys with a mutex.
  udpif: Separate udpif_key maps from revalidators.
  upcall: Rename dump_op -> ukey_op.
  upcall: Create ukeys in handler threads.
  upcall: Revalidate using cache of mask, actions.
  hash: Add 128-bit murmurhash.
  dpif: Generate flow_hash for revalidators in dpif.
  datapath: Add support for unique flow identifiers.
  dpif: Index flows using unique identifiers.
  dpif: Minimize memory copy for revalidation.
  dpctl: Add support for using UFID to add/del flows.

 datapath/README.md                                |   13 +
 datapath/datapath.c                               |  249 ++++--
 datapath/flow.h                                   |   20 +-
 datapath/flow_netlink.c                           |   39 +-
 datapath/flow_netlink.h                           |    5 +-
 datapath/flow_table.c                             |  214 ++++-
 datapath/flow_table.h                             |    8 +
 datapath/linux/compat/include/linux/openvswitch.h |   30 +
 include/openvswitch/types.h                       |   14 +
 lib/dpctl.c                                       |   47 +-
 lib/dpif-netdev.c                                 |  180 +++--
 lib/dpif-netlink.c                                |  258 +++++-
 lib/dpif-provider.h                               |   13 +-
 lib/dpif.c                                        |   65 +-
 lib/dpif.h                                        |   44 +-
 lib/hash.c                                        |  266 ++++++-
 lib/hash.h                                        |   11 +-
 lib/odp-util.c                                    |   94 +++
 lib/odp-util.h                                    |    6 +
 ofproto/ofproto-dpif-upcall.c                     |  868 +++++++++++++++------
 ofproto/ofproto-dpif.c                            |   14 +-
 tests/dpif-netdev.at                              |    5 +
 tests/ofproto-dpif.at                             |   36 +-
 tests/ofproto-macros.at                           |    1 +
 tests/test-hash.c                                 |   83 ++
 utilities/bugtool/ovs-bugtool-ovs-appctl-dpif     |    4 +-
 utilities/bugtool/ovs-bugtool.in                  |    2 +-
 27 files changed, 2058 insertions(+), 531 deletions(-)

-- 
1.7.10.4
