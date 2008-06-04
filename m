From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] ipv6 addrconf: Fix memory leak when deleting addresses
Date: Thu, 5 Jun 2008 01:50:35 +0200
Message-ID: <20080604235035.GJ20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:60327 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756597AbYFDXuP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2008 19:50:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip6_del_rt() may fail in which case the dst/route is not released.

Signed-off-by: Thomas graf <tgraf@suug.ch>

Index: net-2.6/net/ipv6/addrconf.c
===================================================================
--- net-2.6.orig/net/ipv6/addrconf.c	2008-06-04 22:59:11.000000000 +0200
+++ net-2.6/net/ipv6/addrconf.c	2008-06-04 23:07:05.000000000 +0200
@@ -779,8 +779,8 @@
 
 		if (rt && ((rt->rt6i_flags & (RTF_GATEWAY | RTF_DEFAULT)) == 0)) {
 			if (onlink == 0) {
-				ip6_del_rt(rt);
-				rt = NULL;
+				if (ip6_del_rt(rt) == 0)
+					goto out;
 			} else if (!(rt->rt6i_flags & RTF_EXPIRES)) {
 				rt->rt6i_expires = expires;
 				rt->rt6i_flags |= RTF_EXPIRES;
@@ -788,7 +788,7 @@
 		}
 		dst_release(&rt->u.dst);
 	}
-
+out:
 	in6_ifa_put(ifp);
 }
 
