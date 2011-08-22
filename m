From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: [PATCH 2/2] sctp: Bundle HEAERTBEAT into ASCONF_ACK
Date: Tue, 23 Aug 2011 00:44:52 +0900
Message-ID: <E2795E69-CB32-4F53-AB1D-2114BDF5C2EB@sfc.wide.ad.jp>
Mime-Version: 1.0 (Apple Message framework v1244.3)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Wei Yongjun <weiyj.lk@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:57882 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751535Ab1HVPox convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 11:44:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From e7cbeb4d796fec8351ede4affbd4269346639db9 Mon Sep 17 00:00:00 2001
From: Michio Honda <micchie@sfc.wide.ad.jp>
Date: Thu, 16 Jun 2011 17:14:34 +0900
Subject: [PATCH 2/2] sctp: Bundle HEAERTBEAT into ASCONF_ACK

With this patch a HEARTBEAT chunk is bundled into the ASCONF-ACK
for ADD IP ADDRESS, confirming the new destination as quickly as
possible.

Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
---
 include/net/sctp/structs.h |    1 +
 net/sctp/associola.c       |    1 +
 net/sctp/sm_make_chunk.c   |    1 +
 net/sctp/sm_statefuns.c    |    5 +++++
 4 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index f7d9c3f..e90e7a9 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1915,6 +1915,7 @@ struct sctp_association {
 	__u32 addip_serial;
 	union sctp_addr *asconf_addr_del_pending;
 	int src_out_of_asoc_ok;
+	struct sctp_transport *new_transport;
 
 	/* SCTP AUTH: list of the endpoint shared keys.  These
 	 * keys are provided out of band by the user applicaton
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index dc16b90..152b5b3 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -282,6 +282,7 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 		asoc->peer.asconf_capable = 1;
 	asoc->asconf_addr_del_pending = NULL;
 	asoc->src_out_of_asoc_ok = 0;
+	asoc->new_transport = NULL;
 
 	/* Create an input queue.  */
 	sctp_inq_init(&asoc->base.inqueue);
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 81db4e3..0121e0a 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -3015,6 +3015,7 @@ static __be16 sctp_process_asconf_param(struct sctp_association *asoc,
 		/* Start the heartbeat timer. */
 		if (!mod_timer(&peer->hb_timer, sctp_transport_timeout(peer)))
 			sctp_transport_hold(peer);
+		asoc->new_transport = peer;
 		break;
 	case SCTP_PARAM_DEL_IP:
 		/* ADDIP 4.3 D7) If a request is received to delete the
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 49b847b..73d14fc 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -3612,6 +3612,11 @@ sctp_disposition_t sctp_sf_do_asconf(const struct sctp_endpoint *ep,
 	 */
 	asconf_ack->dest = chunk->source;
 	sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(asconf_ack));
+	if (asoc->new_transport) {
+	        sctp_sf_heartbeat(ep, asoc, type, asoc->new_transport,
+                    commands);
+		((struct sctp_association *)asoc)->new_transport = NULL;
+	}
 
 	return SCTP_DISPOSITION_CONSUME;
 }
-- 
1.7.3.2


