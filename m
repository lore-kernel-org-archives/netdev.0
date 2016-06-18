From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 4/5] gre: better support for ICMP messages for gre+ipv6
Date: Sat, 18 Jun 2016 16:26:39 -0700
Message-ID: <1466292400-3638-5-git-send-email-edumazet@google.com>
References: <1466292400-3638-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Oussama Ghorbel <ghorbel@pivasoftware.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:34124 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270AbcFRX1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2016 19:27:20 -0400
Received: by mail-pf0-f175.google.com with SMTP id h14so26629985pfe.1
        for <netdev@vger.kernel.org>; Sat, 18 Jun 2016 16:27:20 -0700 (PDT)
In-Reply-To: <1466292400-3638-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipgre_err() can call ip6_err_gen_icmpv6_unreach() for proper
support of ipv4+gre+icmp+ipv6+... frames, used for example
by traceroute/mtr.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ip_tunnels.h | 1 +
 net/ipv4/gre_demux.c     | 1 +
 net/ipv4/ip_gre.c        | 6 ++++++
 3 files changed, 8 insertions(+)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 9222678426a1..a5e7035fb93f 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -157,6 +157,7 @@ struct tnl_ptk_info {
 	__be16 proto;
 	__be32 key;
 	__be32 seq;
+	int hdr_len;
 };
 
 #define PACKET_RCVD	0
diff --git a/net/ipv4/gre_demux.c b/net/ipv4/gre_demux.c
index de1d119a4497..b798862b6be5 100644
--- a/net/ipv4/gre_demux.c
+++ b/net/ipv4/gre_demux.c
@@ -117,6 +117,7 @@ int gre_parse_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
 		if ((*(u8 *)options & 0xF0) != 0x40)
 			hdr_len += 4;
 	}
+	tpi->hdr_len = hdr_len;
 	return hdr_len;
 }
 EXPORT_SYMBOL(gre_parse_header);
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 48eccc4e4cc5..b199a3c85dfc 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -181,6 +181,12 @@ static void ipgre_err(struct sk_buff *skb, u32 info,
 	if (!t)
 		return;
 
+#if IS_ENABLED(CONFIG_IPV6)
+       if (tpi->proto == htons(ETH_P_IPV6) &&
+           !ip6_err_gen_icmpv6_unreach(skb, iph->ihl * 4 + tpi->hdr_len, type))
+               return;
+#endif
+
 	if (t->parms.iph.daddr == 0 ||
 	    ipv4_is_multicast(t->parms.iph.daddr))
 		return;
-- 
2.8.0.rc3.226.g39d4020
