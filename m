From: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Subject: Re: [PATCH REPOST v5 iproute2 0/8] RDMAtool
Date: Thu, 17 Aug 2017 18:01:18 -0700
Message-ID: <20170817180118.6631382c@xeon-e3>
References: <20170817065614.1393-1-leonro@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170817065614.1393-1-leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 17 Aug 2017 09:56:06 +0300
Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> wrote:

> This is fifth revision of series implementing the RDAMtool -  the tool
> to configure RDMA devices.
>=20
> It looks like everyone who was interested to read cover letter already di=
d it,
> so I'll start from the changelog:
>=20
> Changelog:
> v4->v5:
>  * Rebased to latest net-next branch
>  * Moved BIT() macro from devlink to general utils.h file - Patch #1.
>  * Changed the order of patches - moved man pages to be last patch.
>  * Rewrote all switch->case->return_string constructions to be static
>    tables with help of David's macro magic. Thanks a lot.
>  * Dropped dependency on exported device and port properties. Now tool de=
pends
>    on RDMA netlink only and all needed code is already in Doug's for-next.
>  * Added two OPA specific physical link states, because their names is
>    too broad - TEST and OFFLINE, I named it as OPA_TEST and OPA_OFFLINE.
> v3->v4:
>  * Rebased to latest net-next branch
>  * Added JSON output -j (json) and -p (pretty output)
>  * Exported and reused kernel UAPIs and defines instead of hard coded
>    version.
> v2->v3:
>  * Removed MAX()
>  * Reduced scope of rd_argv_match
>  * Removed return from rdma_free_devmap
>  * Added extra break at rdma_send_msg
> v1->v2:
>  * Squashed multiple (and similar) patches to be one patch for dev object
>    and one patch for link object.
>  * Removed port_map struct
>  * Removed global netlink dump during initialization, it removed the need=
 to store
>    the intermediate variables and reuse ability of netlink to signal if v=
ariable
>    exists or doesn't.
>  * Added "-d" --details option and put all CAPs under it.
>=20
> v0->v1:
>  * Moved hunk with changes in man/Makefile from first patch to the last p=
atch
>  * Removed the "unknown command" from the examples in commit messages
>  * Removed special "caps" parsing command and put it to be part of genera=
l "show" command
>  * Changed parsed capability format to be similar to iproute2 suite
>  * Added FW version as an output of show command.
>  * Added forgotten CAP_FLAGS to the nla_policy list
> RFC->v0:
>  * Removed everything that is not implemented yet.
>  * Abandoned sysfs interfaces in favor of netlink.
>=20
> -----
> The initial proposal was sent as RFC [1] and was based on sysfs entries a=
s POC.
>=20
> The current series was rewritten completely to work with RDMA netlinks as
> a source of user<->kernel communications. In order to achieve that, the
> RDMA netlinks were extensively refactored and modernized [2, 3, 4 and 5].
>=20
> The Doug's for-next tag includes most of the needed patches for this tool.
>=20
> The following is an example of various runs on my machine with 5 devices
> (4 in IB mode and one in Ethernet mode).
>=20
> ### Without parameters
> $ rdma
> Usage: rdma [ OPTIONS ] OBJECT { COMMAND | help }
> where  OBJECT :=3D { dev | link | help }
>        OPTIONS :=3D { -V[ersion] | -d[etails] | -j[son] | -p[retty]}
>=20
> ### With unspecified device name
> $ rdma dev
> 1: mlx5_0: node_type ca fw 2.8.9999 node_guid 5254:00c0:fe12:3457 sys_ima=
ge_guid 5254:00c0:fe12:3457
> 2: mlx5_1: node_type ca fw 2.8.9999 node_guid 5254:00c0:fe12:3458 sys_ima=
ge_guid 5254:00c0:fe12:3458
> 3: mlx5_2: node_type ca fw 2.8.9999 node_guid 5254:00c0:fe12:3459 sys_ima=
ge_guid 5254:00c0:fe12:3459
> 4: mlx5_3: node_type ca fw 2.8.9999 node_guid 5254:00c0:fe12:345a sys_ima=
ge_guid 5254:00c0:fe12:345a
> 5: mlx5_4: node_type ca fw 2.8.9999 node_guid 5254:00c0:fe12:345b sys_ima=
ge_guid 5254:00c0:fe12:345b
>=20
> ### Detailed mode
> $ rdma -d dev
> 1: mlx5_0: node_type ca fw 2.8.9999 node_guid 5254:00c0:fe12:3457 sys_ima=
ge_guid 5254:00c0:fe12:3457
>     caps: <BAD_PKEY_CNTR, BAD_QKEY_CNTR, CHANGE_PHY_POR, PORT_ACTIVE_EVEN=
T, SYS_IMAGE_GUID, RC_RNR_NAK_GEN, MEM_WINDOW, UD_IP_CSUM, UD_TSO, XRC, MEM=
_MGT_EXTENSIONS, BLOCK_MULTICAST_LOOPBACK, MEM_WINDOW_TYPE_2B, RAW_IP_CSUM,=
 MANAGED_FLOW_STEERING, RESIZE_MAX_WR>
> 2: mlx5_1: node_type ca fw 2.8.9999 node_guid 5254:00c0:fe12:3458 sys_ima=
ge_guid 5254:00c0:fe12:3458
>     caps: <BAD_PKEY_CNTR, BAD_QKEY_CNTR, CHANGE_PHY_POR, PORT_ACTIVE_EVEN=
T, SYS_IMAGE_GUID, RC_RNR_NAK_GEN, MEM_WINDOW, UD_IP_CSUM, UD_TSO, XRC, MEM=
_MGT_EXTENSIONS, BLOCK_MULTICAST_LOOPBACK, MEM_WINDOW_TYPE_2B, RAW_IP_CSUM,=
 MANAGED_FLOW_STEERING, RESIZE_MAX_WR>
> 3: mlx5_2: node_type ca fw 2.8.9999 node_guid 5254:00c0:fe12:3459 sys_ima=
ge_guid 5254:00c0:fe12:3459
>     caps: <BAD_PKEY_CNTR, BAD_QKEY_CNTR, CHANGE_PHY_POR, PORT_ACTIVE_EVEN=
T, SYS_IMAGE_GUID, RC_RNR_NAK_GEN, MEM_WINDOW, UD_IP_CSUM, UD_TSO, XRC, MEM=
_MGT_EXTENSIONS, BLOCK_MULTICAST_LOOPBACK, MEM_WINDOW_TYPE_2B, RAW_IP_CSUM,=
 MANAGED_FLOW_STEERING, RESIZE_MAX_WR>
> 4: mlx5_3: node_type ca fw 2.8.9999 node_guid 5254:00c0:fe12:345a sys_ima=
ge_guid 5254:00c0:fe12:345a
>     caps: <BAD_PKEY_CNTR, BAD_QKEY_CNTR, CHANGE_PHY_POR, PORT_ACTIVE_EVEN=
T, SYS_IMAGE_GUID, RC_RNR_NAK_GEN, MEM_WINDOW, UD_IP_CSUM, UD_TSO, XRC, MEM=
_MGT_EXTENSIONS, BLOCK_MULTICAST_LOOPBACK, MEM_WINDOW_TYPE_2B, RAW_IP_CSUM,=
 MANAGED_FLOW_STEERING, RESIZE_MAX_WR>
> 5: mlx5_4: node_type ca fw 2.8.9999 node_guid 5254:00c0:fe12:345b sys_ima=
ge_guid 5254:00c0:fe12:345b
>     caps: <BAD_PKEY_CNTR, BAD_QKEY_CNTR, CHANGE_PHY_POR, PORT_ACTIVE_EVEN=
T, SYS_IMAGE_GUID, RC_RNR_NAK_GEN, MEM_WINDOW, UD_IP_CSUM, UD_TSO, XRC, MEM=
_MGT_EXTENSIONS, BLOCK_MULTICAST_LOOPBACK, MEM_WINDOW_TYPE_2B, RAW_IP_CSUM,=
 MANAGED_FLOW_STEERING, RESIZE_MAX_WR>
>=20
> ### Specific device
> $ rdma dev show mlx5_4
> 5: mlx5_4: node_type ca fw 2.8.9999 node_guid 5254:00c0:fe12:345b sys_ima=
ge_guid 5254:00c0:fe12:345b
>=20
> ### Specific device in detailed mode
> $ rdma dev show mlx5_4 -d
> 5: mlx5_4: node_type ca fw 2.8.9999 node_guid 5254:00c0:fe12:345b sys_ima=
ge_guid 5254:00c0:fe12:345b
>     caps: <BAD_PKEY_CNTR, BAD_QKEY_CNTR, CHANGE_PHY_POR, PORT_ACTIVE_EVEN=
T, SYS_IMAGE_GUID, RC_RNR_NAK_GEN, MEM_WINDOW, UD_IP_CSUM, UD_TSO, XRC, MEM=
_MGT_EXTENSIONS, BLOCK_MULTICAST_LOOPBACK, MEM_WINDOW_TYPE_2B, RAW_IP_CSUM,=
 MANAGED_FLOW_STEERING, RESIZE_MAX_WR>
>=20
> ### Unknown command (caps)
> $ rdma dev show mlx5_4 caps
> Unknown parameter 'caps'.
>=20
> ### Link properties without device name
> $ rdma link
> 1/1: mlx5_0/1: subnet_prefix fe80:0000:0000:0000 lid 13399 sm_lid 49151 l=
mc 0 state ACTIVE physical_state LINK_UP
> 2/1: mlx5_1/1: subnet_prefix fe80:0000:0000:0000 lid 13400 sm_lid 49151 l=
mc 0 state ACTIVE physical_state LINK_UP
> 3/1: mlx5_2/1: subnet_prefix fe80:0000:0000:0000 lid 13401 sm_lid 49151 l=
mc 0 state ACTIVE physical_state LINK_UP
> 4/1: mlx5_3/1: state DOWN physical_state DISABLED
> 5/1: mlx5_4/1: subnet_prefix fe80:0000:0000:0000 lid 13403 sm_lid 49151 l=
mc 0 state ACTIVE physical_state LINK_UP
>=20
> ### Link properties in detailed mode
> $ rdma link -d
> 1/1: mlx5_0/1: subnet_prefix fe80:0000:0000:0000 lid 13399 sm_lid 49151 l=
mc 0 state ACTIVE physical_state LINK_UP
>     caps: <AUTO_MIGR>
> 2/1: mlx5_1/1: subnet_prefix fe80:0000:0000:0000 lid 13400 sm_lid 49151 l=
mc 0 state ACTIVE physical_state LINK_UP
>     caps: <AUTO_MIGR>
> 3/1: mlx5_2/1: subnet_prefix fe80:0000:0000:0000 lid 13401 sm_lid 49151 l=
mc 0 state ACTIVE physical_state LINK_UP
>     caps: <AUTO_MIGR>
> 4/1: mlx5_3/1: state DOWN physical_state DISABLED
>     caps: <CM, IP_BASED_GIDS>
> 5/1: mlx5_4/1: subnet_prefix fe80:0000:0000:0000 lid 13403 sm_lid 49151 l=
mc 0 state ACTIVE physical_state LINK_UP
>     caps: <AUTO_MIGR>
>=20
> ### All links for specific device
> $ rdma link show mlx5_3
> 1/1: mlx5_0/1: subnet_prefix fe80:0000:0000:0000 lid 13399 sm_lid 49151 l=
mc 0 state ACTIVE physical_state LINK_UP
>=20
> ### Detailed link properties for specific device
> $ rdma link -d show mlx5_3
> 1/1: mlx5_0/1: subnet_prefix fe80:0000:0000:0000 lid 13399 sm_lid 49151 l=
mc 0 state ACTIVE physical_state LINK_UP
>     caps: <AUTO_MIGR>
>=20
> ### Specific port for specific device
> $ rdma link show mlx5_4/1
> 1/1: mlx5_0/1: subnet_prefix fe80:0000:0000:0000 lid 13399 sm_lid 49151 l=
mc 0 state ACTIVE physical_state LINK_UP
>=20
> ### Unknown parameter
> $ rdma link show mlx5_4/1 caps
> Unknown parameter 'caps'.
>=20
> Thanks
>=20
> Available in the "topic/rdmatool-netlink-v5" topic branch of this git rep=
o:
> git://git.kernel.org/pub/scm/linux/kernel/git/leon/iproute2.git
>=20
> Or for browsing:
> https://git.kernel.org/cgit/linux/kernel/git/leon/iproute2.git/log/?h=3Dt=
opic/rdmatool-netlink-v5
>=20
> Thanks
>=20
> [1] https://www.spinics.net/lists/linux-rdma/msg49575.html
> [2] https://patchwork.kernel.org/patch/9752865/
> [3] https://www.spinics.net/lists/linux-rdma/msg50827.html
> [4] https://www.spinics.net/lists/linux-rdma/msg51210.html
> [5] https://patchwork.kernel.org/patch/9811729/ and https://patchwork.ker=
nel.org/patch/9811731/]
>=20
> Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
> Cc: Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Cc: Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Cc: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
> Cc: Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
>=20
> Leon Romanovsky (8):
>   utils: Move BIT macro to common header
>   rdma: Add basic infrastructure for RDMA tool
>   rdma: Add dev object
>   rdma: Add link object
>   rdma: Add json and pretty outputs
>   rdma: Implement json output for dev object
>   rdma: Add json output to link object
>   rdma: Add initial manual for the tool
>=20
>  Makefile             |   2 +-
>  devlink/devlink.c    |   2 +-
>  include/utils.h      |   2 +
>  man/man8/rdma-dev.8  |  55 +++++++++
>  man/man8/rdma-link.8 |  55 +++++++++
>  man/man8/rdma.8      | 102 +++++++++++++++
>  rdma/.gitignore      |   1 +
>  rdma/Makefile        |  22 ++++
>  rdma/dev.c           | 284 ++++++++++++++++++++++++++++++++++++++++++
>  rdma/link.c          | 343 +++++++++++++++++++++++++++++++++++++++++++++=
++++++
>  rdma/rdma.c          | 143 +++++++++++++++++++++
>  rdma/rdma.h          |  93 ++++++++++++++
>  rdma/utils.c         | 266 +++++++++++++++++++++++++++++++++++++++
>  13 files changed, 1368 insertions(+), 2 deletions(-)
>  create mode 100644 man/man8/rdma-dev.8
>  create mode 100644 man/man8/rdma-link.8
>  create mode 100644 man/man8/rdma.8
>  create mode 100644 rdma/.gitignore
>  create mode 100644 rdma/Makefile
>  create mode 100644 rdma/dev.c
>  create mode 100644 rdma/link.c
>  create mode 100644 rdma/rdma.c
>  create mode 100644 rdma/rdma.h
>  create mode 100644 rdma/utils.c
>=20
> --
> 2.14.1
>=20

Wanted to apply this (to net-next), but build fails:

rdma
make[1]: Entering directory '/var/src/iproute2-net-next/rdma'
    CC       rdma.o
rdma.c: In function =E2=80=98rd_init=E2=80=99:
rdma.c:64:21: error: =E2=80=98RDMA_NLDEV_CMD_GET=E2=80=99 undeclared (first=
 use in this function)
  rd_prepare_msg(rd, RDMA_NLDEV_CMD_GET,
                     ^~~~~~~~~~~~~~~~~~



I think you are depending on some header file that has a more recent version
on your system. Iproute2 has its own include/ directory to deal with this
type of override. Already have headers for kernel and iptables.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
