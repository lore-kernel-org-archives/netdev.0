From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [PATCH v2] ixgbe: check adapter->vfinfo before dereference
Date: Tue, 14 Oct 2014 23:18:35 +0000
Message-ID: <87618083B2453E4A8714035B62D67992500E19F5@FMSMSX105.amr.corp.intel.com>
References: <1412930732-892-1-git-send-email-thierry.herbelot@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Thierry Herbelot <thierry.herbelot@6wind.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:50914 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751303AbaJNXSi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 19:18:38 -0400
In-Reply-To: <1412930732-892-1-git-send-email-thierry.herbelot@6wind.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-
>owner@vger.kernel.org] On Behalf Of Thierry Herbelot
>Sent: Friday, October 10, 2014 1:46 AM
>To: Kirsher, Jeffrey T; Brandeburg, Jesse; Allan, Bruce W;
>netdev@vger.kernel.org
>Cc: Thierry Herbelot
>Subject: [PATCH v2] ixgbe: check adapter->vfinfo before
>dereference
>
>this protects against the following panic:
>(before a VF was actually created on p96p1 PF Ethernet port)
>ip link set p96p1 vf 0 spoofchk off
>BUG: unable to handle kernel NULL pointer dereference at
>0000000000000052
>IP: [<ffffffffa044a1c1>]
>ixgbe_ndo_set_vf_spoofchk+0x51/0x150 [ixgbe]
>
>Signed-off-by: Thierry Herbelot <thierry.herbelot@6wind.com>
>---
> drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |   73
>+++++++++++++++++++++++-
> 1 file changed, 70 insertions(+), 3 deletions(-)
>
>diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
>b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
>index 706fc69..29279ad 100644
>--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
>+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
>@@ -316,7 +316,7 @@ static int ixgbe_set_vf_multicasts(struct ixgbe_adapter *adapter,
> 	int entries = (msgbuf[0] & IXGBE_VT_MSGINFO_MASK)
> 		       >> IXGBE_VT_MSGINFO_SHIFT;
> 	u16 *hash_list = (u16 *)&msgbuf[1];
>-	struct vf_data_storage *vfinfo = &adapter->vfinfo[vf];
>+	struct vf_data_storage *vfinfo;
> 	struct ixgbe_hw *hw = &adapter->hw;
> 	int i;
> 	u32 vector_bit;
>@@ -324,6 +324,11 @@ static int
>ixgbe_set_vf_multicasts(struct ixgbe_adapter *adapter,
> 	u32 mta_reg;
> 	u32 vmolr = IXGBE_READ_REG(hw, IXGBE_VMOLR(vf));
>
>+	if (!adapter->vfinfo)
>+		return -1;
>+
>+	vfinfo = &adapter->vfinfo[vf];

This check makes sense for the ndo functions that get called by the ip command, but I don't think we need to add them before every use of adapter->vfinfo. In this case for example ixgbe_set_vf_multicasts() is called from
ixgbe_rcv_msg_from_vf() which will be called when an actual VF exists.

Also for the error -EINVAL probably makes more sense than -1.

Thanks,
Emil
