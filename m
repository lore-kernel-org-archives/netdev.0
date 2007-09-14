From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 3/8] SCTP: Implement SCTP-AUTH initializations.
Date: Fri, 14 Sep 2007 14:44:54 -0400
Message-ID: <11897954992191-git-send-email-vladislav.yasevich@hp.com>
References: <1189795499444-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, Vlad Yasevich <vladislav.yasevich@hp.com>
To: lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:55166 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756001AbXINSpb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 14:45:31 -0400
In-Reply-To: <1189795499444-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch initializes AUTH related members of the generic SCTP
structures and provides a way to enable/disable auth extension.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/associola.c   |   34 +++++++++++++++++++
 net/sctp/endpointola.c |   83 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/sctp/output.c      |    4 ++
 net/sctp/protocol.c    |    3 ++
 net/sctp/sysctl.c      |    9 +++++
 5 files changed, 133 insertions(+), 0 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 2ad1caf..b96c132 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -74,6 +74,8 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 {
 	struct sctp_sock *sp;
 	int i;
+	sctp_paramhdr_t *p;
+	int err;
 
 	/* Retrieve the SCTP per socket area.  */
 	sp = sctp_sk((struct sock *)sk);
@@ -299,6 +301,30 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 	asoc->default_timetolive = sp->default_timetolive;
 	asoc->default_rcv_context = sp->default_rcv_context;
 
+	/* AUTH related initializations */
+	INIT_LIST_HEAD(&asoc->endpoint_shared_keys);
+	err = sctp_auth_asoc_copy_shkeys(ep, asoc, gfp);
+	if (err)
+		goto fail_init;
+
+	asoc->active_key_id = ep->active_key_id;
+	asoc->asoc_shared_key = NULL;
+
+	asoc->default_hmac_id = 0;
+	/* Save the hmacs and chunks list into this association */
+	if (ep->auth_hmacs_list)
+		memcpy(asoc->c.auth_hmacs, ep->auth_hmacs_list,
+			ntohs(ep->auth_hmacs_list->param_hdr.length));
+	if (ep->auth_chunk_list)
+		memcpy(asoc->c.auth_chunks, ep->auth_chunk_list,
+			ntohs(ep->auth_chunk_list->param_hdr.length));
+
+	/* Get the AUTH random number for this association */
+	p = (sctp_paramhdr_t *)asoc->c.auth_random;
+	p->type = SCTP_PARAM_RANDOM;
+	p->length = htons(sizeof(sctp_paramhdr_t) + SCTP_AUTH_RANDOM_LENGTH);
+	get_random_bytes(p+1, SCTP_AUTH_RANDOM_LENGTH);
+
 	return asoc;
 
 fail_init:
@@ -408,6 +434,12 @@ void sctp_association_free(struct sctp_association *asoc)
 	if (asoc->addip_last_asconf)
 		sctp_chunk_free(asoc->addip_last_asconf);
 
+	/* AUTH - Free the endpoint shared keys */
+	sctp_auth_destroy_keys(&asoc->endpoint_shared_keys);
+
+	/* AUTH - Free the association shared key */
+	sctp_auth_key_put(asoc->asoc_shared_key);
+
 	sctp_association_put(asoc);
 }
 
@@ -1116,6 +1148,8 @@ void sctp_assoc_update(struct sctp_association *asoc,
 			sctp_assoc_set_id(asoc, GFP_ATOMIC);
 		}
 	}
+
+	/* SCTP-AUTH: XXX something needs to be done here*/
 }
 
 /* Update the retran path for sending a retransmitted packet.
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index aba9258..84843ed 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -69,12 +69,56 @@ static struct sctp_endpoint *sctp_endpoint_init(struct sctp_endpoint *ep,
 						struct sock *sk,
 						gfp_t gfp)
 {
+	struct sctp_hmac_algo_param *auth_hmacs = NULL;
+	struct sctp_chunks_param *auth_chunks = NULL;
+	struct sctp_shared_key *null_key;
+	int err;
+
 	memset(ep, 0, sizeof(struct sctp_endpoint));
 
 	ep->digest = kzalloc(SCTP_SIGNATURE_SIZE, gfp);
 	if (!ep->digest)
 		return NULL;
 
+	if (sctp_auth_enable) {
+		/* Allocate space for HMACS and CHUNKS authentication
+		 * variables.  There are arrays that we encode directly
+		 * into parameters to make the rest of the operations easier.
+		 */
+		auth_hmacs = kzalloc(sizeof(sctp_hmac_algo_param_t) +
+				sizeof(__u16) * SCTP_AUTH_NUM_HMACS, gfp);
+		if (!auth_hmacs)
+			goto nomem;
+
+		auth_chunks = kzalloc(sizeof(sctp_chunks_param_t) +
+					SCTP_NUM_CHUNK_TYPES, gfp);
+		if (!auth_chunks)
+			goto nomem;
+
+		/* Initialize the HMACS parameter.
+		 * SCTP-AUTH: Section 3.3
+		 *    Every endpoint supporting SCTP chunk authentication MUST
+		 *    support the HMAC based on the SHA-1 algorithm.
+		 */
+		auth_hmacs->param_hdr.type = SCTP_PARAM_HMAC_ALGO;
+		auth_hmacs->param_hdr.length =
+					htons(sizeof(sctp_paramhdr_t) + 2);
+		auth_hmacs->hmac_ids[0] = htons(SCTP_AUTH_HMAC_ID_SHA1);
+
+		/* Initialize the CHUNKS parameter */
+		auth_chunks->param_hdr.type = SCTP_PARAM_CHUNKS;
+
+		/* If the Add-IP functionality is enabled, we must
+		 * authenticate, ASCONF and ASCONF-ACK chunks
+		 */
+		if (sctp_addip_enable) {
+			auth_chunks->chunks[0] = SCTP_CID_ASCONF;
+			auth_chunks->chunks[1] = SCTP_CID_ASCONF_ACK;
+			auth_chunks->param_hdr.length =
+					htons(sizeof(sctp_paramhdr_t) + 2);
+		}
+	}
+
 	/* Initialize the base structure. */
 	/* What type of endpoint are we?  */
 	ep->base.type = SCTP_EP_TYPE_SOCKET;
@@ -115,7 +159,36 @@ static struct sctp_endpoint *sctp_endpoint_init(struct sctp_endpoint *ep,
 	ep->last_key = ep->current_key = 0;
 	ep->key_changed_at = jiffies;
 
+	/* SCTP-AUTH extensions*/
+	INIT_LIST_HEAD(&ep->endpoint_shared_keys);
+	null_key = sctp_auth_shkey_create(0, GFP_KERNEL);
+	if (!null_key)
+		goto nomem;
+
+	list_add(&null_key->key_list, &ep->endpoint_shared_keys);
+
+	/* Allocate and initialize transorms arrays for suported HMACs. */
+	err = sctp_auth_init_hmacs(ep, gfp);
+	if (err)
+		goto nomem_hmacs;
+
+	/* Add the null key to the endpoint shared keys list and
+	 * set the hmcas and chunks pointers.
+	 */
+	ep->auth_hmacs_list = auth_hmacs;
+	ep->auth_chunk_list = auth_chunks;
+
 	return ep;
+
+nomem_hmacs:
+	sctp_auth_destroy_keys(&ep->endpoint_shared_keys);
+nomem:
+	/* Free all allocations */
+	kfree(auth_hmacs);
+	kfree(auth_chunks);
+	kfree(ep->digest);
+	return NULL;
+
 }
 
 /* Create a sctp_endpoint with all that boring stuff initialized.
@@ -188,6 +261,16 @@ static void sctp_endpoint_destroy(struct sctp_endpoint *ep)
 	/* Free the digest buffer */
 	kfree(ep->digest);
 
+	/* SCTP-AUTH: Free up AUTH releated data such as shared keys
+	 * chunks and hmacs arrays that were allocated
+	 */
+	sctp_auth_destroy_keys(&ep->endpoint_shared_keys);
+	kfree(ep->auth_hmacs_list);
+	kfree(ep->auth_chunk_list);
+
+	/* AUTH - Free any allocated HMAC transform containers */
+	sctp_auth_destroy_hmacs(ep->auth_hmacs);
+
 	/* Cleanup. */
 	sctp_inq_free(&ep->base.inqueue);
 	sctp_bind_addr_free(&ep->base.bind_addr);
diff --git a/net/sctp/output.c b/net/sctp/output.c
index d85543d..49b9f5f 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -79,7 +79,9 @@ struct sctp_packet *sctp_packet_config(struct sctp_packet *packet,
 	packet->vtag = vtag;
 	packet->has_cookie_echo = 0;
 	packet->has_sack = 0;
+	packet->has_auth = 0;
 	packet->ipfragok = 0;
+	packet->auth = NULL;
 
 	if (ecn_capable && sctp_packet_empty(packet)) {
 		chunk = sctp_get_ecne_prepend(packet->transport->asoc);
@@ -121,8 +123,10 @@ struct sctp_packet *sctp_packet_init(struct sctp_packet *packet,
 	packet->vtag = 0;
 	packet->has_cookie_echo = 0;
 	packet->has_sack = 0;
+	packet->has_auth = 0;
 	packet->ipfragok = 0;
 	packet->malloced = 0;
+	packet->auth = NULL;
 	return packet;
 }
 
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index c49eb99..6919846 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1167,6 +1167,9 @@ SCTP_STATIC __init int sctp_init(void)
 	/* Enable PR-SCTP by default. */
 	sctp_prsctp_enable = 1;
 
+	/* Disable AUTH by default. */
+	sctp_auth_enable = 0;
+
 	sctp_sysctl_register();
 
 	INIT_LIST_HEAD(&sctp_address_families);
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 39b10ee..0669778 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -254,6 +254,15 @@ static ctl_table sctp_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "auth_enable",
+		.data		= &sctp_auth_enable,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+		.strategy	= &sysctl_intvec
+	},
 	{ .ctl_name = 0 }
 };
 
-- 
1.5.2.4

