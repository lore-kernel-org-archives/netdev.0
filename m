From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC] remove NLA_STRING NUL trimming
Date: Fri, 23 Mar 2007 00:12:18 +0100
Message-ID: <1174605138.3588.54.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:40310 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422876AbXCWNl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 09:41:27 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Looking through the netlink/attr.c code I noticed that NLA_STRING
attributes that end with a binary NUL have it removed before passing it
to the consumer.

For wireless, we have a few places where we need to be able to accept
any (even binary) values, for example for the SSID; the SSID can validly
end with \0 and I'd still love to be able to take advantage of
NLA_STRING and .len = 32 so I don't need to check the length myself.
However, given the code above, an SSID with a terminating \0 would be
reduced by one character.

This patch removes the trimming.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

---
This shouldn't break things if all users that rely on terminating NULs
have migrated to NLA_NUL_STRING already. I don't see many users of
NLA_STRING still, but if we can't make that change because some users
still rely on it trimming the NUL I could also make a patch that
introduces NLA_BIN_STRING with the changed semantics.

--- wireless-dev.orig/net/netlink/attr.c	2007-03-23 00:06:41.293435409 +0100
+++ wireless-dev/net/netlink/attr.c	2007-03-23 00:07:13.753435409 +0100
@@ -56,15 +56,8 @@ static int validate_nla(struct nlattr *n
 		if (attrlen < 1)
 			return -ERANGE;
 
-		if (pt->len) {
-			char *buf = nla_data(nla);
-
-			if (buf[attrlen - 1] == '\0')
-				attrlen--;
-
-			if (attrlen > pt->len)
-				return -ERANGE;
-		}
+		if (pt->len && attrlen > pt->len)
+			return -ERANGE;
 		break;
 
 	default:


