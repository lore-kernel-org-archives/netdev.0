From: Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for-next V6 00/10] Move RoCE GID management to IB/Core
Date: Wed, 24 Jun 2015 15:59:16 +0300
Message-ID: <1435150766-6803-1-git-send-email-matanb@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Moni Shoua <monis-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This series has been running in linux-rdma for a while. We added here
CC to netdev for the three pre-patches which come first. They allow
the IB core to access some helpers (e.g generating default Eth IPv6 
link local address), gain more info on bonding changes, etc.

Previously, every vendor implemented its net device notifiers in its own
driver. This introduces a huge code duplication as figuring
whether an event is related to the vendor's net device in the
various cases (bonding, vlan or any other upper device) is
similar for all vendors. In the future, when multiple GID types will
be supported, this code duplication would have gotten even worse.

Therefore, we decided moving this into a common core core.
roce_gid_table and roce_gid_mgmt were created in order to store and
manage the new GID table, by filling it when getting the related events.
Vendors now only have to implement modify_gid and get_netdev IB
device calls, which are truly unique for each vendor.
roce_gid_table is implemented as IB client that manages the GID
table of the IB device. Each GID is associated with a GID type and a
network device (which is mandatory for management of the GID table).
The GID table is populated by using roce_gid_mgmt. roce_gid_mgmt
registers to net device/inet/inet events and calls roce_gid_table
in order to populate the GID table accordingly.

Patch 0005 is the core patch in this series. It creates a new infrastructure
for storing GIDs and their attributes in IB/core. This infrastructure support
reading and writing GIDs alongside with their meta-data. The new infrastructure
is used for both manageing RoCE ports and IB ports. The core difference is that
in IB ports, this infrastructure is used souly as a cache, while in RoCE we
actually manage the vendor's GID table by calling add_gid and del_gid callbacks.
In RoCE, we always enable default gids for an active device (an active device
is defined here as a device that doesn't have a bonding master or is the current
active slave). This is done in order to allow loopback traffic.

Patch 0004 replaces the locking schema for IB devices. Previously, device_mutex
was used in order to lock the devices/clients list against every modification.
However, downstream patches add new functions which iterate over the device
list. Those functions could be executed for a workqueue contexts on behalf
of IB clients. Thus, when a client is removed, we need to wait for all works
to be finished. Since a client removal was done in device_mutex lock, we'll
be in fact waiting for a work which requires to lock the device_mutex itself
(=DEADLOCK). In order to mitigate this problem, we use rw semaphore to allow
multiple readers. We use a mutex in order to solve races between adding
(or removing) a client and a device simultaneously, which could have resulted
in calling client->add (or client->remove) twice for the same device and client.
This patch was sent as part of "Add network namespace support in the RDMA-CM"
series.

Patch 0006 adds population of this table for the bonding case based on net
device events. Only the active slaves retain their master's IP based gids and
default gids.

Patch 0001 exports addrconf_ifid_eui48 in order to generate the default GID.
Patch 0002 adds information for NETDEV_CHANGEUPPER which is used in order to
understand the nature of change - link/unlink and which master net-device is
related to this change.
Patch 0003 exports bond_option_active_slave_get_rcu which is necassary in
order to assign the GIDs only to the active slave.

The rest of the patches add support for ocrdma and mlx4 devices.

This series is rebased over Doug's k.o/for-4.2 branch.

Thanks,
Devesh, Somnath, Moni and Matan

Changes from V5:
(1) Incoporate the changes to cache.c so we use the same infrastructure 
    to manage both IB and RoCE (per Doug's request)
(2) Replace the locking mechanism in the IB core GID cache from seqcount + 
    rcu to rwlock (addressing comments from Jason)
(3) get_netdev returns a helded (dev_hold) device
(4) Squashed the RocE GID table, RoCE GID management and default GID handling
    code into one patch (per Doug's request).
(5) Change modify_gid to add_gid and del_gid.
(6) set the netdev related changes into three dedicated patches and make
    them be 1st in the series.

Changes from V4:
(1) Remove any API changes.
(2) Fixed a bug regarding bonding upper devices.
(3) Rebased ontop of Doug's k.o/for-4.2.

Changes from V3:
(1) Remove RoCE V2 functionality (it will be sent at later patchset).
(2) Instead of removing qp_attr_mask flags, reserve them.
(3) Remove the kref from IB devices in favor of rwsem.
(4) Change the name of roce_gid_cache to roce_gid_table.
(5) Fix a race when roce_gid_table is free'd while getting events.
(6) Remove the roce_gid_cache active/inactive flag/API.

Changes from V2:
(1) When creating multiple vlans over an interface,
    only the last created vlan's GID was populated in the table
    (regression from V2).
(2) Inactive slave of bonding sometimes lost GIDs related to IPs
    that were directly applied to it.
(3) Memory leak in mlx4
(4) roce_gid_cache now calls modify_gid with zgid in order to cause
    the provider to delete all the information it allocated for those
    GIDs.
(4) A mlx4 patch didn't compile and a downstream patch fixed it.
(5) cma_configfs should depend on both address translation and configfs.
(6) ocrdma driver redefined zgid.
(7) Added event information for NETDEV_CHANGEUPPER event.

Changes from V1:
(1) Addressed Shachar and Haggai's comments
(2) Fixed multicast support
(3) Generalized bonding support
(4) Added default GID after the IB device's net device was removed from bonding
(5) Fixed bugs in mlx4 implementation regarding multicast
(6) Fixed bugs in mlx4 when using XRC QPs after this patchset was applied
(7) Fixed bug when the RoCE gid cache didn't exist
(8) Moved the bonding's DRV macros to a private header
(9) Support non-configfs configurations

Haggai Eran (1):
  IB/core: Add rwsem to allow reading device list or client list

Matan Barak (5):
  net/ipv6: Export addrconf_ifid_eui48
  net: Add info for NETDEV_CHANGEUPPER event
  net/bonding: Export bond_option_active_slave_get_rcu
  IB/core: Add RoCE GID table management
  IB/core: Add RoCE table bonding support

Moni Shoua (3):
  net/mlx4: Postpone the registration of net_device
  IB/mlx4: Implement ib_device callbacks
  IB/mlx4: Replace mechanism for RoCE GID management

Somnath Kotur (1):
  RDMA/ocrdma: Incorporate the moving of GID Table mgmt to IB/Core

 drivers/infiniband/core/Makefile             |   3 +-
 drivers/infiniband/core/cache.c              | 752 ++++++++++++++++++++++++---
 drivers/infiniband/core/core_priv.h          |  45 ++
 drivers/infiniband/core/device.c             | 117 ++++-
 drivers/infiniband/core/roce_gid_mgmt.c      | 730 ++++++++++++++++++++++++++
 drivers/infiniband/hw/mlx4/ah.c              |   2 +-
 drivers/infiniband/hw/mlx4/main.c            | 749 ++++++++++----------------
 drivers/infiniband/hw/mlx4/mlx4_ib.h         |  21 +-
 drivers/infiniband/hw/mlx4/qp.c              |  10 +-
 drivers/infiniband/hw/ocrdma/ocrdma.h        |   1 -
 drivers/infiniband/hw/ocrdma/ocrdma_main.c   | 234 +--------
 drivers/infiniband/hw/ocrdma/ocrdma_sli.h    |   2 +
 drivers/infiniband/hw/ocrdma/ocrdma_verbs.c  |  45 +-
 drivers/infiniband/hw/ocrdma/ocrdma_verbs.h  |  11 +
 drivers/net/bonding/bond_options.c           |  13 -
 drivers/net/ethernet/mellanox/mlx4/en_main.c |  36 +-
 drivers/net/ethernet/mellanox/mlx4/intf.c    |   3 +
 include/linux/mlx4/device.h                  |   3 +-
 include/linux/mlx4/driver.h                  |   1 +
 include/linux/netdevice.h                    |  14 +
 include/net/addrconf.h                       |  31 ++
 include/net/bonding.h                        |   7 +
 include/rdma/ib_verbs.h                      |  68 ++-
 net/core/dev.c                               |  12 +-
 net/ipv6/addrconf.c                          |  31 --
 25 files changed, 2064 insertions(+), 877 deletions(-)
 create mode 100644 drivers/infiniband/core/roce_gid_mgmt.c

-- 
2.1.0

Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
