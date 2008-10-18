From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: 2.6.27 [BUG-FIX] [PATCH 1/1] dccp: Port redirection support for
	DCCP
Date: Sat, 18 Oct 2008 11:21:18 +0200
Message-ID: <20081018092118.GA22685@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hidden@sch.bme.hu
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:40572 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751018AbYJRJVb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Oct 2008 05:21:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave, can you please consider the patch below. This fixes a 
bug for DCCP in the current netdev-2.6 tree (2.6.27).

---------------------------> 2.6.27 patch <-----------------------------
dccp: Port redirection support for DCCP

Commit a3116ac5c216fc3c145906a46df9ce542ff7dcf2 from 1st October ("tcp: Port
redirection support for TCP") broke DCCP skb lookup by changing inet_csk_clone,
which is used by DCCP to generate the child socket after the handshake.

This patch updates DCCP to use 'loc_port' instead of 'sport', which fixes the
problem, and thus inheriting port redirection support via the new interface.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ipv6.c      |    2 +-
 net/dccp/minisocks.c |    1 +
 net/dccp/output.c    |    2 +-
 3 files changed, 3 insertions(+), 2 deletions(-)

--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -309,6 +309,7 @@ void dccp_reqsk_init(struct request_sock
 	struct dccp_request_sock *dreq = dccp_rsk(req);
 
 	inet_rsk(req)->rmt_port	  = dccp_hdr(skb)->dccph_sport;
+	inet_rsk(req)->loc_port	  = dccp_hdr(skb)->dccph_dport;
 	inet_rsk(req)->acked	  = 0;
 	req->rcv_wnd		  = sysctl_dccp_feat_sequence_window;
 	dreq->dreq_timestamp_echo = 0;
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -259,7 +259,7 @@ static int dccp_v6_send_response(struct 
 	fl.fl6_flowlabel = 0;
 	fl.oif = ireq6->iif;
 	fl.fl_ip_dport = inet_rsk(req)->rmt_port;
-	fl.fl_ip_sport = inet_sk(sk)->sport;
+	fl.fl_ip_sport = inet_rsk(req)->loc_port;
 	security_req_classify_flow(req, &fl);
 
 	opt = np->opt;
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -347,7 +347,7 @@ struct sk_buff *dccp_make_response(struc
 	/* Build and checksum header */
 	dh = dccp_zeroed_hdr(skb, dccp_header_size);
 
-	dh->dccph_sport	= inet_sk(sk)->sport;
+	dh->dccph_sport	= inet_rsk(req)->loc_port;
 	dh->dccph_dport	= inet_rsk(req)->rmt_port;
 	dh->dccph_doff	= (dccp_header_size +
 			   DCCP_SKB_CB(skb)->dccpd_opt_len) / 4;
-- 
