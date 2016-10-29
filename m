From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/17] i40e: Drop code for unsupported flow types
Date: Sat, 29 Oct 2016 00:30:46 -0700
Message-ID: <1477726258-111563-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1477726258-111563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:10260 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751055AbcJ2HbH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 29 Oct 2016 03:31:07 -0400
In-Reply-To: <1477726258-111563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

We cannot currently support SCTP in the hardware, and IPV4_FLOW is not used
anywhere by the software so we can go through and drop the functionality
related to these two flow types.

In addition we cannot support masking based on the protocol value so if the
user is expecting a value other than TCP or UDP we should simply return an
error rather then trying to allocate a filter for a rule that will only
partially match what the user requested.

Change-ID: I10d52bb97d8104d76255fe244551814ff9531a63
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 31 +++++------------------------
 1 file changed, 5 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index af36c44..7d160c9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -330,22 +330,6 @@ static int i40e_add_del_fdir_tcpv4(struct i40e_vsi *vsi,
 	return err ? -EOPNOTSUPP : 0;
 }
 
-/**
- * i40e_add_del_fdir_sctpv4 - Add/Remove SCTPv4 Flow Director filters for
- * a specific flow spec
- * @vsi: pointer to the targeted VSI
- * @fd_data: the flow director data required for the FDir descriptor
- * @add: true adds a filter, false removes it
- *
- * Returns 0 if the filters were successfully added or removed
- **/
-static int i40e_add_del_fdir_sctpv4(struct i40e_vsi *vsi,
-				    struct i40e_fdir_filter *fd_data,
-				    bool add)
-{
-	return -EOPNOTSUPP;
-}
-
 #define I40E_IP_DUMMY_PACKET_LEN 34
 /**
  * i40e_add_del_fdir_ipv4 - Add/Remove IPv4 Flow Director filters for
@@ -428,12 +412,6 @@ int i40e_add_del_fdir(struct i40e_vsi *vsi,
 	case UDP_V4_FLOW:
 		ret = i40e_add_del_fdir_udpv4(vsi, input, add);
 		break;
-	case SCTP_V4_FLOW:
-		ret = i40e_add_del_fdir_sctpv4(vsi, input, add);
-		break;
-	case IPV4_FLOW:
-		ret = i40e_add_del_fdir_ipv4(vsi, input, add);
-		break;
 	case IP_USER_FLOW:
 		switch (input->ip4_proto) {
 		case IPPROTO_TCP:
@@ -442,15 +420,16 @@ int i40e_add_del_fdir(struct i40e_vsi *vsi,
 		case IPPROTO_UDP:
 			ret = i40e_add_del_fdir_udpv4(vsi, input, add);
 			break;
-		case IPPROTO_SCTP:
-			ret = i40e_add_del_fdir_sctpv4(vsi, input, add);
-			break;
-		default:
+		case IPPROTO_IP:
 			ret = i40e_add_del_fdir_ipv4(vsi, input, add);
 			break;
+		default:
+			/* We cannot support masking based on protocol */
+			goto unsupported_flow;
 		}
 		break;
 	default:
+unsupported_flow:
 		dev_info(&pf->pdev->dev, "Could not specify spec type %d\n",
 			 input->flow_type);
 		ret = -EINVAL;
-- 
2.7.4
