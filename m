From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net] sctp: fix spinfo_srtt to be in msecs and not jiffies
Date: Wed, 14 Jun 2017 16:08:59 -0300
Message-ID: <ed45c6f580535de366377e20af519ecff5bdf28d.1497466458.git.marcelo.leitner@gmail.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:35139 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751670AbdFNTJ3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 15:09:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 6458 (SCTP Sockets API) Section 8.2.2.  Peer Address Information
(SCTP_GET_PEER_ADDR_INFO) defines that spinfo_srtt is in miliseconds,
yet we were using it in jiffies.

Fix it by converting before assigning, similarly to RTO.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
I hope this is not considered UAPI breakage. This is exported via
getsockopt() calls.

 net/sctp/socket.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 5f58dd03e3ace38b9c4babbe2d92f0a3f98a4b68..e51eacbf9ec8248661e41c5c12578b6b8b75487d 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4542,7 +4542,7 @@ int sctp_get_sctp_info(struct sock *sk, struct sctp_association *asoc,
 	       sizeof(struct sockaddr_storage));
 	info->sctpi_p_state = prim->state;
 	info->sctpi_p_cwnd = prim->cwnd;
-	info->sctpi_p_srtt = prim->srtt;
+	info->sctpi_p_srtt = jiffies_to_msecs(prim->srtt);
 	info->sctpi_p_rto = jiffies_to_msecs(prim->rto);
 	info->sctpi_p_hbinterval = prim->hbinterval;
 	info->sctpi_p_pathmaxrxt = prim->pathmaxrxt;
@@ -4738,7 +4738,7 @@ static int sctp_getsockopt_sctp_status(struct sock *sk, int len,
 		(union sctp_addr *)&status.sstat_primary.spinfo_address);
 	status.sstat_primary.spinfo_state = transport->state;
 	status.sstat_primary.spinfo_cwnd = transport->cwnd;
-	status.sstat_primary.spinfo_srtt = transport->srtt;
+	status.sstat_primary.spinfo_srtt = jiffies_to_msecs(transport->srtt);
 	status.sstat_primary.spinfo_rto = jiffies_to_msecs(transport->rto);
 	status.sstat_primary.spinfo_mtu = transport->pathmtu;
 
@@ -4798,7 +4798,7 @@ static int sctp_getsockopt_peer_addr_info(struct sock *sk, int len,
 	pinfo.spinfo_assoc_id = sctp_assoc2id(transport->asoc);
 	pinfo.spinfo_state = transport->state;
 	pinfo.spinfo_cwnd = transport->cwnd;
-	pinfo.spinfo_srtt = transport->srtt;
+	pinfo.spinfo_srtt = jiffies_to_msecs(transport->srtt);
 	pinfo.spinfo_rto = jiffies_to_msecs(transport->rto);
 	pinfo.spinfo_mtu = transport->pathmtu;
 
-- 
2.9.4
