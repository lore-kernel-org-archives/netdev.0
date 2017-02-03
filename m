From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 16/27] netfilter: nft_meta: deal with PACKET_LOOPBACK in netdev family
Date: Fri,  3 Feb 2017 13:25:27 +0100
Message-ID: <1486124738-3013-17-git-send-email-pablo@netfilter.org>
References: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58880 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753254AbdBCM2l (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Feb 2017 07:28:41 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id ADA63C5103
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:40 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 9AFC3DA793
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:40 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 86B49DA814
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:38 +0100 (CET)
In-Reply-To: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

After adding the following nft rule, then ping 224.0.0.1:
  # nft add rule netdev t c pkttype host counter

The warning complain message will be printed out again and again:
  WARNING: CPU: 0 PID: 10182 at net/netfilter/nft_meta.c:163 \
           nft_meta_get_eval+0x3fe/0x460 [nft_meta]
  [...]
  Call Trace:
  <IRQ>
  dump_stack+0x85/0xc2
  __warn+0xcb/0xf0
  warn_slowpath_null+0x1d/0x20
  nft_meta_get_eval+0x3fe/0x460 [nft_meta]
  nft_do_chain+0xff/0x5e0 [nf_tables]

So we should deal with PACKET_LOOPBACK in netdev family too. For ipv4,
convert it to PACKET_BROADCAST/MULTICAST according to the destination
address's type; For ipv6, convert it to PACKET_MULTICAST directly.

Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_meta.c | 28 +++++++++++++++++++++++++++-
 1 file changed, 27 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index 9a22b24346b8..e1f5ca9b423b 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -156,8 +156,34 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 		case NFPROTO_IPV6:
 			*dest = PACKET_MULTICAST;
 			break;
+		case NFPROTO_NETDEV:
+			switch (skb->protocol) {
+			case htons(ETH_P_IP): {
+				int noff = skb_network_offset(skb);
+				struct iphdr *iph, _iph;
+
+				iph = skb_header_pointer(skb, noff,
+							 sizeof(_iph), &_iph);
+				if (!iph)
+					goto err;
+
+				if (ipv4_is_multicast(iph->daddr))
+					*dest = PACKET_MULTICAST;
+				else
+					*dest = PACKET_BROADCAST;
+
+				break;
+			}
+			case htons(ETH_P_IPV6):
+				*dest = PACKET_MULTICAST;
+				break;
+			default:
+				WARN_ON_ONCE(1);
+				goto err;
+			}
+			break;
 		default:
-			WARN_ON(1);
+			WARN_ON_ONCE(1);
 			goto err;
 		}
 		break;
-- 
2.1.4
