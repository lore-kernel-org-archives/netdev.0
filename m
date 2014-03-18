From: David L Stevens <dlstevens@us.ibm.com>
Subject: [PATCH net] VXLAN: fix potential NULL dereference in arp_reduce()
Date: Tue, 18 Mar 2014 12:32:29 -0400
Message-ID: <201403181632.s2IGWTjT003613@lab1.dls>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:44996 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754708AbaCRQci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 12:32:38 -0400
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Tue, 18 Mar 2014 10:32:38 -0600
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 0F77419D8039
	for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 10:32:32 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp08027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2IGW2Pu11075932
	for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 17:32:02 +0100
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2IGWYxf017581
	for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 10:32:35 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	This patch fixes a NULL pointer dereference in the event of an
skb allocation failure in arp_reduce().

Signed-Off-By: David L Stevens <dlstevens@us.ibm.com>

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index eb59b14..570792c 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1315,6 +1315,9 @@ static int arp_reduce(struct net_device *dev, struct sk_buff *skb)
 
 		neigh_release(n);
 
+		if (reply == NULL)
+			goto out;
+
 		skb_reset_mac_header(reply);
 		__skb_pull(reply, skb_network_offset(reply));
 		reply->ip_summed = CHECKSUM_UNNECESSARY;
