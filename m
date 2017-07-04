From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH iproute2 V3 0/4] RDMAtool
Date: Tue,  4 Jul 2017 10:55:37 +0300
Message-ID: <20170704075541.12544-1-leon@kernel.org>
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

This is third version of series implementing the RDAMtool -  the tool
to configure RDMA devices. The initial proposal was sent as RFC [1] and
was based on sysfs entries as POC.

The current series was rewritten completely to work with RDMA netlinks as
a source of user<->kernel communications. In order to achieve that, the
RDMA netlinks were extensively refactored and modernized [2, 3, 4 and 5].

The following is an example of various runs on my machine with 5 devices
(4 in IB mode and one in Ethernet mode)

### Without parameters
$ rdma
Usage: rdma [ OPTIONS ] OBJECT { COMMAND | help }
where  OBJECT := { dev | link | help }
       OPTIONS := { -V[ersion] | -d[etails]}

### With unspecified device name
$ rdma dev
1: mlx5_0: node_type SWITCH fw 2.8.9999 node_guid 5254:00c0:fe12:3457 sys_image_guid 5254:00c0:fe12:3457
2: mlx5_1: node_type SWITCH fw 2.8.9999 node_guid 5254:00c0:fe12:3458 sys_image_guid 5254:00c0:fe12:3458
3: mlx5_2: node_type SWITCH fw 2.8.9999 node_guid 5254:00c0:fe12:3459 sys_image_guid 5254:00c0:fe12:3459
4: mlx5_3: node_type SWITCH fw 2.8.9999 node_guid 5254:00c0:fe12:345a sys_image_guid 5254:00c0:fe12:345a
5: mlx5_4: node_type SWITCH fw 2.8.9999 node_guid 5254:00c0:fe12:345b sys_image_guid 5254:00c0:fe12:345b

### Detailed mode
$ rdma -d dev
1: mlx5_0: node_type SWITCH fw 2.8.9999 node_guid 5254:00c0:fe12:3457 sys_image_guid 5254:00c0:fe12:3457
    caps: <BAD_PKEY_CNTR, BAD_QKEY_CNTR, CHANGE_PHY_PORT, PORT_ACTIVE_EVENT, SYS_IMAGE_GUID, RC_RNR_NAK_GEN, MEM_WINDOW, UD_IP_CSUM, UD_TSO, XRC, MEM_MGT_EXTENSIONS, BLOCK_MULTICAST_LOOPBACK, MEM_WINDOW_TYPE_2B, RAW_IP_CSUM, SIGNATURE_HANDOVER, VIRTUAL_FUNCTION>
2: mlx5_1: node_type SWITCH fw 2.8.9999 node_guid 5254:00c0:fe12:3458 sys_image_guid 5254:00c0:fe12:3458
    caps: <BAD_PKEY_CNTR, BAD_QKEY_CNTR, CHANGE_PHY_PORT, PORT_ACTIVE_EVENT, SYS_IMAGE_GUID, RC_RNR_NAK_GEN, MEM_WINDOW, UD_IP_CSUM, UD_TSO, XRC, MEM_MGT_EXTENSIONS, BLOCK_MULTICAST_LOOPBACK, MEM_WINDOW_TYPE_2B, RAW_IP_CSUM, SIGNATURE_HANDOVER, VIRTUAL_FUNCTION>
3: mlx5_2: node_type SWITCH fw 2.8.9999 node_guid 5254:00c0:fe12:3459 sys_image_guid 5254:00c0:fe12:3459
    caps: <BAD_PKEY_CNTR, BAD_QKEY_CNTR, CHANGE_PHY_PORT, PORT_ACTIVE_EVENT, SYS_IMAGE_GUID, RC_RNR_NAK_GEN, MEM_WINDOW, UD_IP_CSUM, UD_TSO, XRC, MEM_MGT_EXTENSIONS, BLOCK_MULTICAST_LOOPBACK, MEM_WINDOW_TYPE_2B, RAW_IP_CSUM, SIGNATURE_HANDOVER, VIRTUAL_FUNCTION>
4: mlx5_3: node_type SWITCH fw 2.8.9999 node_guid 5254:00c0:fe12:345a sys_image_guid 5254:00c0:fe12:345a
    caps: <BAD_PKEY_CNTR, BAD_QKEY_CNTR, CHANGE_PHY_PORT, PORT_ACTIVE_EVENT, SYS_IMAGE_GUID, RC_RNR_NAK_GEN, MEM_WINDOW, UD_IP_CSUM, UD_TSO, XRC, MEM_MGT_EXTENSIONS, BLOCK_MULTICAST_LOOPBACK, MEM_WINDOW_TYPE_2B, RAW_IP_CSUM, SIGNATURE_HANDOVER, VIRTUAL_FUNCTION>
5: mlx5_4: node_type SWITCH fw 2.8.9999 node_guid 5254:00c0:fe12:345b sys_image_guid 5254:00c0:fe12:345b
    caps: <BAD_PKEY_CNTR, BAD_QKEY_CNTR, CHANGE_PHY_PORT, PORT_ACTIVE_EVENT, SYS_IMAGE_GUID, RC_RNR_NAK_GEN, MEM_WINDOW, UD_IP_CSUM, UD_TSO, XRC, MEM_MGT_EXTENSIONS, BLOCK_MULTICAST_LOOPBACK, MEM_WINDOW_TYPE_2B, RAW_IP_CSUM, SIGNATURE_HANDOVER, VIRTUAL_FUNCTION>

### Specific device
$ rdma dev show mlx5_4
5: mlx5_4: node_type SWITCH fw 2.8.9999 node_guid 5254:00c0:fe12:345b sys_image_guid 5254:00c0:fe12:345b

### Specific device in detailed mode
$ rdma dev show mlx5_4 -d
5: mlx5_4: node_type SWITCH fw 2.8.9999 node_guid 5254:00c0:fe12:345b sys_image_guid 5254:00c0:fe12:345b
    caps: <BAD_PKEY_CNTR, BAD_QKEY_CNTR, CHANGE_PHY_PORT, PORT_ACTIVE_EVENT, SYS_IMAGE_GUID, RC_RNR_NAK_GEN, MEM_WINDOW, UD_IP_CSUM, UD_TSO, XRC, MEM_MGT_EXTENSIONS, BLOCK_MULTICAST_LOOPBACK, MEM_WINDOW_TYPE_2B, RAW_IP_CSUM, SIGNATURE_HANDOVER, VIRTUAL_FUNCTION>

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

Thanks

Changelog:
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

Available in the "topic/rdmatool-netlink-v2" topic branch of this git repo:
git://git.kernel.org/pub/scm/linux/kernel/git/leon/iproute2.git

Or for browsing:
https://git.kernel.org/cgit/linux/kernel/git/leon/iproute2.git/log/?h=topic/rdmatool-netlink-v2

Thanks

[1] https://www.spinics.net/lists/linux-rdma/msg49575.html
[2] https://patchwork.kernel.org/patch/9752865/
[3] https://www.spinics.net/lists/linux-rdma/msg50827.html
[4] https://www.spinics.net/lists/linux-rdma/msg51210.html
[5] https://patchwork.kernel.org/patch/9811729/ and https://patchwork.kernel.org/patch/9811731/]

Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Cc: Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>

Leon Romanovsky (4):
  rdma: Add basic infrastructure for RDMA tool
  rdma: Add dev object
  rdma: Add link object
  rdma: Add initial manual for the tool

 Makefile          |   2 +-
 man/man8/Makefile |   3 +-
 man/man8/rdma.8   |  82 ++++++++++++++++
 rdma/.gitignore   |   1 +
 rdma/Makefile     |  22 +++++
 rdma/dev.c        | 235 +++++++++++++++++++++++++++++++++++++++++++++
 rdma/link.c       | 280 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 rdma/rdma.c       | 118 +++++++++++++++++++++++
 rdma/rdma.h       |  80 ++++++++++++++++
 rdma/utils.c      | 270 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 10 files changed, 1091 insertions(+), 2 deletions(-)
 create mode 100644 man/man8/rdma.8
 create mode 100644 rdma/.gitignore
 create mode 100644 rdma/Makefile
 create mode 100644 rdma/dev.c
 create mode 100644 rdma/link.c
 create mode 100644 rdma/rdma.c
 create mode 100644 rdma/rdma.h
 create mode 100644 rdma/utils.c

--
2.13.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
