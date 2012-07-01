From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 00/10] net/mlx4: Add flow-steering support
Date: Sun,  1 Jul 2012 12:43:33 +0300
Message-ID: <1341135823-29039-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, yevgenyp@mellanox.com, oren@mellanox.com,
	netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.co.il>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:43554 "HELO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754737Ab2GAJn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 05:43:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, 

This patch series from Hadar adds code to manage L2/L3/L4 network 
flow steering rules, a feature which is supported by the ConnectX-3 device.

The series is built as follows:

The first two patches deal with SRIOV resource tracker, whose mechanism 
is changed to use red-black tree instead of radix tree. The reason for 
this change is that the coming steering patches use flow IDs which are 64 
bits in size, where radix tree keys can't be 64bit on 32bit architecture, 
while RB tree can do that.

Patch #3 is little re-design of the Ethernet driver multicast attachments 
flow to be more efficient and robust.

The fourth patch does a re-org of the checks that deal with the current 
"older" steering modes such that we can easily add soon the new steering 
mode and the code remains easy to manage.

Patch #5 adds the firmware commands for the new steering mode, which is 
called "device managed flow steeering".

Patch 6 is the main patch of this series. It adds support for device-managed flow 
steering all across the place. We had to have this patch also to touch the mlx4 
IB driver, since the steering mode is global to the HCA -- so when being enabled, 
multicast attachment calls done by the IB driver into the mlx4 core driver, 
are now routed to the flow steering firmware commands whose API is a bit different, 
something that the IB driver had to be aware to. Following that, the 7th patch 
adds resource tracking for device-managed flow steering rules.

The 8th patch adds promiscuous mode support under device-managed flow steering,
next, the 9th patch adds implementation for the ethtool APIs for attaching 
L2/L3/L4 based flow steering rules, and the last patch adds support for drop 
action through ethtool.

Or.

Hadar Hen Zion (9):
  net/mlx4_core: Change resource tracking mechanism to use red-black tree
  net/mlx4_core: Change resource tracking ID to be 64 bit
  net/mlx4: Set steering mode according to device capabilities
  net/mlx4_core: Add firmware commands to support device managed flow steering
  {NET,IB}/mlx4: Add device managed flow steering firmware API
  net/mlx4_core: Add resource tracking for device managed flow steering rules
  net/mlx4: Implement promiscuous mode with device managed flow-steering
  net/mlx4_en: Manage flow steering rules with ethtool
  net/mlx4_en: Add support for drop action through ethtool

Yevgeny Petrilin (1):
  net/mlx4_en: Re-design multicast attachments flow

 drivers/infiniband/hw/mlx4/main.c                  |   62 ++-
 drivers/infiniband/hw/mlx4/mlx4_ib.h               |    1 +
 drivers/infiniband/hw/mlx4/qp.c                    |    1 +
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |   19 +
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c    |  373 ++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |  313 +++++++++---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c         |   30 ++
 drivers/net/ethernet/mellanox/mlx4/fw.c            |   90 +++-
 drivers/net/ethernet/mellanox/mlx4/fw.h            |    3 +
 drivers/net/ethernet/mellanox/mlx4/main.c          |   60 ++-
 drivers/net/ethernet/mellanox/mlx4/mcg.c           |  524 ++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |   29 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h       |   28 +-
 drivers/net/ethernet/mellanox/mlx4/port.c          |  111 +++--
 drivers/net/ethernet/mellanox/mlx4/profile.c       |   12 +-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |  284 +++++++++--
 include/linux/mlx4/cmd.h                           |    4 +
 include/linux/mlx4/device.h                        |  136 +++++-
 18 files changed, 1848 insertions(+), 232 deletions(-)

-- 
1.7.1

Cc: Hadar Hen Zion <hadarh@mellanox.co.il>
