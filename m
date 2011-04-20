From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH net-next-2.6 8/9] sctp: make heartbeat information in sctp_make_heartbeat()
Date: Wed, 20 Apr 2011 15:31:47 +0800
Message-ID: <4DAE8BE3.2050607@cn.fujitsu.com>
References: <4DAE8A27.3040007@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52633 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751478Ab1DTHbn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 03:31:43 -0400
In-Reply-To: <4DAE8A27.3040007@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make heartbeat information in sctp_make_heartbeat() instead
of make it in sctp_sf_heartbeat() directly for common using.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/sm.h    |    4 +---
 net/sctp/sm_make_chunk.c |   18 +++++++++++++-----
 net/sctp/sm_statefuns.c  |   11 +----------
 3 files changed, 15 insertions(+), 18 deletions(-)

diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index 9352d12..652f09b 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -232,9 +232,7 @@ struct sctp_chunk *sctp_make_violation_paramlen(const struct sctp_association *,
 				   const struct sctp_chunk *,
 				   struct sctp_paramhdr *);
 struct sctp_chunk *sctp_make_heartbeat(const struct sctp_association *,
-				  const struct sctp_transport *,
-				  const void *payload,
-				  const size_t paylen);
+				  const struct sctp_transport *);
 struct sctp_chunk *sctp_make_heartbeat_ack(const struct sctp_association *,
 				      const struct sctp_chunk *,
 				      const void *payload,
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index a7b65e9..58eb27f 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1075,20 +1075,28 @@ nodata:
 
 /* Make a HEARTBEAT chunk.  */
 struct sctp_chunk *sctp_make_heartbeat(const struct sctp_association *asoc,
-				  const struct sctp_transport *transport,
-				  const void *payload, const size_t paylen)
+				  const struct sctp_transport *transport)
 {
-	struct sctp_chunk *retval = sctp_make_chunk(asoc, SCTP_CID_HEARTBEAT,
-						    0, paylen);
+	struct sctp_chunk *retval;
+	sctp_sender_hb_info_t hbinfo;
+
+	retval = sctp_make_chunk(asoc, SCTP_CID_HEARTBEAT, 0, sizeof(hbinfo));
 
 	if (!retval)
 		goto nodata;
 
+	hbinfo.param_hdr.type = SCTP_PARAM_HEARTBEAT_INFO;
+	hbinfo.param_hdr.length = htons(sizeof(sctp_sender_hb_info_t));
+	hbinfo.daddr = transport->ipaddr;
+	hbinfo.sent_at = jiffies;
+	hbinfo.hb_nonce = transport->hb_nonce;
+
 	/* Cast away the 'const', as this is just telling the chunk
 	 * what transport it belongs to.
 	 */
 	retval->transport = (struct sctp_transport *) transport;
-	retval->subh.hbs_hdr = sctp_addto_chunk(retval, paylen, payload);
+	retval->subh.hbs_hdr = sctp_addto_chunk(retval, sizeof(hbinfo),
+						&hbinfo);
 
 nodata:
 	return retval;
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index ab94932..736847e 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -941,18 +941,9 @@ static sctp_disposition_t sctp_sf_heartbeat(const struct sctp_endpoint *ep,
 {
 	struct sctp_transport *transport = (struct sctp_transport *) arg;
 	struct sctp_chunk *reply;
-	sctp_sender_hb_info_t hbinfo;
-	size_t paylen = 0;
-
-	hbinfo.param_hdr.type = SCTP_PARAM_HEARTBEAT_INFO;
-	hbinfo.param_hdr.length = htons(sizeof(sctp_sender_hb_info_t));
-	hbinfo.daddr = transport->ipaddr;
-	hbinfo.sent_at = jiffies;
-	hbinfo.hb_nonce = transport->hb_nonce;
 
 	/* Send a heartbeat to our peer.  */
-	paylen = sizeof(sctp_sender_hb_info_t);
-	reply = sctp_make_heartbeat(asoc, transport, &hbinfo, paylen);
+	reply = sctp_make_heartbeat(asoc, transport);
 	if (!reply)
 		return SCTP_DISPOSITION_NOMEM;
 
-- 
1.6.5.2


