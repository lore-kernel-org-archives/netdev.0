From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 2/2] inet6: Set default traffic class
Date: Sun,  9 Aug 2009 20:12:49 +0200
Message-ID: <1249841569-23706-3-git-send-email-gerrit@erg.abdn.ac.uk>
References: <resolve_IPV6_TCLASS>
 <1249841569-23706-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1249841569-23706-2-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: netdev@vger.kernel.org, Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:51966 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752441AbZHISNE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Aug 2009 14:13:04 -0400
In-Reply-To: <1249841569-23706-2-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch addresses:
 * assigning -1 to np->tclass as it is currently done is not very meaningful,
   since it turns into 0xff;
 * RFC 3542, 6.5 allows -1 for clearing the sticky IPV6_TCLASS option
   and specifies -1 to mean "use kernel default":
   - RFC 2460, 7. requires that the default traffic class must be zero for
     all 8 bits,
   - this is consistent with RFC 2474, 4.1 which recommends a default PHB of 0,
     in combination with a value of the ECN field of "non-ECT" (RFC 3168, 5.).

This patch changes the meaning of -1 from assigning 255 to mean the RFC 2460
default, which at the same time allows to satisfy clearing the sticky TCLASS
option as per RFC 3542, 6.5.

(When passing -1 as ancillary data, the fallback remains np->tclass, which
 has either been set via socket options, or contains the default value.)

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/ipv6/ipv6_sockglue.c |    3 +++
 1 file changed, 3 insertions(+)

--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -315,6 +315,9 @@ static int do_ipv6_setsockopt(struct soc
 			goto e_inval;
 		if (val < -1 || val > 0xff)
 			goto e_inval;
+		/* RFC 3542, 6.5: default traffic class of 0x0 */
+		if (val == -1)
+			val = 0;
 		np->tclass = val;
 		retv = 0;
 		break;
