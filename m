From: Jens Rosenboom <me@jayr.de>
Subject: [PATCH] ipv6: avoid wraparound for expired preferred lifetime
Date: Thu, 25 Jun 2009 16:55:50 +0200
Message-ID: <20090625145550.GQ21357@jayr.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout4.freenet.de ([195.4.92.94]:40443 "EHLO mout4.freenet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751919AbZFYOzx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jun 2009 10:55:53 -0400
Received: from [195.4.92.18] (helo=8.mx.freenet.de)
	by mout4.freenet.de with esmtpa (ID exim) (port 25) (Exim 4.69 #92)
	id 1MJqMj-0002gW-7o
	for netdev@vger.kernel.org; Thu, 25 Jun 2009 16:55:53 +0200
Received: from v6.beuys.jayr.de ([2001:748:305:1001:290:27ff:fe2d:b4cc]:56769 helo=beuys.jayr.de)
	by 8.mx.freenet.de with esmtps (TLSv1:AES256-SHA:256) (port 25) (Exim 4.69 #79)
	id 1MJqMj-0006Pg-4O
	for netdev@vger.kernel.org; Thu, 25 Jun 2009 16:55:53 +0200
Received: from jens by beuys.jayr.de with local (Exim 4.69)
	(envelope-from <jens@jayr.de>)
	id 1MJqMg-00029d-QG
	for netdev@vger.kernel.org; Thu, 25 Jun 2009 16:55:50 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid showing wrong high values when the preferred lifetime of an address
is expired.

Signed-off-by: Jens Rosenboom <me@jayr.de>

---

Revised patch, it should suffice to only check the preferred lifetime, as
the address is deleted before the valid lifetime can wrap around.

--- linux-2.6.30.orig/net/ipv6/addrconf.c	2009-06-10 05:05:27.000000000 +0200
+++ linux-2.6.30/net/ipv6/addrconf.c	2009-06-25 16:43:19.000000000 +0200
@@ -3361,7 +3361,10 @@ static int inet6_fill_ifaddr(struct sk_b
 		valid = ifa->valid_lft;
 		if (preferred != INFINITY_LIFE_TIME) {
 			long tval = (jiffies - ifa->tstamp)/HZ;
-			preferred -= tval;
+			if (preferred > tval)
+				preferred -= tval;
+			else
+				preferred = 0;
 			if (valid != INFINITY_LIFE_TIME)
 				valid -= tval;
 		}
