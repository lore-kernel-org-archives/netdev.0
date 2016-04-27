From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH iproute2 1/2] ip link gre: create interfaces in external mode correctly
Date: Wed, 27 Apr 2016 16:11:13 +0200
Message-ID: <71dc699e5d3ea0f761027440208e51cda3d1d8a5.1461766016.git.jbenc@redhat.com>
References: <cover.1461766016.git.jbenc@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Pravin Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46916 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752171AbcD0OLh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2016 10:11:37 -0400
In-Reply-To: <cover.1461766016.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For GRE interfaces in 'external' mode, the kernel ignores all manual
settings like remote IP address or TTL. However, for some of those
attributes, kernel checks their value and does not allow them to be zero
(even though they're ignored later).

Currently, 'ip link' always includes all attributes in the netlink message.
This leads to problem with creating interfaces in 'external' mode. For
example, this command does not work:

ip link add gre1 type gretap external

and needs a bogus remote IP address to be specified, as the kernel enforces
remote IP address to be either not present, or not null.

Ignore the parameters that do not make sense in 'external' mode.
Unfortunately, we cannot error out, as there may be existing deployments
that workarounded the bug by specifying bogus values.

Fixes: 926b39e1feffd ("gre: add support for collect metadata flag")
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 ip/link_gre.c | 28 +++++++++++++++-------------
 1 file changed, 15 insertions(+), 13 deletions(-)

diff --git a/ip/link_gre.c b/ip/link_gre.c
index bcf003aaa5d7..36ce1252675b 100644
--- a/ip/link_gre.c
+++ b/ip/link_gre.c
@@ -315,24 +315,26 @@ get_failed:
 		return -1;
 	}
 
-	addattr32(n, 1024, IFLA_GRE_IKEY, ikey);
-	addattr32(n, 1024, IFLA_GRE_OKEY, okey);
-	addattr_l(n, 1024, IFLA_GRE_IFLAGS, &iflags, 2);
-	addattr_l(n, 1024, IFLA_GRE_OFLAGS, &oflags, 2);
-	addattr_l(n, 1024, IFLA_GRE_LOCAL, &saddr, 4);
-	addattr_l(n, 1024, IFLA_GRE_REMOTE, &daddr, 4);
-	addattr_l(n, 1024, IFLA_GRE_PMTUDISC, &pmtudisc, 1);
-	if (link)
-		addattr32(n, 1024, IFLA_GRE_LINK, link);
-	addattr_l(n, 1024, IFLA_GRE_TTL, &ttl, 1);
-	addattr_l(n, 1024, IFLA_GRE_TOS, &tos, 1);
+	if (!metadata) {
+		addattr32(n, 1024, IFLA_GRE_IKEY, ikey);
+		addattr32(n, 1024, IFLA_GRE_OKEY, okey);
+		addattr_l(n, 1024, IFLA_GRE_IFLAGS, &iflags, 2);
+		addattr_l(n, 1024, IFLA_GRE_OFLAGS, &oflags, 2);
+		addattr_l(n, 1024, IFLA_GRE_LOCAL, &saddr, 4);
+		addattr_l(n, 1024, IFLA_GRE_REMOTE, &daddr, 4);
+		addattr_l(n, 1024, IFLA_GRE_PMTUDISC, &pmtudisc, 1);
+		if (link)
+			addattr32(n, 1024, IFLA_GRE_LINK, link);
+		addattr_l(n, 1024, IFLA_GRE_TTL, &ttl, 1);
+		addattr_l(n, 1024, IFLA_GRE_TOS, &tos, 1);
+	} else {
+		addattr_l(n, 1024, IFLA_GRE_COLLECT_METADATA, NULL, 0);
+	}
 
 	addattr16(n, 1024, IFLA_GRE_ENCAP_TYPE, encaptype);
 	addattr16(n, 1024, IFLA_GRE_ENCAP_FLAGS, encapflags);
 	addattr16(n, 1024, IFLA_GRE_ENCAP_SPORT, htons(encapsport));
 	addattr16(n, 1024, IFLA_GRE_ENCAP_DPORT, htons(encapdport));
-	if (metadata)
-		addattr_l(n, 1024, IFLA_GRE_COLLECT_METADATA, NULL, 0);
 
 	return 0;
 }
-- 
1.8.3.1
