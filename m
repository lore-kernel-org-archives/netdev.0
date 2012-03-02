From: Simeon Penev <spenev@istac.de>
Subject: Patch for MTU in the routing table cache
Date: Fri, 02 Mar 2012 14:13:45 +0100
Message-ID: <4F50C789.8050709@istac.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020406080904050802060508"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from warnix.istac.de ([212.18.16.42]:43930 "EHLO warnix.istac.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756042Ab2CBNcI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2012 08:32:08 -0500
Received: from warnix.istac.de (localhost [127.0.0.1])
	by warnix.istac.de (Postfix) with ESMTP id D72A8400109B
	for <netdev@vger.kernel.org>; Fri,  2 Mar 2012 14:13:45 +0100 (CET)
Received: from [212.18.16.112] (ip-212-18-16-112.garderos.com [212.18.16.112])
	by warnix.istac.de (Postfix) with ESMTP
	for <netdev@vger.kernel.org>; Fri,  2 Mar 2012 14:13:45 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020406080904050802060508
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

after testing the new 3.2 kernel and the new route caching code, i've 
found a bug in net/ipv4/route.c. The route cache does not detect changes 
to the MTU of the interface. Therefore IP fragmentation will happen with 
false MTU. Please see attached the proposed patch.

Best regards,
Simeon Penev

--------------020406080904050802060508
Content-Type: text/x-patch;
 name="route-cache-mtu.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="route-cache-mtu.patch"

--- linux-3.2.7/net/ipv4/route.c.orig	2012-02-28 17:26:00.214386221 +0100
+++ linux-3.2.7/net/ipv4/route.c	2012-02-28 17:25:27.826225630 +0100
@@ -1926,7 +1926,7 @@
 	const struct rtable *rt = (const struct rtable *) dst;
 	unsigned int mtu = dst_metric_raw(dst, RTAX_MTU);
 
-	if (mtu && rt_is_output_route(rt))
+	if (mtu && rt_is_output_route(rt) && mtu == dst->dev->mtu)
 		return mtu;
 
 	mtu = dst->dev->mtu;
@@ -1940,6 +1940,8 @@
 	if (mtu > IP_MAX_MTU)
 		mtu = IP_MAX_MTU;
 
+	dst_metric_set(dst, RTAX_MTU, mtu);
+
 	return mtu;
 }
 

--------------020406080904050802060508--
