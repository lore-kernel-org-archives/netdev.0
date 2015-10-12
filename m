From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [PATCH 0/5] be2net: patch set
Date: Mon, 12 Oct 2015 03:47:16 -0400
Message-ID: <1444636041-4727-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:50637 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751538AbbJLH53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 03:57:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch 1 fixes a FW image compatibility check in the driver that
prevents certain FW images from being flashed on BE3 (not BE3-R)
adapters.

Patch 2 fixes a spin_lock not being released in a failure case in
be_cmd_notify_wait().

Patch 3 includes a workaround to pad packets that are only 32b long or less
to be applicabe to BE3 too. This workaround was currently applied only to
Skyhawk and Lancer chips. Such packets are causing BE3's TX path to stall
on a SR-IOV config.

Patch 4 fixes the be_cmd_get_profile_config() routine to set the pf_num
field in the cmd request. The FW requires this field to be set for it to
return the specific function's descriptors. If not set, the FW returns
the descriptors of all the functions on the device. If the first descriptor
is not what is being queried for, the driver will read wrong data.
This patch fixes this issue by using the GET_CNTL_ATTRIB cmd to query the
real pci_func_num of a function and then uses it in the GET_PROFILE_CONFIG
cmd.

Patch 5 completes an earlier fix that removed the vlan promisc capability
for VFs. The earlier fix did not update the removal of this capability from
the profile descriptor of the VF. This causes the VF driver to request this
capability when it tries to create it's interface at probe time. This could
potentailly cause the VF probe to fail if the FW enforces strict checking of
the flags based on what was provisoned by the PF.  This strict checking is
not being done by FW currently but will be fixed in a future version. This
patch fixes this issue by updating the VF's profile descriptor so that they
match the interface capability flags provisioned by the PF.

Pls consider adding these patches to the net tree. Thanks!

Kalesh AP (2):
  be2net: fix BE3-R FW download compatibility check
  be2net: remove vlan promisc capability from VF's profile descriptors

Somnath Kotur (1):
  be2net: set pci_func_num while issuing GET_PROFILE_CONFIG cmd

Suresh Reddy (2):
  be2net: release mcc-lock in a failure case in be_cmd_notify_wait()
  be2net: pad skb to meet minimum TX pkt size in BE3

 drivers/net/ethernet/emulex/benet/be.h      |  1 +
 drivers/net/ethernet/emulex/benet/be_cmds.c | 31 ++++++++++++++++++++++-------
 drivers/net/ethernet/emulex/benet/be_cmds.h | 10 ++++++++--
 drivers/net/ethernet/emulex/benet/be_main.c | 28 +++++++++++++++++---------
 4 files changed, 52 insertions(+), 18 deletions(-)

-- 
2.4.1
