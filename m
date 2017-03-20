From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/13] i40e: return immediately when failing to add fdir filter
Date: Mon, 20 Mar 2017 16:47:05 -0700
Message-ID: <20170320234712.84157-7-jeffrey.t.kirsher@intel.com>
References: <20170320234712.84157-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:59023 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755916AbdCTXrU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 19:47:20 -0400
In-Reply-To: <20170320234712.84157-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Instead of setting err=true and checking this to determine when to free
the raw_packet near the end of the function, simply kfree and return
immediately. The resulting code is a bit cleaner and has one less
variable. This also resolves a subtle bug in the ipv4 case which could
fail to add the first filter and then never free the memory, resulting
in a small memory leak.

Change-ID: I7583aac033481dc794b4acaa14445059c8930ff1
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Reviewed-by: Avinash Dayanand <avinash.dayanand@intel.com>
Reviewed-by: Alan Brady <alan.brady@intel.com>
Reviewed-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 33 ++++++++++++-----------------
 1 file changed, 14 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index c4d3a40a3f10..005257b4f218 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -203,7 +203,6 @@ static int i40e_add_del_fdir_udpv4(struct i40e_vsi *vsi,
 	struct i40e_pf *pf = vsi->back;
 	struct udphdr *udp;
 	struct iphdr *ip;
-	bool err = false;
 	u8 *raw_packet;
 	int ret;
 	static char packet[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0x08, 0,
@@ -230,7 +229,9 @@ static int i40e_add_del_fdir_udpv4(struct i40e_vsi *vsi,
 		dev_info(&pf->pdev->dev,
 			 "PCTYPE:%d, Filter command send failed for fd_id:%d (ret = %d)\n",
 			 fd_data->pctype, fd_data->fd_id, ret);
-		err = true;
+		/* Free the packet buffer since it wasn't added to the ring */
+		kfree(raw_packet);
+		return -EOPNOTSUPP;
 	} else if (I40E_DEBUG_FD & pf->hw.debug_mask) {
 		if (add)
 			dev_info(&pf->pdev->dev,
@@ -241,10 +242,8 @@ static int i40e_add_del_fdir_udpv4(struct i40e_vsi *vsi,
 				 "Filter deleted for PCTYPE %d loc = %d\n",
 				 fd_data->pctype, fd_data->fd_id);
 	}
-	if (err)
-		kfree(raw_packet);
 
-	return err ? -EOPNOTSUPP : 0;
+	return 0;
 }
 
 #define I40E_TCPIP_DUMMY_PACKET_LEN 54
@@ -263,7 +262,6 @@ static int i40e_add_del_fdir_tcpv4(struct i40e_vsi *vsi,
 	struct i40e_pf *pf = vsi->back;
 	struct tcphdr *tcp;
 	struct iphdr *ip;
-	bool err = false;
 	u8 *raw_packet;
 	int ret;
 	/* Dummy packet */
@@ -305,12 +303,13 @@ static int i40e_add_del_fdir_tcpv4(struct i40e_vsi *vsi,
 
 	fd_data->pctype = I40E_FILTER_PCTYPE_NONF_IPV4_TCP;
 	ret = i40e_program_fdir_filter(fd_data, raw_packet, pf, add);
-
 	if (ret) {
 		dev_info(&pf->pdev->dev,
 			 "PCTYPE:%d, Filter command send failed for fd_id:%d (ret = %d)\n",
 			 fd_data->pctype, fd_data->fd_id, ret);
-		err = true;
+		/* Free the packet buffer since it wasn't added to the ring */
+		kfree(raw_packet);
+		return -EOPNOTSUPP;
 	} else if (I40E_DEBUG_FD & pf->hw.debug_mask) {
 		if (add)
 			dev_info(&pf->pdev->dev, "Filter OK for PCTYPE %d loc = %d)\n",
@@ -321,10 +320,7 @@ static int i40e_add_del_fdir_tcpv4(struct i40e_vsi *vsi,
 				 fd_data->pctype, fd_data->fd_id);
 	}
 
-	if (err)
-		kfree(raw_packet);
-
-	return err ? -EOPNOTSUPP : 0;
+	return 0;
 }
 
 #define I40E_IP_DUMMY_PACKET_LEN 34
@@ -343,7 +339,6 @@ static int i40e_add_del_fdir_ipv4(struct i40e_vsi *vsi,
 {
 	struct i40e_pf *pf = vsi->back;
 	struct iphdr *ip;
-	bool err = false;
 	u8 *raw_packet;
 	int ret;
 	int i;
@@ -365,12 +360,15 @@ static int i40e_add_del_fdir_ipv4(struct i40e_vsi *vsi,
 
 		fd_data->pctype = i;
 		ret = i40e_program_fdir_filter(fd_data, raw_packet, pf, add);
-
 		if (ret) {
 			dev_info(&pf->pdev->dev,
 				 "PCTYPE:%d, Filter command send failed for fd_id:%d (ret = %d)\n",
 				 fd_data->pctype, fd_data->fd_id, ret);
-			err = true;
+			/* The packet buffer wasn't added to the ring so we
+			 * need to free it now.
+			 */
+			kfree(raw_packet);
+			return -EOPNOTSUPP;
 		} else if (I40E_DEBUG_FD & pf->hw.debug_mask) {
 			if (add)
 				dev_info(&pf->pdev->dev,
@@ -383,10 +381,7 @@ static int i40e_add_del_fdir_ipv4(struct i40e_vsi *vsi,
 		}
 	}
 
-	if (err)
-		kfree(raw_packet);
-
-	return err ? -EOPNOTSUPP : 0;
+	return 0;
 }
 
 /**
-- 
2.12.0
