From: Andreas Meissner <andreas.meissner@indakom.de>
Subject: [PATCH] IPv4: unresolved multicast route cleanup
Date: Mon, 10 May 2010 11:09:33 +0200
Message-ID: <4BE7CD4D.6050704@indakom.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from indakom.de ([213.133.108.139]:1793 "EHLO www.indakom.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751245Ab0EJJJj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 May 2010 05:09:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

from: Andreas Meissner <andreas.meissner@sphairon.com>

Fixes the expiration timer for unresolved multicast route entries.
In case new multicast routing requests come in faster than the 
expiration timeout occurs (e.g. zap through multicast TV streams), the 
timer is prevented from being called at time for already existing entries.

Signed-off by: Andreas Meissner <andreas.meissner@sphairon.com>
---
As the single timer is resetted to default whenever a new entry is made, 
the timeout for existing unresolved entires are missed and/or not 
updated. As a consequence new requests are denied when the limit of 
unresolved entries has been reached because old entries live longer than 
they are supposed to.
The solution is to reset the timer only for the first unresolved entry 
in the multicast routing cache. All other timers are already set and 
updated correctly within the timer function itself by now.
---
 ipv4/ipmr.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)
--- net/ipv4/ipmr.c.orig	2010-05-10 10:07:38.000000000 +0200
+++ net/ipv4/ipmr.c	2010-05-10 10:08:39.000000000 +0200
@@ -753,7 +753,8 @@
 		c->next = mfc_unres_queue;
 		mfc_unres_queue = c;
 
-		mod_timer(&ipmr_expire_timer, c->mfc_un.unres.expires);
+		if (atomic_read(&net->ipv4.cache_resolve_queue_len) == 1)
+			mod_timer(&ipmr_expire_timer, c->mfc_un.unres.expires);
 	}
 
 	/*

