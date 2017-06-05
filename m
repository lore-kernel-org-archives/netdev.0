From: Richard Haines <richard_c_haines-FhtRXb7CoQBt1OO0OYaSVA@public.gmane.org>
Subject: [PATCH] net/ipv6: Fix CALIPSO causing GPF with datagram support
Date: Mon,  5 Jun 2017 16:44:40 +0100
Message-ID: <20170605154440.2434-1-richard_c_haines@btinternet.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
To: paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org
Return-path: <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Post: <mailto:selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Help: <mailto:selinux-request-+05T5uksL2qpZYMLLGbcSA@public.gmane.org?subject=help>
Errors-To: selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
Sender: "Selinux" <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: netdev.vger.kernel.org

When using CALIPSO with IPPROTO_UDP it is possible to trigger a GPF as the
IP header may have moved.

Also update the payload length after adding the CALIPSO option.

Signed-off-by: Richard Haines <richard_c_haines-FhtRXb7CoQBt1OO0OYaSVA@public.gmane.org>
---
 net/ipv6/calipso.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/calipso.c b/net/ipv6/calipso.c
index 37ac9de..8d772fe 100644
--- a/net/ipv6/calipso.c
+++ b/net/ipv6/calipso.c
@@ -1319,7 +1319,7 @@ static int calipso_skbuff_setattr(struct sk_buff *skb,
 	struct ipv6hdr *ip6_hdr;
 	struct ipv6_opt_hdr *hop;
 	unsigned char buf[CALIPSO_MAX_BUFFER];
-	int len_delta, new_end, pad;
+	int len_delta, new_end, pad, payload;
 	unsigned int start, end;
 
 	ip6_hdr = ipv6_hdr(skb);
@@ -1346,6 +1346,8 @@ static int calipso_skbuff_setattr(struct sk_buff *skb,
 	if (ret_val < 0)
 		return ret_val;
 
+	ip6_hdr = ipv6_hdr(skb); /* Reset as skb_cow() may have moved it */
+
 	if (len_delta) {
 		if (len_delta > 0)
 			skb_push(skb, len_delta);
@@ -1355,6 +1357,8 @@ static int calipso_skbuff_setattr(struct sk_buff *skb,
 			sizeof(*ip6_hdr) + start);
 		skb_reset_network_header(skb);
 		ip6_hdr = ipv6_hdr(skb);
+		payload = ntohs(ip6_hdr->payload_len);
+		ip6_hdr->payload_len = htons(payload + len_delta);
 	}
 
 	hop = (struct ipv6_opt_hdr *)(ip6_hdr + 1);
-- 
2.9.4
