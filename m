From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH v4 0/2] Series short description
Date: Tue, 07 Apr 2009 17:37:20 -0700
Message-ID: <20090408003556.2448.26129.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.emeryville.ca.mail.comcast.net ([76.96.27.211]:55539
	"EHLO QMTA11.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758955AbZDHJFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 05:05:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series implements the igbvf driver and modifies the physical
function support provided in igb to automatically load a number of Virtual
Functions (VFs) equal to the number specified by module parameter num_vfs.
 
In trying to use the rtnl_link_ops approach we found multiple issues.  The
SR-IOV interface requires 2 seconds to change number of VFs.  As a result
doing it one VF at a time requires 14 seconds per device to populate all 7
VFs.  The second issue we saw is that when the igbvf driver would attempt
to probe the device while we were adding a VF via the rtnl_link_operation
and it would deadlock the system unless we released rtnl_lock prior to
allocating the VFs.

The original implementation of the igb physical function enabled VFs via a
sysfs value.  This allowed for specifying which port and the number of VFs
to generate.  The new approach is a compromise that removes the num_vfs sysfs
entry and replaces it to a module parameter similar to what is seen in vxge
until we can determine a better way to resolve the issue.
 
Our testing has found that it is now more difficult to sort out PFs and VFs
as they are intermixed during allocation and extra interfaces may be
allocated that are not needed since the num_vfs module parameter was defined
as a global and not per port.  However this is still preferable to the issues
seen with the rtnl_link_ops approach.

Notes from testing:
1. Enumeration is inconsistent and vary depending on how the drivers are
configured and loaded, for example:
igb=m, igbvf=m
eth0 - 7 are VF
eth8 is PF

The above is on reload, the enumeration is different after initial boot...

igb=y, igbvf=m
eth0 is PF
eth1 - 8  are VFs

2. The inability to easily check which VF belongs to which PF hinders users
and the inconsistent enumeration does not make it better.  Testing feels that
this is a valid concern even in VMs, especially with large number of devices. 

---

Alexander Duyck (2):
      igb: remove sysfs entry that was used to set the number of vfs
      igbvf: add new driver to support 82576 virtual functions


 drivers/net/Kconfig         |   21 
 drivers/net/Makefile        |    1 
 drivers/net/igb/igb_main.c  |  159 +-
 drivers/net/igbvf/Makefile  |   38 +
 drivers/net/igbvf/defines.h |  125 ++
 drivers/net/igbvf/ethtool.c |  540 ++++++++
 drivers/net/igbvf/igbvf.h   |  335 +++++
 drivers/net/igbvf/mbx.c     |  350 +++++
 drivers/net/igbvf/mbx.h     |   75 +
 drivers/net/igbvf/netdev.c  | 2919 +++++++++++++++++++++++++++++++++++++++++++
 drivers/net/igbvf/regs.h    |  108 ++
 drivers/net/igbvf/vf.c      |  398 ++++++
 drivers/net/igbvf/vf.h      |  265 ++++
 13 files changed, 5229 insertions(+), 105 deletions(-)
 create mode 100644 drivers/net/igbvf/Makefile
 create mode 100644 drivers/net/igbvf/defines.h
 create mode 100644 drivers/net/igbvf/ethtool.c
 create mode 100644 drivers/net/igbvf/igbvf.h
 create mode 100644 drivers/net/igbvf/mbx.c
 create mode 100644 drivers/net/igbvf/mbx.h
 create mode 100644 drivers/net/igbvf/netdev.c
 create mode 100644 drivers/net/igbvf/regs.h
 create mode 100644 drivers/net/igbvf/vf.c
 create mode 100644 drivers/net/igbvf/vf.h

-- 
Cheers,
Jeff
