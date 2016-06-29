From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/16] i40evf: don't overflow buffer
Date: Tue, 28 Jun 2016 21:40:51 -0700
Message-ID: <1467175262-54719-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:22102 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751003AbcF2EnR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 00:43:17 -0400
In-Reply-To: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

If the user adds an obscene amount of MAC addresses, the driver will run
into the situation where it has too many address requests to fit into a
single PF message. The driver checks for this case, and calculates the
maximum number of messages that it can send. Then it completely ignores
this count and overflows the buffer.

Fix this by checking the address count and bailing out of the loop at
the appropriate time.

Change-ID: If8dcbb04602c75941dc0cd8309065e1de9ca791c
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index f134456..d76c221 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -434,6 +434,8 @@ void i40evf_add_ether_addrs(struct i40evf_adapter *adapter)
 			ether_addr_copy(veal->list[i].addr, f->macaddr);
 			i++;
 			f->add = false;
+			if (i == count)
+				break;
 		}
 	}
 	if (!more)
@@ -497,6 +499,8 @@ void i40evf_del_ether_addrs(struct i40evf_adapter *adapter)
 			i++;
 			list_del(&f->list);
 			kfree(f);
+			if (i == count)
+				break;
 		}
 	}
 	if (!more)
@@ -560,6 +564,8 @@ void i40evf_add_vlans(struct i40evf_adapter *adapter)
 			vvfl->vlan_id[i] = f->vlan;
 			i++;
 			f->add = false;
+			if (i == count)
+				break;
 		}
 	}
 	if (!more)
@@ -623,6 +629,8 @@ void i40evf_del_vlans(struct i40evf_adapter *adapter)
 			i++;
 			list_del(&f->list);
 			kfree(f);
+			if (i == count)
+				break;
 		}
 	}
 	if (!more)
-- 
2.5.5
