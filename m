From: Thomas Graf <tgraf@infradead.org>
Subject: [PATCH] rtnetlink: Fix message size calculation for link messages
Date: Thu, 11 Nov 2010 20:47:59 -0500
Message-ID: <20101112014759.GA8491@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:55667 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756147Ab0KLBsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 20:48:00 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nlmsg_total_size() calculates the length of a netlink message
including header and alignment. nla_total_size() calculates the
space an individual attribute consumes which was meant to be used
in this context.

Also, ensure to account for the attribute header for the
IFLA_INFO_XSTATS attribute as implementations of get_xstats_size()
seem to assume that we do so.

The addition of two message headers minus the missing attribute
header resulted in a calculated message size that was larger than
required. Therefore we never risked running out of skb tailroom.

Signed-off-by: Thomas Graf <tgraf@infradead.org>
Cc: Patrick McHardy <kaber@trash.net>

Index: net-2.6/net/core/rtnetlink.c
===================================================================
--- net-2.6.orig/net/core/rtnetlink.c
+++ net-2.6/net/core/rtnetlink.c
@@ -347,16 +347,17 @@ static size_t rtnl_link_get_size(const s
 	if (!ops)
 		return 0;
 
-	size = nlmsg_total_size(sizeof(struct nlattr)) + /* IFLA_LINKINFO */
-	       nlmsg_total_size(strlen(ops->kind) + 1);	 /* IFLA_INFO_KIND */
+	size = nla_total_size(sizeof(struct nlattr)) + /* IFLA_LINKINFO */
+	       nla_total_size(strlen(ops->kind) + 1);  /* IFLA_INFO_KIND */
 
 	if (ops->get_size)
 		/* IFLA_INFO_DATA + nested data */
-		size += nlmsg_total_size(sizeof(struct nlattr)) +
+		size += nla_total_size(sizeof(struct nlattr)) +
 			ops->get_size(dev);
 
 	if (ops->get_xstats_size)
-		size += ops->get_xstats_size(dev);	/* IFLA_INFO_XSTATS */
+		/* IFLA_INFO_XSTATS */
+		size += nla_total_size(ops->get_xstats_size(dev));
 
 	return size;
 }
