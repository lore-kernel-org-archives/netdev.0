From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: [PATCH net-next-2.6 v4 4/5] sctp: Add ASCONF operation on the single-homed host
Date: Thu, 21 Apr 2011 04:24:46 +0900
Message-ID: <3BDA3586-6A7C-4305-9D41-F146575AC951@sfc.wide.ad.jp>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: lksctp-developers@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:58624 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755648Ab1DTTYs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 15:24:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SCTP can change the IP address on the single-homed host.  
In this case, the SCTP association transmits an ASCONF packet including addition of the new IP address and deletion of the old address.  This patch implements this functionality.  
In this case, the ASCONF chunk is added to the beginning of the queue, because the other chunks cannot be transmitted in this state.  

Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
---
diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index c70d8cc..d7a4ee3 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -441,4 +441,8 @@ enum {
  */
 #define SCTP_AUTH_RANDOM_LENGTH 32
 
+/* ASCONF PARAMETERS */
+#define SCTP_ASCONF_V4_PARAM_LEN 16
+#define SCTP_ASCONF_V6_PARAM_LEN 28
+
 #endif /* __sctp_constants_h__ */
diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index 9352d12..498a3cf 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -259,6 +259,7 @@ struct sctp_chunk *sctp_process_asconf(struct sctp_association *asoc,
 				       struct sctp_chunk *asconf);
 int sctp_process_asconf_ack(struct sctp_association *asoc,
 			    struct sctp_chunk *asconf_ack);
+void sctp_path_check_and_react(struct sctp_association *, struct sockaddr *);
 struct sctp_chunk *sctp_make_fwdtsn(const struct sctp_association *asoc,
 				    __u32 new_cum_tsn, size_t nstreams,
 				    struct sctp_fwdtsn_skip *skiplist);
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index cc9185c..400ee8a 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1901,6 +1901,9 @@ struct sctp_association {
 	 * after reaching 4294967295.
 	 */
 	__u32 addip_serial;
+	union sctp_addr *asconf_addr_del_pending;
+	__u32 asconf_del_pending_cid;
+	int src_out_of_asoc_ok;
 
 	/* SCTP AUTH: list of the endpoint shared keys.  These
 	 * keys are provided out of band by the user applicaton
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 6b04287..6b19387 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -279,6 +279,9 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 	asoc->peer.asconf_capable = 0;
 	if (sctp_addip_noauth)
 		asoc->peer.asconf_capable = 1;
+	asoc->asconf_addr_del_pending = NULL;
+	asoc->asconf_del_pending_cid = 0;
+	asoc->src_out_of_asoc_ok = 0;
 
 	/* Create an input queue.  */
 	sctp_inq_init(&asoc->base.inqueue);
@@ -443,6 +446,10 @@ void sctp_association_free(struct sctp_association *asoc)
 
 	asoc->peer.transport_count = 0;
 
+	/* Free pending address space being deleted */
+	if (asoc->asconf_addr_del_pending != NULL)
+		kfree(asoc->asconf_addr_del_pending);
+
 	/* Free any cached ASCONF_ACK chunk. */
 	sctp_assoc_free_asconf_acks(asoc);
 
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 865ce7b..56c97ce 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -332,6 +332,13 @@ static void sctp_v6_get_saddr(struct sctp_sock *sk,
 				matchlen = bmatchlen;
 			}
 		}
+		if (laddr->state == SCTP_ADDR_NEW && asoc->src_out_of_asoc_ok) {
+			bmatchlen = sctp_v6_addr_match_len(daddr, &laddr->a);
+			if (!baddr || (matchlen < bmatchlen)) {
+				baddr = &laddr->a;
+				matchlen = bmatchlen;
+			}
+		}
 	}
 
 	if (baddr) {
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 26dc005..033ea20 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -344,7 +344,14 @@ int sctp_outq_tail(struct sctp_outq *q, struct sctp_chunk *chunk)
 			break;
 		}
 	} else {
-		list_add_tail(&chunk->list, &q->control_chunk_list);
+		/* We add the ASCONF for the only one newly added address at
+		 * the front of the queue
+		 */
+		if (q->asoc->src_out_of_asoc_ok && \
+		    chunk->chunk_hdr->type == SCTP_CID_ASCONF)
+			list_add(&chunk->list, &q->control_chunk_list);
+		else
+			list_add_tail(&chunk->list, &q->control_chunk_list);
 		SCTP_INC_STATS(SCTP_MIB_OUTCTRLCHUNKS);
 	}
 
@@ -850,6 +857,24 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
 		case SCTP_CID_SHUTDOWN:
 		case SCTP_CID_ECN_ECNE:
 		case SCTP_CID_ASCONF:
+			/* RFC 5061, 5.3
+			 * F1) This means that until such time as the ASCONF
+			 * containing the add is acknowledged, the sender MUST
+			 * NOT use the new IP address as a source for ANY SCTP
+			 * packet except on carrying an ASCONF Chunk.
+			 */
+			if (asoc->src_out_of_asoc_ok) {
+				SCTP_DEBUG_PRINTK("outq_flush: out_of_asoc_ok, transmit chunk type %d\n",
+				    chunk->chunk_hdr->type);
+				packet = &transport->packet;
+				sctp_packet_config(packet, vtag,
+						asoc->peer.ecn_capable);
+				sctp_packet_append_chunk(packet, chunk);
+				error = sctp_packet_transmit(packet);
+				if (error < 0)
+					return error;
+				goto sctp_flush_out;
+			}
 		case SCTP_CID_FWD_TSN:
 			status = sctp_packet_transmit_chunk(packet, chunk,
 							    one_packet);
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 152976e..b8ec3cc 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -510,7 +510,8 @@ static struct dst_entry *sctp_v4_get_dst(struct sctp_association *asoc,
 		sctp_v4_dst_saddr(&dst_saddr, dst, htons(bp->port));
 		rcu_read_lock();
 		list_for_each_entry_rcu(laddr, &bp->address_list, list) {
-			if (!laddr->valid || (laddr->state != SCTP_ADDR_SRC))
+			if (!laddr->valid || (laddr->state != SCTP_ADDR_SRC &&
+			    asoc->src_out_of_asoc_ok == 0))
 				continue;
 			if (sctp_v4_cmp_addr(&dst_saddr, &laddr->a))
 				goto out_unlock;
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index de98665..581a9f5 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2651,6 +2651,61 @@ __u32 sctp_generate_tsn(const struct sctp_endpoint *ep)
 	return retval;
 }
 
+void
+sctp_path_check_and_react(struct sctp_association *asoc, struct sockaddr *sa)
+{
+	struct sctp_transport *trans;
+	int addrnum, family;
+	struct sctp_sockaddr_entry *saddr;
+	struct sctp_bind_addr *bp;
+	union sctp_addr *tmpaddr;
+
+	family = sa->sa_family;
+	bp = &asoc->base.bind_addr;
+	addrnum = 0;
+	/* count up the number of local addresses in the same family */
+	list_for_each_entry(saddr, &bp->address_list, list) {
+		if (saddr->a.sa.sa_family == family) {
+			tmpaddr = &saddr->a;
+			if (family == AF_INET6 &&
+			    ipv6_addr_type(&tmpaddr->v6.sin6_addr) &
+			    IPV6_ADDR_LINKLOCAL) {
+				continue;
+			}
+			addrnum++;
+		}
+	}
+	if (addrnum == 1) {
+		union sctp_addr *tmpaddr;
+		tmpaddr = (union sctp_addr *)sa;
+		SCTP_DEBUG_PRINTK_IPADDR("pcheck_react: only 1 local addr in asoc %p ",
+		    " family %d\n", asoc, tmpaddr, family);
+		list_for_each_entry(trans, &asoc->peer.transport_addr_list,
+		    transports) {
+			/* reset path information and release refcount to the
+			 * dst_entry  based on the src change */
+			sctp_transport_hold(trans);
+			trans->cwnd = min(4*asoc->pathmtu,
+			    max_t(__u32, 2*asoc->pathmtu, 4380));
+			trans->ssthresh = asoc->peer.i.a_rwnd;
+			trans->rtt = 0;
+			trans->srtt = 0;
+			trans->rttvar = 0;
+			trans->rto = asoc->rto_initial;
+			dst_release(trans->dst);
+			trans->dst = NULL;
+			memset(&trans->saddr, 0, sizeof(union sctp_addr));
+			sctp_transport_route(trans, NULL,
+			    sctp_sk(asoc->base.sk));
+			SCTP_DEBUG_PRINTK_IPADDR("we freed dst_entry (asoc: %p dst: ",
+			    " trans: %p)\n", asoc, (&trans->ipaddr), trans);
+			trans->rto_pending = 1;
+			sctp_transport_put(trans);
+		}
+	}
+	return;
+}
+
 /*
  * ADDIP 3.1.1 Address Configuration Change Chunk (ASCONF)
  *      0                   1                   2                   3
@@ -2744,11 +2799,24 @@ struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *asoc,
 	int			addr_param_len = 0;
 	int 			totallen = 0;
 	int 			i;
+	sctp_addip_param_t del_param; /* 8 Bytes (Type 0xC002, Len and CrrID) */
+	struct sctp_af *del_af;
+	int del_addr_param_len = 0;
+	int del_paramlen = sizeof(sctp_addip_param_t);
+	union sctp_addr_param del_addr_param; /* (v4) 8 Bytes, (v6) 20 Bytes */
+	int			v4 = 0;
+	int			v6 = 0;
 
 	/* Get total length of all the address parameters. */
 	addr_buf = addrs;
 	for (i = 0; i < addrcnt; i++) {
 		addr = (union sctp_addr *)addr_buf;
+		if (addr != NULL) {
+			if (addr->sa.sa_family == AF_INET)
+				v4 = 1;
+			else if (addr->sa.sa_family == AF_INET6)
+				v6 = 1;
+		}
 		af = sctp_get_af_specific(addr->v4.sin_family);
 		addr_param_len = af->to_addr_param(addr, &addr_param);
 
@@ -2757,6 +2825,24 @@ struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *asoc,
 
 		addr_buf += af->sockaddr_len;
 	}
+	/* Add the length of a pending address being deleted */
+	if (flags == SCTP_PARAM_ADD_IP && asoc->asconf_addr_del_pending) {
+		if ((asoc->asconf_addr_del_pending->sa.sa_family == AF_INET
+		    && v4) ||
+		    (asoc->asconf_addr_del_pending->sa.sa_family == AF_INET6
+		    && v6)) {
+			del_af = sctp_get_af_specific(
+			    asoc->asconf_addr_del_pending->sa.sa_family);
+			del_addr_param_len = del_af->to_addr_param(
+			    asoc->asconf_addr_del_pending, &del_addr_param);
+			totallen += del_paramlen;
+			totallen += del_addr_param_len;
+			SCTP_DEBUG_PRINTK("mkasconf_update_ip: now we picked del_pending addr, totallen for all addresses is %d\n",
+			    totallen);
+		}
+	}
+	SCTP_DEBUG_PRINTK("mkasconf_update_ip: call mkasconf() for %d bytes\n",
+	    totallen);
 
 	/* Create an asconf chunk with the required length. */
 	retval = sctp_make_asconf(asoc, laddr, totallen);
@@ -2778,6 +2864,20 @@ struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *asoc,
 
 		addr_buf += af->sockaddr_len;
 	}
+	if (flags == SCTP_PARAM_ADD_IP && asoc->asconf_addr_del_pending) {
+		addr = asoc->asconf_addr_del_pending;
+		del_af = sctp_get_af_specific(addr->v4.sin_family);
+		del_addr_param_len = del_af->to_addr_param(addr,
+		    &del_addr_param);
+		del_param.param_hdr.type = SCTP_PARAM_DEL_IP;
+		del_param.param_hdr.length = htons(del_paramlen +
+		    del_addr_param_len);
+		del_param.crr_id = i;
+		asoc->asconf_del_pending_cid = i;
+
+		sctp_addto_chunk(retval, del_paramlen, &del_param);
+		sctp_addto_chunk(retval, del_addr_param_len, &del_addr_param);
+	}
 	return retval;
 }
 
@@ -3193,16 +3293,37 @@ static void sctp_asconf_param_success(struct sctp_association *asoc,
 		local_bh_enable();
 		list_for_each_entry(transport, &asoc->peer.transport_addr_list,
 				transports) {
-			if (transport->state == SCTP_ACTIVE)
+			if (transport->state == SCTP_ACTIVE &&
+			    !asoc->src_out_of_asoc_ok)
 				continue;
 			dst_release(transport->dst);
 			sctp_transport_route(transport, NULL,
 					     sctp_sk(asoc->base.sk));
 		}
+		asoc->src_out_of_asoc_ok = 0;
 		break;
 	case SCTP_PARAM_DEL_IP:
 		local_bh_disable();
 		sctp_del_bind_addr(bp, &addr);
+		if (asoc->asconf_addr_del_pending != NULL) {
+			if ((addr.sa.sa_family == AF_INET) &&
+			    (asoc->asconf_addr_del_pending->sa.sa_family ==
+			     AF_INET)) {
+				if (asoc->asconf_addr_del_pending->v4.sin_addr.s_addr == addr.v4.sin_addr.s_addr) {
+					kfree(asoc->asconf_addr_del_pending);
+					asoc->asconf_del_pending_cid = 0;
+					asoc->asconf_addr_del_pending = NULL;
+				}
+			} else if ((addr.sa.sa_family == AF_INET6) &&
+				(asoc->asconf_addr_del_pending->sa.sa_family ==
+				 AF_INET6)) {
+				if (ipv6_addr_equal(&asoc->asconf_addr_del_pending->v6.sin6_addr, &addr.v6.sin6_addr)) {
+					kfree(asoc->asconf_addr_del_pending);
+					asoc->asconf_del_pending_cid = 0;
+					asoc->asconf_addr_del_pending = NULL;
+				}
+			}
+		}
 		local_bh_enable();
 		list_for_each_entry(transport, &asoc->peer.transport_addr_list,
 				transports) {
@@ -3293,6 +3414,8 @@ int sctp_process_asconf_ack(struct sctp_association *asoc,
 	int	no_err = 1;
 	int	retval = 0;
 	__be16	err_code = SCTP_ERROR_NO_ERROR;
+	sctp_addip_param_t *first_asconf_param = NULL;
+	int first_asconf_paramlen;
 
 	/* Skip the chunkhdr and addiphdr from the last asconf sent and store
 	 * a pointer to address parameter.
@@ -3307,6 +3430,8 @@ int sctp_process_asconf_ack(struct sctp_association *asoc,
 	length = ntohs(addr_param->v4.param_hdr.length);
 	asconf_param = (sctp_addip_param_t *)((void *)addr_param + length);
 	asconf_len -= length;
+	first_asconf_param = asconf_param;
+	first_asconf_paramlen = ntohs(first_asconf_param->param_hdr.length);
 
 	/* ADDIP 4.1
 	 * A8) If there is no response(s) to specific TLV parameter(s), and no
@@ -3361,6 +3486,35 @@ int sctp_process_asconf_ack(struct sctp_association *asoc,
 		asconf_len -= length;
 	}
 
+	/* When the source address obviously changes to newly added one, we
+	   reset the cwnd to re-probe the path condition
+	*/
+	if (no_err && first_asconf_param->param_hdr.type == SCTP_PARAM_ADD_IP) {
+		if (first_asconf_paramlen == SCTP_ASCONF_V4_PARAM_LEN) {
+			struct sockaddr_in sin;
+
+			memset(&sin, 0, sizeof(struct sockaddr_in));
+			sin.sin_family = AF_INET;
+			memcpy(&sin.sin_addr.s_addr, first_asconf_param + 1,
+					sizeof(struct in_addr));
+			sctp_path_check_and_react(asoc,
+					(struct sockaddr *)&sin);
+
+		} else if (first_asconf_paramlen == SCTP_ASCONF_V6_PARAM_LEN) {
+			struct sockaddr_in6 sin6;
+
+			memset(&sin6, 0, sizeof(struct sockaddr_in6));
+			sin6.sin6_family = AF_INET6;
+			memcpy(&sin6.sin6_addr, first_asconf_param + 1,
+					sizeof(struct in6_addr));
+			sctp_path_check_and_react(asoc,
+					(struct sockaddr *)&sin6);
+		} else {
+			SCTP_DEBUG_PRINTK("funny asconf_paramlen? (%d)\n",
+			    first_asconf_paramlen);
+		}
+	}
+
 	/* Free the cached last sent asconf chunk. */
 	list_del_init(&asconf->transmitted_list);
 	sctp_chunk_free(asconf);
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 3951a10..2bfe2a9 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -527,6 +527,7 @@ static int sctp_send_asconf_add_ip(struct sock		*sk,
 	struct list_head		*p;
 	int 				i;
 	int 				retval = 0;
+	struct sctp_transport		*trans = NULL;
 
 	if (!sctp_addip_enable)
 		return retval;
@@ -583,13 +584,10 @@ static int sctp_send_asconf_add_ip(struct sock		*sk,
 			goto out;
 		}
 
-		retval = sctp_send_asconf(asoc, chunk);
-		if (retval)
-			goto out;
-
 		/* Add the new addresses to the bind address list with
 		 * use_as_src set to 0.
 		 */
+		SCTP_DEBUG_PRINTK("snd_asconf_addip: next, add_bind_addr with ADDR_NEW flag\n");
 		addr_buf = addrs;
 		for (i = 0; i < addrcnt; i++) {
 			addr = (union sctp_addr *)addr_buf;
@@ -599,6 +597,28 @@ static int sctp_send_asconf_add_ip(struct sock		*sk,
 						    SCTP_ADDR_NEW, GFP_ATOMIC);
 			addr_buf += af->sockaddr_len;
 		}
+		list_for_each_entry(trans, &asoc->peer.transport_addr_list,
+		    transports) {
+			if (asoc->asconf_addr_del_pending != NULL)
+				/* This ADDIP ASCONF piggybacks DELIP for the
+				 * last address, so need to select src addr
+				 * from the out_of_asoc addrs
+				 */
+				asoc->src_out_of_asoc_ok = 1;
+			/* Clear the source and route cache in the path */
+			memset(&trans->saddr, 0, sizeof(union sctp_addr));
+			dst_release(trans->dst);
+			trans->cwnd = min(4*asoc->pathmtu, max_t(__u32,
+			    2*asoc->pathmtu, 4380));
+			trans->ssthresh = asoc->peer.i.a_rwnd;
+			trans->rto = asoc->rto_initial;
+			trans->rtt = 0;
+			trans->srtt = 0;
+			trans->rttvar = 0;
+			sctp_transport_route(trans, NULL,
+			    sctp_sk(asoc->base.sk));
+		}
+		retval = sctp_send_asconf(asoc, chunk);
 	}
 
 out:
@@ -711,7 +731,9 @@ static int sctp_send_asconf_del_ip(struct sock		*sk,
 	struct sctp_sockaddr_entry *saddr;
 	int 			i;
 	int 			retval = 0;
+	int			stored = 0;
 
+	chunk = NULL;
 	if (!sctp_addip_enable)
 		return retval;
 
@@ -762,8 +784,42 @@ static int sctp_send_asconf_del_ip(struct sock		*sk,
 		bp = &asoc->base.bind_addr;
 		laddr = sctp_find_unmatch_addr(bp, (union sctp_addr *)addrs,
 					       addrcnt, sp);
-		if (!laddr)
-			continue;
+		if ((laddr == NULL) && (addrcnt == 1)) {
+			union sctp_addr *sa_addr = NULL;
+
+			if (asoc->asconf_addr_del_pending == NULL) {
+				asoc->asconf_addr_del_pending =
+				    kmalloc(sizeof(union sctp_addr),
+				    GFP_ATOMIC);
+				memset(asoc->asconf_addr_del_pending, 0,
+						sizeof(union sctp_addr));
+				if (addrs->sa_family == AF_INET) {
+					struct sockaddr_in *sin;
+
+					sin = (struct sockaddr_in *)addrs;
+					asoc->asconf_addr_del_pending->v4.sin_family = AF_INET;
+					memcpy(&asoc->asconf_addr_del_pending->v4.sin_addr, &sin->sin_addr, sizeof(struct in_addr));
+				} else if (addrs->sa_family == AF_INET6) {
+					struct sockaddr_in6 *sin6;
+
+					sin6 = (struct sockaddr_in6 *)addrs;
+					asoc->asconf_addr_del_pending->v6.sin6_family = AF_INET6;
+					memcpy(&asoc->asconf_addr_del_pending->v6.sin6_addr, &sin6->sin6_addr, sizeof(struct in6_addr));
+				}
+				sa_addr = (union sctp_addr *)addrs;
+				SCTP_DEBUG_PRINTK_IPADDR("send_asconf_del_ip: keep the last address asoc: %p ",
+				    " at %p\n", asoc, sa_addr,
+				    asoc->asconf_addr_del_pending);
+				stored = 1;
+				goto skip_mkasconf;
+			} else {
+				SCTP_DEBUG_PRINTK_IPADDR("send_asconf_del_ip: asoc %p, deleting last address ",
+				    " is already stored at %p\n", asoc,
+				    asoc->asconf_addr_del_pending,
+				    asoc->asconf_addr_del_pending);
+				continue;
+			}
+		}
 
 		/* We do not need RCU protection throughout this loop
 		 * because this is done under a socket lock from the
@@ -776,6 +832,7 @@ static int sctp_send_asconf_del_ip(struct sock		*sk,
 			goto out;
 		}
 
+skip_mkasconf:
 		/* Reset use_as_src flag for the addresses in the bind address
 		 * list that are to be deleted.
 		 */
@@ -797,10 +854,16 @@ static int sctp_send_asconf_del_ip(struct sock		*sk,
 		list_for_each_entry(transport, &asoc->peer.transport_addr_list,
 					transports) {
 			dst_release(transport->dst);
+			/* Clear source address cache */
+			memset(&transport->saddr, 0, sizeof(union sctp_addr));
 			sctp_transport_route(transport, NULL,
 					     sctp_sk(asoc->base.sk));
 		}
 
+		if (stored) {
+			/* We don't need to transmit ASCONF */
+			continue;
+		}
 		retval = sctp_send_asconf(asoc, chunk);
 	}
 out:

