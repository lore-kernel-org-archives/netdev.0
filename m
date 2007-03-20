From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: [PATCH 30/31] [DCCP]: Sample RTT from SYN exchange
Date: Tue, 20 Mar 2007 20:18:28 -0300
Message-ID: <20070320231828.GS17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.231]:40598 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933879AbXCTXSd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 19:18:33 -0400
Received: by wx-out-0506.google.com with SMTP id h31so67362wxd
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 16:18:32 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Function:
---------
 This patch acquires the RTT of the initial SYN (Request/Response) exchange
 and stores it in an unused field of dccp_sock.

Purpose:
--------
 The purpose is primarily to provide an initial RTT sample for CCIDs. CCID 3
 in particular benefits from such a sample; using the RTT of the SYN exchange
 is recommended in an erratum to RFC 4342, and in draft-ietf-dccp-rfc3448bis.

Implementation note:
--------------------
 Double use is made of the `icsk_ack.lrcvtime' field by #defining an alias for it.
 This is justified (1) by exploiting that Acks are only meaningful when the client
 has reached the OPEN state and the alias is used before reaching this state and
 (2) since there is currently no other use for this field in the entire DCCP code.
 (NB: Since the RTT sample is currently used only by CCID 3, it could be wrapped in
  Kconfig #ifdef options, but this clutters code and so has not been done.)

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 include/linux/dccp.h |    2 ++
 net/dccp/input.c     |    8 ++++++++
 net/dccp/options.c   |    8 ++++++++
 3 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index fdd4217..e668cf5 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -481,10 +481,12 @@ struct dccp_ackvec;
  * @dccps_hc_rx_insert_options -
  * @dccps_hc_tx_insert_options -
  * @dccps_xmit_timer - timer for when CCID is not ready to send
+ * @dccps_syn_rtt - RTT sample from Request/Response exchange (in usecs)
  */
 struct dccp_sock {
 	/* inet_connection_sock has to be the first member of dccp_sock */
 	struct inet_connection_sock	dccps_inet_connection;
+#define dccps_syn_rtt			dccps_inet_connection.icsk_ack.lrcvtime
 	__u64				dccps_swl;
 	__u64				dccps_swh;
 	__u64				dccps_awl;
diff --git a/net/dccp/input.c b/net/dccp/input.c
index bd578c8..da6ec18 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -300,6 +300,14 @@ static int dccp_rcv_request_sent_state_process(struct sock *sk,
 		if (dccp_parse_options(sk, skb))
 			goto out_invalid_packet;
 
+		/* Obtain RTT sample from SYN exchange (used by CCID 3) */
+		if (dp->dccps_options_received.dccpor_timestamp_echo) {
+			struct timeval now;
+
+			dccp_timestamp(sk, &now);
+			dp->dccps_syn_rtt = dccp_sample_rtt(sk, &now, NULL);
+		}
+
 		if (dccp_msk(sk)->dccpms_send_ack_vector &&
 		    dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
 				    DCCP_SKB_CB(skb)->dccpd_seq,
diff --git a/net/dccp/options.c b/net/dccp/options.c
index 9074ca7..14b6212 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -563,6 +563,14 @@ int dccp_insert_options(struct sock *sk, struct sk_buff *skb)
 	    dccp_insert_options_feat(sk, skb))
 		return -1;
 
+	/*
+	 * Obtain RTT sample from Request/Response exchange.
+	 * This is currently used in CCID 3 initialisation.
+	 */
+	if (DCCP_SKB_CB(skb)->dccpd_type == DCCP_PKT_REQUEST &&
+	    dccp_insert_option_timestamp(sk, skb))
+		return -1;
+
 	/* XXX: insert other options when appropriate */
 
 	if (DCCP_SKB_CB(skb)->dccpd_opt_len != 0) {
-- 
1.5.0.3

