From: Pedro Ribeiro <pribeiro-bulk@net.ipl.pt>
Subject: [PATCH] Fix IPv6 default gateway selection criteria in presence of
 the HIGH/LOW preference option in router advertisements (text wrap fixed
 I hope!)
Date: Wed, 15 Oct 2008 17:09:10 +0100
Message-ID: <48F615A6.8000201@net.ipl.pt>
References: <159769323.20081014120620@net.ipl.pt>	<20081014.135423.91524319.davem@davemloft.net>	<1338007712.20081014233811@net.ipl.pt> <20081014.154716.139460375.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out2.net.ipl.pt ([192.104.48.15]:52389 "EHLO
	smtp-out2.net.ipl.pt" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751054AbYJOQJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2008 12:09:12 -0400
In-Reply-To: <20081014.154716.139460375.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Problem observed:
               In IPv6, in the presence of multiple routers candidates to
               default gateway in one segment, each sending a different
               value of preference, the Linux hosts connected to the
               segment weren't selecting the right one in all the
               combinations possible of LOW/MEDIUM/HIGH preference.
                         
This patch changes two files:
include/linux/icmpv6.h
               Get the "router_pref" bitfield in the right place
               (as RFC4191 says), named the bit left with this fix as
               "home_agent" (RFC3775 say that's his function)

net/ipv6/ndisc.c
               Corrects the binary logic behind the updating of the
               router preference in the flags of the routing table

Result:
               With this two fixes applied, the default route used by
               the system was to consistent with the rules mentioned
               in RFC4191 in case of changes in the value of preference
               in router advertisements

Signed-off-by: Pedro Ribeiro <pribeiro@net.ipl.pt>

diff -uprN linux-2.6.27/include/linux/icmpv6.h linux-2.6.27fix/include/linux/icmpv6.h
--- linux-2.6.27/include/linux/icmpv6.h	2008-10-09 23:13:53.000000000 +0100
+++ linux-2.6.27fix/include/linux/icmpv6.h	2008-10-14 23:24:31.000000000 +0100
@@ -40,16 +40,18 @@ struct icmp6hdr {
                 struct icmpv6_nd_ra {
 			__u8		hop_limit;
 #if defined(__LITTLE_ENDIAN_BITFIELD)
-			__u8		reserved:4,
+			__u8		reserved:3,
 					router_pref:2,
+					home_agent:1,
 					other:1,
 					managed:1;
 
 #elif defined(__BIG_ENDIAN_BITFIELD)
 			__u8		managed:1,
 					other:1,
+					home_agent:1,
 					router_pref:2,
-					reserved:4;
+					reserved:3;
 #else
 #error	"Please fix <asm/byteorder.h>"
 #endif
diff -uprN linux-2.6.27/net/ipv6/ndisc.c linux-2.6.27fix/net/ipv6/ndisc.c
--- linux-2.6.27/net/ipv6/ndisc.c	2008-10-09 23:13:53.000000000 +0100
+++ linux-2.6.27fix/net/ipv6/ndisc.c	2008-10-14 23:24:31.000000000 +0100
@@ -1199,7 +1199,7 @@ static void ndisc_router_discovery(struc
 		}
 		neigh->flags |= NTF_ROUTER;
 	} else if (rt) {
-		rt->rt6i_flags |= (rt->rt6i_flags & ~RTF_PREF_MASK) | RTF_PREF(pref);
+		rt->rt6i_flags = (rt->rt6i_flags & ~RTF_PREF_MASK) | RTF_PREF(pref);
 	}
 
 	if (rt)


