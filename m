From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [PATCH net-next v7 3/7] ixgbe: Add a RETA query command to
 VF-PF channel API
Date: Wed, 25 Mar 2015 18:03:47 +0000
Message-ID: <87618083B2453E4A8714035B62D6799250275A68@FMSMSX105.amr.corp.intel.com>
References: <1427202346-12502-1-git-send-email-vladz@cloudius-systems.com>
 <1427202346-12502-4-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"avi@cloudius-systems.com" <avi@cloudius-systems.com>,
	"gleb@cloudius-systems.com" <gleb@cloudius-systems.com>
To: Vlad Zolotarov <vladz@cloudius-systems.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:23525 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932159AbbCYSDu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 14:03:50 -0400
In-Reply-To: <1427202346-12502-4-git-send-email-vladz@cloudius-systems.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Vlad Zolotarov
>Sent: Tuesday, March 24, 2015 6:06 AM
>Subject: [PATCH net-next v7 3/7] ixgbe: Add a RETA query command to VF-PF channel API
>
>82599 and x540 VFs and PF share the same RSS redirection table (RETA). Therefore we
>just return it for all VFs. x550 on the other hand provides a separate redirection
>table for each VF (there is a per-pool RETA table).
>
>For 82599 and x540 RETA table is an array of 32 registers (128 bytes) and the maximum number of
>registers that may be delivered in a single VF-PF channel command is 15. Therefore
>we will deliver the whole table in 3 steps: 12, 12 and 8 registers in each
>step correspondingly.
>
>For x550 VFs RETA is a 64 byte array, so we may deliver it in two steps: 12 and 4 registers
>correspondingly.
>
>Thus this patch does the following:
>
>  - Adds a new API version (to specify a new commands set).
>  - Adds the IXGBE_VF_GET_RETA command to the VF-PF commands set.
>
>Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
>---

<snip>

+static int ixgbe_get_vf_reta(struct ixgbe_adapter *adapter, u32 *msgbuf, u32 vf)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	int i, j;
+	u32 *reta = &msgbuf[1];
+	u32 mask = 0;
+	u32 psrtype;
+	u32 reta_offset_dw = msgbuf[IXGBE_VF_RETA_OFFSET];
+	u32 dwords = msgbuf[IXGBE_VF_RETA_SZ];
+
+	/* verify the PF is supporting the correct API */
+	if (!adapter->vfinfo[vf].rss_query_enabled ||
+	    (adapter->vfinfo[vf].vf_api != ixgbe_mbox_api_12))
+		return -EPERM;
+
+	psrtype = IXGBE_READ_REG(hw, IXGBE_PSRTYPE(vf));
+
+	/* The redirection table is composed as follows:
+	 * 82598: 128 (8 bit wide) entries containing pair of 4 bit RSS indices
+	 * 82599/X540: 128 (8 bit wide) entries containing 4 bit RSS index X550:
+	 * 512 (8 bit wide) entries containing 6 bit RSS index
+	 *
+	 * PSRTYPE[n].RQPL defines if 0, 1 or 2 bits from the redirection table
+	 * value should be used.
+	 */
+
+	if ((psrtype & (1 << 29)) == (1 << 29))
+		mask = 0x01010101;
+	else if ((psrtype & (2 << 29)) == (2 << 29))
+		mask = 0x03030303;
+	else
+		mask = 0;
+
+	switch (hw->mac.type) {
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
+		/* Read the appropriate portion of RETA */
+		for (i = 0; i < dwords; i++)
+			reta[i] = IXGBE_READ_REG(hw,
+						IXGBE_RETA(i + reta_offset_dw));
+		break;
+	case ixgbe_mac_X550:
+	case ixgbe_mac_X550EM_x:
+		/* X550 has a per-VF RETA */
+		for (i = 0, j = reta_offset_dw; i < dwords; i++, j++)
+			reta[i] = IXGBE_READ_REG(hw,
+						IXGBE_PFVFRETA(j, vf));
+		break;
+	default:
+		return -1;

There is no need to query the X550 info through the mailbox - this information can be obtained directly from the VF registers.

Thanks,
Emil
