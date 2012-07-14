From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] sctp: Implement quick failover draft from tsvwg
Date: Sat, 14 Jul 2012 14:12:36 -0400
Message-ID: <fd33324e-93b0-4ced-8f57-f3c6032baf9b@email.android.com>
References: <1342203998-24037-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, linux-sctp@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:42014 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750915Ab2GNSMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2012 14:12:42 -0400
In-Reply-To: <1342203998-24037-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman <nhorman@tuxdriver.com> wrote:

>I've seen several attempts recently made to do quick failover of sctp
>transports
>by reducing various retransmit timers and counters.  While its possible
>to
>implement a faster failover on multihomed sctp associations, its not
>particularly robust, in that it can lead to unneeded retransmits, as
>well as
>false connection failures due to intermittent latency on a network.
>
>Instead, lets implement the new ietf quick failover draft found here:
>http://tools.ietf.org/html/draft-nishida-tsvwg-sctp-failover-05
>
>This will let the sctp stack identify transports that have had a small
>number of
>errors, and avoid using them quickly until their reliability can be
>re-established.  I've tested this out on two virt guests connected via
>multiple
>isolated virt networks and believe its in compliance with the above
>draft and
>works well.
>
>Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>CC: Vlad Yasevich <vyasevich@gmail.com>
>CC: Sridhar Samudrala <sri@us.ibm.com>
>CC: "David S. Miller" <davem@davemloft.net>
>CC: linux-sctp@vger.kernel.org
>---
> Documentation/networking/ip-sysctl.txt |   14 +++++++++++++
> include/net/sctp/constants.h           |    1 +
> include/net/sctp/structs.h             |    4 +++
> include/net/sctp/user.h                |    1 +
>net/sctp/associola.c                   |   33
>+++++++++++++++++++++++++------
> net/sctp/outqueue.c                    |    6 +++-
>net/sctp/sm_sideeffect.c               |   33
>++++++++++++++++++++++++++++---
> net/sctp/sysctl.c                      |    9 ++++++++
> net/sctp/transport.c                   |    3 +-
> 9 files changed, 90 insertions(+), 14 deletions(-)
>
>diff --git a/Documentation/networking/ip-sysctl.txt
>b/Documentation/networking/ip-sysctl.txt
>index 47b6c79..c636f9c 100644
>--- a/Documentation/networking/ip-sysctl.txt
>+++ b/Documentation/networking/ip-sysctl.txt
>@@ -1408,6 +1408,20 @@ path_max_retrans - INTEGER
> 
> 	Default: 5
> 
>+pf_retrans - INTEGER
>+	The number of retransmissions that will be attempted on a given path
>+	before traffic is redirected to an alternate transport (should one
>+	exist).  Note this is distinct from path_max_retrans, as a path that
>+	passes the pf_retrans threshold can still be used.  Its only
>+	deprioritized when a transmission path is selected by the stack. 
>This
>+	setting is primarily used to enable fast failover mechanisms without
>+	having to reduce path_max_retrans to a very low value.  See:
>+	http://www.ietf.org/id/draft-nishida-tsvwg-sctp-failover-05.txt
>+	for details.  Note also that a value of pf_retrans > path_max_retrans
>+	disables this feature
>+
>+	Default: 0
>+
> rto_initial - INTEGER
>	The initial round trip timeout value in milliseconds that will be used
> 	in calculating round trip times.  This is the initial time interval
>diff --git a/include/net/sctp/constants.h
>b/include/net/sctp/constants.h
>index 942b864..d053d2e 100644
>--- a/include/net/sctp/constants.h
>+++ b/include/net/sctp/constants.h
>@@ -334,6 +334,7 @@ typedef enum {
> typedef enum {
> 	SCTP_TRANSPORT_UP,
> 	SCTP_TRANSPORT_DOWN,
>+	SCTP_TRANSPORT_PF,
> } sctp_transport_cmd_t;
> 
> /* These are the address scopes defined mainly for IPv4 addresses
>diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
>index e4652fe..22825abe 100644
>--- a/include/net/sctp/structs.h
>+++ b/include/net/sctp/structs.h
>@@ -160,6 +160,7 @@ extern struct sctp_globals {
> 	int max_retrans_association;
> 	int max_retrans_path;
> 	int max_retrans_init;
>+	int pf_retrans;
> 
> 	/*
> 	 * Policy for preforming sctp/socket accounting
>@@ -258,6 +259,7 @@ extern struct sctp_globals {
> #define sctp_sndbuf_policy	 	(sctp_globals.sndbuf_policy)
> #define sctp_rcvbuf_policy	 	(sctp_globals.rcvbuf_policy)
> #define sctp_max_retrans_path		(sctp_globals.max_retrans_path)
>+#define sctp_pf_retrans			(sctp_globals.pf_retrans)
> #define sctp_max_retrans_init		(sctp_globals.max_retrans_init)
> #define sctp_sack_timeout		(sctp_globals.sack_timeout)
> #define sctp_hb_interval		(sctp_globals.hb_interval)
>@@ -1660,6 +1662,8 @@ struct sctp_association {
> 	 */
> 	int max_retrans;
> 
>+	int pf_retrans;
>+
> 	/* Maximum number of times the endpoint will retransmit INIT  */
> 	__u16 max_init_attempts;
> 
>diff --git a/include/net/sctp/user.h b/include/net/sctp/user.h
>index 0842ef0..cece1bf 100644
>--- a/include/net/sctp/user.h
>+++ b/include/net/sctp/user.h
>@@ -649,6 +649,7 @@ struct sctp_paddrinfo {
>  */
> enum sctp_spinfo_state {
> 	SCTP_INACTIVE,
>+	SCTP_PF,
> 	SCTP_ACTIVE,
> 	SCTP_UNCONFIRMED,
> 	SCTP_UNKNOWN = 0xffff  /* Value used for transport state unknown */
>diff --git a/net/sctp/associola.c b/net/sctp/associola.c
>index 5bc9ab1..f3ebc23 100644
>--- a/net/sctp/associola.c
>+++ b/net/sctp/associola.c
>@@ -124,6 +124,8 @@ static struct sctp_association
>*sctp_association_init(struct sctp_association *a
> 	 * socket values.
> 	 */
> 	asoc->max_retrans = sp->assocparams.sasoc_asocmaxrxt;
>+	asoc->pf_retrans  = sctp_pf_retrans;
>+
> 	asoc->rto_initial = msecs_to_jiffies(sp->rtoinfo.srto_initial);
> 	asoc->rto_max = msecs_to_jiffies(sp->rtoinfo.srto_max);
> 	asoc->rto_min = msecs_to_jiffies(sp->rtoinfo.srto_min);
>@@ -840,6 +842,7 @@ void sctp_assoc_control_transport(struct
>sctp_association *asoc,
> 	struct sctp_ulpevent *event;
> 	struct sockaddr_storage addr;
> 	int spc_state = 0;
>+	bool ulp_notify = true;
> 
> 	/* Record the transition on the transport.  */
> 	switch (command) {
>@@ -853,6 +856,14 @@ void sctp_assoc_control_transport(struct
>sctp_association *asoc,
> 			spc_state = SCTP_ADDR_CONFIRMED;
> 		else
> 			spc_state = SCTP_ADDR_AVAILABLE;
>+		/* Don't inform ULP about transition from PF to
>+		 * active state and set cwnd to 1, see SCTP
>+		 * Quick failover draft section 5.1, point 5
>+		 */
>+		if (transport->state == SCTP_PF) {
>+			ulp_notify = false;
>+			transport->cwnd = 1;
>+		}
> 		transport->state = SCTP_ACTIVE;
> 		break;
> 
>@@ -871,6 +882,10 @@ void sctp_assoc_control_transport(struct
>sctp_association *asoc,
> 		spc_state = SCTP_ADDR_UNREACHABLE;
> 		break;
> 
>+	case SCTP_TRANSPORT_PF:
>+		transport->state = SCTP_PF;
>+		ulp_notify = false;
>+		break;
> 	default:
> 		return;
> 	}
>@@ -878,12 +893,15 @@ void sctp_assoc_control_transport(struct
>sctp_association *asoc,
> 	/* Generate and send a SCTP_PEER_ADDR_CHANGE notification to the
> 	 * user.
> 	 */
>-	memset(&addr, 0, sizeof(struct sockaddr_storage));
>-	memcpy(&addr, &transport->ipaddr,
>transport->af_specific->sockaddr_len);
>-	event = sctp_ulpevent_make_peer_addr_change(asoc, &addr,
>-				0, spc_state, error, GFP_ATOMIC);
>-	if (event)
>-		sctp_ulpq_tail_event(&asoc->ulpq, event);
>+	if (ulp_notify) {
>+		memset(&addr, 0, sizeof(struct sockaddr_storage));
>+		memcpy(&addr, &transport->ipaddr,
>+		       transport->af_specific->sockaddr_len);
>+		event = sctp_ulpevent_make_peer_addr_change(asoc, &addr,
>+					0, spc_state, error, GFP_ATOMIC);
>+		if (event)
>+			sctp_ulpq_tail_event(&asoc->ulpq, event);
>+	}
> 
> 	/* Select new active and retran paths. */
> 
>@@ -899,7 +917,8 @@ void sctp_assoc_control_transport(struct
>sctp_association *asoc,
> 			transports) {
> 
> 		if ((t->state == SCTP_INACTIVE) ||
>-		    (t->state == SCTP_UNCONFIRMED))
>+		    (t->state == SCTP_UNCONFIRMED) ||
>+		    (t->state == SCTP_PF))
> 			continue;
> 		if (!first || t->last_time_heard > first->last_time_heard) {
> 			second = first;
>diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
>index a0fa19f..e7aa177c 100644
>--- a/net/sctp/outqueue.c
>+++ b/net/sctp/outqueue.c
>@@ -792,7 +792,8 @@ static int sctp_outq_flush(struct sctp_outq *q, int
>rtx_timeout)
> 			if (!new_transport)
> 				new_transport = asoc->peer.active_path;
> 		} else if ((new_transport->state == SCTP_INACTIVE) ||
>-			   (new_transport->state == SCTP_UNCONFIRMED)) {
>+			   (new_transport->state == SCTP_UNCONFIRMED) ||
>+			   (new_transport->state == SCTP_PF)) {
> 			/* If the chunk is Heartbeat or Heartbeat Ack,
> 			 * send it to chunk->transport, even if it's
> 			 * inactive.
>@@ -987,7 +988,8 @@ static int sctp_outq_flush(struct sctp_outq *q, int
>rtx_timeout)
> 			new_transport = chunk->transport;
> 			if (!new_transport ||
> 			    ((new_transport->state == SCTP_INACTIVE) ||
>-			     (new_transport->state == SCTP_UNCONFIRMED)))
>+			     (new_transport->state == SCTP_UNCONFIRMED) ||
>+			     (new_transport->state == SCTP_PF)))
> 				new_transport = asoc->peer.active_path;
> 			if (new_transport->state == SCTP_UNCONFIRMED)
> 				continue;
>diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
>index c96d1a8..285e26a 100644
>--- a/net/sctp/sm_sideeffect.c
>+++ b/net/sctp/sm_sideeffect.c
>@@ -76,6 +76,8 @@ static int sctp_side_effects(sctp_event_t event_type,
>sctp_subtype_t subtype,
> 			     sctp_cmd_seq_t *commands,
> 			     gfp_t gfp);
> 
>+static void sctp_cmd_hb_timer_update(sctp_cmd_seq_t *cmds,
>+				     struct sctp_transport *t);
> /********************************************************************
>  * Helper functions
>  ********************************************************************/
>@@ -470,7 +472,8 @@ sctp_timer_event_t
>*sctp_timer_events[SCTP_NUM_TIMEOUT_TYPES] = {
>  * notification SHOULD be sent to the upper layer.
>  *
>  */
>-static void sctp_do_8_2_transport_strike(struct sctp_association
>*asoc,
>+static void sctp_do_8_2_transport_strike(sctp_cmd_seq_t *commands,
>+					 struct sctp_association *asoc,
> 					 struct sctp_transport *transport,
> 					 int is_hb)
> {
>@@ -495,6 +498,23 @@ static void sctp_do_8_2_transport_strike(struct
>sctp_association *asoc,
> 			transport->error_count++;
> 	}
> 
>+	/* If the transport error count is greater than the pf_retrans
>+	 * threshold, and less than pathmaxrtx, then mark this transport
>+	 * as Partially Failed, ee SCTP Quick Failover Draft, secon 5.1,
>+	 * point 1
>+	 */
>+	if ((transport->state != SCTP_PF) &&
>+	   (asoc->pf_retrans < transport->pathmaxrxt) &&
>+	   (transport->error_count > asoc->pf_retrans)) {
>+
>+		sctp_assoc_control_transport(asoc, transport,
>+					     SCTP_TRANSPORT_PF,
>+					     0);
>+
>+		/* Update the hb timer to resend a heartbeat every rto */
>+		sctp_cmd_hb_timer_update(commands, transport);
>+	}
>+
> 	if (transport->state != SCTP_INACTIVE &&
> 	    (transport->error_count > transport->pathmaxrxt)) {
> 		SCTP_DEBUG_PRINTK_IPADDR("transport_strike:association %p",
>@@ -699,6 +719,10 @@ static void sctp_cmd_transport_on(sctp_cmd_seq_t
>*cmds,
> 					     SCTP_HEARTBEAT_SUCCESS);
> 	}
> 
>+	if (t->state == SCTP_PF)
>+		sctp_assoc_control_transport(asoc, t, SCTP_TRANSPORT_UP,
>+					     SCTP_HEARTBEAT_SUCCESS);
>+
> 	/* The receiver of the HEARTBEAT ACK should also perform an
> 	 * RTT measurement for that destination transport address
> 	 * using the time value carried in the HEARTBEAT ACK chunk.
>@@ -1565,8 +1589,8 @@ static int sctp_cmd_interpreter(sctp_event_t
>event_type,
> 
> 		case SCTP_CMD_STRIKE:
> 			/* Mark one strike against a transport.  */
>-			sctp_do_8_2_transport_strike(asoc, cmd->obj.transport,
>-						    0);
>+			sctp_do_8_2_transport_strike(commands, asoc,
>+						    cmd->obj.transport, 0);
> 			break;
> 
> 		case SCTP_CMD_TRANSPORT_IDLE:
>@@ -1576,7 +1600,8 @@ static int sctp_cmd_interpreter(sctp_event_t
>event_type,
> 
> 		case SCTP_CMD_TRANSPORT_HB_SENT:
> 			t = cmd->obj.transport;
>-			sctp_do_8_2_transport_strike(asoc, t, 1);
>+			sctp_do_8_2_transport_strike(commands, asoc,
>+						     t, 1);
> 			t->hb_sent = 1;
> 			break;
> 
>diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
>index e5fe639..2b2bfe9 100644
>--- a/net/sctp/sysctl.c
>+++ b/net/sctp/sysctl.c
>@@ -141,6 +141,15 @@ static ctl_table sctp_table[] = {
> 		.extra2		= &int_max
> 	},
> 	{
>+		.procname	= "pf_retrans",
>+		.data		= &sctp_pf_retrans,
>+		.maxlen		= sizeof(int),
>+		.mode		= 0644,
>+		.proc_handler	= proc_dointvec_minmax,
>+		.extra1		= &zero,
>+		.extra2		= &int_max
>+	},
>+	{
> 		.procname	= "max_init_retransmits",
> 		.data		= &sctp_max_retrans_init,
> 		.maxlen		= sizeof(int),
>diff --git a/net/sctp/transport.c b/net/sctp/transport.c
>index b026ba0..4639ba2 100644
>--- a/net/sctp/transport.c
>+++ b/net/sctp/transport.c
>@@ -585,7 +585,8 @@ unsigned long sctp_transport_timeout(struct
>sctp_transport *t)
> {
> 	unsigned long timeout;
> 	timeout = t->rto + sctp_jitter(t->rto);
>-	if (t->state != SCTP_UNCONFIRMED)
>+	if ((t->state != SCTP_UNCONFIRMED) &&
>+	    (t->state != SCTP_PF))
> 		timeout += t->hbinterval;
> 	timeout += jiffies;
> 	return timeout;
>-- 
>1.7.7.6

One thing that seems to be missing is the API.  As a result you don't carry the value per transport which we'll need.  That caused you to add assoc parameter to some functions.  That's really the only missing item.
-- 
Sent from my Android phone with SkitMail. Please excuse my brevity.
