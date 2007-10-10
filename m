From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH] division-by-zero in inet_csk_get_port
Date: Wed, 10 Oct 2007 12:55:30 +0400
Message-ID: <20071010085530.GA7532@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: aarapov@redhat.com, dev@openvz.org, den@openvz.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:63625 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752782AbXJJIxt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2007 04:53:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixed a possible division-by-zero in inet_csk_get_port
treating situation low > high as if low == high.

Signed-off-by: Denis V. Lunev <den@openvz.org>
CC: Antov Arapov  <aarapov@redhat.com>

--- ./net/ipv4/inet_connection_sock.c.getport	2007-10-09 15:16:02.000000000 +0400
+++ ./net/ipv4/inet_connection_sock.c	2007-10-10 12:44:04.000000000 +0400
@@ -80,7 +80,14 @@ int inet_csk_get_port(struct inet_hashin
 		int low = sysctl_local_port_range[0];
 		int high = sysctl_local_port_range[1];
 		int remaining = (high - low) + 1;
-		int rover = net_random() % (high - low) + low;
+		int rover;
+
+		/* Treat low > high as high == low */
+		if (remaining <= 1) {
+			remaining = 1;
+			rover = low;
+		} else
+			rover = net_random() % (high - low) + low;
 
 		do {
 			head = &hashinfo->bhash[inet_bhashfn(rover, hashinfo->bhash_size)];
