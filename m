From: Wei Liu <wei.liu2@citrix.com>
Subject: [RFC PATCH V4] Xen netback / netfront improvement
Date: Thu, 2 Feb 2012 16:49:10 +0000
Message-ID: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: ian.campbell@citrix.com, konrad.wilk@oracle.com
To: netdev@vger.kernel.org, xen-devel@lists.xensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:16259 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753002Ab2BBQt0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Feb 2012 11:49:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes in V4:
 - Squash several patches
 - Per-cpu scratch improvement, guard against race condition, NUMA
   awared allocation
 - Extend xenbus ring mapping interface to benifit all Xen BE / FE
 - Remove RX protocol stub patch

Changes in V3:
 - Rework of per-cpu scratch space
 - Multi page ring support
 - Split event channels
 - Rx protocol stub
 - Fix a minor bug in module_put path

Changes in V2:
 - Fix minor bugs in V1
 - Embed pending_tx_info into page pool
 - Per-cpu scratch space
 - Notification code path clean up

This version has been tested by 
Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

V1:
A new netback implementation which includes three major features:

 - Global page pool support
 - NAPI + kthread 1:1 model
 - Netback internal name changes

This patch series is the foundation of furture work. So it is better
to get it right first. Patch 1 and 3 have the real meat.

The first benifit of 1:1 model will be scheduling fairness.

The rational behind a global page pool is that we need to limit
overall memory consumed by all vifs.

Utilization of NAPI enables the possibility to mitigate
interrupts/events, the code path is cleaned up in a separated patch.

Netback internal changes cleans up the code structure after switching
to 1:1 model. It also prepares netback for further code layout
changes.

-----
 drivers/block/xen-blkback/xenbus.c    |    8 +-
 drivers/block/xen-blkfront.c          |    5 +-
 drivers/net/xen-netback/Makefile      |    2 +-
 drivers/net/xen-netback/common.h      |  107 +++--
 drivers/net/xen-netback/interface.c   |  230 ++++++--
 drivers/net/xen-netback/netback.c     |  999 +++++++++++++++------------------
 drivers/net/xen-netback/page_pool.c   |  185 ++++++
 drivers/net/xen-netback/page_pool.h   |   66 +++
 drivers/net/xen-netback/xenbus.c      |  178 ++++++-
 drivers/net/xen-netfront.c            |  393 ++++++++++----
 drivers/pci/xen-pcifront.c            |    5 +-
 drivers/scsi/xen-scsiback/common.h    |    3 +-
 drivers/scsi/xen-scsiback/interface.c |    6 +-
 drivers/scsi/xen-scsiback/xenbus.c    |    4 +-
 drivers/scsi/xen-scsifront/xenbus.c   |    5 +-
 drivers/xen/xen-pciback/xenbus.c      |   11 +-
 drivers/xen/xenbus/xenbus_client.c    |  282 +++++++---
 include/xen/xenbus.h                  |   15 +-
 18 files changed, 1646 insertions(+), 858 deletions(-)
