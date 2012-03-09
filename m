From: John Fastabend <john.r.fastabend@intel.com>
Subject: [RFC PATCH v1 0/4] net: bridge: FDB management
Date: Fri, 09 Mar 2012 14:47:50 -0800
Message-ID: <20120309223621.2514.82321.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, roprabhu@cisco.com, netdev@vger.kernel.org,
	mst@redhat.com, chrisw@redhat.com, davem@davemloft.net,
	gregory.v.rose@intel.com, kvm@vger.kernel.org, sri@us.ibm.com,
	chealy@imsco-us.com
To: jhs@mojatatu.com, shemminger@vyatta.com, bhutchings@solarflare.com
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series is a follow up to the previous thread here:

http://lists.openwall.net/netdev/2012/02/29/31

There are some significant changes in this series. First
I add two NTF_XXX bits to signal if the PF_BRIDGE netlink
command should be parsed by the embedded bridge or the
SW bridge. The insight here is the SW bridge is always the
master device (NTF_MASTER) and the embedded bridge is
the lower device (NTF_LOWERDEV). Without either flag set
the command is parsed by the SW bridge to support existing
tooling.

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
notifier hooks and other methods but for now at least
this seems to be the simplest.

I'm going to drop this into my testbed and let it run
for a few days. But I think (hope?) this series is close
to being ready for a non-RFC submission. I'll probably
audit the patches once more as well.

Thanks to Stephen, Ben, and Jamal for bearing with me
and the feedback on the last round of patches.

As always any comments/feedback is appreciated!

---

John Fastabend (4):
      ixgbe: enable FDB netdevice ops
      net: add fdb generic dump routine
      net: addr_list: add exclusive dev_uc_add
      net: add generic PF_BRIDGE:RTM_XXX FDB hooks


 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   59 ++++++++
 include/linux/neighbour.h                     |    3 
 include/linux/netdevice.h                     |   27 +++
 include/linux/rtnetlink.h                     |    4 +
 net/bridge/br_device.c                        |    3 
 net/bridge/br_fdb.c                           |  128 ++++------------
 net/bridge/br_netlink.c                       |   12 --
 net/bridge/br_private.h                       |   15 ++
 net/core/dev_addr_lists.c                     |   19 ++
 net/core/rtnetlink.c                          |  194 +++++++++++++++++++++++++
 10 files changed, 352 insertions(+), 112 deletions(-)

-- 
Signature
