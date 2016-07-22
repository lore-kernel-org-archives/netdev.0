From: Sathya Perla <sathya.perla@broadcom.com>
Subject: [net-next PATCH 0/4] be2net: patch set
Date: Fri, 22 Jul 2016 06:55:42 -0400
Message-ID: <1469184946-26309-1-git-send-email-sathya.perla@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [192.19.245.250] ([192.19.245.250]:20969 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753788AbcGVK4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2016 06:56:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David, pls consider applying this patch-set to the net-next tree.

Patch 1 fixes the driver to workaournd a bug in the Lancer FW in the
vlan-config cmd processing. The FW in some cases clears the vlan-promisc
setting even if it cannot apply the vlan filter. The driver has no means
of knowing if the vlan-promisc setting has been cleared or not. This
patch now explicitly clears the vlan-promisc setting via the RX-Filter cmd
and then tries to program the vlan-list.

Patch 2 fixes the failure path in the vlan vid add code. 
The driver currently removes a new vid from the adapter->vids[] array if
be_vid_config() returns an error, which occurs when there is an error in
HW/FW. This is wrong. After the HW/FW error is recovered from, we need the
complete vids[] array to re-program the vlan list.

Patch 3 fixes the ndo_set_rx_mode() path to avoid unnecessary multicast
list updates to the FW. Each time the ndo_set_rx_mode() routine is called,
the driver programs the multicast list in the adapter without checking
if there are any changes to the list. This leads to a flood of RX_FILTER
cmds when a number of vlan interfaces are configured over the device,
as the ndo_ gets called for each vlan interface. To avoid this, we now
use __dev_mc_sync() and __dev_uc_sync() API, but only to detect if there
is a change in the mc/uc lists. Now that we use this API, the code has to
be-designed to issue these API calls for each invocation of the ndo_ call.

Patch 4 replaces polling with sleeping in the FW completion path.
The ndo_set_rx_mode() and ndo_add/del_vxlan_port() calls may be called with
BHs disabled. The driver currently issues the required cmds to the FW in
these contexts and polls on completions from the FW, while BHs remain
disabled.  This can cause either packet loss or packet reception to be
delayed on that CPU.  This patch defers processing of the above cmds to a
separate workqueue. With this change, FW cmds are now issued only in process
context. Now that the FW cmds are issued only in process context, they can
sleep waiting for a completion instead of polling.

Sathya Perla (2):
  be2net: do not remove vids from driver table if be_vid_config() fails.
  be2net: replace polling with sleeping in the FW completion path

Somnath Kotur (1):
  be2net: clear vlan-promisc setting before programming the vlan list

Sriharsha Basavapatna (1):
  be2net: Avoid unnecessary firmware updates of multicast list

 drivers/net/ethernet/emulex/benet/be.h      |  21 +-
 drivers/net/ethernet/emulex/benet/be_cmds.c | 202 ++++++-------
 drivers/net/ethernet/emulex/benet/be_main.c | 422 ++++++++++++++++++++++------
 3 files changed, 450 insertions(+), 195 deletions(-)

-- 
2.4.1
