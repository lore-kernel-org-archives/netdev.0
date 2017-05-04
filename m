From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [RFC iproute2 0/8] RDMA tool
Date: Thu,  4 May 2017 21:02:08 +0300
Message-ID: <20170504180216.7665-1-leon@kernel.org>
Cc: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Ram Amrani <ram.amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>,
        Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>,
        Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

----
This is initial phase to understand if user experience for this tool fits
RDMA and netdev communities exepectations. Also I would like to get feedback
if it is really worth to provide legacy sysfs for old kernels, or maybe I should
implement netlink from the beginning and abandon sysfs completely.
-----

Hi,

Please find below, the patch set with initial implementation of configuration
tool for RDMA subsystem, which will be supplementary tool to already existed
tools in netdev community (ip, devlink, ethtool, ..).

In opposite to netdev community, where standard tools exist to configure and
present different devices abilities, RDMA subsystem historically lacked it.

Following our discussion both in mailing list [1] and at the LPC 2016 [2],
we would like to propose this RDMA tool to be part of iproute2 package
and finally improve this situation.

The development of tool was influenced by ip and devlink tools. This implies
to the object->command interface and naming convention.

In order to close object model, ensure reuse of existing code and make this
tool usable from day one, we decided to implement wrappers over legacy sysfs
prior to implementing netlink functionality. As a nice bonus, it will allow
to use this tool with old kernels too.

It is important to mention that any future extension will be required to be
done with netlink, so for already existing objects small conversion to netlink
will be unavoidable.

  # rdma -h
  Usage: rdma [ OPTIONS ] OBJECT { COMMAND | help }
  where  OBJECT := { dev | link | ipoib | memory | stats | protocols | providers | monitor }
  OPTIONS := { -V[ersion] }

* DEV object equals to CA in IBTA specification and will provide
  a way to configure/present settings relevant to specific struct ib_device.

* LINK object represents port in IBTA specification and will give access to
  struct ib_port_immutable. From the day one, It prints netdev name of
  the corresponding IB port that makes ibdev2netdev script redundant.

* IPoIB object is supposed to be specific for IP-over-Infiniband upper
  layer protocol [3]. This ULP was mainly configured by combination
  of various sysfs knobs together with ethtool. Such situation adds
  challenges to add new and expose old configuration settings due to
  the mix between different subsystems.

* MEMORY object will be used to configure memory related settings,
  e.g. on-demand-paging (ODP), force-mr (force usage of MRs for
  RDMA READ/WRITE operation).

* STATS object is needed for everything related to statistics
  (per-PID, per-QP, per-device etc.). Despite the fact that RDMA
  devices provide extensive set of counters, the decision was to
  implement it in netlink directly, because there is a need to add
  filter mechanism to them, which doesn't exist now.

* PROTOCOLS object is going to be used for device special treatment
  of global to protocol settings (e.g. set device in RoCEv2 mode as
  a default, instead of RoCEv1, instead of configfs).

* PROVIDERS objects gives ability to get specific to the device
  information, like supported kABI objects [4].

* MONITOR object is needed to debug netlink communication and will
  follow standard functionality, which exists in ip and devlink tools.

There are number of ULPs which are not covered by this tool yet:
 * HFI-VNIC - I have no access to the HW and believe that Intel
   will add native object support for it.
 * Other storage related ULPs (iSER and SRP) were not introduced too,
   because they have special tools (scci-target-utils) to configure them.
   However it will be pretty straightforward to introduce new object,
   if there is demand for it.

At the initial stage, we implemented infrastructure to read legacy
sysfs entries (Patch #1), initial man pages (Patch #7) and provided
future object examples (Patch #2-6) to allow parallel development.

Following patches will focus on cleaning user interface, parsing other
relevant entries in similar fashion to the link capability mask (Patch #8)
and providing netlink interface.

These patches were tested with two following setups:
 * Setup A:
   - Two Mellanox ConnectX-4 devices (one port)
   - One Mellanox Connect-IB device (two ports)
 * Setup B:
   - One Mellanox ConnectX-4 device (one port)
   - One Mellanox ConnectX-3 Pro device (two ports)

Please consider the inclusion of the RDMA tool into iproute2 package,
so other participants will be able to speed up development.

[1] https://www.mail-archive.com/netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg148523.html
[2] http://www.medkio.com/talks/lpc_debug.pdf
[3] https://tools.ietf.org/html/rfc4392
[4] http://marc.info/?l=linux-rdma&m=149261526916544&w=2

TODO: Add json output

Cc: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Cc: Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Cc: Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Ram Amrani <ram.amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Cc: Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
Cc: Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>
Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Cc: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Cc: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Cc: Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>

Leon Romanovsky (8):
  rdma: Add basic infrastructure for RDMA tool
  rdma: Add dev object
  rdma: Add link object
  rdma: Add IPoIB object
  rdma: Add memory object
  rdma: add stubs for future objects
  man: rdma.8: Document objects and commands
  rdma: Add link capability parsing

 Makefile          |   2 +-
 man/man8/Makefile |   3 +-
 man/man8/rdma.8   | 109 +++++++++++++++++++
 rdma/.gitignore   |   1 +
 rdma/Makefile     |  15 +++
 rdma/dev.c        | 101 ++++++++++++++++++
 rdma/ipoib.c      |  54 ++++++++++
 rdma/link.c       | 160 ++++++++++++++++++++++++++++
 rdma/memory.c     |  30 ++++++
 rdma/monitor.c    |  22 ++++
 rdma/protocols.c  |  22 ++++
 rdma/providers.c  |  28 +++++
 rdma/rdma.c       | 104 ++++++++++++++++++
 rdma/rdma.h       |  93 ++++++++++++++++
 rdma/stats.c      |  22 ++++
 rdma/utils.c      | 313 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 16 files changed, 1077 insertions(+), 2 deletions(-)
 create mode 100644 man/man8/rdma.8
 create mode 100644 rdma/.gitignore
 create mode 100644 rdma/Makefile
 create mode 100644 rdma/dev.c
 create mode 100644 rdma/ipoib.c
 create mode 100644 rdma/link.c
 create mode 100644 rdma/memory.c
 create mode 100644 rdma/monitor.c
 create mode 100644 rdma/protocols.c
 create mode 100644 rdma/providers.c
 create mode 100644 rdma/rdma.c
 create mode 100644 rdma/rdma.h
 create mode 100644 rdma/stats.c
 create mode 100644 rdma/utils.c

--
2.12.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
