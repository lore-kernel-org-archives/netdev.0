From: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Subject: i40e: driver can't probe device (capabilities discovery error)
Date: Wed, 8 Feb 2017 14:31:58 -0200
Message-ID: <64ac2d0b-7685-4adb-a0e4-2ab7bfd6975e@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------0DB768661D23E6149FC4FA92"
Cc: netdev <netdev@vger.kernel.org>,
        Brian King <brking@linux.vnet.ibm.com>,
        alexander.h.duyck@intel.com,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Murilo pIO <muvic@linux.vnet.ibm.com>,
        maurosr@linux.vnet.ibm.com, gpiccoli@linux.vnet.ibm.com
To: "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:50645 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754282AbdBHQcT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 11:32:19 -0500
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v18GTIPS139700
        for <netdev@vger.kernel.org>; Wed, 8 Feb 2017 11:32:13 -0500
Received: from e24smtp02.br.ibm.com (e24smtp02.br.ibm.com [32.104.18.86])
        by mx0a-001b2d01.pphosted.com with ESMTP id 28g555dmtu-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 11:32:13 -0500
Received: from localhost
        by e24smtp02.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gpiccoli@linux.vnet.ibm.com>;
        Wed, 8 Feb 2017 14:32:10 -0200
Received: from d24relay03.br.ibm.com (d24relay03.br.ibm.com [9.18.232.225])
        by d24dlp02.br.ibm.com (Postfix) with ESMTP id 3DDD11DC006F
        for <netdev@vger.kernel.org>; Wed,  8 Feb 2017 11:32:09 -0500 (EST)
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
        by d24relay03.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v18GW8fe34472132
        for <netdev@vger.kernel.org>; Wed, 8 Feb 2017 14:32:08 -0200
Received: from d24av04.br.ibm.com (localhost [127.0.0.1])
        by d24av04.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v18GW7Tv019712
        for <netdev@vger.kernel.org>; Wed, 8 Feb 2017 14:32:07 -0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------0DB768661D23E6149FC4FA92
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

Recently we had a sudden fail on Intel XL710 adapter, in which the i40e
driver is not able to probe the device anymore - it fails right on the
beginning of the probe process, on discovery capabilities procedure. We
observed the following messages on kernel (v4.10-rc7) log:


i40e: Intel(R) Ethernet Connection XL710 Network Driver - version 1.6.25-k
i40e: Copyright (c) 2013 - 2014 Intel Corporation.
i40e 0002:01:00.0: Using 64-bit DMA iommu bypass
i40e 0002:01:00.0: fw 5.1.40981 api 1.5 nvm 5.03 0x80002469 1.1313.0
i40e 0002:01:00.0: capability discovery failed, err OK aq_err
I40E_AQ_RC_EMODE
i40e 0002:01:00.1: Using 64-bit DMA iommu bypass
i40e 0002:01:00.1: fw 5.1.40981 api 1.5 nvm 5.03 0x80002469 1.1313.0
i40e 0002:01:00.1: capability discovery failed, err OK aq_err
I40E_AQ_RC_EMODE

<and the same messages on functions .2 and .3 too>


We were able to "revive" the adapter using one of the following 2
procedures:

i) PowerPC systems have a feature called EEH, that is a PCI slot reset
in essence. It's something in HW/PHB level, so the mechanism does a slot
reset, that can be a PCI Hot Reset or Fundamental Reset (PERST).

The 1st way to recover the adapter was to inject an error on this slot
and forcing a called "hotplug recovery". Basically, we removed the
adapter from the PCI core (echo 1 >
/sys/bus/pci/devices/0002:01:00.*/remove), then we froze the PHB
transactions (using a debug facility on powerpc kernel) and then we do a
rescan on PCI bus (echo 1 > /sys/bus/pci/rescan).

This led to Hot Reset on slot, and adapter recovered fine, i40e driver
was able to complete the probe procedure. I can provide full logs if
desired.
Although I think this is too hacky way...

ii) With the attached patch, we were able to "partially" circumvent the
issue. Basically, the probe procedure worked fine to all device
functions, but on function 3 we failed in eeprom check - the following
messages were observed in the kernel log:

[29.1126] i40e 0002:01:00.3: Using 64-bit DMA iommu bypass
[32.3530] i40e 0002:01:00.3: fw 5.1.40981 api 1.5 nvm 5.03 0x24695003
192.0.63
[32.8441] i40e 0002:01:00.3: eeprom check failed (-2), Tx/Rx traffic
disabled
[32.8583] i40e 0002:01:00.3: MAC address: 0c:c4:7a:89:f1:c3
[32.8712] i40e 0002:01:00.3: MSI-X vector limit reached, attempting to
redistribute vectors
[32.9765] i40e 0002:01:00.3: Added LAN device PF3 bus=0x00 func=0x03
[32.9766] i40e 0002:01:00.3: PCI-Express: Speed 8.0GT/s Width x8
[32.9867] i40e 0002:01:00.3: Features: PF-id[3] VFs: 32 VSIs: 34 QP: 119
RSS FD_ATR FD_SB NTUPLE DCB VxLAN Geneve PTP VEPA


All the other 3 functions presented the same messages except the eeprom
check failed.
I'm aware the patch needs some rework (in my understanding, the logic
works only to a single adapter, because we need a global reset only in
one function of the adapter. But the patch logic fails if we have more
than 1 physical adapter on machine. It's just a draft/RFC version for now).
--

So, I'd like to request help/feedback from you regarding what's going
on. I'm not sure the root cause of the sudden adapter failure. In one
day it was fine, and in the other, after a machine reboot, it entered in
this odd state. We have 2 machines presenting this behavior and 5 others
that are fine.

Is there a way to clear this bad state on the adapter, like a special
reset (or even a jumper that we should play physically)? I tried EMP
reset too, but seems it's not allowed for some reason (perhaps only in
NVM update mode? Not sure). Also, any pointers on how to understand the
root cause are welcome.
Thanks in advance,


Guilherme

--------------0DB768661D23E6149FC4FA92
Content-Type: text/x-patch;
 name="0001-i40-force-global-reset-on-adapter-probe.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0001-i40-force-global-reset-on-adapter-probe.patch"

>From 1a49e453816dbab747788b87f9d03edc978cb50b Mon Sep 17 00:00:00 2001
From: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Date: Tue, 7 Feb 2017 17:38:04 -0200
Subject: [PATCH] i40: force global reset on adapter probe

Device might experience a bad state on probe time, making impossible
to the function i40e_probe() to successfully complete.

In these cases, for example we observed the following message in
kernel log:

  [22.6397] i40e 0002:01:00.0: capability discovery failed, err OK aq_err I40E_AQ_RC_EMODE

This patch forces a global reset to happen on driver probe to avoid
the issue.

Signed-off-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index ad4cf63..f686c4a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -10928,7 +10928,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	static u16 pfs_found;
 	u16 wol_nvm_bits;
 	u16 link_status;
-	int err;
+	int err, globr_probe = 1;
 	u32 val;
 	u32 i;
 	u8 set_fc_aq_fail;
@@ -11009,6 +11009,11 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (debug < -1)
 		pf->hw.debug_mask = debug;
 
+	if (globr_probe) {
+		i40e_do_reset_safe(pf, BIT(__I40E_GLOBAL_RESET_REQUESTED));
+		globr_probe = 0;
+	}
+
 	/* do a special CORER for clearing PXE mode once at init */
 	if (hw->revision_id == 0 &&
 	    (rd32(hw, I40E_GLLAN_RCTL_0) & I40E_GLLAN_RCTL_0_PXE_MODE_MASK)) {
-- 
2.7.4




--------------0DB768661D23E6149FC4FA92--
