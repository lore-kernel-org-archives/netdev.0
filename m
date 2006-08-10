From: Ryan Nowakowski <ryan@britestream.com>
Subject: ipvs locahost client patch for 2.6?
Date: Thu, 10 Aug 2006 11:18:38 -0500
Message-ID: <20060810161838.GD5088@britestream.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway.britestream.com ([207.191.53.98]:61363 "EHLO
	gateway.layern.com") by vger.kernel.org with ESMTP id S1161421AbWHJQSi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Aug 2006 12:18:38 -0400
Received: from pineapple.layern.com (pineapple.layern.com [192.168.1.233])
	by gateway.layern.com (8.12.11.20060308/8.12.11) with ESMTP id k7AGIcxq011263
	for <netdev@vger.kernel.org>; Thu, 10 Aug 2006 11:18:38 -0500
Received: from ryan by pineapple.layern.com with local (Exim 4.62)
	(envelope-from <ryan@britestream.com>)
	id 1GBDF0-00060P-59
	for netdev@vger.kernel.org; Thu, 10 Aug 2006 11:18:38 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I found this patch for 2.4 that allows the host running ipvs to act
as it's own client via loopback connection.  Does anyone have a similar
patch for 2.6?

--- ip_vs_core.c.orig	2003-11-28 19:26:21.000000000 +0100
+++ ip_vs_core.c.list	2004-07-02 11:13:51.000000000 +0200
@@ -1036,7 +1036,7 @@
 	 *	Big tappo: only PACKET_HOST (nor loopback neither mcasts)
 	 *	... don't know why 1st test DOES NOT include 2nd (?)
 	 */
-	if (skb->pkt_type != PACKET_HOST || skb->dev == &loopback_dev) {
+	if (skb->pkt_type != PACKET_HOST) { /* || skb->dev == &loopback_dev) { */
 		IP_VS_DBG(12, "packet type=%d proto=%d daddr=%d.%d.%d.%d ignored\n",
 			  skb->pkt_type,
 			  iph->protocol,
@@ -1059,6 +1059,13 @@
 	iph = skb->nh.iph;
 	h.raw = (char*) iph + ihl;
 
+        cp = ip_vs_conn_out_get(iph->protocol, iph->saddr, h.portp[0],
+                               iph->daddr, h.portp[1]);
+        if (cp) {
+           __ip_vs_conn_put(cp);
+           return (ip_vs_out(hooknum,skb_p,in,out,okfn));
+        }
+
 	/*
 	 * Check if the packet belongs to an existing connection entry
 	 */

