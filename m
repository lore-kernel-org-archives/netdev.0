From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH v6 iproute2 0/8] RDMAtool
Date: Sun, 20 Aug 2017 12:58:20 +0300
Message-ID: <20170820095828.13812-1-leon@kernel.org>
Cc: linux-rdma@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Ariel Almog <ariela@mellanox.com>,
        David Laight <David.Laight@ACULAB.COM>,
        Linux Netdev <netdev@vger.kernel.org>
To: Doug Ledford <dledford@redhat.com>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:49070 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751019AbdHTJ6c (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 20 Aug 2017 05:58:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

This is fifth revision of series implementing the RDAMtool -  the tool
to configure RDMA devices.

It looks like everyone who was interested to read cover letter already did it,
so I'll start from the changelog:

Changelog:
v5->v6:
 * Removed double includes
 * Copied rdma_netlink.h from he kernel to include/rdma folder, so the
   tool can be built as a standalone.
v4->v5:
 * Rebased to latest net-next branch
 * Moved BIT() macro from devlink to general utils.h file - Patch #1.
 * Changed the order of patches - moved man pages to be last patch.
 * Rewrote all switch->case->return_string constructions to be static
   tables with help of David's macro magic. Thanks a lot.
 * Dropped dependency on exported device and port properties. Now tool depends
   on RDMA netlink only and all needed code is already in Doug's for-next.
 * Added two OPA specific physical link states, because their names is
   too broad - TEST and OFFLINE, I named it as OPA_TEST and OPA_OFFLINE.
v3->v4:
 * Rebased to latest net-next branch
 * Added JSON output -j (json) and -p (pretty output)
 * Exported and reused kernel UAPIs and defines instead of hard coded
   version.
v2->v3:
 * Removed MAX()
 * Reduced scope of rd_argv_match
 * Removed return from rdma_free_devmap
 * Added extra break at rdma_send_msg
v1->v2:
 * Squashed multiple (and similar) patches to be one patch for dev object
   and one patch for link object.
 * Removed port_map struct
 * Removed global netlink dump during initialization, it removed the need to store
   the intermediate variables and reuse ability of netlink to signal if variable
   exists or doesn't.
 * Added "-d" --details option and put all CAPs under it.

v0->v1:
 * Moved hunk with changes in man/Makefile from first patch to the last patch
 * Removed the "unknown command" from the examples in commit messages
 * Removed special "caps" parsing command and put it to be part of general "show" command
 * Changed parsed capability format to be similar to iproute2 suite
 * Added FW version as an output of show command.
 * Added forgotten CAP_FLAGS to the nla_policy list
RFC->v0:
 * Removed everything that is not implemented yet.
 * Abandoned sysfs interfaces in favor of netlink.

-----
The initial proposal was sent as RFC [1] and was based on sysfs entries as POC.

The current series was rewritten completely to work with RDMA netlinks as
a source of user<->kernel communications. In order to achieve that, the
RDMA netlinks were extensively refactored and modernized [2, 3, 4 and 5].

The Doug's for-next tag includes most of the needed patches for this tool.

The following is an example of various runs on my machine with 5 devices
(4 in IB mode and one in Ethernet mode).

### Without parameters
$ rdma
Usage: rdma [ OPTIONS ] OBJECT { COMMAND | help }
where  OBJECT := { dev | link | help }
       OPTIONS := { -V[ersion] | -d[etails] | -j[son] | -p[retty]}

### With unspecified device name
$ rdma dev
1: mlx5_0: node_type ca fw 2.8.9999 node_guid 5254:00c0:fe12:3457 sys_image_guid 5254:00c0:fe12:3457
2: mlx5_1: node_type ca fw 2.8.9999 node_guid 5254:00c0:fe12:3458 sys_image_guid 5254:00c0:fe12:3458
3: mlx5_2: node_type ca fw 2.8.9999 node_guid 5254:00c0:fe12:3459 sys_image_guid 5254:00c0:fe12:3459
4: mlx5_3: node_type ca fw 2.8.9999 node_guid 5254:00c0:fe12:345a sys_image_guid 5254:00c0:fe12:345a
5: mlx5_4: node_type ca fw 2.8.9999 node_guid 5254:00c0:fe12:345b sys_image_guid 5254:00c0:fe12:345b

### Detailed mode
$ rdma -d dev
1: mlx5_0: node_type ca fw 2.8.9999 node_guid 5254:00c0:fe12:3457 sys_image_guid 5254:00c0:fe12:3457
    caps: <BAD_PKEY_CNTR, BAD_QKEY_CNTR, CHANGE_PHY_POR, PORT_ACTIVE_EVENT, SYS_IMAGE_GUID, RC_RNR_NAK_GEN, MEM_WINDOW, UD_IP_CSUM, UD_TSO, XRC, MEM_MGT_EXTENSIONS, BLOCK_MULTICAST_LOOPBACK, MEM_WINDOW_TYPE_2B, RAW_IP_CSUM, MANAGED_FLOW_STEERING, RESIZE_MAX_WR>
2: mlx5_1: node_type ca fw 2.8.9999 node_guid 5254:00c0:fe12:3458 sys_image_guid 5254:00c0:fe12:3458
    caps: <BAD_PKEY_CNTR, BAD_QKEY_CNTR, CHANGE_PHY_POR, PORT_ACTIVE_EVENT, SYS_IMAGE_GUID, RC_RNR_NAK_GEN, MEM_WINDOW, UD_IP_CSUM, UD_TSO, XRC, MEM_MGT_EXTENSIONS, BLOCK_MULTICAST_LOOPBACK, MEM_WINDOW_TYPE_2B, RAW_IP_CSUM, MANAGED_FLOW_STEERING, RESIZE_MAX_WR>
3: mlx5_2: node_type ca fw 2.8.9999 node_guid 5254:00c0:fe12:3459 sys_image_guid 5254:00c0:fe12:3459
    caps: <BAD_PKEY_CNTR, BAD_QKEY_CNTR, CHANGE_PHY_POR, PORT_ACTIVE_EVENT, SYS_IMAGE_GUID, RC_RNR_NAK_GEN, MEM_WINDOW, UD_IP_CSUM, UD_TSO, XRC, MEM_MGT_EXTENSIONS, BLOCK_MULTICAST_LOOPBACK, MEM_WINDOW_TYPE_2B, RAW_IP_CSUM, MANAGED_FLOW_STEERING, RESIZE_MAX_WR>
4: mlx5_3: node_type ca fw 2.8.9999 node_guid 5254:00c0:fe12:345a sys_image_guid 5254:00c0:fe12:345a
    caps: <BAD_PKEY_CNTR, BAD_QKEY_CNTR, CHANGE_PHY_POR, PORT_ACTIVE_EVENT, SYS_IMAGE_GUID, RC_RNR_NAK_GEN, MEM_WINDOW, UD_IP_CSUM, UD_TSO, XRC, MEM_MGT_EXTENSIONS, BLOCK_MULTICAST_LOOPBACK, MEM_WINDOW_TYPE_2B, RAW_IP_CSUM, MANAGED_FLOW_STEERING, RESIZE_MAX_WR>
5: mlx5_4: node_type ca fw 2.8.9999 node_guid 5254:00c0:fe12:345b sys_image_guid 5254:00c0:fe12:345b
    caps: <BAD_PKEY_CNTR, BAD_QKEY_CNTR, CHANGE_PHY_POR, PORT_ACTIVE_EVENT, SYS_IMAGE_GUID, RC_RNR_NAK_GEN, MEM_WINDOW, UD_IP_CSUM, UD_TSO, XRC, MEM_MGT_EXTENSIONS, BLOCK_MULTICAST_LOOPBACK, MEM_WINDOW_TYPE_2B, RAW_IP_CSUM, MANAGED_FLOW_STEERING, RESIZE_MAX_WR>

### Specific device
$ rdma dev show mlx5_4
5: mlx5_4: node_type ca fw 2.8.9999 node_guid 5254:00c0:fe12:345b sys_image_guid 5254:00c0:fe12:345b

### Specific device in detailed mode
$ rdma dev show mlx5_4 -d
5: mlx5_4: node_type ca fw 2.8.9999 node_guid 5254:00c0:fe12:345b sys_image_guid 5254:00c0:fe12:345b
    caps: <BAD_PKEY_CNTR, BAD_QKEY_CNTR, CHANGE_PHY_POR, PORT_ACTIVE_EVENT, SYS_IMAGE_GUID, RC_RNR_NAK_GEN, MEM_WINDOW, UD_IP_CSUM, UD_TSO, XRC, MEM_MGT_EXTENSIONS, BLOCK_MULTICAST_LOOPBACK, MEM_WINDOW_TYPE_2B, RAW_IP_CSUM, MANAGED_FLOW_STEERING, RESIZE_MAX_WR>

### Unknown command (caps)
$ rdma dev show mlx5_4 caps
Unknown parameter 'caps'.

### Link properties without device name
$ rdma link
1/1: mlx5_0/1: subnet_prefix fe80:0000:0000:0000 lid 13399 sm_lid 49151 lmc 0 state ACTIVE physical_state LINK_UP
2/1: mlx5_1/1: subnet_prefix fe80:0000:0000:0000 lid 13400 sm_lid 49151 lmc 0 state ACTIVE physical_state LINK_UP
3/1: mlx5_2/1: subnet_prefix fe80:0000:0000:0000 lid 13401 sm_lid 49151 lmc 0 state ACTIVE physical_state LINK_UP
4/1: mlx5_3/1: state DOWN physical_state DISABLED
5/1: mlx5_4/1: subnet_prefix fe80:0000:0000:0000 lid 13403 sm_lid 49151 lmc 0 state ACTIVE physical_state LINK_UP

### Link properties in detailed mode
$ rdma link -d
1/1: mlx5_0/1: subnet_prefix fe80:0000:0000:0000 lid 13399 sm_lid 49151 lmc 0 state ACTIVE physical_state LINK_UP
    caps: <AUTO_MIGR>
2/1: mlx5_1/1: subnet_prefix fe80:0000:0000:0000 lid 13400 sm_lid 49151 lmc 0 state ACTIVE physical_state LINK_UP
    caps: <AUTO_MIGR>
3/1: mlx5_2/1: subnet_prefix fe80:0000:0000:0000 lid 13401 sm_lid 49151 lmc 0 state ACTIVE physical_state LINK_UP
    caps: <AUTO_MIGR>
4/1: mlx5_3/1: state DOWN physical_state DISABLED
    caps: <CM, IP_BASED_GIDS>
5/1: mlx5_4/1: subnet_prefix fe80:0000:0000:0000 lid 13403 sm_lid 49151 lmc 0 state ACTIVE physical_state LINK_UP
    caps: <AUTO_MIGR>

### All links for specific device
$ rdma link show mlx5_3
1/1: mlx5_0/1: subnet_prefix fe80:0000:0000:0000 lid 13399 sm_lid 49151 lmc 0 state ACTIVE physical_state LINK_UP

### Detailed link properties for specific device
$ rdma link -d show mlx5_3
1/1: mlx5_0/1: subnet_prefix fe80:0000:0000:0000 lid 13399 sm_lid 49151 lmc 0 state ACTIVE physical_state LINK_UP
    caps: <AUTO_MIGR>

### Specific port for specific device
$ rdma link show mlx5_4/1
1/1: mlx5_0/1: subnet_prefix fe80:0000:0000:0000 lid 13399 sm_lid 49151 lmc 0 state ACTIVE physical_state LINK_UP

### Unknown parameter
$ rdma link show mlx5_4/1 caps
Unknown parameter 'caps'.

Available in the "topic/rdmatool-netlink-v6" topic branch of this git repo:
git://git.kernel.org/pub/scm/linux/kernel/git/leon/iproute2.git

Or for browsing:
https://git.kernel.org/cgit/linux/kernel/git/leon/iproute2.git/log/?h=topic/rdmatool-netlink-v6

Thanks

[1] https://www.spinics.net/lists/linux-rdma/msg49575.html
[2] https://patchwork.kernel.org/patch/9752865/
[3] https://www.spinics.net/lists/linux-rdma/msg50827.html
[4] https://www.spinics.net/lists/linux-rdma/msg51210.html
[5] https://patchwork.kernel.org/patch/9811729/ and https://patchwork.kernel.org/patch/9811731/]

Cc: Doug Ledford <dledford@redhat.com>
Cc: Dennis Dalessandro <dennis.dalessandro@intel.com>
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Jiri Pirko <jiri@mellanox.com>
Cc: Ariel Almog <ariela@mellanox.com>
Cc: David Laight <David.Laight@ACULAB.COM>
Cc: Linux Netdev <netdev@vger.kernel.org>

Leon Romanovsky (8):
  utils: Move BIT macro to common header
  rdma: Add basic infrastructure for RDMA tool
  rdma: Add dev object
  rdma: Add link object
  rdma: Add json and pretty outputs
  rdma: Implement json output for dev object
  rdma: Add json output to link object
  rdma: Add initial manual for the tool

 Makefile                    |   2 +-
 devlink/devlink.c           |   2 +-
 include/rdma/rdma_netlink.h | 307 +++++++++++++++++++++++++++++++++++++++
 include/utils.h             |   2 +
 man/man8/rdma-dev.8         |  55 +++++++
 man/man8/rdma-link.8        |  55 +++++++
 man/man8/rdma.8             | 102 +++++++++++++
 rdma/.gitignore             |   1 +
 rdma/Makefile               |  22 +++
 rdma/dev.c                  | 284 ++++++++++++++++++++++++++++++++++++
 rdma/link.c                 | 343 ++++++++++++++++++++++++++++++++++++++++++++
 rdma/rdma.c                 | 143 ++++++++++++++++++
 rdma/rdma.h                 |  91 ++++++++++++
 rdma/utils.c                | 266 ++++++++++++++++++++++++++++++++++
 14 files changed, 1673 insertions(+), 2 deletions(-)
 create mode 100644 include/rdma/rdma_netlink.h
 create mode 100644 man/man8/rdma-dev.8
 create mode 100644 man/man8/rdma-link.8
 create mode 100644 man/man8/rdma.8
 create mode 100644 rdma/.gitignore
 create mode 100644 rdma/Makefile
 create mode 100644 rdma/dev.c
 create mode 100644 rdma/link.c
 create mode 100644 rdma/rdma.c
 create mode 100644 rdma/rdma.h
 create mode 100644 rdma/utils.c
