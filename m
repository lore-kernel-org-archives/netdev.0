From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH 4/4] [IPV6]: Clean up hop-by-hop options handler.
Date: Wed, 19 Apr 2006 00:21:13 +0900 (JST)
Message-ID: <20060419.002113.53952911.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:5651 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S932277AbWDRPSc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Apr 2006 11:18:32 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPV6]: Clean up hop-by-hop options handler.

- Removed unused argument (nhoff) for ipv6_parse_hopopts().
- Make ipv6_parse_hopopts() to align with other extension header
  handlers.
- Removed pointless assignment (hdr), which is not used afterwards.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

---

 include/net/ipv6.h   |    2 +-
 net/ipv6/exthdrs.c   |    4 ++--
 net/ipv6/ip6_input.c |    3 +--
 3 files changed, 4 insertions(+), 5 deletions(-)

e261b91167cad07c4639dffb72ecabedb4ed9e49
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 6d6f063..4abedb8 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -230,7 +230,7 @@ extern int 			ip6_ra_control(struct sock
 					       void (*destructor)(struct sock *));
 
 
-extern int			ipv6_parse_hopopts(struct sk_buff *skb, int);
+extern int			ipv6_parse_hopopts(struct sk_buff *skb);
 
 extern struct ipv6_txoptions *  ipv6_dup_options(struct sock *sk, struct ipv6_txoptions *opt);
 extern struct ipv6_txoptions *	ipv6_renew_options(struct sock *sk, struct ipv6_txoptions *opt,
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index d88cab7..a18d425 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -485,7 +485,7 @@ static struct tlvtype_proc tlvprochopopt
 	{ -1, }
 };
 
-int ipv6_parse_hopopts(struct sk_buff *skb, int nhoff)
+int ipv6_parse_hopopts(struct sk_buff *skb)
 {
 	struct inet6_skb_parm *opt = IP6CB(skb);
 
@@ -505,7 +505,7 @@ int ipv6_parse_hopopts(struct sk_buff *s
 	if (ip6_parse_tlv(tlvprochopopt_lst, skb)) {
 		skb->h.raw += (skb->h.raw[1]+1)<<3;
 		opt->nhoff = sizeof(struct ipv6hdr);
-		return sizeof(struct ipv6hdr);
+		return 1;
 	}
 	return -1;
 }
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 29f7359..aceee25 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -114,11 +114,10 @@ int ipv6_rcv(struct sk_buff *skb, struct
 	}
 
 	if (hdr->nexthdr == NEXTHDR_HOP) {
-		if (ipv6_parse_hopopts(skb, IP6CB(skb)->nhoff) < 0) {
+		if (ipv6_parse_hopopts(skb) < 0) {
 			IP6_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
 			return 0;
 		}
-		hdr = skb->nh.ipv6h;
 	}
 
 	return NF_HOOK(PF_INET6,NF_IP6_PRE_ROUTING, skb, dev, NULL, ip6_rcv_finish);
-- 
1.0.8

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
