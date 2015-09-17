From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH net-next] igb: assume MSI-X interrupts during initialization
Date: Thu, 17 Sep 2015 14:46:10 +0200
Message-ID: <1442493970-20073-1-git-send-email-sassmann@kpanic.de>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, sassmann@kpanic.de
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45683 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751000AbbIQMqc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2015 08:46:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In igb_sw_init() the sequence of calls was changed from
igb_init_queue_configuration()
igb_init_interrupt_scheme()
igb_probe_vfs()
to
igb_probe_vfs()
igb_init_queue_configuration()
igb_init_interrupt_scheme()

This results in adapter->flags not having the IGB_FLAG_HAS_MSIX bit set
during igb_probe_vfs()->igb_enable_sriov(). Therefore SR-IOV does not
get enabled properly and we run into a NULL pointer if the max_vfs
module parameter is specified (adapter->vf_data does not get allocated,
crash on accessing the structure).

[    7.419348] BUG: unable to handle kernel NULL pointer dereference at 0000000000000048
[    7.419367] IP: [<ffffffffa02161c6>] igb_reset+0xe6/0x5d0 [igb]
[    7.419370] PGD 0
[    7.419373] Oops: 0002 [#1] SMP
[    7.419381] Modules linked in: ahci(+) libahci igb(+) i40e(+) vxlan ip6_udp_tunnel udp_tunnel megaraid_sas(+) ixgbe(+) mdio
[    7.419385] CPU: 0 PID: 4 Comm: kworker/0:0 Not tainted 4.2.0+ #153
[    7.419387] Hardware name: Dell Inc. PowerEdge R720/0C4Y3R, BIOS 1.6.0 03/07/2013
[...]
[    7.419431] Call Trace:
[    7.419442]  [<ffffffffa0217236>] igb_probe+0x8b6/0x1340 [igb]
[    7.419447]  [<ffffffff814c7f15>] local_pci_probe+0x45/0xa0

Prevent this by setting the IGB_FLAG_HAS_MSIX bit before calling
igb_probe_vfs(). The real interrupt capabilities will be checked during
igb_init_interrupt_scheme() so this is safe to do.

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index e174fbb..ba019fc 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2986,6 +2986,9 @@ static int igb_sw_init(struct igb_adapter *adapter)
 	}
 #endif /* CONFIG_PCI_IOV */
 
+	/* Assume MSI-X interrupts, will be checked during IRQ allocation */
+	adapter->flags |= IGB_FLAG_HAS_MSIX;
+
 	igb_probe_vfs(adapter);
 
 	igb_init_queue_configuration(adapter);
-- 
2.4.3
