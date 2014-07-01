From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/14] i40evf: set flags before sending message
Date: Tue,  1 Jul 2014 04:35:02 -0700
Message-ID: <1404214511-26868-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1404214511-26868-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:7349 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752302AbaGALfQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jul 2014 07:35:16 -0400
In-Reply-To: <1404214511-26868-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Mitch Williams <mitch.a.williams@intel.com>

In some circumstances, the firmware could beat us to the punch, and the
reply from the PF would come back before we were able to properly modif=
y
the aq_pending and aq_required flags. This would mess up the flags and
put the driver in an indeterminate state, much like Schr=C3=B6dinger's =
cat.
However, unlike the cat, the driver is definitely dead.

To fix this, simply set the flags before sending the request to the AQ.
This way, it won't matter if the interrupt comes back too soon.

Change-ID: I9784655e475675ebcb3140cc7f36f4a96aaadce5
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    | 33 +++++++++++---=
--------
 1 file changed, 16 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/driv=
ers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index 0ed2ad7..66d12f5 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -248,11 +248,11 @@ void i40evf_configure_queues(struct i40evf_adapte=
r *adapter)
 		vqpi++;
 	}
=20
+	adapter->aq_pending |=3D I40EVF_FLAG_AQ_CONFIGURE_QUEUES;
+	adapter->aq_required &=3D ~I40EVF_FLAG_AQ_CONFIGURE_QUEUES;
 	i40evf_send_pf_msg(adapter, I40E_VIRTCHNL_OP_CONFIG_VSI_QUEUES,
 			   (u8 *)vqci, len);
 	kfree(vqci);
-	adapter->aq_pending |=3D I40EVF_FLAG_AQ_CONFIGURE_QUEUES;
-	adapter->aq_required &=3D ~I40EVF_FLAG_AQ_CONFIGURE_QUEUES;
 }
=20
 /**
@@ -275,10 +275,10 @@ void i40evf_enable_queues(struct i40evf_adapter *=
adapter)
 	vqs.vsi_id =3D adapter->vsi_res->vsi_id;
 	vqs.tx_queues =3D (1 << adapter->vsi_res->num_queue_pairs) - 1;
 	vqs.rx_queues =3D vqs.tx_queues;
-	i40evf_send_pf_msg(adapter, I40E_VIRTCHNL_OP_ENABLE_QUEUES,
-			   (u8 *)&vqs, sizeof(vqs));
 	adapter->aq_pending |=3D I40EVF_FLAG_AQ_ENABLE_QUEUES;
 	adapter->aq_required &=3D ~I40EVF_FLAG_AQ_ENABLE_QUEUES;
+	i40evf_send_pf_msg(adapter, I40E_VIRTCHNL_OP_ENABLE_QUEUES,
+			   (u8 *)&vqs, sizeof(vqs));
 }
=20
 /**
@@ -301,10 +301,10 @@ void i40evf_disable_queues(struct i40evf_adapter =
*adapter)
 	vqs.vsi_id =3D adapter->vsi_res->vsi_id;
 	vqs.tx_queues =3D (1 << adapter->vsi_res->num_queue_pairs) - 1;
 	vqs.rx_queues =3D vqs.tx_queues;
-	i40evf_send_pf_msg(adapter, I40E_VIRTCHNL_OP_DISABLE_QUEUES,
-			   (u8 *)&vqs, sizeof(vqs));
 	adapter->aq_pending |=3D I40EVF_FLAG_AQ_DISABLE_QUEUES;
 	adapter->aq_required &=3D ~I40EVF_FLAG_AQ_DISABLE_QUEUES;
+	i40evf_send_pf_msg(adapter, I40E_VIRTCHNL_OP_DISABLE_QUEUES,
+			   (u8 *)&vqs, sizeof(vqs));
 }
=20
 /**
@@ -352,11 +352,11 @@ void i40evf_map_queues(struct i40evf_adapter *ada=
pter)
 	vimi->vecmap[v_idx].txq_map =3D 0;
 	vimi->vecmap[v_idx].rxq_map =3D 0;
=20
+	adapter->aq_pending |=3D I40EVF_FLAG_AQ_MAP_VECTORS;
+	adapter->aq_required &=3D ~I40EVF_FLAG_AQ_MAP_VECTORS;
 	i40evf_send_pf_msg(adapter, I40E_VIRTCHNL_OP_CONFIG_IRQ_MAP,
 			   (u8 *)vimi, len);
 	kfree(vimi);
-	adapter->aq_pending |=3D I40EVF_FLAG_AQ_MAP_VECTORS;
-	adapter->aq_required &=3D ~I40EVF_FLAG_AQ_MAP_VECTORS;
 }
=20
 /**
@@ -413,12 +413,11 @@ void i40evf_add_ether_addrs(struct i40evf_adapter=
 *adapter)
 			f->add =3D false;
 		}
 	}
+	adapter->aq_pending |=3D I40EVF_FLAG_AQ_ADD_MAC_FILTER;
+	adapter->aq_required &=3D ~I40EVF_FLAG_AQ_ADD_MAC_FILTER;
 	i40evf_send_pf_msg(adapter, I40E_VIRTCHNL_OP_ADD_ETHER_ADDRESS,
 			   (u8 *)veal, len);
 	kfree(veal);
-	adapter->aq_pending |=3D I40EVF_FLAG_AQ_ADD_MAC_FILTER;
-	adapter->aq_required &=3D ~I40EVF_FLAG_AQ_ADD_MAC_FILTER;
-
 }
=20
 /**
@@ -475,11 +474,11 @@ void i40evf_del_ether_addrs(struct i40evf_adapter=
 *adapter)
 			kfree(f);
 		}
 	}
+	adapter->aq_pending |=3D I40EVF_FLAG_AQ_DEL_MAC_FILTER;
+	adapter->aq_required &=3D ~I40EVF_FLAG_AQ_DEL_MAC_FILTER;
 	i40evf_send_pf_msg(adapter, I40E_VIRTCHNL_OP_DEL_ETHER_ADDRESS,
 			   (u8 *)veal, len);
 	kfree(veal);
-	adapter->aq_pending |=3D I40EVF_FLAG_AQ_DEL_MAC_FILTER;
-	adapter->aq_required &=3D ~I40EVF_FLAG_AQ_DEL_MAC_FILTER;
 }
=20
 /**
@@ -536,10 +535,10 @@ void i40evf_add_vlans(struct i40evf_adapter *adap=
ter)
 			f->add =3D false;
 		}
 	}
-	i40evf_send_pf_msg(adapter, I40E_VIRTCHNL_OP_ADD_VLAN, (u8 *)vvfl, le=
n);
-	kfree(vvfl);
 	adapter->aq_pending |=3D I40EVF_FLAG_AQ_ADD_VLAN_FILTER;
 	adapter->aq_required &=3D ~I40EVF_FLAG_AQ_ADD_VLAN_FILTER;
+	i40evf_send_pf_msg(adapter, I40E_VIRTCHNL_OP_ADD_VLAN, (u8 *)vvfl, le=
n);
+	kfree(vvfl);
 }
=20
 /**
@@ -597,10 +596,10 @@ void i40evf_del_vlans(struct i40evf_adapter *adap=
ter)
 			kfree(f);
 		}
 	}
-	i40evf_send_pf_msg(adapter, I40E_VIRTCHNL_OP_DEL_VLAN, (u8 *)vvfl, le=
n);
-	kfree(vvfl);
 	adapter->aq_pending |=3D I40EVF_FLAG_AQ_DEL_VLAN_FILTER;
 	adapter->aq_required &=3D ~I40EVF_FLAG_AQ_DEL_VLAN_FILTER;
+	i40evf_send_pf_msg(adapter, I40E_VIRTCHNL_OP_DEL_VLAN, (u8 *)vvfl, le=
n);
+	kfree(vvfl);
 }
=20
 /**
--=20
1.9.3
