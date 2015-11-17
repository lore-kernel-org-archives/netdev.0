From: Stephen Hemminger <shemming@brocade.com>
Subject: [PATCH] hdlc: fix null-deref on allocation failure
Date: Tue, 17 Nov 2015 14:26:06 -0800
Message-ID: <20151117142606.4a0ca2d1@samsung9>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:28091 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751694AbbKQW0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 17:26:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If alloc_netdev() failed and return NULL, then the next instruction
would dereference it. Found by Coverity.

Compile tested only. Not sure if anyone still uses this driver
(or the whole WAN subsystem).

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/wan/hdlc_fr.c	2015-08-18 17:45:21.414525304 -0700
+++ b/drivers/net/wan/hdlc_fr.c	2015-11-16 09:50:07.317597825 -0800
@@ -1075,11 +1075,10 @@ static int fr_add_pvc(struct net_device
 
 	used = pvc_is_used(pvc);
 
-	if (type == ARPHRD_ETHER) {
+	if (type == ARPHRD_ETHER)
 		dev = alloc_netdev(0, "pvceth%d", NET_NAME_UNKNOWN,
 				   ether_setup);
-		dev->priv_flags &= ~IFF_TX_SKB_SHARING;
-	} else
+	else
 		dev = alloc_netdev(0, "pvc%d", NET_NAME_UNKNOWN, pvc_setup);
 
 	if (!dev) {
@@ -1088,9 +1087,10 @@ static int fr_add_pvc(struct net_device
 		return -ENOBUFS;
 	}
 
-	if (type == ARPHRD_ETHER)
+	if (type == ARPHRD_ETHER) {
+		dev->priv_flags &= ~IFF_TX_SKB_SHARING;
 		eth_hw_addr_random(dev);
-	else {
+	} else {
 		*(__be16*)dev->dev_addr = htons(dlci);
 		dlci_to_q922(dev->broadcast, dlci);
 	}
