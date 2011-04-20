From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: [PATCH net-next-2.6 v4 5/5] sctp: Add ADD/DEL ASCONF handling at the receiver
Date: Thu, 21 Apr 2011 04:24:55 +0900
Message-ID: <AD392EDF-F72C-407A-9FBC-4F3F2902687A@sfc.wide.ad.jp>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: lksctp-developers@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:58630 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754541Ab1DTTY4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 15:24:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With this patch, ASCONF receiver supports deletion of the source address of the ASCONF chunk when the ADDIP co-located in the earlier parameter.  

Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
---
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index de98665..a5d673b 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2914,6 +2914,7 @@ static __be16 sctp_process_asconf_param(struct sctp_association *asoc,
 	struct sctp_af *af;
 	union sctp_addr	addr;
 	union sctp_addr_param *addr_param;
+	int del_srcaddr_ok = 0;
 
 	addr_param = (union sctp_addr_param *)
 			((void *)asconf_param + sizeof(sctp_addip_param_t));
@@ -2973,6 +2974,7 @@ static __be16 sctp_process_asconf_param(struct sctp_association *asoc,
 		/* Start the heartbeat timer. */
 		if (!mod_timer(&peer->hb_timer, sctp_transport_timeout(peer)))
 			sctp_transport_hold(peer);
+		del_srcaddr_ok = 1;
 		break;
 	case SCTP_PARAM_DEL_IP:
 		/* ADDIP 4.3 D7) If a request is received to delete the
@@ -2990,7 +2992,8 @@ static __be16 sctp_process_asconf_param(struct sctp_association *asoc,
 		 * an Error Cause TLV set to the new error code 'Request to
 		 * Delete Source IP Address'
 		 */
-		if (sctp_cmp_addr_exact(sctp_source(asconf), &addr))
+		if (sctp_cmp_addr_exact(sctp_source(asconf), &addr) &&
+		    !del_srcaddr_ok)
 			return SCTP_ERROR_DEL_SRC_IP;
 
 		/* Section 4.2.2

