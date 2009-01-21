From: Timo Teras <timo.teras@iki.fi>
Subject: [PATCH] af_key: parse and send SADB_X_EXT_NAT_T_OA extension
Date: Wed, 21 Jan 2009 09:34:07 +0200
Message-ID: <1232523247-6893-1-git-send-email-timo.teras@iki.fi>
Cc: Timo Teras <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f20.google.com ([209.85.219.20]:34948 "EHLO
	mail-ew0-f20.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755373AbZAUHeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 02:34:13 -0500
Received: by ewy13 with SMTP id 13so1333804ewy.13
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2009 23:34:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Parse and send SADB_X_EXT_NAT_T_OA along with other NAT-T extensions.

Signed-off-by: Timo Teras <timo.teras@iki.fi>
---
 net/key/af_key.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index f8bd8df..f3e9998 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -824,6 +824,7 @@ static struct sk_buff *__pfkey_xfrm_state2msg(struct xfrm_state *x,
 		size += sizeof(struct sadb_x_nat_t_type);
 		size += sizeof(struct sadb_x_nat_t_port);
 		size += sizeof(struct sadb_x_nat_t_port);
+		size += sizeof(struct sadb_address) + sockaddr_size;
 	}
 
 	skb =  alloc_skb(size + 16, GFP_ATOMIC);
@@ -1031,6 +1032,20 @@ static struct sk_buff *__pfkey_xfrm_state2msg(struct xfrm_state *x,
 		n_port->sadb_x_nat_t_port_exttype = SADB_X_EXT_NAT_T_DPORT;
 		n_port->sadb_x_nat_t_port_port = natt->encap_dport;
 		n_port->sadb_x_nat_t_port_reserved = 0;
+
+		/* original address */
+		addr = (struct sadb_address*) skb_put(skb,
+					      sizeof(struct sadb_address)+sockaddr_size);
+		addr->sadb_address_len =
+			(sizeof(struct sadb_address)+sockaddr_size)/
+			sizeof(uint64_t);
+		addr->sadb_address_exttype = SADB_X_EXT_NAT_T_OA;
+		addr->sadb_address_proto = 0;
+		addr->sadb_address_reserved = 0;
+		addr->sadb_address_prefixlen =
+			pfkey_sockaddr_fill(&natt->encap_oa, 0,
+					    (struct sockaddr *) (addr + 1),
+					    x->props.family);
 	}
 
 	/* security context */
@@ -1285,6 +1300,11 @@ static struct xfrm_state * pfkey_msg2xfrm_state(struct net *net,
 				ext_hdrs[SADB_X_EXT_NAT_T_DPORT-1];
 			natt->encap_dport = n_port->sadb_x_nat_t_port_port;
 		}
+		if (ext_hdrs[SADB_X_EXT_NAT_T_OA-1]) {
+			struct sadb_address* n_oa =
+				ext_hdrs[SADB_X_EXT_NAT_T_OA-1];
+			pfkey_sadb_addr2xfrm_addr(n_oa, &natt->encap_oa);
+		}
 	}
 
 	err = xfrm_init_state(x);
-- 
1.5.6.3

