From: Davide Caratti <dcaratti@redhat.com>
Subject: [PATCH RFC net-next v4 4/7] net: use skb->csum_not_inet to identify packets needing crc32c
Date: Thu, 20 Apr 2017 15:38:10 +0200
Message-ID: <4f3a01b66bc46d3a2169a8ef2b4d4285e03f5894.1492692976.git.dcaratti@redhat.com>
References: <CALx6S36rem=OuN_At6qYA=se5cpuYM1N2R8efoaszvo8b8Tz5A@mail.gmail.com>
Cc: "David S . Miller" <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54284 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S946083AbdDTNjp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 09:39:45 -0400
In-Reply-To: <CALx6S36rem=OuN_At6qYA=se5cpuYM1N2R8efoaszvo8b8Tz5A@mail.gmail.com>
In-Reply-To: <cover.1492692976.git.dcaratti@redhat.com>
References: <cover.1492692976.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb->csum_not_inet carries the indication on which algorithm is needed to
compute checksum on skb in the transmit path, when skb->ip_summed is equal
to CHECKSUM_PARTIAL. If skb carries a SCTP packet and crc32c hasn't been
yet written in L4 header, skb->csum_not_inet is assigned to 1; otherwise,
assume Internet Checksum is needed and thus set skb->csum_not_inet to 0.

Suggested-by: Tom Herbert <tom@herbertland.com>
Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 include/linux/skbuff.h | 16 +++++++++-------
 net/core/dev.c         |  1 +
 net/sched/act_csum.c   |  1 +
 net/sctp/offload.c     |  1 +
 net/sctp/output.c      |  1 +
 5 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 927309e..419f4c8 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -189,12 +189,13 @@
  *
  *   NETIF_F_SCTP_CRC - This feature indicates that a device is capable of
  *     offloading the SCTP CRC in a packet. To perform this offload the stack
- *     will set ip_summed to CHECKSUM_PARTIAL and set csum_start and csum_offset
- *     accordingly. Note the there is no indication in the skbuff that the
- *     CHECKSUM_PARTIAL refers to an SCTP checksum, a driver that supports
- *     both IP checksum offload and SCTP CRC offload must verify which offload
- *     is configured for a packet presumably by inspecting packet headers; in
- *     case, skb_crc32c_csum_help is provided to compute CRC on SCTP packets.
+ *     will set set csum_start and csum_offset accordingly, set ip_summed to
+ *     CHECKSUM_PARTIAL and set csum_not_inet to 1, to provide an indication in
+ *     the skbuff that the CHECKSUM_PARTIAL refers to CRC32c.
+ *     A driver that supports both IP checksum offload and SCTP CRC32c offload
+ *     must verify which offload is configured for a packet by testing the
+ *     value of skb->csum_not_inet; skb_crc32c_csum_help is provided to resolve
+ *     CHECKSUM_PARTIAL on skbs where csum_not_inet is set to 1.
  *
  *   NETIF_F_FCOE_CRC - This feature indicates that a device is capable of
  *     offloading the FCOE CRC in a packet. To perform this offload the stack
@@ -615,6 +616,7 @@ static inline bool skb_mstamp_after(const struct skb_mstamp *t1,
  *	@wifi_acked_valid: wifi_acked was set
  *	@wifi_acked: whether frame was acked on wifi or not
  *	@no_fcs:  Request NIC to treat last 4 bytes as Ethernet FCS
+ *	@csum_not_inet: use CRC32c to resolve CHECKSUM_PARTIAL
  *	@dst_pending_confirm: need to confirm neighbour
   *	@napi_id: id of the NAPI struct this skb came from
  *	@secmark: security marking
@@ -743,7 +745,7 @@ struct sk_buff {
 	__u8			csum_valid:1;
 	__u8			csum_complete_sw:1;
 	__u8			csum_level:2;
-	__u8			__csum_bad_unused:1; /* one bit hole */
+	__u8			csum_not_inet:1;
 
 	__u8			dst_pending_confirm:1;
 #ifdef CONFIG_IPV6_NDISC_NODETYPE
diff --git a/net/core/dev.c b/net/core/dev.c
index 77a2d73..9f56f87 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2642,6 +2642,7 @@ int skb_crc32c_csum_help(struct sk_buff *skb)
 	}
 	*(__le32 *)(skb->data + offset) = crc32c_csum;
 	skb->ip_summed = CHECKSUM_NONE;
+	skb->csum_not_inet = 0;
 out:
 	return ret;
 }
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index ab6fdbd..3317a2f 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -350,6 +350,7 @@ static int tcf_csum_sctp(struct sk_buff *skb, unsigned int ihl,
 	sctph->checksum = sctp_compute_cksum(skb,
 					     skb_network_offset(skb) + ihl);
 	skb->ip_summed = CHECKSUM_NONE;
+	skb->csum_not_inet = 0;
 
 	return 1;
 }
diff --git a/net/sctp/offload.c b/net/sctp/offload.c
index 378f462..ef156ac 100644
--- a/net/sctp/offload.c
+++ b/net/sctp/offload.c
@@ -35,6 +35,7 @@
 static __le32 sctp_gso_make_checksum(struct sk_buff *skb)
 {
 	skb->ip_summed = CHECKSUM_NONE;
+	skb->csum_not_inet = 0;
 	return sctp_compute_cksum(skb, skb_transport_offset(skb));
 }
 
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 1409a87..e2edf2e 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -538,6 +538,7 @@ static int sctp_packet_pack(struct sctp_packet *packet,
 	} else {
 chksum:
 		head->ip_summed = CHECKSUM_PARTIAL;
+		head->csum_not_inet = 1;
 		head->csum_start = skb_transport_header(head) - head->head;
 		head->csum_offset = offsetof(struct sctphdr, checksum);
 	}
-- 
2.7.4
