From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/13] i40e: Fix static checker warning
Date: Wed,  5 Mar 2014 20:21:41 -0800
Message-ID: <1394079704-1108-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394079704-1108-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <Neerav.Parikh@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Kevin Scott <kevin.c.scott@intel.com>,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:39886 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753215AbaCFEVy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2014 23:21:54 -0500
In-Reply-To: <1394079704-1108-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <Neerav.Parikh@intel.com>

This patch fixes the following static checker warning:

  drivers/net/ethernet/intel/i40e/i40e_dcb.c:342
  i40e_lldp_to_dcb_config() warn: 'tlv' can't be NULL.

Exit criteria from the while loop is encountering LLDP END
LV or if the TLV length goes beyond the buffer length.

Change-ID: I7548b16db90230ec2ba0fa791b0343ca8b7dd5bb
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Neerav Parikh <Neerav.Parikh@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Kevin Scott <kevin.c.scott@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Tested-By: Jack Morgan<jack.morgan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_dcb.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_dcb.c b/drivers/net/ethernet/intel/i40e/i40e_dcb.c
index 5073014..036570d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_dcb.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_dcb.c
@@ -332,6 +332,7 @@ i40e_status i40e_lldp_to_dcb_config(u8 *lldpmib,
 	u16 type;
 	u16 length;
 	u16 typelength;
+	u16 offset = 0;
 
 	if (!lldpmib || !dcbcfg)
 		return I40E_ERR_PARAM;
@@ -339,15 +340,17 @@ i40e_status i40e_lldp_to_dcb_config(u8 *lldpmib,
 	/* set to the start of LLDPDU */
 	lldpmib += ETH_HLEN;
 	tlv = (struct i40e_lldp_org_tlv *)lldpmib;
-	while (tlv) {
+	while (1) {
 		typelength = ntohs(tlv->typelength);
 		type = (u16)((typelength & I40E_LLDP_TLV_TYPE_MASK) >>
 			     I40E_LLDP_TLV_TYPE_SHIFT);
 		length = (u16)((typelength & I40E_LLDP_TLV_LEN_MASK) >>
 			       I40E_LLDP_TLV_LEN_SHIFT);
+		offset += sizeof(typelength) + length;
 
-		if (type == I40E_TLV_TYPE_END)
-			break;/* END TLV break out */
+		/* END TLV or beyond LLDPDU size */
+		if ((type == I40E_TLV_TYPE_END) || (offset > I40E_LLDPDU_SIZE))
+			break;
 
 		switch (type) {
 		case I40E_TLV_TYPE_ORG:
-- 
1.8.3.1
