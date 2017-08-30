From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next 0/3 v10] Add support for rmnet driver
Date: Tue, 29 Aug 2017 18:47:55 -0600
Message-ID: <1504054078-10173-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: netdev@vger.kernel.org, davem@davemloft.net,
        fengguang.wu@intel.com, dcbw@redhat.com, jiri@resnulli.us,
        stephen@networkplumber.org, David.Laight@ACULAB.COM,
        marcel@holtmann.org, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:45574 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751290AbdH3Atg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 20:49:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

I have updated the locking scheme as follows -

The shared resource which needs to be protected is realdev->rx_handler_data.

For the writer path, this is using rtnl_lock(). The writer paths are
rmnet_newlink(), rmnet_dellink() and rmnet_force_unassociate_device(). These
paths are already called with rtnl_lock() acquired in. There is also an
ASSERT_RTNL() to ensure that we are calling with rtnl acquired. For
dereference here, we will need to use rtnl_dereference(). Dev list writing
needs to happen with rtnl_lock() acquired for netdev_master_upper_dev_link().

For the reader path, the real_dev->rx_handler_data is called in the TX / RX
path. We only need rcu_read_lock() for these scenarios. In these cases,
the rcu_read_lock() is held in __dev_queue_xmit() and
netif_receive_skb_internal(), so readers need to use rcu_dereference_rtnl()
to get the relevant information. For dev list reading, we again acquire
rcu_read_lock() in rmnet_dellink() for netdev_master_upper_dev_get_rcu().
We also use unregister_netdevice_many() to free all rmnet devices in
rmnet_force_unassociate_device() so we dont lose the rtnl_lock() and free in
same context.

I have also added this as a comment in rmnet_config.c.

--
v1: Same as the RFC patch with some minor fixes for issues reported by
kbuild test robot.

v1->v2: Change datatypes and remove config IOCTL as mentioned by David.
Also fix checkpatch issues and remove some unused code.

v2->v3: Move location to drivers/net and rename to rmnet. Change the
userspace - netlink communication from custom netlink to rtnl_link_ops.
Refactor some code. Use a fixed config for ingress and egress.

v3->v4: Move location to drivers/net/ethernet/qualcomm/.
Fix comments from Stephen and Jiri -
Split the ether and arp type changes into seperate patches.
Remove debug and custom logging and switch to standard netdevice log.
Remove module parameters. Refactor and change some code style issues.

v4->v5: Rename some structs and variables. Move the initializer
before the for loop start. Put the arp type in correct sequence.

v5->v6: Fix comments from Dan -
Use the upper link API. As a result, remove all the refcounting logic.
Device refcount is explicitly held on real_dev on rx_handler
registration only. Modifiy the flow control struct. Remove the unused
ethernet mode handling.

v6->v7: Fix comments from David - Add newline to end of Makefile. Remove
inline from .c files. Move the module init/exit to rmnet config. Fix an
error reported by kbuild test robot for an unused file.

v7->v8: Use a smaller value for ETH_P_MAP as mentioned by David. Change
netdev_info to netdev_dbg as mentioned by Andew. Fix comments from
Stephen regarding netdev_priv and sparse related errors of using 0 as NULL

v8->v9: Fix comments from David - Remove the CFLAG rule. Change the way
rmnet devices are freed. Instead of using a workqueue to unregister devices
individually, go through the list and free all devices within the rtnl_lock().

v9->v10: Fix the locking scheme as mentioned by David. Change comment near
MAP type definition as mentioned by Dan. Refactor some code.

Subash Abhinov Kasiviswanathan (3):
  net: ether: Add support for multiplexing and aggregation type
  net: arp: Add support for raw IP device
  drivers: net: ethernet: qualcomm: rmnet: Initial implementation

 Documentation/networking/rmnet.txt                 |  82 ++++
 drivers/net/ethernet/qualcomm/Kconfig              |   2 +
 drivers/net/ethernet/qualcomm/Makefile             |   2 +
 drivers/net/ethernet/qualcomm/rmnet/Kconfig        |  12 +
 drivers/net/ethernet/qualcomm/rmnet/Makefile       |  10 +
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c | 419 +++++++++++++++++++++
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h |  56 +++
 .../net/ethernet/qualcomm/rmnet/rmnet_handlers.c   | 271 +++++++++++++
 .../net/ethernet/qualcomm/rmnet/rmnet_handlers.h   |  26 ++
 drivers/net/ethernet/qualcomm/rmnet/rmnet_map.h    |  88 +++++
 .../ethernet/qualcomm/rmnet/rmnet_map_command.c    | 107 ++++++
 .../net/ethernet/qualcomm/rmnet/rmnet_map_data.c   | 105 ++++++
 .../net/ethernet/qualcomm/rmnet/rmnet_private.h    |  45 +++
 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c    | 170 +++++++++
 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h    |  29 ++
 include/uapi/linux/if_arp.h                        |   1 +
 include/uapi/linux/if_ether.h                      |   3 +
 17 files changed, 1428 insertions(+)
 create mode 100644 Documentation/networking/rmnet.txt
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/Kconfig
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/Makefile
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.h
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/rmnet_map.h
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/rmnet_map_command.c
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/rmnet_map_data.c
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/rmnet_private.h
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h

-- 
1.9.1
