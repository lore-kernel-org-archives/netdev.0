From: Davide Caratti <dcaratti@redhat.com>
Subject: [PATCH RFC net-next v2 3/4] net: more accurate checksumming in validate_xmit_skb
Date: Tue, 28 Feb 2017 11:32:47 +0100
Message-ID: <03f4d4bb40e78f228923dd61bc3d30f737a7621e.1488199633.git.dcaratti@redhat.com>
References: <1488202783.2713.67.camel@redhat.com>
Cc: "David S . Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "linux-sctp @ vger . kernel . org" <linux-sctp@vger.kernel.org>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>,
        Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55778 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751737AbdB1Kf3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Feb 2017 05:35:29 -0500
In-Reply-To: <1488202783.2713.67.camel@redhat.com>
In-Reply-To: <56fcd0848eae2b0693797e09500892659323546c.1488199633.git.dcaratti@redhat.com>
References: <56fcd0848eae2b0693797e09500892659323546c.1488199633.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce skb->csum_not_inet to identify not-yet-checksummed SCTP packets.
Use this bit in combination with netdev feature bit in validate_xmit_skb,
to discriminate whether skb needs crc32c or 2-complement Internet Checksum
(or none of the two, when the underlying device can do checksum offload).

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 include/linux/skbuff.h                |  1 +
 net/core/dev.c                        | 14 ++++++++++++--
 net/netfilter/ipvs/ip_vs_proto_sctp.c |  1 +
 net/netfilter/nf_nat_proto_sctp.c     |  1 +
 net/sched/act_csum.c                  |  1 +
 net/sctp/output.c                     |  1 +
 6 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 0671131..236b7d9 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -759,6 +759,7 @@ struct sk_buff {
 	__u8			tc_redirected:1;
 	__u8			tc_from_ingress:1;
 #endif
+	__u8			csum_not_inet:1;
 
 #ifdef CONFIG_NET_SCHED
 	__u16			tc_index;	/* traffic control index */
diff --git a/net/core/dev.c b/net/core/dev.c
index b9fb843..fae3217 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2614,6 +2614,7 @@ int skb_sctp_csum_help(struct sk_buff *skb)
 	}
 	*(__le32 *)(skb->data + offset) = crc32c_csum;
 	skb->ip_summed = CHECKSUM_NONE;
+	skb->csum_not_inet = 0;
 out:
 	return ret;
 }
@@ -2960,6 +2961,16 @@ static struct sk_buff *validate_xmit_vlan(struct sk_buff *skb,
 	return skb;
 }
 
+static int skb_csum_hwoffload_help(struct sk_buff *skb,
+				   netdev_features_t features)
+{
+	if (unlikely(skb->csum_not_inet))
+		return !(features & NETIF_F_SCTP_CRC) ?
+				skb_sctp_csum_help(skb) : 0;
+
+	return !(features & NETIF_F_CSUM_MASK) ? skb_checksum_help(skb) : 0;
+}
+
 static struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device *dev)
 {
 	netdev_features_t features;
@@ -2995,8 +3006,7 @@ static struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device
 			else
 				skb_set_transport_header(skb,
 							 skb_checksum_start_offset(skb));
-			if (!(features & NETIF_F_CSUM_MASK) &&
-			    skb_checksum_help(skb))
+			if (skb_csum_hwoffload_help(skb, features))
 				goto out_kfree_skb;
 		}
 	}
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index d952d67..4972a60 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -81,6 +81,7 @@ static void sctp_nat_csum(struct sk_buff *skb, sctp_sctphdr_t *sctph,
 			  unsigned int sctphoff)
 {
 	sctph->checksum = sctp_compute_cksum(skb, sctphoff);
+	skb->csum_not_inet = 0;
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 }
 
diff --git a/net/netfilter/nf_nat_proto_sctp.c b/net/netfilter/nf_nat_proto_sctp.c
index 31d3586..9459b88 100644
--- a/net/netfilter/nf_nat_proto_sctp.c
+++ b/net/netfilter/nf_nat_proto_sctp.c
@@ -49,6 +49,7 @@ sctp_manip_pkt(struct sk_buff *skb,
 
 	if (skb->ip_summed != CHECKSUM_PARTIAL) {
 		hdr->checksum = sctp_compute_cksum(skb, hdroff);
+		skb->csum_not_inet = 0;
 		skb->ip_summed = CHECKSUM_NONE;
 	}
 
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index e978ccd4..85cb150 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -337,6 +337,7 @@ static int tcf_csum_sctp(struct sk_buff *skb, unsigned int ihl,
 
 	sctph->checksum = sctp_compute_cksum(skb,
 					     skb_network_offset(skb) + ihl);
+	skb->csum_not_inet = 0;
 	skb->ip_summed = CHECKSUM_NONE;
 
 	return 1;
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 814eac0..0dc227b 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -528,6 +528,7 @@ static int sctp_packet_pack(struct sctp_packet *packet,
 	} else {
 chksum:
 		head->ip_summed = CHECKSUM_PARTIAL;
+		head->csum_not_inet = 1;
 		head->csum_start = skb_transport_header(head) - head->head;
 		head->csum_offset = offsetof(struct sctphdr, checksum);
 	}
-- 
2.7.4
