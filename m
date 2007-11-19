From: Joy Latten <latten@austin.ibm.com>
Subject: [PATCH 1/1]: SAs created although tmpl->optional set
Date: Mon, 19 Nov 2007 02:53:50 -0600
Message-ID: <200711190853.lAJ8ro9f006107@faith.austin.ibm.com>
Cc: davem@davemloft.net, herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:47789 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752287AbXKSI7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 03:59:05 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAJ8x2SJ030914
	for <netdev@vger.kernel.org>; Mon, 19 Nov 2007 03:59:02 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lAJ8x2g8091460
	for <netdev@vger.kernel.org>; Mon, 19 Nov 2007 01:59:02 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAJ8x2qb008032
	for <netdev@vger.kernel.org>; Mon, 19 Nov 2007 01:59:02 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Although tmpl->optional is set, kernel still attempts
to create a set of SAs. 

In xfrm_tmpl_resolve_one(), xfrm_state_find() is called
to find an SA. First time, there won't be an SA, so an
ACQUIRE will be sent and code then returns to 
xfrm_tmpl_resolv_one() who then checks tmpl->optional. 
Since tmpl->optional is set, the xfrm code will then 
allow flow to pass not transformed.

I may have misinterpreted semantics of tmpl->optional,
(I thought it meant use an SA only if there is one, otherwise
do not transform) but do we want to create an SA as well as
send flow without xfrm'ing?

regards,
Joy

Signed-off-by: Joy Latten <latten@austin.ibm.com>


diff -urpN linux-2.6.orig/net/xfrm/xfrm_state.c linux-2.6.spd/net/xfrm/xfrm_state.c
--- linux-2.6.orig/net/xfrm/xfrm_state.c	2007-11-18 16:53:16.000000000 -0600
+++ linux-2.6.spd/net/xfrm/xfrm_state.c	2007-11-18 23:38:08.000000000 -0600
@@ -814,6 +814,12 @@ xfrm_state_find(xfrm_address_t *daddr, x
 			error = -EEXIST;
 			goto out;
 		}
+
+		if (tmpl->optional) {
+			error = 0;
+			goto out;
+		}
+
 		x = xfrm_state_alloc();
 		if (x == NULL) {
 			error = -ENOMEM;
