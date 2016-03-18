From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH] sctp: align MTU to a word
Date: Fri, 18 Mar 2016 18:39:16 -0300
Message-ID: <1458337159-22792-1-git-send-email-marcelo.leitner@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54551 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932364AbcCRVju (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2016 17:39:50 -0400
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

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/associola.c | 2 +-
 net/sctp/input.c     | 2 +-
 net/sctp/transport.c | 4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index a19b3e60770382507050a56a172ffc5adb2f497a..f89862194093f160c2801c22050690789d956b44 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1406,7 +1406,7 @@ void sctp_assoc_sync_pmtu(struct sock *sk, struct sctp_association *asoc)
 	list_for_each_entry(t, &asoc->peer.transport_addr_list,
 				transports) {
 		if (t->pmtu_pending && t->dst) {
-			sctp_transport_update_pmtu(sk, t, dst_mtu(t->dst));
+			sctp_transport_update_pmtu(sk, t, dst_mtu(t->dst) & ~3);
 			t->pmtu_pending = 0;
 		}
 		if (!pmtu || (t->pathmtu < pmtu))
diff --git a/net/sctp/input.c b/net/sctp/input.c
index db76f1ab4ac2cb16b4568f0d9fbe4e3b90deaa1c..fda32738986971648ff73b05318b8a306d496446 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -606,7 +606,7 @@ void sctp_v4_err(struct sk_buff *skb, __u32 info)
 
 		/* PMTU discovery (RFC1191) */
 		if (ICMP_FRAG_NEEDED == code) {
-			sctp_icmp_frag_needed(sk, asoc, transport, info);
+			sctp_icmp_frag_needed(sk, asoc, transport, info & ~3);
 			goto out_unlock;
 		} else {
 			if (ICMP_PROT_UNREACH == code) {
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index d517153891a6efca6242ce1a4b3d86afb9026542..22219e8e6e510469d9d5868245bd7e2a9e2faf78 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -226,7 +226,7 @@ void sctp_transport_pmtu(struct sctp_transport *transport, struct sock *sk)
 	}
 
 	if (transport->dst) {
-		transport->pathmtu = dst_mtu(transport->dst);
+		transport->pathmtu = dst_mtu(transport->dst) & ~3;
 	} else
 		transport->pathmtu = SCTP_DEFAULT_MAXSEGMENT;
 }
@@ -280,7 +280,7 @@ void sctp_transport_route(struct sctp_transport *transport,
 		return;
 	}
 	if (transport->dst) {
-		transport->pathmtu = dst_mtu(transport->dst);
+		transport->pathmtu = dst_mtu(transport->dst) & ~3;
 
 		/* Initialize sk->sk_rcv_saddr, if the transport is the
 		 * association's active path for getsockname().
-- 
2.5.0
