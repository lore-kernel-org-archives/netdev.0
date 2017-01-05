From: Davide Caratti <dcaratti@redhat.com>
Subject: [PATCH net-next 2/2] net/sched: act_csum: compute crc32c on SCTP packets
Date: Thu,  5 Jan 2017 17:59:03 +0100
Message-ID: <c9ee721fd7816b9d30939f23783f50f9aeb00d66.1483630849.git.dcaratti@redhat.com>
References: <cover.1483630849.git.dcaratti@redhat.com>
Cc: netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S . Miller" <davem@davemloft.net>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56728 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754118AbdAERAJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Jan 2017 12:00:09 -0500
In-Reply-To: <cover.1483630849.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

modify act_csum to compute crc32c on IPv4/IPv6 packets having SCTP in
their payload, and extend UAPI definitions accordingly.

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 include/uapi/linux/tc_act/tc_csum.h |  3 ++-
 net/sched/act_csum.c                | 32 ++++++++++++++++++++++++++++++++
 2 files changed, 34 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/tc_act/tc_csum.h b/include/uapi/linux/tc_act/tc_csum.h
index 8ac8041..58d457f 100644
--- a/include/uapi/linux/tc_act/tc_csum.h
+++ b/include/uapi/linux/tc_act/tc_csum.h
@@ -21,7 +21,8 @@ enum {
 	TCA_CSUM_UPDATE_FLAG_IGMP    = 4,
 	TCA_CSUM_UPDATE_FLAG_TCP     = 8,
 	TCA_CSUM_UPDATE_FLAG_UDP     = 16,
-	TCA_CSUM_UPDATE_FLAG_UDPLITE = 32
+	TCA_CSUM_UPDATE_FLAG_UDPLITE = 32,
+	TCA_CSUM_UPDATE_FLAG_SCTP    = 64
 };
 
 struct tc_csum {
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index a0edd80..620ac9b 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -30,6 +30,7 @@
 #include <net/tcp.h>
 #include <net/udp.h>
 #include <net/ip6_checksum.h>
+#include <net/sctp/checksum.h>
 
 #include <net/act_api.h>
 
@@ -322,6 +323,25 @@ static int tcf_csum_ipv6_udp(struct sk_buff *skb, unsigned int ihl,
 	return 1;
 }
 
+static int tcf_csum_sctp(struct sk_buff *skb, unsigned int ihl,
+			 unsigned int ipl)
+{
+	struct sctphdr *sctph;
+
+	if (skb_is_gso(skb) && skb_shinfo(skb)->gso_type & SKB_GSO_SCTP)
+		return 1;
+
+	sctph = tcf_csum_skb_nextlayer(skb, ihl, ipl, sizeof(*sctph));
+	if (!sctph)
+		return 0;
+
+	sctph->checksum = sctp_compute_cksum(skb,
+					     skb_network_offset(skb) + ihl);
+	skb->ip_summed = CHECKSUM_NONE;
+
+	return 1;
+}
+
 static int tcf_csum_ipv4(struct sk_buff *skb, u32 update_flags)
 {
 	const struct iphdr *iph;
@@ -365,6 +385,12 @@ static int tcf_csum_ipv4(struct sk_buff *skb, u32 update_flags)
 					       ntohs(iph->tot_len), 1))
 				goto fail;
 		break;
+	case IPPROTO_SCTP:
+		if (update_flags & TCA_CSUM_UPDATE_FLAG_SCTP)
+			if (!tcf_csum_sctp(skb, iph->ihl * 4,
+					   ntohs(iph->tot_len)))
+				goto fail;
+		break;
 	}
 
 	if (update_flags & TCA_CSUM_UPDATE_FLAG_IPV4HDR) {
@@ -481,6 +507,12 @@ static int tcf_csum_ipv6(struct sk_buff *skb, u32 update_flags)
 						       pl + sizeof(*ip6h), 1))
 					goto fail;
 			goto done;
+		case IPPROTO_SCTP:
+			if (update_flags & TCA_CSUM_UPDATE_FLAG_SCTP)
+				if (!tcf_csum_sctp(skb, hl,
+						   pl + sizeof(*ip6h)))
+					goto fail;
+			goto done;
 		default:
 			goto ignore_skb;
 		}
-- 
2.7.4
