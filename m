From: Unknown <unknown@unknown.invalid>
Subject: [net-next v5 0/8] dpaa_eth: Add the Freescale DPAA Ethernet driver
Date: Thu, 3 Dec 2015 14:08:58 +0200
Message-ID: <1449144546-25438-1-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
	<davem@davemloft.net>, <scottwood@freescale.com>,
	<igal.liberman@freescale.com>, <ppc@mindchasers.com>,
	<joe@perches.com>, <pebolle@tiscali.nl>,
	<joakim.tjernlund@transmode.se>, <gregkh@linuxfoundation.org>,
	Madalin Bucur <madalin.bucur@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0096.outbound.protection.outlook.com ([157.56.110.96]:7536
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759909AbbLCLL0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 06:11:26 -0500
From: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Madalin Bucur <madalin.bucur@freescale.com>

This patch series adds the Ethernet driver for the Freescale
QorIQ Data Path Acceleration Architecture (DPAA).

This version includes changes following the feedback received
on previous versions from Eric Dumazet, Bob Cochran, Joe Perches,
Paul Bolle, Joakim Tjernlund, Scott Wood, David Miller - thank you.

Together with the driver a managed version of alloc_percpu
is provided that simplifies the release of per-CPU memory.

The Freescale DPAA architecture consists in a series of hardware
blocks that support the Ethernet connectivity. The Ethernet driver
depends upon the following drivers that are currently in the Linux
kernel or in review (the underlying drivers are not inter-dependent):
 - Peripheral Access Memory Unit (PAMU)
    drivers/iommu/fsl_*
 - Frame Manager (FMan)
    drivers/net/ethernet/freescale/fman
 - Queue Manager (QMan), Buffer Manager (BMan)
    drivers/soc/fsl/qbman

dpaa_eth interfaces mapping to FMan MACs:

  dpaa_eth       /eth0\     ...       /ethN\
  driver        |      |             |      |
  -------------   ----   -----------   ----   -------------
       -Ports  / Tx  Rx \    ...    / Tx  Rx \
  FMan        |          |         |          |
       -MACs  |   MAC0   |         |   MACN   |
             /   dtsec0   \  ...  /   dtsecN   \ (or tgec)
            /              \     /              \(or memac)
  ---------  --------------  ---  --------------  ---------
      FMan, FMan Port, FMan SP, FMan MURAM drivers
  ---------------------------------------------------------
      FMan HW blocks: MURAM, MACs, Ports, SP
  ---------------------------------------------------------

dpaa_eth relation to QMan, FMan:
              ________________________________
  dpaa_eth   /            eth0                \
  driver    /                                  \
  ---------   -^-   -^-   -^-   ---    ---------
  QMan driver / \   / \   / \  \   /  | BMan    |
             |Rx | |Rx | |Tx | |Tx |  | driver  |
  ---------  |Dfl| |Err| |Cnf| |FQs|  |         |
  QMan HW    |FQ | |FQ | |FQ | |   |  |         |
             /   \ /   \ /   \  \ /   |         |
  ---------   ---   ---   ---   -v-    ---------
            |        FMan QMI         |         |
            | FMan HW       FMan BMI  | BMan HW |
              -----------------------   --------

where the acronyms used above (and in the code) are:
DPAA = Data Path Acceleration Architecture
FMan = DPAA Frame Manager
QMan = DPAA Queue Manager
BMan = DPAA Buffers Manager
QMI = QMan interface in FMan
BMI = BMan interface in FMan
FMan SP = FMan Storage Profiles
MURAM = Multi-user RAM in FMan
FQ = QMan Frame Queue
Rx Dfl FQ = default reception FQ
Rx Err FQ = Rx error frames FQ
Tx Cnf FQ = Tx confirmation FQ
Tx FQs = transmission frame queues
dtsec = datapath three speed Ethernet controller (10/100/1000 Mbps)
tgec = ten gigabit Ethernet controller (10 Gbps)
memac = multirate Ethernet MAC (10/100/1000/10000)

The latest FMan driver patches were submitted by Igal Liberman:
https://patchwork.ozlabs.org/project/netdev/list/?submitter=64715&state=*

The latest Q/BMan drivers were submitted by Roy Pledge:
https://patchwork.ozlabs.org/project/linuxppc-dev/list/?submitter=66331&state=*

Changes from v4:
 - addressed feedback from Scott Wood and Joe Perches
 - fixed spelling
 - fixed leak of uninitialized stack to userspace
 - fix prints
 - replace raw_cpu_ptr() with this_cpu_ptr()
 - remove _s from the end of structure names
 - remove underscores at start of functions, goto labels
 - remove likely in error paths
 - use container_of() instead of open casts
 - remove priv from the driver name
 - move return type on same line with function name
 - drop DPA_READ_SKB_PTR/DPA_WRITE_SKB_PTR

Changes from v3:
 - removed bogus delay and comment in .ndo_stop implementation
 - addressed minor issues reported by David Miller

Changes from v2:
 - removed debugfs, moved exports to ethtool statistics
 - removed congestion groups Kconfig params

Changes from v1:
 - bpool level Kconfig options removed
 - print format using pr_fmt, cleaned up prints
 - __hot/__cold removed
 - gratuitous unlikely() removed
 - code style aligned, consistent spacing for declarations
 - comment formatting

The complete patch set based on the latest net-next/master kernel
can be found in the public git at:
http://git.freescale.com/git/cgit.cgi/ppc/upstream/linux.git
under the tag ldup_public_git_20151202:
http://git.freescale.com/git/cgit.cgi/ppc/upstream/linux.git/tag/?h=ldup_public_git_20151202

There is one u-boot patch that one needs to make sure it's applied
to align u-boot to the latest device tree binding document specification
used by the FMan driver. Please make sure your u-boot includes this patch:

        commit 97a8d010e029111e5711a45264a726bedbeb24c4
        Author: Igal Liberman <igal.liberman@freescale.com>
        Date:   Tue Aug 18 14:47:05 2015 +0300

            net/fman: Support both new and legacy FMan Compatibles

The patch was included in u-boot in v2015.10-rc3.

Madalin Bucur (8):
  devres: add devm_alloc_percpu()
  dpaa_eth: add support for DPAA Ethernet
  dpaa_eth: add support for S/G frames
  dpaa_eth: add driver's Tx queue selection mechanism
  dpaa_eth: add ethtool functionality
  dpaa_eth: add ethtool statistics
  dpaa_eth: add sysfs exports
  dpaa_eth: add trace points

 Documentation/driver-model/devres.txt              |    4 +
 drivers/base/devres.c                              |   64 +
 drivers/net/ethernet/freescale/Kconfig             |    2 +
 drivers/net/ethernet/freescale/Makefile            |    1 +
 drivers/net/ethernet/freescale/dpaa/Kconfig        |   32 +
 drivers/net/ethernet/freescale/dpaa/Makefile       |   12 +
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c     |  788 +++++++++++
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.h     |  464 +++++++
 .../net/ethernet/freescale/dpaa/dpaa_eth_common.c  | 1416 ++++++++++++++++++++
 .../net/ethernet/freescale/dpaa/dpaa_eth_common.h  |  108 ++
 drivers/net/ethernet/freescale/dpaa/dpaa_eth_sg.c  |  686 ++++++++++
 .../net/ethernet/freescale/dpaa/dpaa_eth_sysfs.c   |  167 +++
 .../net/ethernet/freescale/dpaa/dpaa_eth_trace.h   |  141 ++
 drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c |  414 ++++++
 include/linux/device.h                             |   19 +
 15 files changed, 4318 insertions(+)
 create mode 100644 drivers/net/ethernet/freescale/dpaa/Kconfig
 create mode 100644 drivers/net/ethernet/freescale/dpaa/Makefile
 create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
 create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
 create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c
 create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.h
 create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_eth_sg.c
 create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_eth_sysfs.c
 create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_eth_trace.h
 create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c

-- 
1.7.11.7
