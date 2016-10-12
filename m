From: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Subject: [PATCH net-next 00/11] net: Fix netdev adjacency tracking
Date: Wed, 12 Oct 2016 13:51:48 -0700
Message-ID: <1476305519-28833-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        j.vosburgh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, vfalico-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
        jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, intel-wired-lan-qjLDD68F18P21nG7glBr7A@public.gmane.org,
        David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
To: jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The netdev adjacency tracking is failing to create proper dependencies
for some topologies. For example this topology

        +--------+
        |  myvrf |
        +--------+
          |    |
          |  +---------+
          |  | macvlan |
          |  +---------+
          |    |
      +----------+
      |  bridge  |
      +----------+
          |
      +--------+
      | bond0  |
      +--------+
          |
      +--------+
      |  eth3  |
      +--------+

hits 1 of 2 problems depending on the order of enslavement. The base set of
commands for both cases:

    ip link add bond1 type bond
    ip link set bond1 up
    ip link set eth3 down
    ip link set eth3 master bond1
    ip link set eth3 up

    ip link add bridge type bridge
    ip link set bridge up
    ip link add macvlan link bridge type macvlan
    ip link set macvlan up

    ip link add myvrf type vrf table 1234
    ip link set myvrf up

    ip link set bridge master myvrf

Case 1 enslave macvlan to the vrf before enslaving the bond to the bridge:

    ip link set macvlan master myvrf
    ip link set bond1 master bridge

Attempts to delete the VRF:
    ip link delete myvrf

trigger the BUG in __netdev_adjacent_dev_remove:

[  587.405260] tried to remove device eth3 from myvrf
[  587.407269] ------------[ cut here ]------------
[  587.408918] kernel BUG at /home/dsa/kernel.git/net/core/dev.c:5661!
[  587.411113] invalid opcode: 0000 [#1] SMP
[  587.412454] Modules linked in: macvlan bridge stp llc bonding vrf
[  587.414765] CPU: 0 PID: 726 Comm: ip Not tainted 4.8.0+ #109
[  587.416766] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[  587.420241] task: ffff88013ab6eec0 task.stack: ffffc90000628000
[  587.422163] RIP: 0010:[<ffffffff813cef03>]  [<ffffffff813cef03>] __netdev_adjacent_dev_remove+0x40/0x12c
...
[  587.446053] Call Trace:
[  587.446424]  [<ffffffff813d1542>] __netdev_adjacent_dev_unlink+0x20/0x3c
[  587.447390]  [<ffffffff813d16a3>] netdev_upper_dev_unlink+0xfa/0x15e
[  587.448297]  [<ffffffffa00003a3>] vrf_del_slave+0x13/0x2a [vrf]
[  587.449153]  [<ffffffffa00004a4>] vrf_dev_uninit+0xea/0x114 [vrf]
[  587.450036]  [<ffffffff813d19b0>] rollback_registered_many+0x22b/0x2da
[  587.450974]  [<ffffffff813d1aac>] unregister_netdevice_many+0x17/0x48
[  587.451903]  [<ffffffff813de444>] rtnl_delete_link+0x3c/0x43
[  587.452719]  [<ffffffff813dedcd>] rtnl_dellink+0x180/0x194

When the BUG is converted to a WARN_ON it shows 4 missing adjacencies:
  eth3 - myvrf, mvrf - eth3, bond1 - myvrf and myvrf - bond1

All of those are because the __netdev_upper_dev_link function does not
properly link macvlan lower devices to myvrf when it is enslaved.

The second case just flips the ordering of the enslavements:
    ip link set bond1 master bridge
    ip link set macvlan master myvrf

Then run:
    ip link delete bond1
    ip link delete myvrf

The vrf delete command hangs because myvrf has a reference that has not
been released. In this case the removal code does not account for 2 paths 
between eth3 and myvrf - one from bridge to vrf and the other through the
macvlan.

Rather than try to maintain a linked list of all upper and lower devices
per netdevice, only track the direct neighbors. The remaining stack can
be determined by recursively walking the neighbors.

The existing netdev_for_each_all_upper_dev_rcu,
netdev_for_each_all_lower_dev and netdev_for_each_all_lower_dev_rcu macros
are replaced with APIs that walk the upper and lower device lists. The
new APIs take a callback function and a data arg that is passed to the
callback for each device in the list. Drivers using the old macros are
converted in separate patches to make it easier on reviewers. It is an
API conversion only; no functional change is intended.

DaveM: Given the impact of this bug (both cases requiring a reboot) I
would like to get this backported to at least the 4.8 tree which as I 
understand it has been targeted as the next LTS.

David Ahern (11):
  net: Remove refnr arg when inserting link adjacencies
  net: Introduce new api for walking upper and lower devices
  net: bonding: Flip to the new dev walk API
  IB/core: Flip to the new dev walk API
  IB/ipoib: Flip to new dev walk API
  ixgbe: Flip to the new dev walk API
  mlxsw: Flip to the new dev walk API
  rocker: Flip to the new dev walk API
  net: Remove all_adj_list and its references
  net: Add warning if any lower device is still in adjacency list
  net: dev: Improve debug statements for adjacency tracking

 drivers/infiniband/core/core_priv.h            |   9 +-
 drivers/infiniband/core/roce_gid_mgmt.c        |  42 +--
 drivers/infiniband/ulp/ipoib/ipoib_main.c      |  37 ++-
 drivers/net/bonding/bond_alb.c                 |  82 +++---
 drivers/net/bonding/bond_main.c                |  21 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 132 ++++++----
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c |  37 ++-
 drivers/net/ethernet/rocker/rocker_main.c      |  31 ++-
 include/linux/netdevice.h                      |  38 ++-
 net/core/dev.c                                 | 349 ++++++++++++-------------
 10 files changed, 428 insertions(+), 350 deletions(-)

-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
