From: "Dave Johnson" <djohnson+linux-kernel@sw.starentnetworks.com>
Subject: [PATCH 2/2] NET: Re-add VLAN tag for devices incapable of keeping it
Date: Mon, 5 Nov 2007 12:47:04 -0500
Message-ID: <18223.22296.654548.764588@zeus.sw.starentnetworks.com>
References: <472A49BD.6000802@hp.com>
	<20071101.145956.63020380.davem@davemloft.net>
	<472A4D5C.2070301@hp.com>
	<20071101.150723.30590053.davem@davemloft.net>
	<472A6089.7020104@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, jes@trained-monkey.org,
	mchan@broadcom.com, ram.vepa@neterion.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bguo@sw.starentnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.starentnetworks.com ([12.38.223.203]:54170 "EHLO
	mx0.starentnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753049AbXKERrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 12:47:10 -0500
In-Reply-To: <472A6089.7020104@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch changes the following drivers to use vlan_hwaccel_rx()
and/or vlan_hwaccel_receive_skb() with a NULL vlan group if needed as
they are not setup to dynamically enable/disable vlan removal in
their MAC based on the vlan group:

drivers/net/tg3.c           Tested on BCM5704, looks good
drivers/net/bnx2.c          Tested on BCM5708, looks good
drivers/net/acenic.c        Not tested, I don't have one of these
drivers/net/s2io.c          Not tested, I don't have one of these

In addition, these drivers might also need changes, but should
probably be done by the maintainer as it's not clear exactly what
change is needed:

drivers/net/amd8111e.c
drivers/net/cxgb3/*

Signed-off-by: Dave Johnson <djohnson@sw.starentnetworks.com>

===== drivers/net/acenic.c 1.77 vs edited =====
--- 1.77/drivers/net/acenic.c	2007-07-24 16:28:41 -04:00
+++ edited/drivers/net/acenic.c	2007-11-03 12:27:40 -04:00
@@ -2036,7 +2036,7 @@
 
 		/* send it up */
 #if ACENIC_DO_VLAN
-		if (ap->vlgrp && (bd_flags & BD_FLG_VLAN_TAG)) {
+		if (bd_flags & BD_FLG_VLAN_TAG) {
 			vlan_hwaccel_rx(skb, ap->vlgrp, retdesc->vlan);
 		} else
 #endif
===== drivers/net/bnx2.c 1.135 vs edited =====
--- 1.135/drivers/net/bnx2.c	2007-09-20 15:14:21 -04:00
+++ edited/drivers/net/bnx2.c	2007-11-05 09:34:26 -05:00
@@ -2493,7 +2493,8 @@
 		}
 
 #ifdef BCM_VLAN
-		if ((status & L2_FHDR_STATUS_L2_VLAN_TAG) && (bp->vlgrp != 0)) {
+		if ((status & L2_FHDR_STATUS_L2_VLAN_TAG) &&
+		    (bp->vlgrp || (bp->flags & ASF_ENABLE_FLAG))) {
 			vlan_hwaccel_receive_skb(skb, bp->vlgrp,
 				rx_hdr->l2_fhdr_vlan_tag);
 		}
===== drivers/net/s2io.c 1.124 vs edited =====
--- 1.124/drivers/net/s2io.c	2007-08-03 18:10:44 -04:00
+++ edited/drivers/net/s2io.c	2007-11-03 12:29:09 -04:00
@@ -6834,8 +6834,7 @@
 	sp->mac_control.stats_info->sw_stat.mem_freed += skb->truesize;
 	if (!sp->lro) {
 		skb->protocol = eth_type_trans(skb, dev);
-		if ((sp->vlgrp && RXD_GET_VLAN_TAG(rxdp->Control_2) &&
-			vlan_strip_flag)) {
+		if (RXD_GET_VLAN_TAG(rxdp->Control_2) && vlan_strip_flag) {
 			/* Queueing the vlan frame to the upper layer */
 			if (napi)
 				vlan_hwaccel_receive_skb(skb, sp->vlgrp,
===== drivers/net/tg3.c 1.523 vs edited =====
--- 1.523/drivers/net/tg3.c	2007-09-11 04:28:44 -04:00
+++ edited/drivers/net/tg3.c	2007-11-05 09:38:33 -05:00
@@ -3417,7 +3417,7 @@
 
 		skb->protocol = eth_type_trans(skb, tp->dev);
 #if TG3_VLAN_TAG_USED
-		if (tp->vlgrp != NULL &&
+		if ((tp->vlgrp || (tp->tg3_flags & TG3_FLAG_ENABLE_ASF)) &&
 		    desc->type_flags & RXD_FLAG_VLAN) {
 			tg3_vlan_rx(tp, skb,
 				    desc->err_vlan & RXD_VLAN_MASK);

