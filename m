From: Joy Latten <latten@austin.ibm.com>
Subject: [PATCH 1/1]: Using ICMP type and code in xfrm selector
Date: Fri, 2 Nov 2007 18:17:40 -0500
Message-ID: <200711022317.lA2NHeX2018386@faith.austin.ibm.com>
Cc: davem@davemloft.net, herbert@gondor.apana.org.au, tgraf@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:36559 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752949AbXKBXWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2007 19:22:47 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA2NMWuf026656
	for <netdev@vger.kernel.org>; Fri, 2 Nov 2007 19:22:32 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA2NMRSd119428
	for <netdev@vger.kernel.org>; Fri, 2 Nov 2007 17:22:32 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA2NMQNO019982
	for <netdev@vger.kernel.org>; Fri, 2 Nov 2007 17:22:27 -0600
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ICMP message type and/or code may be value "0" when
used as selector.
Currently, if you specify SPD entry with upper layer 
protocol set as icmp, specify message type is 0 and 
code is 0, then all icmp messages get
mapped to this. It appears value 0 for port is 
interpreted to mean ANY, which is not entirely true for
ICMP and MH message type values.

Below patch fixes this so ICMP message types and
codes as well as MH types having value "0" aren't
interpreted as ANY.

While fixing this I wondered why we put icmp message
type in sport and code in dport?

recent ipsec rfc 4301 says: 

           If the Next Layer Protocol is a Mobility Header, then there
           is a selector for IPv6 Mobility Header message type (MH type)
           [Mobip].  This is an 8-bit value that identifies a particular
           mobility message.  Note that the MH type may not be available
           in the case of receipt of a fragmented packet. (See Section
           7, "Handling Fragments".) For IKE, the IPv6 Mobility Header
           message type (MH type) is placed in the most significant
           eight bits of the 16-bit local "port" selector.

           If the Next Layer Protocol value is ICMP, then there is a
           16-bit selector for the ICMP message type and code.  The
           message type is a single 8-bit value, which defines the type
           of an ICMP message, or ANY.  The ICMP code is a single 8-bit
           value that defines a specific subtype for an ICMP message.
           For IKE, the message type is placed in the most significant 8
           bits of the 16-bit selector and the code is placed in the
           least significant 8 bits.

Should I leave as is or put both type and code into sport 
and also copy into dport to be closer to rfc? Similar 
question for MH type... 
Seems ok as is, but I could be missing something.

xfrm_user did not appear to require this change.

I tested icmp with my patched ipsec-tools.

Signed-off-by: Joy Latten <latten@austin.ibm.com>

diff -urpN linux-2.6.24-rc1-git11/include/linux/ipsec.h linux-2.6.24-rc1-git11.patch/include/linux/ipsec.h
--- linux-2.6.24-rc1-git11/include/linux/ipsec.h	2007-11-02 16:36:30.000000000 -0500
+++ linux-2.6.24-rc1-git11.patch/include/linux/ipsec.h	2007-11-02 16:52:57.000000000 -0500
@@ -8,6 +8,7 @@
 #define IPSEC_PORT_ANY		0
 #define IPSEC_ULPROTO_ANY	255
 #define IPSEC_PROTO_ANY		255
+#define IPSEC_ICMPMH_ANY	255
 
 enum {
 	IPSEC_MODE_ANY		= 0,	/* We do not support this for SA */
diff -urpN linux-2.6.24-rc1-git11/net/key/af_key.c linux-2.6.24-rc1-git11.patch/net/key/af_key.c
--- linux-2.6.24-rc1-git11/net/key/af_key.c	2007-11-02 16:39:40.000000000 -0500
+++ linux-2.6.24-rc1-git11.patch/net/key/af_key.c	2007-11-02 16:44:17.000000000 -0500
@@ -568,6 +568,35 @@ static int pfkey_sadb_addr2xfrm_addr(str
 	/* NOTREACHED */
 }
 
+static void pfkey_set_sportmask(struct xfrm_selector *sel)
+{
+	switch(sel->proto) {
+	case IPPROTO_ICMP:
+	case IPPROTO_ICMPV6:
+	case IPPROTO_MH:
+		if (sel->sport != IPSEC_ICMPMH_ANY)
+			sel->sport_mask = htons(0xffff);
+		break;
+	default:
+		if (sel->sport)
+			sel->sport_mask = htons(0xffff);
+	}
+}
+
+static void pfkey_set_dportmask(struct xfrm_selector *sel)
+{
+	switch(sel->proto) {
+	case IPPROTO_ICMP:
+	case IPPROTO_ICMPV6:
+		if (sel->dport != IPSEC_ICMPMH_ANY)
+			sel->dport_mask = htons(0xffff);
+		break;
+	default:
+		if (sel->dport)
+			sel->dport_mask = htons(0xffff);
+	}
+}
+
 static struct  xfrm_state *pfkey_xfrm_state_lookup(struct sadb_msg *hdr, void **ext_hdrs)
 {
 	struct sadb_sa *sa;
@@ -2218,8 +2247,7 @@ static int pfkey_spdadd(struct sock *sk,
 	xp->selector.prefixlen_s = sa->sadb_address_prefixlen;
 	xp->selector.proto = pfkey_proto_to_xfrm(sa->sadb_address_proto);
 	xp->selector.sport = ((struct sockaddr_in *)(sa+1))->sin_port;
-	if (xp->selector.sport)
-		xp->selector.sport_mask = htons(0xffff);
+	pfkey_set_sportmask(&xp->selector);
 
 	sa = ext_hdrs[SADB_EXT_ADDRESS_DST-1],
 	pfkey_sadb_addr2xfrm_addr(sa, &xp->selector.daddr);
@@ -2231,8 +2259,7 @@ static int pfkey_spdadd(struct sock *sk,
 	xp->selector.proto = pfkey_proto_to_xfrm(sa->sadb_address_proto);
 
 	xp->selector.dport = ((struct sockaddr_in *)(sa+1))->sin_port;
-	if (xp->selector.dport)
-		xp->selector.dport_mask = htons(0xffff);
+	pfkey_set_dportmask(&xp->selector);
 
 	sec_ctx = (struct sadb_x_sec_ctx *) ext_hdrs[SADB_X_EXT_SEC_CTX-1];
 	if (sec_ctx != NULL) {
@@ -2324,16 +2351,14 @@ static int pfkey_spddelete(struct sock *
 	sel.prefixlen_s = sa->sadb_address_prefixlen;
 	sel.proto = pfkey_proto_to_xfrm(sa->sadb_address_proto);
 	sel.sport = ((struct sockaddr_in *)(sa+1))->sin_port;
-	if (sel.sport)
-		sel.sport_mask = htons(0xffff);
+	pfkey_set_sportmask(&sel);
 
 	sa = ext_hdrs[SADB_EXT_ADDRESS_DST-1],
 	pfkey_sadb_addr2xfrm_addr(sa, &sel.daddr);
 	sel.prefixlen_d = sa->sadb_address_prefixlen;
 	sel.proto = pfkey_proto_to_xfrm(sa->sadb_address_proto);
 	sel.dport = ((struct sockaddr_in *)(sa+1))->sin_port;
-	if (sel.dport)
-		sel.dport_mask = htons(0xffff);
+	pfkey_set_dportmask(&sel);
 
 	sec_ctx = (struct sadb_x_sec_ctx *) ext_hdrs[SADB_X_EXT_SEC_CTX-1];
 	memset(&tmp, 0, sizeof(struct xfrm_policy));
@@ -2548,8 +2573,7 @@ static int pfkey_migrate(struct sock *sk
 	sel.prefixlen_s = sa->sadb_address_prefixlen;
 	sel.proto = pfkey_proto_to_xfrm(sa->sadb_address_proto);
 	sel.sport = ((struct sockaddr_in *)(sa + 1))->sin_port;
-	if (sel.sport)
-		sel.sport_mask = htons(0xffff);
+	pfkey_set_sportmask(&sel);
 
 	/* set destination address info of selector */
 	sa = ext_hdrs[SADB_EXT_ADDRESS_DST - 1],
@@ -2557,8 +2581,7 @@ static int pfkey_migrate(struct sock *sk
 	sel.prefixlen_d = sa->sadb_address_prefixlen;
 	sel.proto = pfkey_proto_to_xfrm(sa->sadb_address_proto);
 	sel.dport = ((struct sockaddr_in *)(sa + 1))->sin_port;
-	if (sel.dport)
-		sel.dport_mask = htons(0xffff);
+	pfkey_set_dportmask(&sel);
 
 	rq = (struct sadb_x_ipsecrequest *)(pol + 1);
 
