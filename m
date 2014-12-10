From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v2 0/4] switchdev offload flags
Date: Wed, 10 Dec 2014 01:05:16 -0800
Message-ID: <1418202320-19491-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:57157 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751568AbaLJJFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 04:05:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>


This patch series introduces new offload flags for switchdev.
This flag can be used to accelerate kernel network functions by
offloading to hw.

This patch series currently only addresses bridge driver link
attribute offloads to hardware.

Looking at the current state of bridge l2 offload in the kernel,
    - flag 'self' is the way to directly manage the bridge device in hw via
      the ndo_bridge_setlink/ndo_bridge_getlink calls
 
    - flag 'master' is always used to manage the in kernel bridge devices
      via the same ndo_bridge_setlink/ndo_bridge_getlink calls

Today these are used separately. The nic offloads use hwmode "vepa/veb" to go
directly to hw with the "self" flag.

At this point i am trying not to introduce any new user facing flags/attributes.
In the model where we want the kernel bridging to be accelerated with
hardware, we very much want the bridge driver to be involved.

In this proposal,
- The offload flag/bit helps switch asic drivers to indicate that they
  accelerate the kernel networking objects/functions
- The user does not have to specify a new flag to do so. A bridge created with
  switch asic ports will be accelerated if the switch driver supports it.
- The user can continue to directly manage l2 in nics (ixgbe) using the
  existing hwmode/self flags
- It also does not stop users from using the 'self' flag to talk to the
  switch asic driver directly
- Involving the bridge driver makes sure the add/del notifications to user
  space go out after both kernel and hardware are programmed

(To selectively offload bridge port attributes,
example learning in hw only etc, we can introduce offload bits for 
per bridge port flag attribute as in my previous patch
https://patchwork.ozlabs.org/patch/413211/. I have not included that in this
series)

v1 -> v2 
   - try a different name for the offload flag/bit
   - tries to solve the stacked netdev case

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Roopa Prabhu (4):
  netdev: introduce new NETIF_F_HW_SWITCH_OFFLOAD feature flag for
    switch device offloads
  swdevice: add new api to set and del bridge port attributes
  bridge: offload bridge port attributes to switch asic if feature flag
    set
  rocker: set feature NETIF_F_HW_SWITCH_OFFLOAD

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 +-
 drivers/net/ethernet/rocker/rocker.c          |   10 ++--
 include/linux/netdev_features.h               |    2 +
 include/linux/netdevice.h                     |    4 +-
 include/net/switchdev.h                       |    5 +-
 net/bridge/br_netlink.c                       |   40 +++++++++++++--
 net/bridge/br_private.h                       |    4 +-
 net/core/rtnetlink.c                          |    8 +--
 net/switchdev/switchdev.c                     |   66 +++++++++++++++++++++++++
 9 files changed, 122 insertions(+), 19 deletions(-)

-- 
1.7.10.4
