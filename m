From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next v2 1/4] sctp: remove the duplicate initialize
Date: Fri, 8 Nov 2013 14:17:48 +0800
Message-ID: <1383891471-20892-2-git-send-email-wangweidong1@huawei.com>
References: <1383891471-20892-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <dingtianhong@huawei.com>,
	<linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>
To: <vyasevich@gmail.com>, <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:2895 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751422Ab3KHGSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 01:18:40 -0500
In-Reply-To: <1383891471-20892-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kzalloc had initialize the allocated memroy. Therefore, remove the
initialize with 0 and the memset.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/associola.c | 41 -----------------------------------------
 1 file changed, 41 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index cef5099..667f984 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -90,14 +90,12 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 
 	/* Initialize the object handling fields.  */
 	atomic_set(&asoc->base.refcnt, 1);
-	asoc->base.dead = false;
 
 	/* Initialize the bind addr area.  */
 	sctp_bind_addr_init(&asoc->base.bind_addr, ep->base.bind_addr.port);
 
 	asoc->state = SCTP_STATE_CLOSED;
 	asoc->cookie_life = ms_to_ktime(sp->assocparams.sasoc_cookie_life);
-	asoc->frag_point = 0;
 	asoc->user_frag = sp->user_frag;
 
 	/* Set the association max_retrans and RTO values from the
@@ -110,8 +108,6 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 	asoc->rto_max = msecs_to_jiffies(sp->rtoinfo.srto_max);
 	asoc->rto_min = msecs_to_jiffies(sp->rtoinfo.srto_min);
 
-	asoc->overall_error_count = 0;
-
 	/* Initialize the association's heartbeat interval based on the
 	 * sock configured value.
 	 */
@@ -138,12 +134,9 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 	asoc->max_burst = sp->max_burst;
 
 	/* initialize association timers */
-	asoc->timeouts[SCTP_EVENT_TIMEOUT_NONE] = 0;
 	asoc->timeouts[SCTP_EVENT_TIMEOUT_T1_COOKIE] = asoc->rto_initial;
 	asoc->timeouts[SCTP_EVENT_TIMEOUT_T1_INIT] = asoc->rto_initial;
 	asoc->timeouts[SCTP_EVENT_TIMEOUT_T2_SHUTDOWN] = asoc->rto_initial;
-	asoc->timeouts[SCTP_EVENT_TIMEOUT_T3_RTX] = 0;
-	asoc->timeouts[SCTP_EVENT_TIMEOUT_T4_RTO] = 0;
 
 	/* sctpimpguide Section 2.12.2
 	 * If the 'T5-shutdown-guard' timer is used, it SHOULD be set to the
@@ -152,7 +145,6 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 	asoc->timeouts[SCTP_EVENT_TIMEOUT_T5_SHUTDOWN_GUARD]
 		= 5 * asoc->rto_max;
 
-	asoc->timeouts[SCTP_EVENT_TIMEOUT_HEARTBEAT] = 0;
 	asoc->timeouts[SCTP_EVENT_TIMEOUT_SACK] = asoc->sackdelay;
 	asoc->timeouts[SCTP_EVENT_TIMEOUT_AUTOCLOSE] =
 		min_t(unsigned long, sp->autoclose, net->sctp.max_autoclose) * HZ;
@@ -173,11 +165,6 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 	asoc->max_init_timeo =
 		 msecs_to_jiffies(sp->initmsg.sinit_max_init_timeo);
 
-	/* Allocate storage for the ssnmap after the inbound and outbound
-	 * streams have been negotiated during Init.
-	 */
-	asoc->ssnmap = NULL;
-
 	/* Set the local window size for receive.
 	 * This is also the rcvbuf space per association.
 	 * RFC 6 - A SCTP receiver MUST be able to receive a minimum of
@@ -190,25 +177,15 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 
 	asoc->a_rwnd = asoc->rwnd;
 
-	asoc->rwnd_over = 0;
-	asoc->rwnd_press = 0;
-
 	/* Use my own max window until I learn something better.  */
 	asoc->peer.rwnd = SCTP_DEFAULT_MAXWINDOW;
 
-	/* Set the sndbuf size for transmit.  */
-	asoc->sndbuf_used = 0;
-
 	/* Initialize the receive memory counter */
 	atomic_set(&asoc->rmem_alloc, 0);
 
 	init_waitqueue_head(&asoc->wait);
 
 	asoc->c.my_vtag = sctp_generate_tag(ep);
-	asoc->peer.i.init_tag = 0;     /* INIT needs a vtag of 0. */
-	asoc->c.peer_vtag = 0;
-	asoc->c.my_ttag   = 0;
-	asoc->c.peer_ttag = 0;
 	asoc->c.my_port = ep->base.bind_addr.port;
 
 	asoc->c.initial_tsn = sctp_generate_tsn(ep);
@@ -219,7 +196,6 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 	asoc->adv_peer_ack_point = asoc->ctsn_ack_point;
 	asoc->highest_sacked = asoc->ctsn_ack_point;
 	asoc->last_cwr_tsn = asoc->ctsn_ack_point;
-	asoc->unack_data = 0;
 
 	/* ADDIP Section 4.1 Asconf Chunk Procedures
 	 *
@@ -238,7 +214,6 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 
 	/* Make an empty list of remote transport addresses.  */
 	INIT_LIST_HEAD(&asoc->peer.transport_addr_list);
-	asoc->peer.transport_count = 0;
 
 	/* RFC 2960 5.1 Normal Establishment of an Association
 	 *
@@ -252,7 +227,6 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 	 * already received one packet.]
 	 */
 	asoc->peer.sack_needed = 1;
-	asoc->peer.sack_cnt = 0;
 	asoc->peer.sack_generation = 1;
 
 	/* Assume that the peer will tell us if he recognizes ASCONF
@@ -260,12 +234,8 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 	 * The sctp_addip_noauth option is there for backward compatibilty
 	 * and will revert old behavior.
 	 */
-	asoc->peer.asconf_capable = 0;
 	if (net->sctp.addip_noauth)
 		asoc->peer.asconf_capable = 1;
-	asoc->asconf_addr_del_pending = NULL;
-	asoc->src_out_of_asoc_ok = 0;
-	asoc->new_transport = NULL;
 
 	/* Create an input queue.  */
 	sctp_inq_init(&asoc->base.inqueue);
@@ -277,12 +247,6 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 	if (!sctp_ulpq_init(&asoc->ulpq, asoc))
 		goto fail_init;
 
-	memset(&asoc->peer.tsn_map, 0, sizeof(struct sctp_tsnmap));
-
-	asoc->need_ecne = 0;
-
-	asoc->assoc_id = 0;
-
 	/* Assume that peer would support both address types unless we are
 	 * told otherwise.
 	 */
@@ -300,9 +264,6 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 	asoc->default_timetolive = sp->default_timetolive;
 	asoc->default_rcv_context = sp->default_rcv_context;
 
-	/* SCTP_GET_ASSOC_STATS COUNTERS */
-	memset(&asoc->stats, 0, sizeof(struct sctp_priv_assoc_stats));
-
 	/* AUTH related initializations */
 	INIT_LIST_HEAD(&asoc->endpoint_shared_keys);
 	err = sctp_auth_asoc_copy_shkeys(ep, asoc, gfp);
@@ -310,9 +271,7 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 		goto fail_init;
 
 	asoc->active_key_id = ep->active_key_id;
-	asoc->asoc_shared_key = NULL;
 
-	asoc->default_hmac_id = 0;
 	/* Save the hmacs and chunks list into this association */
 	if (ep->auth_hmacs_list)
 		memcpy(asoc->c.auth_hmacs, ep->auth_hmacs_list,
-- 
1.7.12
