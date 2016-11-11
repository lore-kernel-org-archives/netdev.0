From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH net-next v7 00/10] dpaa_eth: Add the QorIQ DPAA Ethernet driver
Date: Fri, 11 Nov 2016 10:19:57 +0200
Message-ID: <1478852407-27420-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: <madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
        <davem@davemloft.net>, <oss@buserror.net>, <ppc@mindchasers.com>,
        <joe@perches.com>, <pebolle@tiscali.nl>,
        <joakim.tjernlund@infinera.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
kernel:
 - Peripheral Access Memory Unit (PAMU)
    drivers/iommu/fsl_*
 - Frame Manager (FMan) added in v4.4
    drivers/net/ethernet/freescale/fman
 - Queue Manager (QMan), Buffer Manager (BMan) added in v4.9-rc1
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

Changed from v6:
 - fixed an issue on an error path in dpaa_set_mac_address()
 - removed NDO operation definitions that were not needed
 - sorted the local variable declarations
 - cleaned up a few checkpatch checks
 - removed friendly network interface naming code

Changes from v5:
 - adapt to the latest Q/BMan drivers API
 - use build_skb() on Rx path instead of buffer pool refill path
 - proper support for multiple buffer pools
 - align function, variable names, code cleanup
 - driver file structure cleanup

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

The changes are also available in the public git repository at
git://git.freescale.com/ppc/upstream/linux.git on the branch dpaa_eth-next.

Madalin Bucur (10):
  devres: add devm_alloc_percpu()
  dpaa_eth: add support for DPAA Ethernet
  dpaa_eth: add option to use one buffer pool set
  dpaa_eth: add ethtool functionality
  dpaa_eth: add ethtool statistics
  dpaa_eth: add sysfs exports
  dpaa_eth: add trace points
  arch/powerpc: Enable FSL_PAMU
  arch/powerpc: Enable FSL_FMAN
  arch/powerpc: Enable dpaa_eth

 Documentation/driver-model/devres.txt              |    4 +
 arch/powerpc/configs/dpaa.config                   |    3 +
 drivers/base/devres.c                              |   66 +
 drivers/net/ethernet/freescale/Kconfig             |    2 +
 drivers/net/ethernet/freescale/Makefile            |    1 +
 drivers/net/ethernet/freescale/dpaa/Kconfig        |   19 +
 drivers/net/ethernet/freescale/dpaa/Makefile       |   12 +
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c     | 2776 ++++++++++++++++++++
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.h     |  185 ++
 .../net/ethernet/freescale/dpaa/dpaa_eth_sysfs.c   |  165 ++
 .../net/ethernet/freescale/dpaa/dpaa_eth_trace.h   |  141 +
 drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c |  417 +++
 include/linux/device.h                             |   19 +
 13 files changed, 3810 insertions(+)
 create mode 100644 drivers/net/ethernet/freescale/dpaa/Kconfig
 create mode 100644 drivers/net/ethernet/freescale/dpaa/Makefile
 create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
 create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
 create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_eth_sysfs.c
 create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_eth_trace.h
 create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c

-- 
2.1.0
