From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 v2 00/12] net-caif: introducing CAIF protocol stack
Date: Tue, 16 Feb 2010 14:46:45 +0100
Message-ID: <1266328017-28406-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com,
	daniel.martensson@stericsson.com, kaber@trash.net,
	marcel@holtmann.org,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgo1smout1.broadpark.no ([217.13.4.94]:56525 "EHLO
	bgo1smout1.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756332Ab0BPNrd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 08:47:33 -0500
Received: from bgo1sminn1.broadpark.no ([217.13.4.93])
 by bgo1smout1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KXX00066SZ1VAD0@bgo1smout1.broadpark.no> for
 netdev@vger.kernel.org; Tue, 16 Feb 2010 14:47:25 +0100 (CET)
Received: from localhost.localdomain ([84.49.71.7]) by bgo1sminn1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KXX00DUYSYQXZJ0@bgo1sminn1.broadpark.no> for
 netdev@vger.kernel.org; Tue, 16 Feb 2010 14:47:15 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

This patch-set introduces the CAIF protocol Stack.
The "Communication CPU to Application CPU Interface" (CAIF) is a packet based
connection-oriented MUX protocol developed by ST-Ericsson for use with its
modems.


CHANGE LOG:
Based on review comment from Marcel Holtmann, Patrick McHardy, and Randy Dunlap
on the previous patch set submitted the 20th Jan the following changes has
been done:
- Removed "CAIF Kernel Client API for CAIF".
- In CAIF Net device: removed IOCTL management.
- In Socket Interface, removed socket option CAIFSO_CHANNEL,
  and replaced it with SO_PRIORITY, SO_BINDTODEVICE and CAIFSO_LINK_SELECT.
- In caif_socket.c, implemented most of CAIF socket options.
- Moved Caif Core protocol files out of directory 'generic'
- Removed glue code cfglue.h, this causes lots of small changes in CAIF core.
- Removed linked list code cflst.h, cflist.c this impacts caifmux.c.
- Added CAIF debug service cfdbgl.c.
- In CAIF Net device, fixed race condition with rtnl when unloading of module.
- In Linux-CAIF.txt, minor updates including fixing some spelling mistakes.
- In README, added more documentation on CAIF Serial debugging.
- In caif_serial.c, the TTY is no longer opened from kernel, but
  the line discipline must be installed from user space utility.
- In caif_serial.c, added debugfs entries for last received and transmitted 
  messages and status information.
- Attempting to conform to kernel-doc formatting conventions.


OVERVIEW:

* CAIF provides a socket interface which can be used to open virtual AT
  channels, create and configure GPRS Data connections.

* A CAIF Network device is also provided for GPRS access.
  This interface can be managed with RTNL.

* A kernel interface is provided allowing Kernel modules to use CAIF.

* A serial link layer layer implemented as a line discipline is currently 
  implemented. Other link interfaces may be contributed at a later stage.

  RTNL
   !
   !	 +------+   +------+   +------+
   !	+------+!  +------+!  +------+!
   !	! Sock !!  !Kernel!!  ! Net  !!
   !	! API  !+  ! API  !+  ! Dev  !+	  <- CAIF "Client" APIs
   !	+------+   +------!   +------+
   !	   !	      !		 !
   !	   +----------!----------+
   !		   +------+		  <- CAIF Core Protocol Implementation
   +------->	   ! CAIF !
		   ! Core !
		   +------+
	     +--------!--------+
	     !		       !
	  +------+	    +-----+
	  ! ldisc!	    ! ... !	  <- Link Layer (Net Devices)
	  +------+	    +-----+
	     !
	  +------+
	  ! tty	 !
	  +------+

Please see Documentation/networking/CAIF for more documentation.


Based on net-next-2.6



Sjur Braendeland (12):
  net-caif: add CAIF protocol definitions
  net-caif: add CAIF socket and configuration headers
  net-caif: add CAIF core protocol stack header files
  net-caif: add CAIF Link layer device header files
  net-caif: add CAIF core protocol stack
  net-caif: add CAIF generic caif support functions
  net-caif: add CAIF device registration functionality
  net-caif: add CAIF socket implementation
  net-caif: add CAIF netdevice
  net-caif: add CAIF Kconfig and Makefiles
  net-caif: add CAIF documentation
  net-caif-driver: add CAIF serial driver (ldisc)

 Documentation/networking/caif/Linux-CAIF.txt |  212 ++++
 Documentation/networking/caif/README         |  110 ++
 drivers/net/Kconfig                          |    2 +
 drivers/net/Makefile                         |    1 +
 drivers/net/caif/Kconfig                     |   15 +
 drivers/net/caif/Makefile                    |   14 +
 drivers/net/caif/caif_serial.c               |  467 ++++++++
 include/linux/caif/caif_config.h             |  163 +++
 include/linux/caif/caif_socket.h             |  195 ++++
 include/linux/caif/if_caif.h                 |   34 +
 include/linux/if_arp.h                       |    1 +
 include/linux/if_ether.h                     |    1 +
 include/linux/socket.h                       |    5 +-
 include/linux/tty.h                          |    4 +-
 include/net/caif/caif_dev.h                  |   65 ++
 include/net/caif/caif_device.h               |   57 +
 include/net/caif/caif_layer.h                |  283 +++++
 include/net/caif/cfcnfg.h                    |  134 +++
 include/net/caif/cfctrl.h                    |  136 +++
 include/net/caif/cffrml.h                    |   17 +
 include/net/caif/cfmuxl.h                    |   22 +
 include/net/caif/cfpkt.h                     |  274 +++++
 include/net/caif/cfserl.h                    |   13 +
 include/net/caif/cfsrvl.h                    |   34 +
 net/Kconfig                                  |    2 +
 net/Makefile                                 |    1 +
 net/caif/Kconfig                             |   48 +
 net/caif/Makefile                            |   28 +
 net/caif/caif_config_util.c                  |  122 ++
 net/caif/caif_dev.c                          |  398 +++++++
 net/caif/caif_socket.c                       | 1526 ++++++++++++++++++++++++++
 net/caif/cfcnfg.c                            |  531 +++++++++
 net/caif/cfctrl.c                            |  701 ++++++++++++
 net/caif/cfdbgl.c                            |   40 +
 net/caif/cfdgml.c                            |  108 ++
 net/caif/cffrml.c                            |  151 +++
 net/caif/cfmuxl.c                            |  246 +++++
 net/caif/cfpkt_skbuff.c                      |  595 ++++++++++
 net/caif/cfrfml.c                            |  106 ++
 net/caif/cfserl.c                            |  199 ++++
 net/caif/cfsrvl.c                            |  185 ++++
 net/caif/cfutill.c                           |  115 ++
 net/caif/cfveil.c                            |  107 ++
 net/caif/cfvidl.c                            |   65 ++
 net/caif/chnl_net.c                          |  429 ++++++++
 45 files changed, 7959 insertions(+), 3 deletions(-)

