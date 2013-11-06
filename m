From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next PATCH v4 0/2] l2 hardware accelerated macvlans
Date: Wed, 06 Nov 2013 09:54:40 -0800
Message-ID: <20131106175308.3822.73239.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, andy@greyhouse.net,
	netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	vyasevich@gmail.com
To: nhorman@tuxdriver.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:4443 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751716Ab3KFSP5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Nov 2013 13:15:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support to offload macvlan net_devices to the
hardware. With these patches packets are pushed to the macvlan
net_device directly and do not pass through the lower dev.

The patches here have made it through multiple iterations
each with a slightly different focus. First I tried to
push these as a new link type called "VMDQ". The patches
shown here,

http://comments.gmane.org/gmane.linux.network/237617

Following this implementation I renamed the link type
"VSI" and addressed various comments. Finally Neil
Horman picked up the patches and integrated the offload
into the macvlan code. Here,

http://permalink.gmane.org/gmane.linux.network/285658

The attached series is clean-up of his patches, with a
few fixes.

If folks find this series acceptable there are a few
items we can work on next. First broadcast and multicast
will use the hardware even for local traffic with this
series. It would be best (I think) to use the software
path for macvlan to macvlan traffic and save the PCIe
bus. This depends on how much you value CPU time vs
PCIE bandwidth. This will need another patch series
to flush out.

Also this series only allows for layer 2 mac forwarding
where some hardware supports more interesting forwarding
capabilities. Integrating with OVS may be useful here.

As always any comments/feedback welcome.

My basic I/O test is here but I've also done some link
testing, SRIOV/DCB with macvlans and others,

#ip link add link eth2 numtxqueues 4 numrxqueues 4 txqueuelen 50 type macvlan
#tc qdisc add dev macvlan0 mq
#iperf -c 10.0.0.1 -P 8 -t 5000 -i 10

Changelog:
v2: two fixes to ixgbe when all features DCB, FCoE, SR-IOV
    are enabled with macvlans. A VMDQ_P() reference
    should have been accel->pool and do not set the offset
    of the ring index from dfwd add call. The offset is used
    by SR-IOV so clearing it can cause SR-IOV quue index's
    to go sideways. With these fixes testing macvlan's with
    SRIOV enabled was successful.
v3: addressed Neil's comments in ixgbe
    fixed error path on dfwd_add_station() in ixgbe
    fixed ixgbe to allow SRIOV and accelerated macvlans to
    coexist.
v4: Dave caught some strange indentation, fixed it here
---

John Fastabend (2):
      ixgbe: enable l2 forwarding acceleration for macvlans
      net: Add layer 2 hardware acceleration operations for macvlan devices


 drivers/net/ethernet/intel/ixgbe/ixgbe.h       |   20 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c   |   15 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |  480 ++++++++++++++++++++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |   17 -
 drivers/net/macvlan.c                          |   36 ++
 include/linux/if_macvlan.h                     |    1 
 include/linux/netdev_features.h                |    2 
 include/linux/netdevice.h                      |   36 ++
 include/uapi/linux/if.h                        |    1 
 net/core/dev.c                                 |   18 +
 net/core/ethtool.c                             |    1 
 net/sched/sch_generic.c                        |    2 
 12 files changed, 532 insertions(+), 97 deletions(-)

-- 
Signature
