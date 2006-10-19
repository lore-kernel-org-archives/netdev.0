From: "Michal Ruzicka" <michal.ruzicka@comstar.cz>
Subject: AF_KEY extended xfrm_state selector handling
Date: Thu, 19 Oct 2006 18:26:07 +0100
Message-ID: <200610191626.k9JGQ7x4014606@gateplz.comstar.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateplz-adsl.comstar.cz ([193.179.24.196]:1225 "EHLO
	gateplz.comstar.cz") by vger.kernel.org with ESMTP id S1946198AbWJSQ07 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Oct 2006 12:26:59 -0400
Content-Disposition: inline
To: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello

In an effort to configure an L2TP/IPsec server on Linux capable of supporting
multiple clients behind a single NAT device I ran into difficulties with pf_key
protocol implementation not being able to exploit all the information
passed to it as a SADB_EXT_ADDRESS_PROXY info. Perhaps as the original source
suggested (/* Nobody uses this, but we try. */) this info has never been used
before.

So I propose the included patch. It changes the following:
1) the amount of information that is stored into the struct xfrm_state's
   selector from the SADB_EXT_ADDRESS_PROXY info received from userspace
   in the pfkey_msg2xfrm_state() function
   The information stored now is:
    - the address (stored as the selector's source address, including family)
    - the prefix length (stored as the selector's source address prefix length)
    - the protocol (stored as selector's protocol)
    - the port (stored as selector's source port)
   Previously only the address and the prefix length were stored.

2) the conditions under which the SADB_EXT_ADDRESS_PROXY info
   is included while converting a struct xfrm_state into a pf_key message
   in the pfkey_xfrm_state2msg() function
   The conditions now are:
    - selector' protcol family is non-zero (ie. the selector is defined)
    and
    (
      - selector's prtocol is non-zero (ie. the protocol is specified)
      or
      - selector's source port is non-zero (ie. the port is specified)
      or
      - selector's source address is different from xfrm_state source address
    )
   Further the case when selector's address is of a different family from
   the xfrm_state address is now handled.

3) the way how port information is obtained from struct sadb_address
   The port information extraction is now part of
   the pfkey_sadb_addr2xfrm_addr() function wich handles that in a protocol
   family safe manner, instead of using ((struct sockaddr_in *)x)->sin_port
   construct irrespective of the protocol family

NOTES:
  - This patch should cause no problems, since as the original source says
    nobody uses that info.
  - I've also created a patch for racoon (ipsec-tools) to actually pass
    that info. Eventually I've been able to establish L2TP/IPSec connections
    from multiple clients behind the same NAT to the same L2TP/IPSec linux 2.6
    based server.
    (The procedure required a manual insertion of certain SPD entries during
    the connection establishment but this will hopefuly be handled by
    the L2TP daemon automatically soon.)

Here comes the patch (it is against 2.6.17.11):
Signed-off-by: Michal Ruzicka <michal.ruzicka@comstar.cz>

diff -Naur linux-2.6.17.11.orig/net/key/af_key.c linux-2.6.17.11/net/key/af_key.c
--- linux-2.6.17.11.orig/net/key/af_key.c	2006-08-23 23:16:33.000000000 +0200
+++ linux-2.6.17.11/net/key/af_key.c	2006-10-18 16:53:48.000000000 +0200
@@ -552,19 +552,28 @@
 }
 
 static int pfkey_sadb_addr2xfrm_addr(struct sadb_address *addr,
-				     xfrm_address_t *xaddr)
+				     xfrm_address_t *xaddr, __u16 *port)
 {
 	switch (((struct sockaddr*)(addr + 1))->sa_family) {
 	case AF_INET:
-		xaddr->a4 = 
-			((struct sockaddr_in *)(addr + 1))->sin_addr.s_addr;
+	{
+		struct sockaddr_in *in = (struct sockaddr_in *)(addr + 1);
+
+		xaddr->a4 = in->sin_addr.s_addr;
+		if (port)
+			*port = in->sin_port;
 		return AF_INET;
+	}
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	case AF_INET6:
-		memcpy(xaddr->a6, 
-		       &((struct sockaddr_in6 *)(addr + 1))->sin6_addr,
-		       sizeof(struct in6_addr));
+	{
+		struct sockaddr_in6 *in6 = (struct sockaddr_in6 *)(addr + 1);
+
+		memcpy(xaddr->a6, &in6->sin6_addr, sizeof(struct in6_addr));
+		if (port)
+			*port = in6->sin6_port;
 		return AF_INET6;
+	}
 #endif
 	default:
 		return 0;
@@ -651,6 +660,7 @@
 	int encrypt_key_size = 0;
 	int sockaddr_size;
 	struct xfrm_encap_tmpl *natt = NULL;
+	int proxy_size;
 
 	/* address family check */
 	sockaddr_size = pfkey_sockaddr_size(x->props.family);
@@ -674,14 +684,25 @@
 
 	/* identity & sensitivity */
 
-	if ((x->props.family == AF_INET &&
-	     x->sel.saddr.a4 != x->props.saddr.a4)
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	    || (x->props.family == AF_INET6 &&
-		memcmp (x->sel.saddr.a6, x->props.saddr.a6, sizeof (struct in6_addr)))
-#endif
-		)
-		size += sizeof(struct sadb_address) + sockaddr_size;
+	if (x->sel.family != 0 &&
+	    (x->sel.sport != 0 || x->sel.proto != 0
+	     || x->sel.family != x->props.family
+	     || (x->sel.family == AF_INET &&
+	         x->sel.saddr.a4 != x->props.saddr.a4)
+	     /*
+	      * the following test is not made dependent on INET6 since
+	      * if we get an AF_INET6 address here in situation when we
+	      * do not want to support that, than pfkey_sockaddr_size()
+	      * returns 0 which results into: return ERR_PTR(-EINVAL);
+	      */
+	     || (x->sel.family == AF_INET6 &&
+	         memcmp (x->sel.saddr.a6, x->props.saddr.a6, sizeof (struct in6_addr))))) {
+		proxy_size = pfkey_sockaddr_size(x->sel.family);
+		if (!proxy_size)
+			return ERR_PTR(-EINVAL);
+		size += proxy_size += sizeof(struct sadb_address);
+	} else
+		proxy_size = 0;
 
 	if (add_keys) {
 		if (x->aalg && x->aalg->alg_key_len) {
@@ -790,6 +811,7 @@
 	lifetime->sadb_lifetime_bytes = x->curlft.bytes;
 	lifetime->sadb_lifetime_addtime = x->curlft.add_time;
 	lifetime->sadb_lifetime_usetime = x->curlft.use_time;
+
 	/* src address */
 	addr = (struct sadb_address*) skb_put(skb, 
 					      sizeof(struct sadb_address)+sockaddr_size);
@@ -835,33 +857,15 @@
 			sizeof(uint64_t);
 	addr->sadb_address_exttype = SADB_EXT_ADDRESS_DST;
 	addr->sadb_address_proto = 0; 
-	addr->sadb_address_prefixlen = 32; /* XXX */ 
 	addr->sadb_address_reserved = 0;
 	if (x->props.family == AF_INET) {
+		addr->sadb_address_prefixlen = 32;
+
 		sin = (struct sockaddr_in *) (addr + 1);
 		sin->sin_family = AF_INET;
 		sin->sin_addr.s_addr = x->id.daddr.a4;
 		sin->sin_port = 0;
 		memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
-
-		if (x->sel.saddr.a4 != x->props.saddr.a4) {
-			addr = (struct sadb_address*) skb_put(skb, 
-				sizeof(struct sadb_address)+sockaddr_size);
-			addr->sadb_address_len = 
-				(sizeof(struct sadb_address)+sockaddr_size)/
-				sizeof(uint64_t);
-			addr->sadb_address_exttype = SADB_EXT_ADDRESS_PROXY;
-			addr->sadb_address_proto =
-				pfkey_proto_from_xfrm(x->sel.proto);
-			addr->sadb_address_prefixlen = x->sel.prefixlen_s;
-			addr->sadb_address_reserved = 0;
-
-			sin = (struct sockaddr_in *) (addr + 1);
-			sin->sin_family = AF_INET;
-			sin->sin_addr.s_addr = x->sel.saddr.a4;
-			sin->sin_port = x->sel.sport;
-			memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
-		}
 	}
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	else if (x->props.family == AF_INET6) {
@@ -873,20 +877,27 @@
 		sin6->sin6_flowinfo = 0;
 		memcpy(&sin6->sin6_addr, x->id.daddr.a6, sizeof(struct in6_addr));
 		sin6->sin6_scope_id = 0;
+	}
+#endif
+	else
+		BUG();
 
-		if (memcmp (x->sel.saddr.a6, x->props.saddr.a6,
-			    sizeof(struct in6_addr))) {
-			addr = (struct sadb_address *) skb_put(skb, 
-				sizeof(struct sadb_address)+sockaddr_size);
-			addr->sadb_address_len = 
-				(sizeof(struct sadb_address)+sockaddr_size)/
-				sizeof(uint64_t);
-			addr->sadb_address_exttype = SADB_EXT_ADDRESS_PROXY;
-			addr->sadb_address_proto =
-				pfkey_proto_from_xfrm(x->sel.proto);
-			addr->sadb_address_prefixlen = x->sel.prefixlen_s;
-			addr->sadb_address_reserved = 0;
-
+	if (proxy_size) {
+		addr = (struct sadb_address*) skb_put(skb, proxy_size);
+		addr->sadb_address_len = proxy_size / sizeof(uint64_t);
+		addr->sadb_address_exttype = SADB_EXT_ADDRESS_PROXY;
+		addr->sadb_address_proto = pfkey_proto_from_xfrm(x->sel.proto);
+		addr->sadb_address_prefixlen = x->sel.prefixlen_s;
+		addr->sadb_address_reserved = 0;
+		if (x->sel.family == AF_INET) {
+			sin = (struct sockaddr_in *) (addr + 1);
+			sin->sin_family = AF_INET;
+			sin->sin_addr.s_addr = x->sel.saddr.a4;
+			sin->sin_port = x->sel.sport;
+			memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
+		}
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		else if (x->sel.family == AF_INET6) {
 			sin6 = (struct sockaddr_in6 *) (addr + 1);
 			sin6->sin6_family = AF_INET6;
 			sin6->sin6_port = x->sel.sport;
@@ -895,10 +906,10 @@
 			       sizeof(struct in6_addr));
 			sin6->sin6_scope_id = 0;
 		}
-	}
 #endif
-	else
-		BUG();
+		else
+			BUG();
+	}
 
 	/* auth key */
 	if (add_keys && auth_key_size) {
@@ -1145,13 +1156,13 @@
 	/* x->algo.flags = sa->sadb_sa_flags; */
 
 	x->props.family = pfkey_sadb_addr2xfrm_addr((struct sadb_address *) ext_hdrs[SADB_EXT_ADDRESS_SRC-1], 
-						    &x->props.saddr);
+						    &x->props.saddr, NULL);
 	if (!x->props.family) {
 		err = -EAFNOSUPPORT;
 		goto out;
 	}
 	pfkey_sadb_addr2xfrm_addr((struct sadb_address *) ext_hdrs[SADB_EXT_ADDRESS_DST-1], 
-				  &x->id.daddr);
+				  &x->id.daddr, NULL);
 
 	if (ext_hdrs[SADB_X_EXT_SA2-1]) {
 		struct sadb_x_sa2 *sa2 = (void*)ext_hdrs[SADB_X_EXT_SA2-1];
@@ -1164,9 +1175,17 @@
 	if (ext_hdrs[SADB_EXT_ADDRESS_PROXY-1]) {
 		struct sadb_address *addr = ext_hdrs[SADB_EXT_ADDRESS_PROXY-1];
 
-		/* Nobody uses this, but we try. */
-		x->sel.family = pfkey_sadb_addr2xfrm_addr(addr, &x->sel.saddr);
-		x->sel.prefixlen_s = addr->sadb_address_prefixlen;
+		/* racoon uses this */
+		x->sel.family = pfkey_sadb_addr2xfrm_addr(addr, &x->sel.saddr,
+							  &x->sel.sport);
+		/* silently ignore unsupported address families */
+		if (x->sel.family) {
+			x->sel.prefixlen_s = addr->sadb_address_prefixlen;
+			x->sel.proto =
+				pfkey_proto_to_xfrm(addr->sadb_address_proto);
+			if (x->sel.sport)
+				x->sel.sport_mask = ~0;
+		}
 	}
 
 	if (ext_hdrs[SADB_X_EXT_NAT_T_TYPE-1]) {
@@ -2128,7 +2147,8 @@
 	xp->priority = pol->sadb_x_policy_priority;
 
 	sa = ext_hdrs[SADB_EXT_ADDRESS_SRC-1], 
-	xp->family = pfkey_sadb_addr2xfrm_addr(sa, &xp->selector.saddr);
+	xp->family = pfkey_sadb_addr2xfrm_addr(sa, &xp->selector.saddr,
+					       &xp->selector.sport);
 	if (!xp->family) {
 		err = -EINVAL;
 		goto out;
@@ -2136,12 +2156,11 @@
 	xp->selector.family = xp->family;
 	xp->selector.prefixlen_s = sa->sadb_address_prefixlen;
 	xp->selector.proto = pfkey_proto_to_xfrm(sa->sadb_address_proto);
-	xp->selector.sport = ((struct sockaddr_in *)(sa+1))->sin_port;
 	if (xp->selector.sport)
 		xp->selector.sport_mask = ~0;
 
 	sa = ext_hdrs[SADB_EXT_ADDRESS_DST-1], 
-	pfkey_sadb_addr2xfrm_addr(sa, &xp->selector.daddr);
+	pfkey_sadb_addr2xfrm_addr(sa, &xp->selector.daddr, &xp->selector.dport);
 	xp->selector.prefixlen_d = sa->sadb_address_prefixlen;
 
 	/* Amusing, we set this twice.  KAME apps appear to set same value
@@ -2149,7 +2168,6 @@
 	 */
 	xp->selector.proto = pfkey_proto_to_xfrm(sa->sadb_address_proto);
 
-	xp->selector.dport = ((struct sockaddr_in *)(sa+1))->sin_port;
 	if (xp->selector.dport)
 		xp->selector.dport_mask = ~0;
 
@@ -2236,18 +2254,16 @@
 	memset(&sel, 0, sizeof(sel));
 
 	sa = ext_hdrs[SADB_EXT_ADDRESS_SRC-1], 
-	sel.family = pfkey_sadb_addr2xfrm_addr(sa, &sel.saddr);
+	sel.family = pfkey_sadb_addr2xfrm_addr(sa, &sel.saddr, &sel.sport);
 	sel.prefixlen_s = sa->sadb_address_prefixlen;
 	sel.proto = pfkey_proto_to_xfrm(sa->sadb_address_proto);
-	sel.sport = ((struct sockaddr_in *)(sa+1))->sin_port;
 	if (sel.sport)
 		sel.sport_mask = ~0;
 
 	sa = ext_hdrs[SADB_EXT_ADDRESS_DST-1], 
-	pfkey_sadb_addr2xfrm_addr(sa, &sel.daddr);
+	pfkey_sadb_addr2xfrm_addr(sa, &sel.daddr, &sel.dport);
 	sel.prefixlen_d = sa->sadb_address_prefixlen;
 	sel.proto = pfkey_proto_to_xfrm(sa->sadb_address_proto);
-	sel.dport = ((struct sockaddr_in *)(sa+1))->sin_port;
 	if (sel.dport)
 		sel.dport_mask = ~0;
 

Thanks
Michal Ruzicka
