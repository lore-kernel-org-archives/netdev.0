From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH] vxlan: Update vxlan fdb 'used' field after each usage.
Date: Thu, 16 May 2013 10:05:43 -0700
Message-ID: <1368723943.14093.4.camel@sridhar.usor.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org, dlstevens@us.ibm.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:37783 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752146Ab3EPRJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 13:09:03 -0400
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sri@us.ibm.com>;
	Thu, 16 May 2013 11:09:02 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id A816C3E40062
	for <netdev@vger.kernel.org>; Thu, 16 May 2013 11:05:45 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4GH5jaB057046
	for <netdev@vger.kernel.org>; Thu, 16 May 2013 11:05:50 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4GH8jei001194
	for <netdev@vger.kernel.org>; Thu, 16 May 2013 11:08:46 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix some instances where vxlan fdb 'used' field is not updated after the entry 
is used.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index ba81f3c..3bfa6c4 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -814,6 +814,7 @@ static int arp_reduce(struct net_device *dev, struct sk_buff *skb)
 
 		f = vxlan_find_mac(vxlan, n->ha);
 		if (f && f->remote.remote_ip == htonl(INADDR_ANY)) {
+			f->used = jiffies;
 			/* bridge-local neighbor */
 			neigh_release(n);
 			goto out;
@@ -1118,6 +1119,7 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (f && (f->flags & NTF_ROUTER) && (vxlan->flags & VXLAN_F_RSC) &&
 	    ntohs(eth->h_proto) == ETH_P_IP) {
+		f->used = jiffies;
 		did_rsc = route_shortcircuit(dev, skb);
 		if (did_rsc)
 			f = vxlan_find_mac(vxlan, eth->h_dest);
@@ -1130,8 +1132,10 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 		    (vxlan->flags & VXLAN_F_L2MISS) &&
 		    !is_multicast_ether_addr(eth->h_dest))
 			vxlan_fdb_miss(vxlan, eth->h_dest);
-	} else
+	} else {
+		f->used = jiffies;
 		rdst0 = &f->remote;
+	}
 
 	rc = NETDEV_TX_OK;
 
