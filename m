From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [BK PATCH] 2.6 & 2.4 SCTP updates
Date: Fri, 22 Oct 2004 12:24:47 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0410221215550.5956@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

Please do a
	bk pull http://linux-lksctp.bkbits.net/lksctp-2.5.work &
	bk pull http://linux-lksctp.bkbits.net/lksctp-2.4.work

to get the following SCTP updates to 2.6 and 2.4.

Thanks
Sridhar

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/21 15:38:41-07:00 sri@us.ibm.com
#   [SCTP] Fix HEARTBEAT_ACKs being sent to wrong dest. ip address in a
#   multi-homing scenario after a failback.
#
#   Signed-off-by: Jorge Hernandez-Herrero <jhh@lucent.com>
#   Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
#
# net/sctp/outqueue.c
#
# ChangeSet
#   2004/10/21 15:32:54-07:00 sri@us.ibm.com
#   [SCTP] When an address is deleted, update any transports that are caching it as a source adddress.
#
#   Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
#
# net/sctp/sm_make_chunk.c
#
# ChangeSet
#   2004/10/21 15:28:41-07:00 sri@us.ibm.com
#   [SCTP] Update cwnd/ssthresh as per the sctpimpguide modifications.
#
#   Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
#
# net/sctp/transport.c
# net/sctp/associola.c
#
# ChangeSet
#   2004/10/21 15:21:31-07:00 sri@us.ibm.com
#   [SCTP] Adaption layer indication support.
#
#   Add support for SCTP_ADAPTION_INDICATION notification, SCTP_ADAPTION_LAYER
#   socket option and SCTP_PARAM_ADAPTION_LAYER_IND parameter.
#
#   Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
#
# net/sctp/ulpevent.c
# net/sctp/socket.c
# net/sctp/sm_statefuns.c
# net/sctp/sm_make_chunk.c
# include/net/sctp/ulpevent.h
# include/net/sctp/structs.h
# include/linux/sctp.h
#
# ChangeSet
#   2004/10/21 15:18:18-07:00 sri@us.ibm.com
#   [SCTP] Change sctp_assoc_t to a sized type(s32).
#
#   Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
#
# net/sctp/socket.c
# net/sctp/associola.c
# include/net/sctp/user.h
# include/net/sctp/sctp.h
#
diff -Nru a/include/linux/sctp.h b/include/linux/sctp.h
--- a/include/linux/sctp.h	2004-10-22 12:06:24 -07:00
+++ b/include/linux/sctp.h	2004-10-22 12:06:24 -07:00
@@ -281,7 +281,11 @@
 	sctp_paramhdr_t param_hdr;
 } __attribute__((packed)) sctp_ecn_capable_param_t;

-
+/* ADDIP Section 3.2.6 Adaption Layer Indication */
+typedef struct sctp_adaption_ind_param {
+	struct sctp_paramhdr param_hdr;
+	__u32 adaption_ind;
+} __attribute__((packed)) sctp_adaption_ind_param_t;

 /* RFC 2960.  Section 3.3.3 Initiation Acknowledgement (INIT ACK) (2):
  *   The INIT ACK chunk is used to acknowledge the initiation of an SCTP
diff -Nru a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
--- a/include/net/sctp/sctp.h	2004-10-22 12:06:24 -07:00
+++ b/include/net/sctp/sctp.h	2004-10-22 12:06:24 -07:00
@@ -335,7 +335,7 @@
 /* Map an association to an assoc_id. */
 static inline sctp_assoc_t sctp_assoc2id(const struct sctp_association *asoc)
 {
-	return (asoc?asoc->assoc_id:NULL);
+	return (asoc?asoc->assoc_id:0);
 }

 /* Look up the association by its id.  */
diff -Nru a/include/net/sctp/structs.h b/include/net/sctp/structs.h
--- a/include/net/sctp/structs.h	2004-10-22 12:06:24 -07:00
+++ b/include/net/sctp/structs.h	2004-10-22 12:06:24 -07:00
@@ -266,6 +266,7 @@
 	__u8 disable_fragments;
 	__u8 pd_mode;
 	__u8 v4mapped;
+	__u32 adaption_ind;

 	/* Receive to here while partial delivery is in effect. */
 	struct sk_buff_head pd_lobby;
@@ -323,6 +324,8 @@

 	__u8 prsctp_capable;

+	__u32 adaption_ind;
+
 	/* This is a shim for my peer's INIT packet, followed by
 	 * a copy of the raw address list of the association.
 	 * The length of the raw address list is saved in the
@@ -362,6 +365,7 @@
 	struct sctp_ipv4addr_param *v4;
 	struct sctp_ipv6addr_param *v6;
 	union sctp_addr_param *addr;
+	struct sctp_adaption_ind_param *aind;
 };

 /* RFC 2960.  Section 3.3.5 Heartbeat.
@@ -1394,6 +1398,8 @@
 		__u8	hostname_address;/* Peer understands DNS addresses? */
 		__u8    asconf_capable;  /* Does peer support ADDIP? */
 		__u8    prsctp_capable;  /* Can peer do PR-SCTP? */
+
+		__u32   adaption_ind;	 /* Adaption Code point. */

 		/* This mask is used to disable sending the ASCONF chunk
 		 * with specified parameter to peer.
diff -Nru a/include/net/sctp/ulpevent.h b/include/net/sctp/ulpevent.h
--- a/include/net/sctp/ulpevent.h	2004-10-22 12:06:24 -07:00
+++ b/include/net/sctp/ulpevent.h	2004-10-22 12:06:24 -07:00
@@ -121,6 +121,9 @@
 	const struct sctp_association *asoc,
 	__u32 indication, int gfp);

+struct sctp_ulpevent *sctp_ulpevent_make_adaption_indication(
+	const struct sctp_association *asoc, int gfp);
+
 struct sctp_ulpevent *sctp_ulpevent_make_rcvmsg(struct sctp_association *asoc,
 	struct sctp_chunk *chunk,
 	int gfp);
diff -Nru a/include/net/sctp/user.h b/include/net/sctp/user.h
--- a/include/net/sctp/user.h	2004-10-22 12:06:24 -07:00
+++ b/include/net/sctp/user.h	2004-10-22 12:06:24 -07:00
@@ -55,7 +55,7 @@
 #include <linux/types.h>
 #include <linux/socket.h>

-typedef void * sctp_assoc_t;
+typedef __s32 sctp_assoc_t;

 /* The following symbols come from the Sockets API Extensions for
  * SCTP <draft-ietf-tsvwg-sctpsocket-07.txt>.
diff -Nru a/net/sctp/associola.c b/net/sctp/associola.c
--- a/net/sctp/associola.c	2004-10-22 12:06:24 -07:00
+++ b/net/sctp/associola.c	2004-10-22 12:06:24 -07:00
@@ -271,7 +271,7 @@

 	asoc->need_ecne = 0;

-	asoc->assoc_id = (sctp_assoc_t)-1L;
+	asoc->assoc_id = 0;

 	/* Assume that peer would support both address types unless we are
 	 * told otherwise.
@@ -374,9 +374,9 @@
 	sctp_endpoint_put(asoc->ep);
 	sock_put(asoc->base.sk);

-	if ((long)asoc->assoc_id != -1L) {
+	if (asoc->assoc_id != 0) {
 		spin_lock_bh(&sctp_assocs_id_lock);
-		idr_remove(&sctp_assocs_id, (long)asoc->assoc_id);
+		idr_remove(&sctp_assocs_id, asoc->assoc_id);
 		spin_unlock_bh(&sctp_assocs_id_lock);
 	}

@@ -482,14 +482,15 @@

 	/* 7.2.1 Slow-Start
 	 *
-	 * o The initial cwnd before data transmission or after a
-	 *   sufficiently long idle period MUST be <= 2*MTU.
+	 * o The initial cwnd before DATA transmission or after a sufficiently
+	 *   long idle period MUST be set to
+	 *      min(4*MTU, max(2*MTU, 4380 bytes))
 	 *
 	 * o The initial value of ssthresh MAY be arbitrarily high
 	 *   (for example, implementations MAY use the size of the
 	 *   receiver advertised window).
 	 */
-	peer->cwnd = asoc->pmtu * 2;
+	peer->cwnd = min(4*asoc->pmtu, max_t(__u32, 2*asoc->pmtu, 4380));

 	/* At this point, we may not have the receiver's advertised window,
 	 * so initialize ssthresh to the default value and it will be set
diff -Nru a/net/sctp/outqueue.c b/net/sctp/outqueue.c
--- a/net/sctp/outqueue.c	2004-10-22 12:06:24 -07:00
+++ b/net/sctp/outqueue.c	2004-10-22 12:06:24 -07:00
@@ -706,10 +706,19 @@
 		if (!new_transport) {
 			new_transport = asoc->peer.active_path;
 		} else if (!new_transport->active) {
-			/* If the chunk is Heartbeat, send it to
-			 * chunk->transport, even it's inactive.
+			/* If the chunk is Heartbeat or Heartbeat Ack,
+			 * send it to chunk->transport, even if it's
+			 * inactive.
+			 *
+			 * 3.3.6 Heartbeat Acknowledgement:
+			 * ...
+			 * A HEARTBEAT ACK is always sent to the source IP
+			 * address of the IP datagram containing the
+			 * HEARTBEAT chunk to which this ack is responding.
+			 * ...
 			 */
-			if (chunk->chunk_hdr->type != SCTP_CID_HEARTBEAT)
+			if (chunk->chunk_hdr->type != SCTP_CID_HEARTBEAT &&
+			    chunk->chunk_hdr->type != SCTP_CID_HEARTBEAT_ACK)
 				new_transport = asoc->peer.active_path;
 		}

diff -Nru a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
--- a/net/sctp/sm_make_chunk.c	2004-10-22 12:06:24 -07:00
+++ b/net/sctp/sm_make_chunk.c	2004-10-22 12:06:24 -07:00
@@ -171,6 +171,7 @@
 	struct sctp_opt *sp;
 	sctp_supported_addrs_param_t sat;
 	__u16 types[2];
+	sctp_adaption_ind_param_t aiparam;

 	/* RFC 2960 3.3.2 Initiation (INIT) (1)
 	 *
@@ -196,6 +197,7 @@
 	chunksize += sizeof(ecap_param);
 	if (sctp_prsctp_enable)
 		chunksize += sizeof(prsctp_param);
+	chunksize += sizeof(aiparam);
 	chunksize += vparam_len;

 	/* RFC 2960 3.3.2 Initiation (INIT) (1)
@@ -234,6 +236,10 @@
 	sctp_addto_chunk(retval, sizeof(ecap_param), &ecap_param);
 	if (sctp_prsctp_enable)
 		sctp_addto_chunk(retval, sizeof(prsctp_param), &prsctp_param);
+	aiparam.param_hdr.type = SCTP_PARAM_ADAPTION_LAYER_IND;
+	aiparam.param_hdr.length = htons(sizeof(aiparam));
+	aiparam.adaption_ind = htonl(sp->adaption_ind);
+	sctp_addto_chunk(retval, sizeof(aiparam), &aiparam);
 nodata:
 	if (addrs.v)
 		kfree(addrs.v);
@@ -251,6 +257,7 @@
 	sctp_cookie_param_t *cookie;
 	int cookie_len;
 	size_t chunksize;
+	sctp_adaption_ind_param_t aiparam;

 	retval = NULL;

@@ -284,6 +291,8 @@
 	if (asoc->peer.prsctp_capable)
 		chunksize += sizeof(prsctp_param);

+	chunksize += sizeof(aiparam);
+
 	/* Now allocate and fill out the chunk.  */
 	retval = sctp_make_chunk(asoc, SCTP_CID_INIT_ACK, 0, chunksize);
 	if (!retval)
@@ -302,6 +311,11 @@
 	if (asoc->peer.prsctp_capable)
 		sctp_addto_chunk(retval, sizeof(prsctp_param), &prsctp_param);

+	aiparam.param_hdr.type = SCTP_PARAM_ADAPTION_LAYER_IND;
+	aiparam.param_hdr.length = htons(sizeof(aiparam));
+	aiparam.adaption_ind = htonl(sctp_sk(asoc->base.sk)->adaption_ind);
+	sctp_addto_chunk(retval, sizeof(aiparam), &aiparam);
+
 	/* We need to remove the const qualifier at this point.  */
 	retval->asoc = (struct sctp_association *) asoc;

@@ -1297,6 +1311,9 @@
 	/* Remember PR-SCTP capability. */
 	cookie->c.prsctp_capable = asoc->peer.prsctp_capable;

+	/* Save adaption indication in the cookie. */
+	cookie->c.adaption_ind = asoc->peer.adaption_ind;
+
 	/* Set an expiration time for the cookie.  */
 	do_gettimeofday(&cookie->c.expiration);
 	TIMEVAL_ADD(asoc->cookie_life, cookie->c.expiration);
@@ -1455,6 +1472,7 @@
 	retval->addip_serial = retval->c.initial_tsn;
 	retval->adv_peer_ack_point = retval->ctsn_ack_point;
 	retval->peer.prsctp_capable = retval->c.prsctp_capable;
+	retval->peer.adaption_ind = retval->c.adaption_ind;

 	/* The INIT stuff will be done by the side effects.  */
 	return retval;
@@ -1661,6 +1679,7 @@
 	case SCTP_PARAM_HEARTBEAT_INFO:
 	case SCTP_PARAM_UNRECOGNIZED_PARAMETERS:
 	case SCTP_PARAM_ECN_CAPABLE:
+	case SCTP_PARAM_ADAPTION_LAYER_IND:
 		break;

 	case SCTP_PARAM_HOST_NAME_ADDRESS:
@@ -1989,6 +2008,10 @@
 		asoc->peer.ecn_capable = 1;
 		break;

+	case SCTP_PARAM_ADAPTION_LAYER_IND:
+		asoc->peer.adaption_ind = param.aind->adaption_ind;
+		break;
+
 	case SCTP_PARAM_FWD_TSN_SUPPORT:
 		if (sctp_prsctp_enable) {
 			asoc->peer.prsctp_capable = 1;
@@ -2459,6 +2482,8 @@
 	union sctp_addr	addr;
 	struct sctp_bind_addr *bp = &asoc->base.bind_addr;
 	union sctp_addr_param *addr_param;
+	struct list_head *pos;
+	struct sctp_transport *transport;
 	int retval = 0;

 	addr_param = (union sctp_addr_param *)
@@ -2482,6 +2507,12 @@
 		retval = sctp_del_bind_addr(bp, &addr);
 		sctp_write_unlock(&asoc->base.addr_lock);
 		sctp_local_bh_enable();
+		list_for_each(pos, &asoc->peer.transport_addr_list) {
+			transport = list_entry(pos, struct sctp_transport,
+						 transports);
+			sctp_transport_route(transport, NULL,
+					     sctp_sk(asoc->base.sk));
+		}
 		break;
 	default:
 		break;
diff -Nru a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
--- a/net/sctp/sm_statefuns.c	2004-10-22 12:06:24 -07:00
+++ b/net/sctp/sm_statefuns.c	2004-10-22 12:06:24 -07:00
@@ -629,6 +629,21 @@

 	sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP, SCTP_ULPEVENT(ev));

+	/* Sockets API Draft Section 5.3.1.6
+	 * When a peer sends a Adaption Layer Indication parameter , SCTP
+	 * delivers this notification to inform the application that of the
+	 * peers requested adaption layer.
+	 */
+	if (new_asoc->peer.adaption_ind) {
+		ev = sctp_ulpevent_make_adaption_indication(new_asoc,
+							    GFP_ATOMIC);
+		if (!ev)
+			goto nomem_ev;
+
+		sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP,
+				SCTP_ULPEVENT(ev));
+	}
+
 	return SCTP_DISPOSITION_CONSUME;

 nomem_ev:
@@ -713,6 +728,20 @@

 	sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP, SCTP_ULPEVENT(ev));

+	/* Sockets API Draft Section 5.3.1.6
+	 * When a peer sends a Adaption Layer Indication parameter , SCTP
+	 * delivers this notification to inform the application that of the
+	 * peers requested adaption layer.
+	 */
+	if (asoc->peer.adaption_ind) {
+		ev = sctp_ulpevent_make_adaption_indication(asoc, GFP_ATOMIC);
+		if (!ev)
+			goto nomem;
+
+		sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP,
+				SCTP_ULPEVENT(ev));
+	}
+
 	return SCTP_DISPOSITION_CONSUME;
 nomem:
 	return SCTP_DISPOSITION_NOMEM;
@@ -1532,6 +1561,21 @@
 		goto nomem_ev;

 	sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP, SCTP_ULPEVENT(ev));
+
+	/* Sockets API Draft Section 5.3.1.6
+	 * When a peer sends a Adaption Layer Indication parameter , SCTP
+	 * delivers this notification to inform the application that of the
+	 * peers requested adaption layer.
+	 */
+	if (asoc->peer.adaption_ind) {
+		ev = sctp_ulpevent_make_adaption_indication(asoc, GFP_ATOMIC);
+		if (!ev)
+			goto nomem_ev;
+
+		sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP,
+				SCTP_ULPEVENT(ev));
+	}
+
 	return SCTP_DISPOSITION_CONSUME;

 nomem_ev:
@@ -1612,6 +1656,21 @@
 			goto nomem;
 		sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP,
 				SCTP_ULPEVENT(ev));
+
+		/* Sockets API Draft Section 5.3.1.6
+		 * When a peer sends a Adaption Layer Indication parameter,
+		 * SCTP delivers this notification to inform the application
+		 * that of the peers requested adaption layer.
+		 */
+		if (new_asoc->peer.adaption_ind) {
+			ev = sctp_ulpevent_make_adaption_indication(new_asoc,
+								 GFP_ATOMIC);
+			if (!ev)
+				goto nomem;
+
+			sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP,
+					SCTP_ULPEVENT(ev));
+		}
 	}
 	sctp_add_cmd_sf(commands, SCTP_CMD_TRANSMIT, SCTP_NULL());

diff -Nru a/net/sctp/socket.c b/net/sctp/socket.c
--- a/net/sctp/socket.c	2004-10-22 12:06:24 -07:00
+++ b/net/sctp/socket.c	2004-10-22 12:06:24 -07:00
@@ -1063,7 +1063,7 @@
 	struct sctp_sndrcvinfo default_sinfo = { 0 };
 	struct sctp_sndrcvinfo *sinfo;
 	struct sctp_initmsg *sinit;
-	sctp_assoc_t associd = NULL;
+	sctp_assoc_t associd = 0;
 	sctp_cmsgs_t cmsgs = { NULL };
 	int err;
 	sctp_scope_t scope;
@@ -2120,6 +2120,20 @@
 	return err;
 }

+static int sctp_setsockopt_adaption_layer(struct sock *sk, char __user *optval,
+					  int optlen)
+{
+	__u32 val;
+
+	if (optlen < sizeof(__u32))
+		return -EINVAL;
+	if (copy_from_user(&val, optval, sizeof(__u32)))
+		return -EFAULT;
+
+	sctp_sk(sk)->adaption_ind = val;
+
+	return 0;
+}

 /* API 6.2 setsockopt(), getsockopt()
  *
@@ -2219,6 +2233,10 @@
 	case SCTP_MAXSEG:
 		retval = sctp_setsockopt_maxseg(sk, optval, optlen);
 		break;
+	case SCTP_ADAPTION_LAYER:
+		retval = sctp_setsockopt_adaption_layer(sk, optval, optlen);
+		break;
+
 	default:
 		retval = -ENOPROTOOPT;
 		break;
@@ -2518,6 +2536,8 @@
 	/* User specified fragmentation limit. */
 	sp->user_frag         = 0;

+	sp->adaption_ind = 0;
+
 	sp->pf = sctp_get_pf_specific(sk->sk_family);

 	/* Control variables for partial data delivery. */
@@ -3160,6 +3180,29 @@
 }

 /*
+ * 7.1.11  Set Adaption Layer Indicator (SCTP_ADAPTION_LAYER)
+ *
+ * Requests that the local endpoint set the specified Adaption Layer
+ * Indication parameter for all future INIT and INIT-ACK exchanges.
+ */
+static int sctp_getsockopt_adaption_layer(struct sock *sk, int len,
+				  char __user *optval, int __user *optlen)
+{
+	__u32 val;
+
+	if (len < sizeof(__u32))
+		return -EINVAL;
+
+	len = sizeof(__u32);
+	val = sctp_sk(sk)->adaption_ind;
+	if (put_user(len, optlen))
+		return -EFAULT;
+	if (copy_to_user(optval, &val, len))
+		return -EFAULT;
+	return 0;
+}
+
+/*
  *
  * 7.1.14 Set default send parameters (SCTP_DEFAULT_SEND_PARAM)
  *
@@ -3513,6 +3556,10 @@
 		break;
 	case SCTP_GET_PEER_ADDR_INFO:
 		retval = sctp_getsockopt_peer_addr_info(sk, len, optval,
+							optlen);
+		break;
+	case SCTP_ADAPTION_LAYER:
+		retval = sctp_getsockopt_adaption_layer(sk, len, optval,
 							optlen);
 		break;
 	default:
diff -Nru a/net/sctp/transport.c b/net/sctp/transport.c
--- a/net/sctp/transport.c	2004-10-22 12:06:24 -07:00
+++ b/net/sctp/transport.c	2004-10-22 12:06:24 -07:00
@@ -421,15 +421,15 @@
 {
 	switch (reason) {
 	case SCTP_LOWER_CWND_T3_RTX:
-		/* RFC 2960 Section 7.2.3, sctpimpguide-05 Section 2.9.2
+		/* RFC 2960 Section 7.2.3, sctpimpguide
 		 * When the T3-rtx timer expires on an address, SCTP should
 		 * perform slow start by:
-		 *      ssthresh = max(cwnd/2, 2*MTU)
+		 *      ssthresh = max(cwnd/2, 4*MTU)
 		 *      cwnd = 1*MTU
 		 *      partial_bytes_acked = 0
 		 */
 		transport->ssthresh = max(transport->cwnd/2,
-					  2*transport->asoc->pmtu);
+					  4*transport->asoc->pmtu);
 		transport->cwnd = transport->asoc->pmtu;
 		break;

@@ -439,15 +439,15 @@
 		 * were last sent, according to the formula described in
 		 * Section 7.2.3.
 	 	 *
-	 	 * RFC 2960 7.2.3, sctpimpguide-05 2.9.2 Upon detection of
-		 * packet losses from SACK (see Section 7.2.4), An endpoint
+	 	 * RFC 2960 7.2.3, sctpimpguide Upon detection of packet
+		 * losses from SACK (see Section 7.2.4), An endpoint
 		 * should do the following:
-		 *      ssthresh = max(cwnd/2, 2*MTU)
+		 *      ssthresh = max(cwnd/2, 4*MTU)
 		 *      cwnd = ssthresh
 		 *      partial_bytes_acked = 0
 		 */
 		transport->ssthresh = max(transport->cwnd/2,
-					  2*transport->asoc->pmtu);
+					  4*transport->asoc->pmtu);
 		transport->cwnd = transport->ssthresh;
 		break;

@@ -467,23 +467,24 @@
 		if ((jiffies - transport->last_time_ecne_reduced) >
 		    transport->rtt) {
 			transport->ssthresh = max(transport->cwnd/2,
-					  	  2*transport->asoc->pmtu);
+					  	  4*transport->asoc->pmtu);
 			transport->cwnd = transport->ssthresh;
 			transport->last_time_ecne_reduced = jiffies;
 		}
 		break;

 	case SCTP_LOWER_CWND_INACTIVE:
-		/* RFC 2960 Section 7.2.1, sctpimpguide-05 Section 2.14.2
-		 * When the association does not transmit data on a given
-		 * transport address within an RTO, the cwnd of the transport
-		 * address should be adjusted to 2*MTU.
+		/* RFC 2960 Section 7.2.1, sctpimpguide
+		 * When the endpoint does not transmit data on a given
+		 * transport address, the cwnd of the transport address
+		 * should be adjusted to max(cwnd/2, 4*MTU) per RTO.
 		 * NOTE: Although the draft recommends that this check needs
 		 * to be done every RTO interval, we do it every hearbeat
 		 * interval.
 		 */
 		if ((jiffies - transport->last_time_used) > transport->rto)
-			transport->cwnd = 2*transport->asoc->pmtu;
+			transport->cwnd = max(transport->cwnd/2,
+						 4*transport->asoc->pmtu);
 		break;
 	};

diff -Nru a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
--- a/net/sctp/ulpevent.c	2004-10-22 12:06:24 -07:00
+++ b/net/sctp/ulpevent.c	2004-10-22 12:06:24 -07:00
@@ -562,7 +562,7 @@
 	struct sctp_shutdown_event *sse;
 	struct sk_buff *skb;

-	event = sctp_ulpevent_new(sizeof(struct sctp_assoc_change),
+	event = sctp_ulpevent_new(sizeof(struct sctp_shutdown_event),
 				  MSG_NOTIFICATION, gfp);
 	if (!event)
 		goto fail;
@@ -613,6 +613,40 @@
 	return NULL;
 }

+/* Create and initialize a SCTP_ADAPTION_INDICATION notification.
+ *
+ * Socket Extensions for SCTP
+ * 5.3.1.6 SCTP_ADAPTION_INDICATION
+ */
+struct sctp_ulpevent *sctp_ulpevent_make_adaption_indication(
+	const struct sctp_association *asoc, int gfp)
+{
+	struct sctp_ulpevent *event;
+	struct sctp_adaption_event *sai;
+	struct sk_buff *skb;
+
+	event = sctp_ulpevent_new(sizeof(struct sctp_adaption_event),
+				  MSG_NOTIFICATION, gfp);
+	if (!event)
+		goto fail;
+
+	skb = sctp_event2skb(event);
+	sai = (struct sctp_adaption_event *)
+		skb_put(skb, sizeof(struct sctp_adaption_event));
+
+	sai->sai_type = SCTP_ADAPTION_INDICATION;
+	sai->sai_flags = 0;
+	sai->sai_length = sizeof(struct sctp_adaption_event);
+	sai->sai_adaption_ind = asoc->peer.adaption_ind;
+	sctp_ulpevent_set_owner(event, asoc);
+	sai->sai_assoc_id = sctp_assoc2id(asoc);
+
+	return event;
+
+fail:
+	return NULL;
+}
+
 /* A message has been received.  Package this message as a notification
  * to pass it to the upper layers.  Go ahead and calculate the sndrcvinfo
  * even if filtered out later.
@@ -689,7 +723,7 @@
 	struct sctp_pdapi_event *pd;
 	struct sk_buff *skb;

-	event = sctp_ulpevent_new(sizeof(struct sctp_assoc_change),
+	event = sctp_ulpevent_new(sizeof(struct sctp_pdapi_event),
 				  MSG_NOTIFICATION, gfp);
 	if (!event)
 		goto fail;
