From: "Ariel Elior" <ariele@broadcom.com>
Subject: [PATCH net-next v5 00/22] bnx2x: support SR-IOV
Date: Tue, 1 Jan 2013 17:22:22 +0200
Message-ID: <1357053764-8187-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, eilong@broadcom.com,
	"Ariel Elior" <ariele@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4221 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752300Ab3AAPTv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jan 2013 10:19:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Changes for v2:
-Remove redundant empty lines
-Remove redundant 'inline'

Changes for v3:
-Really remove all redundant empty lines
-Remove __dev* attributes from series

Changes for v4:
-Rearrange comments to be indented according to basic block
-Remove more redundant empty lines...
-use dev_info() rather than pr_info()
-add termnating newlines to all printouts (thanks Joe)
-add empty line between functional local variable declarations and actual code

Changes for v5:
-Fix compile warnings on gcc-4.7.2 on Fedora 17

This patch series adds support for SR-IOV in the bnx2x driver.
In bnx2x SR-IOV scheme the same bnx2x driver drives both VFs and PFs (single
binary).
The bulk of the communication between the VF drivers and the PF driver is done
via the VF <-> PF channel, a hardware-based communications channel with TLV
messages. The TLVs are designed to support different versions of VF drivers
(from multiple VMs) communicating with the same PF driver.

Patches:
01-03 - Probing and removing a VF driver
Includes sending the 'acquire' and 'release' messages on the VF PF channel.
Here the VF PF channel infrastructure is added, including the allocations of
the mailboxes and the definition of thin API structures (which will fill out 
with more content as the series progresses).

04-07 - Loading/Unloading a VF driver
Includes refactoring of the driver load code and differentiating the VF flow
from the PF flow. This also includes requests from the VF for the PF to open
a queue in the HW on its behalf, configure the device with macs/vlans/rxmode
data, etc. Likewise the unload flow has been modified for the PF to undo these
configurations when the VF indicates it is going down.

08    - Modify fastpath flows for VFs
VFs have almost identical behavior in fastpath to PFs. In this patch the
VFs prepare transmit transaction for tx-switching, and the code for acking a
fastpath interrupt has been reorganized to allow a VF or PF to preconfigure the
offset of the interrupt's location in the BAR (as they have BARs with different
mapping) so as not to do so in fastpath.

09-10 - Probe and Load a PF driver with SR-IOV
The PF driver allocates and initializes the VF database to manage and keep track
of its VFs, their resources, queues, etc.

11-19 - The PF side of the VF <-> PF channel requests
Here is the implementation on the PF's side of the requests submitted in patches
01 through 07 by the VF. Patch 14 adds support for statistics collection by the 
PF for all of its VFs (stats are DMAEed directly to VM GPA memory).

20    - Support for VF function level reset
When FLR indication is received for VFs, the PF reclaims all the resources
allocated for these VFs (interrupts, queues) and releases allocation it
performed for the FLRed VFs (it does so by consulting the VF database).

21    - Bulletin Board interface
This patch adds the PF <-> VF Bulletin Board interface. This interface is a
simple interface where the PF can be the initiator, and indicate to a VF that
it has a new MAC for it to use. In this interface each post "covers" any
previous posts (hence the name).

22    - Add the VF device ids and enable feature
In this patch we add the VF device ids of the various devices driven by bnx2x.
Here we also add the calls to "pci_enable_sriov" and "pci_disable_sriov".

Important: In this patch series we have laid the ground work for interfacing
with the infrastructure for dynamically controlling the number of VFs of a
physical device.

Meanwhile, in patch 9 this code is added to bnx2x_init_one():
--snip snip--
rc = bnx2x_iov_init_one(bp, int_mode, 0/*num vfs*/);
--snip snip--
recompiling the bnx2x with a number of vfs which is not 0 will enable SR-IOV
with that number of VFs.

Please consider applying these patches.
