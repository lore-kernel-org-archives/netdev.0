From: Thomas Klein <osstklei@de.ibm.com>
Subject: [PATCH 2.6.22-rc4] ehea: Fixed possible kernel panic on VLAN packet recv
Date: Wed, 6 Jun 2007 20:53:16 +0200
Message-ID: <200706062053.16986.osstklei@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <ossthema@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <ossrosch@linux.vnet.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:51271 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758843AbXFFSxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 14:53:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes a possible kernel panic due to not checking the vlan group
when processing received VLAN packets and a malfunction in VLAN/hypervisor
registration.


Signed-off-by: Thomas Klein <tklein@de.ibm.com>
---


diff -Nurp -X dontdiff linux-2.6.22-rc4/drivers/net/ehea/ehea.h patched_kernel/drivers/net/ehea/ehea.h
--- linux-2.6.22-rc4/drivers/net/ehea/ehea.h	2007-06-05 02:57:25.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea.h	2007-06-06 12:53:58.000000000 +0200
@@ -39,7 +39,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0061"
+#define DRV_VERSION	"EHEA_0064"
 
 #define EHEA_MSG_DEFAULT (NETIF_MSG_LINK | NETIF_MSG_TIMER \
 	| NETIF_MSG_RX_ERR | NETIF_MSG_TX_ERR)
diff -Nurp -X dontdiff linux-2.6.22-rc4/drivers/net/ehea/ehea_main.c patched_kernel/drivers/net/ehea/ehea_main.c
--- linux-2.6.22-rc4/drivers/net/ehea/ehea_main.c	2007-06-05 02:57:25.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea_main.c	2007-06-06 12:53:58.000000000 +0200
@@ -451,7 +451,8 @@ static struct ehea_cqe *ehea_proc_rwqes(
 				processed_rq3++;
 			}
 
-			if (cqe->status & EHEA_CQE_VLAN_TAG_XTRACT)
+			if ((cqe->status & EHEA_CQE_VLAN_TAG_XTRACT)
+			    && port->vgrp)
 				vlan_hwaccel_receive_skb(skb, port->vgrp,
 							 cqe->vlan_tag);
 			else
@@ -1910,10 +1911,7 @@ static void ehea_vlan_rx_register(struct
 		goto out;
 	}
 
-	if (grp)
-		memset(cb1->vlan_filter, 0, sizeof(cb1->vlan_filter));
-	else
-		memset(cb1->vlan_filter, 0xFF, sizeof(cb1->vlan_filter));
+	memset(cb1->vlan_filter, 0, sizeof(cb1->vlan_filter));
 
 	hret = ehea_h_modify_ehea_port(adapter->handle, port->logical_port_id,
 				       H_PORT_CB1, H_PORT_CB1_ALL, cb1);
@@ -1947,7 +1945,7 @@ static void ehea_vlan_rx_add_vid(struct 
 	}
 
 	index = (vid / 64);
-	cb1->vlan_filter[index] |= ((u64)(1 << (vid & 0x3F)));
+	cb1->vlan_filter[index] |= ((u64)(0x8000000000000000 >> (vid & 0x3F)));
 
 	hret = ehea_h_modify_ehea_port(adapter->handle, port->logical_port_id,
 				       H_PORT_CB1, H_PORT_CB1_ALL, cb1);
@@ -1982,7 +1980,7 @@ static void ehea_vlan_rx_kill_vid(struct
 	}
 
 	index = (vid / 64);
-	cb1->vlan_filter[index] &= ~((u64)(1 << (vid & 0x3F)));
+	cb1->vlan_filter[index] &= ~((u64)(0x8000000000000000 >> (vid & 0x3F)));
 
 	hret = ehea_h_modify_ehea_port(adapter->handle, port->logical_port_id,
 				       H_PORT_CB1, H_PORT_CB1_ALL, cb1);

