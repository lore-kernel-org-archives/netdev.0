From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: dccp-test-tree [PATCH 4/10] net: Hack to enable IPv6 ECN support
Date: Sun,  9 Aug 2009 21:48:41 +0200
Message-ID: <1249847327-6792-5-git-send-email-gerrit@erg.abdn.ac.uk>
References: <dccp_test_tree_sending_ecn_for_review>
 <1249847327-6792-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1249847327-6792-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1249847327-6792-3-git-send-email-gerrit@erg.abdn.ac.uk>
 <1249847327-6792-4-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: netdev@vger.kernel.org, Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:54864 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752779AbZHITsu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Aug 2009 15:48:50 -0400
In-Reply-To: <1249847327-6792-4-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ECN is not currently supported on inet6 sockets.

This is a hack to copy over the ECN bits when ECN-capable transport
has been enabled on the inet_sk socket.

This allows to support DCCPv6 ECN support, but needs to be revised:
 * the inet_sock already has an u8 `tos' field for the DSCP/ECN bits;
 * the same field is present as u8 `tclass' field in ipv6_pinfo;
 * the DS field (RFC 2474) and the ECN bits (RFC 3168) are AF-independent,
   so TOS/Traffic Class could be made AF-independent;
 * sockets that include ipv6_pinfo also include struct inet_sock.

Ideally there should be one field, e.g. `inet->dsfield', but doing
this requires some more careful analysis, since inet_sk(sk)->tos and
inet6_sk(sk)->tclass are referenced all over the source code.

Leaving this for the moment, to be completed later.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/net/inet_ecn.h |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

--- a/include/net/inet_ecn.h
+++ b/include/net/inet_ecn.h
@@ -46,9 +46,13 @@ static inline __u8 INET_ECN_encapsulate(__u8 outer, __u8 inner)
       (label) &= ~htonl(INET_ECN_MASK << 20);	\
     } while (0)
 
+/*
+ * XXX Hack: copy over the ECN bits from inet_sk to inet6_sk.
+ *           This should be replaced by a single `dsfield' in inet
+ */
 #define	IP6_ECN_flow_xmit(sk, label) do {				\
-	if (INET_ECN_is_capable(inet6_sk(sk)->tclass))			\
-		(label) |= htonl(INET_ECN_ECT_0 << 20);			\
+	IP6_ECN_flow_init(label);					\
+	(label) |= htonl((inet_sk(sk)->tos & INET_ECN_MASK) << 20);	\
     } while (0)
 
 static inline int IP_ECN_set_ce(struct iphdr *iph)
-- 
1.6.0.rc2

