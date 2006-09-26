From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] genetlink custom attribute type
Date: Tue, 26 Sep 2006 09:25:20 +0200
Message-ID: <1159255520.2782.1.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:30916 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750769AbWIZHYb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Sep 2006 03:24:31 -0400
To: davem <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds an NLA_CUSTOM_CHECK type for netlink attributes
in order to be able to centrally define new attribute structures
instead of having to check these special types in each function
that uses such an attribute.

nl80211 will benefit from this because it needs an information
element attribute with a fixed type|length|value structure defined
in IEEE 802.11 which ought to be checked when passing an IE from
userspace.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/include/net/netlink.h	2006-09-13 22:06:09.979647141 +0200
+++ wireless-dev/include/net/netlink.h	2006-09-13 22:06:11.329647141 +0200
@@ -159,6 +159,7 @@ enum {
 	NLA_MSECS,
 	NLA_NESTED,
 	NLA_NUL_STRING,
+	NLA_CUSTOM_CHECK,
 	__NLA_TYPE_MAX,
 };
 
@@ -176,6 +177,8 @@ enum {
  *    NLA_STRING           Maximum length of string
  *    NLA_NUL_STRING       Maximum length of string (excluding NUL)
  *    NLA_FLAG             Unused
+ *    NLA_CUSTOM_CHECK     Unused, check function must be assigned,
+ *                         it must return 0 if the attribute is valid
  *    All other            Exact length of attribute payload
  *
  * Example:
@@ -183,11 +186,13 @@ enum {
  * 	[ATTR_FOO] = { .type = NLA_U16 },
  *	[ATTR_BAR] = { .type = NLA_STRING, len = BARSIZ },
  *	[ATTR_BAZ] = { .len = sizeof(struct mystruct) },
+ *	[ATTR_CST] = { .type = NLA_CUSTOM_CHECK, .check = my_check },
  * };
  */
 struct nla_policy {
 	u16		type;
 	u16		len;
+	int		(*check)(struct nlattr *nla);
 };
 
 extern void		netlink_run_queue(struct sock *sk, unsigned int *qlen,
--- wireless-dev.orig/net/netlink/attr.c	2006-09-13 22:06:05.889647141 +0200
+++ wireless-dev/net/netlink/attr.c	2006-09-13 22:06:11.329647141 +0200
@@ -67,6 +67,9 @@ static int validate_nla(struct nlattr *n
 		}
 		break;
 
+	case NLA_CUSTOM_CHECK:
+		BUG_ON(!pt->check);
+		return pt->check(nla);
 	default:
 		if (pt->len)
 			minlen = pt->len;

