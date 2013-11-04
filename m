From: John Fastabend <john.r.fastabend@intel.com>
Subject: [PATCH 0/2] l2 hardware accelerated macvlans
Date: Mon, 04 Nov 2013 09:15:31 -0800
Message-ID: <20131104170424.2999.55773.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: nhorman@tuxdriver.com, alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:4011 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751527Ab3KDRmw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Nov 2013 12:42:52 -0500
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
few fixes. I suspect Neil will add his signed-off-by
line assuming I didn't mangle anything.

If folks find this series acceptable there are a few
items we can work on next. First broadcast and multicast
will use the hardware even for local traffic with this
series. It would be best (I think) to use the software
path for macvlan to macvlan traffic and save the PCIe
bus. Also this only allows for layer 2 mac forwarding
where some hardware supports more interesting forwarding
capabilities. Integrating with OVS may be useful here.

As always any comments/feedback welcome.

I'm going to continue testing these on top of ixgbe but
I believe these are stable and wanted to get them out to
a wider audience. I've tested multiple offloaded macvlans
with iperf and netperf using multiple sessions of each
and seen no issues.

My basic I/O test is here but I've also done some link
testing and others,

#ip link add link eth2 numtxqueues 4 numrxqueues 4 txqueuelen 50 type macvlan
#tc qdisc add dev macvlan0 mq
#iperf -c 10.0.0.1 -P 8 -t 5000 -i 10

Thanks,
John

---

John Fastabend (2):
      ixgbe: enable l2 forwarding acceleration for macvlans
      net: Add layer 2 hardware acceleration operations for macvlan devices


 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |   20 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c  |   12 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  465 +++++++++++++++++++++----
 drivers/net/macvlan.c                         |   36 ++
 include/linux/if_macvlan.h                    |    1 
 include/linux/netdev_features.h               |    2 
 include/linux/netdevice.h                     |   36 ++
 include/uapi/linux/if.h                       |    1 
 net/core/dev.c                                |   18 +
 net/core/ethtool.c                            |    1 
 net/sched/sch_generic.c                       |    2 
 11 files changed, 506 insertions(+), 88 deletions(-)

-- 
Signature
