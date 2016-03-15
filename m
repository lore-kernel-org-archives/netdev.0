From: Aaron Young <Aaron.Young@oracle.com>
Subject: [PATCH net-next v2 0/4] ldmvsw: Add ldmvsw driver
Date: Tue, 15 Mar 2016 11:35:36 -0700
Message-ID: <cover.1458006737.git.Aaron.Young@oracle.com>
Cc: netdev@vger.kernel.org, sowmini.varadhan@oracle.com,
	alexandre.chartre@oracle.com, rashmi.narasimhan@oracle.com,
	aaron.young@oracle.com, atish.patra@oracle.com,
	Aaron Young <Aaron.Young@oracle.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:39014 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965568AbcCOSfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 14:35:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Young <aaron.young@oracle.com>

This series adds a new Logical Domains vSwitch (ldmvsw) driver.

The ldmvsw driver code will live in the drivers/net/ethernet/sun/
directory and will operate on Oracle systems running SPARC Linux in a
Logical Domains environment (typically in the control domain).

The ldmvsw driver is very similar in function to the existing sunvnet
driver. Ldmvsw creates a network interface for each "vsw-port" node
found in the Machine Description (MD) of a service domain. These
nodes correspond to ports on a vswitch created by the logical domains
manager. The created network interface(s) can be used by bridge/vswitch
software (such as the Linux bridge or Open vSwitch) to provide
guest domain(s) with network interconnectivity or connectivity
to a physical network.

Here is a example diagram of ldmvsw driver usage in a logical
domain environment to provide a guest domain with network connectivity
to a physical NIC on the service domain:

   +----------------+             +-----------------
   | Service Domain |             |  Guest domain  |
   |                |             |                |
   |  LinuxBridge   |             |                |
   |    |    |      |             |                |
   |   NIC Ldmvsw   |             |    Sunvnet     |
   +----------------+             +----------------+
        |    |           LDC              |
       LAN   ------------------------------

As stated, the sunvnet and ldmvsw drivers are _very_ similar in function.
They both create network interface(s) to receive/transmit network
traffic across LDC network channel(s). Since the driver is so similar
in function to sunvnet, the approach will be as follows to integrate
the driver and take advantage of common code:

Patch #1: Split sunvnet.c driver into sunvnet.c and sunvnet_common.c
Patch #2: Modify the sunvnet_common code and data structures to be compatible
          with both the sunvnet and ldmvsw drivers.
Patch #3: Add the new ldmvsw.c driver code
Patch #4: Checkpatch cleanup of the sunvnet/sunvnet_common code.

NOTE - Patch#1 renames a file (sunvnet.h -> sunvnet_common.h). When generating
the patches (using git format-patch), I had to use the --no-renames option
otherwise patch#1 would NOT apply using 'patch -p1' - which as I
understand is a requirement for patch acceptance. I wasn't sure if this
is proper thing to do.  Please advise if not. Thanks.

v2 changes:
  * change all EXPORT_SYMBOL declarations to EXPORT_SYMBOL_GPL
  * remove inline attribute for external function port_is_up_common()
  * Give all exported/global funcs in sunvnet_common.c a 'sunvnet_' prefix
    to avoid kernel global namespace pollution/collisions
  * ldmvsw.c: Order local variable declarations from longest to shortest line
  * ldmvsw.c: register the netdevice after all supporting state is ready/setup.
              NOTE: The consensus at Oracle is that the following functions
                    must be done AFTER register_netdev() - this is the same
                    ordering currently used in the sunvnet driver:
                    1. sunvnet_port_add_txq_common() - needs registered netdev
                    2. napi_enable() - requires registered netdev
                    3. vio_port_up() - as soon as this function is called
                                       LDC handshake messages will come in
                                       which must be handled by the napi code.

Aaron Young (4):
  net-next: ldmvsw: Split sunvnet driver into common code
  net-next: ldmvsw: Make sunvnet_common compatible with ldmvsw
  net-next: ldmvsw: Add ldmvsw.c driver code
  net-next: ldmvsw: Checkpatch sunvnet.c and sunvnet_common.c

 arch/sparc/configs/sparc64_defconfig      |    1 +
 drivers/net/ethernet/sun/Kconfig          |   16 +
 drivers/net/ethernet/sun/Makefile         |    2 +
 drivers/net/ethernet/sun/ldmvsw.c         |  468 ++++++++
 drivers/net/ethernet/sun/sunvnet.c        | 1753 +----------------------------
 drivers/net/ethernet/sun/sunvnet.h        |  114 --
 drivers/net/ethernet/sun/sunvnet_common.c | 1732 ++++++++++++++++++++++++++++
 drivers/net/ethernet/sun/sunvnet_common.h |  145 +++
 8 files changed, 2421 insertions(+), 1810 deletions(-)
 create mode 100644 drivers/net/ethernet/sun/ldmvsw.c
 delete mode 100644 drivers/net/ethernet/sun/sunvnet.h
 create mode 100644 drivers/net/ethernet/sun/sunvnet_common.c
 create mode 100644 drivers/net/ethernet/sun/sunvnet_common.h
