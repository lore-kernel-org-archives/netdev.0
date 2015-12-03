From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/4] ixgbe: Reset interface after enabling SR-IOV
Date: Thu,  3 Dec 2015 13:57:51 -0800
Message-ID: <1449179874-49174-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449179874-49174-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:60729 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750844AbbLCV54 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 16:57:56 -0500
In-Reply-To: <1449179874-49174-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

Enabling SR-IOV and then bringing the interface up was resulting in the PF
MAC addresses getting into a bad state.  Specifically the MAC address was
enabled for both VF 0 and the PF.  This resulted in some odd behaviors such
as VF 0 receiving a copy of the PFs traffic, which in turn enables the
ability for VF 0 to spoof the PF.

A workaround for this issue appears to be to bring up the interface first
and then enable SR-IOV as this way the reset is then triggered in the
existing code.

In order to correct this I have added a change to ixgbe_setup_tc where if
the interface is down we still will at least call ixgbe_reset so that the
MAC addresses for the device are reset to the correct pools.

Steps to reproduce issue:
modprobe ixgbe
echo 7 > /sys/bus/pci/devices/0000\:01\:00.1/sriov_numvfs
ifconfig enp1s0f1 up
ethregs -s 1:00.1 | grep MPSAR | grep -v 00000000

Result:
	MPSAR[0]               00000081
	MPSAR[254]             00000001

Expected Result, behavior after patch:
	MPSAR[0]               00000080
	MPSAR[254]             00000080

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Darin Miller <darin.j.miller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 47395ff..aed8d02 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7920,6 +7920,9 @@ int ixgbe_setup_tc(struct net_device *dev, u8 tc)
 	 */
 	if (netif_running(dev))
 		ixgbe_close(dev);
+	else
+		ixgbe_reset(adapter);
+
 	ixgbe_clear_interrupt_scheme(adapter);
 
 #ifdef CONFIG_IXGBE_DCB
-- 
2.5.0
