From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH v2] sctp: align MTU to a word
Date: Sat, 19 Mar 2016 12:17:20 -0300
Message-ID: <1458400640-25448-1-git-send-email-marcelo.leitner@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44968 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754118AbcCSPRf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Mar 2016 11:17:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SCTP is a protocol that is aligned to a word (4 bytes). Thus using bare
MTU can sometimes return values that are not aligned, like for loopback,
which is 65536 but ipv4_mtu() limits that to 65535. This mis-alignment
will cause the last non-aligned bytes to never be used and can cause
issues with congestion control.

So it's better to just consider a lower MTU and keep congestion control
calcs saner as they are based on PMTU.

Same applies to icmp frag needed messages, which is also fixed by this
patch.

One other effect of this is the inability to send MTU-sized packet
without queueing or fragmentation and without hitting Nagle. As the
check performed at sctp_packet_can_append_data():

if (chunk->skb->len + q->out_qlen >= transport->pathmtu - packet->overhead)
	/* Enough data queued to fill a packet */
	return SCTP_XMIT_OK;

with the above example of MTU, if there are no other messages queued,
one cannot send a packet that just fits one packet (65532 bytes) and
without causing DATA chunk fragmentation or a delay.

v2:
 - Added WORD_TRUNC macro

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 include/net/sctp/sctp.h | 8 +++++---
 net/sctp/associola.c    | 3 ++-
 net/sctp/input.c        | 3 ++-
 net/sctp/transport.c    | 4 ++--
 4 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 835aa2ed987092634a4242314e9eabb51d1e4e35..ad2136caa7d65fdc0f51e4c7ad3a526c2f39660d 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -82,6 +82,11 @@
 #define SCTP_PROTOSW_FLAG INET_PROTOSW_PERMANENT
 #endif
 
+/* Round an int up to the next multiple of 4.  */
+#define WORD_ROUND(s) (((s)+3)&~3)
+/* Truncate to the previous multiple of 4.  */
+#define WORD_TRUNC(s) ((s)&~3)
+
 /*
  * Function declarations.
  */
@@ -475,9 +480,6 @@ for (pos = chunk->subh.fwdtsn_hdr->skip;\
      (void *)pos <= (void *)chunk->subh.fwdtsn_hdr->skip + end - sizeof(struct sctp_fwdtsn_skip);\
      pos++)
 
-/* Round an int up to the next multiple of 4.  */
-#define WORD_ROUND(s) (((s)+3)&~3)
-
 /* External references. */
 
 extern struct proto sctp_prot;
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index a19b3e60770382507050a56a172ffc5adb2f497a..e1849f3714adc47c22b92d8aaeba40b0287d2ba7 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1406,7 +1406,8 @@ void sctp_assoc_sync_pmtu(struct sock *sk, struct sctp_association *asoc)
 	list_for_each_entry(t, &asoc->peer.transport_addr_list,
 				transports) {
 		if (t->pmtu_pending && t->dst) {
-			sctp_transport_update_pmtu(sk, t, dst_mtu(t->dst));
+			sctp_transport_update_pmtu(sk, t,
+						   WORD_TRUNC(dst_mtu(t->dst)));
 			t->pmtu_pending = 0;
 		}
 		if (!pmtu || (t->pathmtu < pmtu))
diff --git a/net/sctp/input.c b/net/sctp/input.c
index db76f1ab4ac2cb16b4568f0d9fbe4e3b90deaa1c..00b8445364e3d5045f0ff71d9e836c18e7c6a401 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -606,7 +606,8 @@ void sctp_v4_err(struct sk_buff *skb, __u32 info)
 
 		/* PMTU discovery (RFC1191) */
 		if (ICMP_FRAG_NEEDED == code) {
-			sctp_icmp_frag_needed(sk, asoc, transport, info);
+			sctp_icmp_frag_needed(sk, asoc, transport,
+					      WORD_TRUNC(info));
 			goto out_unlock;
 		} else {
 			if (ICMP_PROT_UNREACH == code) {
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index d517153891a6efca6242ce1a4b3d86afb9026542..9b6b48c7524e4b441a151b80f0babec81f539d49 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -226,7 +226,7 @@ void sctp_transport_pmtu(struct sctp_transport *transport, struct sock *sk)
 	}
 
 	if (transport->dst) {
-		transport->pathmtu = dst_mtu(transport->dst);
+		transport->pathmtu = WORD_TRUNC(dst_mtu(transport->dst));
 	} else
 		transport->pathmtu = SCTP_DEFAULT_MAXSEGMENT;
 }
@@ -280,7 +280,7 @@ void sctp_transport_route(struct sctp_transport *transport,
 		return;
 	}
 	if (transport->dst) {
-		transport->pathmtu = dst_mtu(transport->dst);
+		transport->pathmtu = WORD_TRUNC(dst_mtu(transport->dst));
 
 		/* Initialize sk->sk_rcv_saddr, if the transport is the
 		 * association's active path for getsockname().
-- 
2.5.0
