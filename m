From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V3 0/4] Introduce mlx5 ethernet timestamping
Date: Tue, 29 Dec 2015 14:58:28 +0200
Message-ID: <1451393912-13736-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Richard Cochran <richardcochran@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	saeedm@dev.mellanox.co.il, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37873 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752717AbbL2M7I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Dec 2015 07:59:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series introduces the support for ConnectX-4 timestamping
and the PTP kernel interface.

Changes from V2:
net/mlx5_core: Introduce access function to read internal_timer
	- Remove one line function
	- Change function name

net/mlx5e: Add HW timestamping (TS) support:
	- Data path performance optimization (caching tstamp struct in rq,sq)
	- Change read/write_lock_irqsave to read/write_lock
	- Move ioctl functions to en_clock file
	- Changed overflow start algorithm according to comments from Richard
	- Move timestamp init/cleanup to open/close ndos.

In details:

1st patch prevents the driver from modifying skb->data and SKB CB in
device xmit function.

2nd patch adds the needed low level helpers for:
	- Fetching the hardware clock (hardware internal timer)
	- Parsing CQEs timestamps
	- Device frequency capability

3rd patch adds new en_clock.c file that handles all needed timestamping
operations:
	- Internal clock structure initialization and other helper functions
	- Added the needed ioctl for setting/getting the current timestamping
	  configuration.
	- used this configuration in RX/TX data path to fill the SKB with 
	  the timestamp.

4th patch Introduces PTP (PHC) support.

Achiad Shochat (1):
  net/mlx5e: Do not modify the TX SKB

Eran Ben Elisha (3):
  net/mlx5_core: Introduce access function to read internal timer
  net/mlx5e: Add HW timestamping (TS) support
  net/mlx5e: Add PTP Hardware Clock (PHC) support

 drivers/net/ethernet/mellanox/mlx5/core/Kconfig    |    1 +
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   31 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c |  287 ++++++++++++++++++++
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   30 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   24 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |    9 +
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |   85 ++++--
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |   13 +
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |    1 +
 include/linux/mlx5/device.h                        |   20 ++-
 include/linux/mlx5/mlx5_ifc.h                      |    6 +-
 12 files changed, 467 insertions(+), 42 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
