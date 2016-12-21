From: Satha Koteswara Rao <satha.rao@caviumnetworks.com>
Subject: [RFC PATCH 0/7] ThunderX Embedded switch support
Date: Wed, 21 Dec 2016 14:16:44 +0530
Message-ID: <1482310011-1862-1-git-send-email-satha.rao@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: rvatsavayi@caviumnetworks.com, rric@kernel.org, david.daney@cavium.com,
 netdev@vger.kernel.org, satha.rao@caviumnetworks.com,
 derek.chickles@caviumnetworks.com, sgoutham@cavium.com, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org, philip.romanov@cavium.com
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Background
==========

Proposed patch configures programmable ThunderX embedded network switch to
emulate functions of e-switch found in most industry standard NICs.

Embedded switch is pre-configured by loading firmware image which exposes
several firmware defined tables allowing configuration of VLAN and MAC filters.

Embedded switch configuration profile and the driver introduce the following
features:

* Support of configurable number of VFs per physical port (see num_vfs below)

* VLAN filters per VF

* Unicast MAC-DA filters per VF

* Multicast MAC-DA filters per VF

* Support of dedicated VF allowing packet mirroring of all traffic traversing
  physical port (such VF is attached to the interface representing physical
  port)

* Administrative VLAN enforcement per VF (i.e. inserting/overwriting VLAN tag
  on all traffic originated by particular VF)

Each VF operates in two modes: a) full filter mode, where it receives only
registered MAC-DA/VLAN packets and b) multicast promiscuous mode. The latter
is enabled when VF reaches it's maximum MAC-DA filter limit: in this mode VF
receives all multicast and registered unicast MAC frames.

Special effort is made to track association of interface switching groups
to underlying physical ports: entry of /sys/class/net/<intf>/phys_port_name
contains string describing underlying physical port the interface is attached
to in a form <node-id>-<port-group-id>-<port>.

Set of patches include following changes:

1) Patch to original NIC drivers to enable internal switch, and load firmware
   image.

2) Modification of VF driver to subscribe to interface MAC/VLAN ADD/DELETE
   notifications and send them to the PF driver.

3) Modification of PF driver to receive MBOX interrupts from VF for ADD/DELETE
   MAC/VLAN registrations.

4) E-switch initialization code

5) API to access firmware-defined tables embedded switch tables.

The following new parameter is introduced by the driver:

num_vfs: Number of VFs attached to each physical port, default value of this
         parameter is 0, in which case driver operates in backward-compatible
         switch bypass mode.

Set of patches uses below git branch

git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git

patchset generated against below commit

commit 69973b830859bc6529a7a0468ba0d80ee5117826
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Sun Dec 11 11:17:54 2016 -0800

    Linux 4.9

Thank You!

-------------------------------------------------------------------------------

Satha Koteswara Rao (7):

* Patch 1:
  * PF driver modified to enable HW filter support, changes works in
    backward compatibility mode. Enable required things in Makefile.
    Enable LZ4 dependecy inside config file

* Patch 2:
  * VF driver changes to enable hooks to get kernel notifications

* Patch 3:
  * Enable pause frame support

* Patch 4:
  * HW Filter Initialization code and register access APIs

* Patch 5:
  * Multiple VF's grouped together under single physical port called PF
    group. PF Group maintainance API's.

* Patch 6:
  * HW Filter Table access API's

* Patch 7:
  * Get notifications from PF driver and configure filter block based on
    requested data.


 drivers/net/ethernet/cavium/Kconfig               |    1 +
 drivers/net/ethernet/cavium/thunder/Makefile      |    2 +-
 drivers/net/ethernet/cavium/thunder/nic.h         |  203 ++-
 drivers/net/ethernet/cavium/thunder/nic_main.c    |  735 ++++++++-
 drivers/net/ethernet/cavium/thunder/nicvf_main.c  |  579 ++++++-
 drivers/net/ethernet/cavium/thunder/pf_filter.c   | 1678 +++++++++++++++++++++
 drivers/net/ethernet/cavium/thunder/pf_globals.h  |   78 +
 drivers/net/ethernet/cavium/thunder/pf_locals.h   |  365 +++++
 drivers/net/ethernet/cavium/thunder/pf_reg.c      |  660 ++++++++
 drivers/net/ethernet/cavium/thunder/pf_vf.c       |  207 +++
 drivers/net/ethernet/cavium/thunder/tbl_access.c  |  262 ++++
 drivers/net/ethernet/cavium/thunder/tbl_access.h  |   61 +
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c |   25 +
 drivers/net/ethernet/cavium/thunder/thunder_bgx.h |    7 +
 14 files changed, 4712 insertions(+), 151 deletions(-)
 create mode 100644 drivers/net/ethernet/cavium/thunder/pf_filter.c
 create mode 100644 drivers/net/ethernet/cavium/thunder/pf_globals.h
 create mode 100644 drivers/net/ethernet/cavium/thunder/pf_locals.h
 create mode 100644 drivers/net/ethernet/cavium/thunder/pf_reg.c
 create mode 100644 drivers/net/ethernet/cavium/thunder/pf_vf.c
 create mode 100644 drivers/net/ethernet/cavium/thunder/tbl_access.c
 create mode 100644 drivers/net/ethernet/cavium/thunder/tbl_access.h

-- 
1.8.3.1
