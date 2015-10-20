From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net PATCH v2] ixgbe: Reset interface after enabling SR-IOV
Date: Tue, 20 Oct 2015 13:28:17 -0700
Message-ID: <20151020202715.2955.88128.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34881 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751789AbbJTU2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 16:28:18 -0400
Received: by pasz6 with SMTP id z6so31054748pas.2
        for <netdev@vger.kernel.org>; Tue, 20 Oct 2015 13:28:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
---

This is also a candidate for stable going back to 3.9 kernel as that
appears to be where the code for using ixgbe_setup_tc as a part of the
SR-IOV initialization was introduced.

v2: Replaced dev with adapter as parameter for ixgbe_reset().

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 191003901adb..7831346b483d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7912,6 +7912,9 @@ int ixgbe_setup_tc(struct net_device *dev, u8 tc)
 	 */
 	if (netif_running(dev))
 		ixgbe_close(dev);
+	else
+		ixgbe_reset(adapter);
+
 	ixgbe_clear_interrupt_scheme(adapter);
 
 #ifdef CONFIG_IXGBE_DCB
