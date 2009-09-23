From: sjur.brandeland@stericsson.com
Subject: [PATCH 0/8] [RFC] CAIF Protocol Stack
Date: Wed, 23 Sep 2009 19:30:23 +0200
Message-ID: <1253727023-10203-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kim.xx.Lilliestierna@ericsson.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgo1smout1.broadpark.no ([217.13.4.94]:55315 "EHLO
	bgo1smout1.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751623AbZIWSaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 14:30:22 -0400
Received: from bgo1sminn1.broadpark.no ([217.13.4.93])
 by bgo1smout1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KQF003F8PYOF560@bgo1smout1.broadpark.no> for
 netdev@vger.kernel.org; Wed, 23 Sep 2009 19:30:24 +0200 (CEST)
Received: from localhost.localdomain ([84.49.68.131])
 by bgo1sminn1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KQF004HGPYNH4G0@bgo1sminn1.broadpark.no> for
 netdev@vger.kernel.org; Wed, 23 Sep 2009 19:30:24 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

=46irst of all, apologies for the size of this patch set,=20
but we like to get comments and feedback from this list.

We are working on a patch set in order to introduce the CAIF protocol i=
n Linux.
CAIF (Communication CPU to Application CPU Interface) is the primary pr=
otocol
used to communicate between to ST-Ericsson modem and the external host =
system.=20

The host processes can use CAIF to open virtual AT channels, initiate G=
PRS Data
connections, Video channels and Utility Channels. The Utility Channels =
are=20
general-purpose pipes between modem and host.

ST-Ericsson modems support a number of Link Layers between modem and ho=
st,
currently Uart and Shared Memory are available for Linux, SPI is soon t=
o come.

Architecture:
------------
The Implementation of CAIF is divided into:
* CAIF Devices Drivers: Character Device, Net Device and Kernel API.
* CAIF Protocol Implementation
* CAIF Link Layer

In order to configure the devices a set of IOCTLs is used.



  IOCTL                                 =20
   !                                    =20
   !     +------+   +------+   +------+                =20
   !    +------+!  +------+!  +------+!   =20
   !    ! Chr  !!  !Kernel!!  ! Net  !!
   !    ! Dev  !+  ! API  !+  ! Dev  !+   <- CAIF Devices Drivers
   !    +------+   +------!   +------+          =20
   !       !          !          !      =20
   !       +----------!----------+
   !               +------+               <- CAIF Protocol Implementati=
on
   +------->       ! CAIF !                  /dev/caifconfig
                   +------+                 =20
             +--------!--------+        =20
             !                 !             =20
          +------+          +-----+    =20
          !ShMem !          ! TTY !       <- Link Layer         =20
          +------+          +-----+          =20

Any comments welcome.


The patch set is compiled on arm and 386 for 2.6.31.
We have split the patches up in the following way:

--- [1/8] User Space header files used in IOCTL
 include/linux/caif/caif_config.h |  203 ++++++++++++++++++++++++++++++=
++++++++
 include/linux/caif/caif_ioctl.h  |  114 +++++++++++++++++++++

--- [2/8] Generic CAIF Protocol Stack header files
 include/net/caif/generic/caif_layer.h |  378 +++++++++++++++++++++++++=
++++++++
 include/net/caif/generic/cfcnfg.h     |  223 +++++++++++++++++++
 include/net/caif/generic/cfctrl.h     |  139 ++++++++++++
 include/net/caif/generic/cffrml.h     |   29 +++
 include/net/caif/generic/cfglue.h     |  206 ++++++++++++++++++
 include/net/caif/generic/cfloopcfg.h  |   28 +++
 include/net/caif/generic/cflst.h      |   27 +++
 include/net/caif/generic/cfmsll.h     |   22 ++
 include/net/caif/generic/cfmuxl.h     |   30 +++
 include/net/caif/generic/cfpkt.h      |  246 +++++++++++++++++++++
 include/net/caif/generic/cfserl.h     |   22 ++
 include/net/caif/generic/cfshml.h     |   21 ++
 include/net/caif/generic/cfspil.h     |   80 +++++++
 include/net/caif/generic/cfsrvl.h     |   48 ++++
 include/net/caif/generic/fcs.h        |   22 ++

--- [3/8] c
 include/net/caif/caif_actions.h     |   81 +++++++++
 include/net/caif/caif_chr.h         |   52 ++++++
 include/net/caif/caif_config_util.h |   27 +++
 include/net/caif/caif_kernel.h      |  324 +++++++++++++++++++++++++++=
++++++++
 include/net/caif/caif_log.h         |   83 +++++++++

--- [4/8] Generic CAIF Protocol Stack code
 net/caif/generic/cfcnfg.c       |  546 +++++++++++++++++++++++++++++++=
++
 net/caif/generic/cfctrl.c       |  641 +++++++++++++++++++++++++++++++=
++++++++
 net/caif/generic/cfdgml.c       |  119 ++++++++
 net/caif/generic/cffrml.c       |  146 +++++++++
 net/caif/generic/cflist.c       |   99 ++++++
 net/caif/generic/cfloopcfg.c    |   93 ++++++
 net/caif/generic/cflooplayer.c  |  116 +++++++
 net/caif/generic/cfmsll.c       |   55 ++++
 net/caif/generic/cfmuxl.c       |  263 ++++++++++++++++
 net/caif/generic/cfpkt_skbuff.c |  590 +++++++++++++++++++++++++++++++=
++++
 net/caif/generic/cfrfml.c       |  112 +++++++
 net/caif/generic/cfserl.c       |  297 ++++++++++++++++++
 net/caif/generic/cfshml.c       |   67 ++++
 net/caif/generic/cfspil.c       |  245 +++++++++++++++
 net/caif/generic/cfsrvl.c       |  177 +++++++++++
 net/caif/generic/cfutill.c      |  115 +++++++
 net/caif/generic/cfveil.c       |  118 +++++++
 net/caif/generic/cfvidl.c       |   68 ++++
 net/caif/generic/fcs.c          |   58 ++++

--- [5/8] Device Drivers code: CHR device, NET device, CAIF Kernel API
 net/caif/Kconfig            |   61 +++
 net/caif/Makefile           |   62 +++
 net/caif/caif_chnlif.c      |  219 ++++++++
 net/caif/caif_chr.c         |  378 ++++++++++++++
 net/caif/caif_config_util.c |  167 +++++++
 net/caif/chnl_chr.c         | 1161 +++++++++++++++++++++++++++++++++++=
++++++++
 net/caif/chnl_net.c         |  464 +++++++++++++++++

--- [6/8] 8
 drivers/net/caif/Kconfig      |   64 +++
 drivers/net/caif/Makefile     |   29 ++
 drivers/net/caif/chnl_tty.c   |  220 +++++++++++
 drivers/net/caif/phyif_loop.c |  309 +++++++++++++++
 drivers/net/caif/phyif_ser.c  |  189 +++++++++
 drivers/net/caif/phyif_shm.c  |  870 +++++++++++++++++++++++++++++++++=
++++++++
 drivers/net/caif/shm.h        |   95 +++++
 drivers/net/caif/shm_cfgifc.c |   60 +++
 drivers/net/caif/shm_mbxifc.c |   98 +++++
 drivers/net/caif/shm_smbx.c   |   81 ++++

--- [7/8] Documentation
 Documentation/CAIF/Linux-CAIF.txt                  |  319 ++++++++++++=
+++++
 Documentation/CAIF/README                          |   60 ++++
 Documentation/CAIF/chardevconfig/Makefile          |   11 +
 Documentation/CAIF/chardevconfig/README            |   39 ++
 Documentation/CAIF/chardevconfig/caif_cmd_parse.c  |  365 ++++++++++++=
++++++++
 Documentation/CAIF/chardevconfig/chardevconfig.c   |  111 ++++++
 .../CAIF/chardevconfig/create_devices.config       |   12 +
 .../CAIF/chardevconfig/delete_devices.config       |   12 +
 Documentation/CAIF/ldiscd/ldiscd.c                 |  123 +++++++


--- [8/8] Kconfig and Makefiles
 drivers/net/Makefile |    1 +
 net/Kconfig          |    1 +
 net/Makefile         |    1 +


Regards
Sjur Br=E6ndeland
ST-Ericsson
