From: Jiri Bohac <jbohac@suse.cz>
Subject: ICMPv6: treat dest unreachable codes 5 and 6 as EACCES, not EPROTO
Date: Fri, 30 Aug 2013 11:18:45 +0200
Message-ID: <20130830091844.GA2706@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:60657 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754147Ab3H3JSu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Aug 2013 05:18:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 4443 has defined two additional codes for ICMPv6 type 1 (destination
unreachable) messages:
        5 - Source address failed ingress/egress policy
	6 - Reject route to destination

Now they are treated as protocol error and icmpv6_err_convert() converts them
to EPROTO.

RFC 4443 says:
	"Codes 5 and 6 are more informative subsets of code 1."

Treat codes 5 and 6 as code 1 (EACCES)

Btw, connect() returning -EPROTO confuses firefox, so that fallback to
other/IPv4 addresses does not work:
https://bugzilla.mozilla.org/show_bug.cgi?id=910773


Signed-off-by: Jiri Bohac <jbohac@suse.cz>

diff --git a/include/uapi/linux/icmpv6.h b/include/uapi/linux/icmpv6.h
index e0133c7..590beda 100644
--- a/include/uapi/linux/icmpv6.h
+++ b/include/uapi/linux/icmpv6.h
@@ -115,6 +115,8 @@ struct icmp6hdr {
 #define ICMPV6_NOT_NEIGHBOUR		2
 #define ICMPV6_ADDR_UNREACH		3
 #define ICMPV6_PORT_UNREACH		4
+#define ICMPV6_POLICY_FAIL		5
+#define ICMPV6_REJECT_ROUTE		6
 
 /*
  *	Codes for Time Exceeded
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 7cfc8d2..5b341bf 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -940,6 +940,14 @@ static const struct icmp6_err {
 		.err	= ECONNREFUSED,
 		.fatal	= 1,
 	},
+	{	/* POLICY_FAIL */
+		.err	= EACCES,
+		.fatal	= 1,
+	},
+	{	/* REJECT_ROUTE	*/
+		.err	= EACCES,
+		.fatal	= 1,
+	},
 };
 
 int icmpv6_err_convert(u8 type, u8 code, int *err)
@@ -951,7 +959,7 @@ int icmpv6_err_convert(u8 type, u8 code, int *err)
 	switch (type) {
 	case ICMPV6_DEST_UNREACH:
 		fatal = 1;
-		if (code <= ICMPV6_PORT_UNREACH) {
+		if (code < ARRAY_SIZE(tab_unreach)) {
 			*err  = tab_unreach[code].err;
 			fatal = tab_unreach[code].fatal;
 		}


-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
