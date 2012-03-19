From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next PATCH v0 0/5] Series short description
Date: Sun, 18 Mar 2012 23:51:45 -0700
Message-ID: <20120319064719.10959.93361.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	gregory.v.rose@intel.com, kvm@vger.kernel.org, sri@us.ibm.com,
	chealy@imsco-us.com
To: jhs@mojatatu.com, shemminger@vyatta.com, bhutchings@solarflare.com,
	roprabhu@cisco.com, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:11136 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751884Ab2CSHER (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2012 03:04:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series is a follow up to this thread:

http://www.spinics.net/lists/netdev/msg191360.html

This adds two NTF_XXX bits to signal if the PF_BRIDGE
netlink command should be parsed by the embedded bridge
or the SW bridge. The insight here is the SW bridge is
always the master device (NTF_MASTER) and the embedded
bridge is the lower device (NTF_LOWERDEV). Without either
flag set the command is parsed by the SW bridge to support
existing tooling.

To make this work correctly I added three new ndo ops

	ndo_fdb_add
	ndo_fdb_del
	ndo_fdb_dump

to add, delete, and dump FDB entries. These operations
can be used by drivers to program embedded nics or by
software bridges. We have at least three SW bridge now
net/bridge, openvswitch, and macvlan. And three variants
of embedded bridges SR-IOV devices, multi-function devices
and Distributed Switch Architecture (DSA).

I think at least in this case adding netdevice ops is
the cleanest way to implement this. I thought about
notifier hooks and other methods but this seems to be
the simplest.

I've tested these three scenarios, embedded bridge only,
sw bridge only, and embedded bridge and SW bridge. These
are working on the Intel 82599 devices with this patch
series. I am also working on a patch for the macvlan
drivers. I'll submit that as an RFC shortly so far I
only have the passthru mode wired up.

Thanks to Stephen, Ben, and Jamal for bearing with me
and the feedback on the last round of patches.

As always any comments/feedback appreciated!

---

John Fastabend (5):
      ixgbe: allow RAR table to be updated in promisc mode
      ixgbe: enable FDB netdevice ops
      net: add fdb generic dump routine
      net: addr_list: add exclusive dev_uc_add
      net: add generic PF_BRIDGE:RTM_XXX FDB hooks


 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   80 +++++++++-
 include/linux/neighbour.h                     |    3 
 include/linux/netdevice.h                     |   27 +++
 include/linux/rtnetlink.h                     |    4 +
 net/bridge/br_device.c                        |    3 
 net/bridge/br_fdb.c                           |  128 ++++------------
 net/bridge/br_netlink.c                       |   12 --
 net/bridge/br_private.h                       |   15 ++
 net/core/dev_addr_lists.c                     |   19 ++
 net/core/rtnetlink.c                          |  194 +++++++++++++++++++++++++
 10 files changed, 363 insertions(+), 122 deletions(-)

-- 
Signature
