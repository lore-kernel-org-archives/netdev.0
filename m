From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v4 net-next 07/11] net: Get rid of IPv6 hash addresses
 flow keys
Date: Fri, 22 May 2015 10:08:54 +0200
Message-ID: <20150522080854.GG2138@nanopsycho.orion>
References: <1432253506-3646977-1-git-send-email-tom@herbertland.com>
 <1432253506-3646977-8-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:35974 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754712AbbEVII5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 04:08:57 -0400
Received: by wgbgq6 with SMTP id gq6so10137855wgb.3
        for <netdev@vger.kernel.org>; Fri, 22 May 2015 01:08:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1432253506-3646977-8-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, May 22, 2015 at 02:11:42AM CEST, tom@herbertland.com wrote:
>We don't need to return the IPv6 address hash as part of flow keys.
>In general, using the IPv6 address hash is risky in a hash value
>since the underlying use of xor provides no entropy. If someone
>really needs the hash value they can get it from the full IPv6
>addresses in flow keys (e.g. from flow_get_u32_src).
>
>Signed-off-by: Tom Herbert <tom@herbertland.com>
>---
> include/net/flow_dissector.h |  1 -
> net/core/flow_dissector.c    | 17 -----------------
> 2 files changed, 18 deletions(-)
>
>diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
>index 3ee606a..59f00f9 100644
>--- a/include/net/flow_dissector.h
>+++ b/include/net/flow_dissector.h
>@@ -103,7 +103,6 @@ enum flow_dissector_key_id {
> 	FLOW_DISSECTOR_KEY_BASIC, /* struct flow_dissector_key_basic */
> 	FLOW_DISSECTOR_KEY_IPV4_ADDRS, /* struct flow_dissector_key_ipv4_addrs */
> 	FLOW_DISSECTOR_KEY_IPV6_ADDRS, /* struct flow_dissector_key_ipv6_addrs */
>-	FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS, /* struct flow_dissector_key_addrs */
> 	FLOW_DISSECTOR_KEY_PORTS, /* struct flow_dissector_key_ports */
> 	FLOW_DISSECTOR_KEY_ETH_ADDRS, /* struct flow_dissector_key_eth_addrs */
> 	FLOW_DISSECTOR_KEY_TIPC_ADDRS, /* struct flow_dissector_key_tipc_addrs */
>diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
>index 8d6f089..44e47c5 100644
>--- a/net/core/flow_dissector.c
>+++ b/net/core/flow_dissector.c
>@@ -200,19 +200,6 @@ ipv6:
> 		nhoff += sizeof(struct ipv6hdr);
> 
> 		if (skb_flow_dissector_uses_key(flow_dissector,
>-						FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS)) {
>-			key_addrs = skb_flow_dissector_target(flow_dissector,
>-							      FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS,
>-							      target_container);
>-
>-			key_addrs->v4addrs.src =
>-				(__force __be32)ipv6_addr_hash(&iph->saddr);
>-			key_addrs->v4addrs.dst =
>-				(__force __be32)ipv6_addr_hash(&iph->daddr);
>-			key_control->addr_type = FLOW_DISSECTOR_KEY_IPV6_ADDRS;
>-			goto flow_label;
>-		}
>-		if (skb_flow_dissector_uses_key(flow_dissector,
> 						FLOW_DISSECTOR_KEY_IPV6_ADDRS)) {
> 			struct flow_dissector_key_ipv6_addrs *key_ipv6_addrs;
> 


You can change the code flow now to pre-b924933cbbfbdcaa2831a39 state:

		if (!skb_flow_dissector_uses_key(flow_dissector,
						 FLOW_DISSECTOR_KEY_IPV6_ADDRS))
			break;
		....
		flow_label = .....

killing flow_label label.

Other than that,

Acked-by: Jiri Pirko <jiri@resnulli.us>
