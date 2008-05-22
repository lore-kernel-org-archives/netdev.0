From: Thomas Graf <tgraf@suug.ch>
Subject: [NETLINK]: Fix nla_parse_nested_compat() to call nla_parse() directly
Date: Thu, 22 May 2008 13:37:20 +0200
Message-ID: <20080522113720.GR20815@postel.suug.ch>
References: <20080521214523.GB22591@codemonkey.org.uk> <20080521151021.3d47a3d8@extreme> <20080522002155.GP20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave Jones <davej@codemonkey.org.uk>, netdev@vger.kernel.org
To: davem@davemloft.net, Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:36988 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756870AbYEVLhA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 07:37:00 -0400
Content-Disposition: inline
In-Reply-To: <20080522002155.GP20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The purpose of nla_parse_nested_compat() is to parse attributes
which contain a struct followed by a stream of nested attributes.
So far, it called nla_parse_nested() to parse the stream of
nested attributes which was wrong, as nla_parse_nested() expects
a container attribute as data which holds the attribute stream.
It needs to call nla_parse() directly while pointing at the
next possible alignment point after the struct in the beginning
of the attribute.

With this patch, I can no longer reproduce the reported leftover
warnings.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6/include/net/netlink.h
===================================================================
--- net-2.6.orig/include/net/netlink.h	2008-05-22 13:00:10.000000000 +0200
+++ net-2.6/include/net/netlink.h	2008-05-22 13:02:08.000000000 +0200
@@ -772,12 +772,13 @@
 					    const struct nla_policy *policy,
 					    int len)
 {
-	if (nla_len(nla) < len)
+	int nested_len = nla_len(nla) - NLA_ALIGN(len);
+
+	if (nested_len < 0)
 		return -1;
-	if (nla_len(nla) >= NLA_ALIGN(len) + sizeof(struct nlattr))
-		return nla_parse_nested(tb, maxtype,
-					nla_data(nla) + NLA_ALIGN(len),
-					policy);
+	if (nested_len >= nla_attr_size(0))
+		return nla_parse(tb, maxtype, nla_data(nla) + NLA_ALIGN(len),
+				 nested_len, policy);
 	memset(tb, 0, sizeof(struct nlattr *) * (maxtype + 1));
 	return 0;
 }
