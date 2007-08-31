From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [Lksctp-developers] SCTP: Fix dead loop while received unexpected
 chunk with length set to zero
Date: Fri, 31 Aug 2007 18:21:27 +0800
Message-ID: <46D7EBA7.5080807@cn.fujitsu.com>
References: <46D223A0.3080604@cn.fujitsu.com> <46D44630.8070802@hp.com> <46D51F91.90101@cn.fujitsu.com> <46D5901C.3010802@hp.com> <46D658B8.8070801@cn.fujitsu.com> <46D6C9F2.5020702@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:53297 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754268AbXHaKXa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 06:23:30 -0400
In-Reply-To: <46D6C9F2.5020702@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vlad Yasevich wrote:
> Wei Yongjun wrote:
>   
>> Vlad Yasevich wrote:
>>     
>>> Wei Yongjun wrote:
>>>  
>>>       
>>>> Vlad Yasevich wrote:
>>>>    
>>>>         
>>>>> NACK
>>>>>
>>>>> Section 8.4:
>>>>>
>>>>>    An SCTP packet is called an "out of the blue" (OOTB) packet if it is
>>>>>    correctly formed (i.e., passed the receiver's CRC32c check; see
>>>>>    Section 6.8), but the receiver is not able to identify the
>>>>>    association to which this packet belongs.
>>>>>
>>>>>
>>>>> I would argue that the packet is not correctly formed in this case
>>>>> and deserves a protocol violation ABORT in return.
>>>>>
>>>>> -vlad
>>>>>         
>>>>>           
>>>> As your comment, patch has been changed.
>>>> Patch has been split to two, one is resolve this dead loop problem in
>>>> this mail.
>>>> And the other is come in another mail to discard partial chunk which
>>>> chunk length is set to zero.
>>>>     
>>>>         
>>> I am starting to question the entire OOTB packet handling.  There are way
>>> too many function that do almost the same thing and all handle OOTB a
>>> little
>>> different.
>>>
>>> sctp_sf_do_9_2_reshutack() is also called during sctp_sf_do_dupcook_a()
>>> processing, so checking for INIT chunk is wrong.  Checking for just the
>>> chunkhdr_t should be enough.
>>>   
>>>       
>> This has been changed.
>>     
>>> sctp_sf_tabort_8_4_8 is used directly as well (not just through the state
>>> machine).  Not sure if the header verification is appropriate.
>>>   
>>>       
>> It is needed. Because sctp_sf_tabort_8_4_8() is called to handle OOTB
>> packet before check the header length.
>>     
>
> But now we are doing the same thing twice (and this is not the only place).
> I know I am being really picky here, but I am starting to thing the ootb handling\
> is a mess and I really don't want to add to the mess.
>
> Until I (or someone else) prove that it's not a mess or fix it, I am going
> to hold off on these patches.
>
> Feel free to go through the spec and fix all the OOTB handling.
>
> Thanks
> -vlad
>   
Packet changed:
1. Used sctp_sf_ootb() to handle OOTB packet
2. Remove length check from sctp_sf_tabort_8_4_8() in last patch
3. Add length check to sctp_sf_ootb()
4. Changed validity check order in sctp_sf_do_5_1B_init() and other functions to fix possible attack.

This patch may be correct.

 
Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

diff -Nurp a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
--- a/net/sctp/sm_statefuns.c	2007-08-17 06:17:14.000000000 -0400
+++ b/net/sctp/sm_statefuns.c	2007-08-19 07:52:17.000000000 -0400
@@ -98,6 +98,7 @@ static sctp_disposition_t sctp_stop_t1_a
 					   struct sctp_transport *transport);
 
 static sctp_disposition_t sctp_sf_abort_violation(
+				     const struct sctp_endpoint *ep,
 				     const struct sctp_association *asoc,
 				     void *arg,
 				     sctp_cmd_seq_t *commands,
@@ -181,6 +182,14 @@ sctp_disposition_t sctp_sf_do_4_C(const 
 	struct sctp_chunk *chunk = arg;
 	struct sctp_ulpevent *ev;
 
+	if (!sctp_vtag_verify_either(chunk, asoc))
+		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
+
+	/* Make sure that the SHUTDOWN_COMPLETE chunk has a valid length. */
+	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_chunkhdr_t)))
+		return sctp_sf_violation_chunklen(ep, asoc, type, arg,
+						  commands);
+
 	/* RFC 2960 6.10 Bundling
 	 *
 	 * An endpoint MUST NOT bundle INIT, INIT ACK or
@@ -189,9 +198,6 @@ sctp_disposition_t sctp_sf_do_4_C(const 
 	if (!chunk->singleton)
 		return SCTP_DISPOSITION_VIOLATION;
 
-	if (!sctp_vtag_verify_either(chunk, asoc))
-		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
-
 	/* RFC 2960 10.2 SCTP-to-ULP
 	 *
 	 * H) SHUTDOWN COMPLETE notification
@@ -267,6 +273,20 @@ sctp_disposition_t sctp_sf_do_5_1B_init(
 	struct sock *sk;
 	int len;
 
+	/* Make sure that the INIT chunk has a valid length.
+	 * Normally, this would cause an ABORT with a Protocol Violation
+	 * error, but since we don't have an association, we'll
+	 * just discard the packet.
+	 */
+	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_init_chunk_t)))
+		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
+
+	/* 3.1 A packet containing an INIT chunk MUST have a zero Verification
+	 * Tag.
+	 */
+	if (chunk->sctp_hdr->vtag != 0)
+		return sctp_sf_tabort_8_4_8(ep, asoc, type, arg, commands);
+
 	/* 6.10 Bundling
 	 * An endpoint MUST NOT bundle INIT, INIT ACK or
 	 * SHUTDOWN COMPLETE with any other chunks.
@@ -295,20 +315,6 @@ sctp_disposition_t sctp_sf_do_5_1B_init(
 	     sk_acceptq_is_full(sk)))
 		return sctp_sf_tabort_8_4_8(ep, asoc, type, arg, commands);
 
-	/* 3.1 A packet containing an INIT chunk MUST have a zero Verification
-	 * Tag.
-	 */
-	if (chunk->sctp_hdr->vtag != 0)
-		return sctp_sf_tabort_8_4_8(ep, asoc, type, arg, commands);
-
-	/* Make sure that the INIT chunk has a valid length.
-	 * Normally, this would cause an ABORT with a Protocol Violation
-	 * error, but since we don't have an association, we'll
-	 * just discard the packet.
-	 */
-	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_init_chunk_t)))
-		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
-
 	/* Verify the INIT chunk before processing it. */
 	err_chunk = NULL;
 	if (!sctp_verify_init(asoc, chunk->chunk_hdr->type,
@@ -591,12 +597,6 @@ sctp_disposition_t sctp_sf_do_5_1D_ce(co
 	int error = 0;
 	struct sctp_chunk *err_chk_p;
 
-	/* If the packet is an OOTB packet which is temporarily on the
-	 * control endpoint, respond with an ABORT.
-	 */
-	if (ep == sctp_sk((sctp_get_ctl_sock()))->ep)
-		return sctp_sf_ootb(ep, asoc, type, arg, commands);
-
 	/* Make sure that the COOKIE_ECHO chunk has a valid length.
 	 * In this case, we check that we have enough for at least a
 	 * chunk header.  More detailed verification is done
@@ -605,6 +605,12 @@ sctp_disposition_t sctp_sf_do_5_1D_ce(co
 	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_chunkhdr_t)))
 		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
 
+	/* If the packet is an OOTB packet which is temporarily on the
+	 * control endpoint, respond with an ABORT.
+	 */
+	if (ep == sctp_sk((sctp_get_ctl_sock()))->ep)
+		return sctp_sf_tabort_8_4_8(ep, asoc, type, arg, commands);
+
 	/* "Decode" the chunk.  We have no optional parameters so we
 	 * are in good shape.
 	 */
@@ -1281,6 +1287,20 @@ static sctp_disposition_t sctp_sf_do_une
 	sctp_unrecognized_param_t *unk_param;
 	int len;
 
+	/* Make sure that the INIT chunk has a valid length.
+	 * In this case, we generate a protocol violation since we have
+	 * an association established.
+	 */
+	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_init_chunk_t)))
+		return sctp_sf_violation_chunklen(ep, asoc, type, arg,
+						  commands);
+
+	/* 3.1 A packet containing an INIT chunk MUST have a zero Verification
+	 * Tag.
+	 */
+	if (chunk->sctp_hdr->vtag != 0)
+		return sctp_sf_tabort_8_4_8(ep, asoc, type, arg, commands);
+
 	/* 6.10 Bundling
 	 * An endpoint MUST NOT bundle INIT, INIT ACK or
 	 * SHUTDOWN COMPLETE with any other chunks.
@@ -1293,19 +1313,6 @@ static sctp_disposition_t sctp_sf_do_une
 	if (!chunk->singleton)
 		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
 
-	/* 3.1 A packet containing an INIT chunk MUST have a zero Verification
-	 * Tag.
-	 */
-	if (chunk->sctp_hdr->vtag != 0)
-		return sctp_sf_tabort_8_4_8(ep, asoc, type, arg, commands);
-
-	/* Make sure that the INIT chunk has a valid length.
-	 * In this case, we generate a protocol violation since we have
-	 * an association established.
-	 */
-	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_init_chunk_t)))
-		return sctp_sf_violation_chunklen(ep, asoc, type, arg,
-						  commands);
 	/* Grab the INIT header.  */
 	chunk->subh.init_hdr = (sctp_inithdr_t *) chunk->skb->data;
 
@@ -2495,6 +2502,11 @@ sctp_disposition_t sctp_sf_do_9_2_reshut
 	struct sctp_chunk *chunk = (struct sctp_chunk *) arg;
 	struct sctp_chunk *reply;
 
+	/* Make sure that the chunk has a valid length */
+	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_chunkhdr_t)))
+		return sctp_sf_violation_chunklen(ep, asoc, type, arg,
+						  commands);
+
 	/* Since we are not going to really process this INIT, there
 	 * is no point in verifying chunk boundries.  Just generate
 	 * the SHUTDOWN ACK.
@@ -3146,6 +3158,11 @@ sctp_disposition_t sctp_sf_ootb(const st
 		ch = (sctp_chunkhdr_t *) ch_end;
 	} while (ch_end < skb_tail_pointer(skb));
 
+	/* Make sure that the chunk has a valid length. */
+	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_chunkhdr_t)))
+		return sctp_sf_violation_chunklen(ep, asoc, type, arg,
+						  commands);
+
 	if (ootb_shut_ack)
 		sctp_sf_shut_8_4_5(ep, asoc, type, arg, commands);
 	else
@@ -3240,6 +3257,13 @@ sctp_disposition_t sctp_sf_do_8_5_1_E_sa
 				      void *arg,
 				      sctp_cmd_seq_t *commands)
 {
+	struct sctp_chunk *chunk = arg;
+
+	/* Make sure that the SHUTDOWN_ACK chunk has a valid length. */
+	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_chunkhdr_t)))
+		return sctp_sf_violation_chunklen(ep, asoc, type, arg,
+						  commands);
+
 	/* Although we do have an association in this case, it corresponds
 	 * to a restarted association. So the packet is treated as an OOTB
 	 * packet and the state function that handles OOTB SHUTDOWN_ACK is
@@ -3654,6 +3678,16 @@ sctp_disposition_t sctp_sf_discard_chunk
 					 void *arg,
 					 sctp_cmd_seq_t *commands)
 {
+	struct sctp_chunk *chunk = arg;
+
+	/* Make sure that the chunk has a valid length.
+	 * Since we don't know the chunk type, we use a general
+	 * chunkhdr structure to make a comparison.
+	 */
+	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_chunkhdr_t)))
+		return sctp_sf_violation_chunklen(ep, asoc, type, arg,
+						  commands);
+
 	SCTP_DEBUG_PRINTK("Chunk %d is discarded\n", type.chunk);
 	return SCTP_DISPOSITION_DISCARD;
 }
@@ -3709,6 +3743,13 @@ sctp_disposition_t sctp_sf_violation(con
 				     void *arg,
 				     sctp_cmd_seq_t *commands)
 {
+	struct sctp_chunk *chunk = arg;
+
+	/* Make sure that the chunk has a valid length. */
+	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_chunkhdr_t)))
+		return sctp_sf_violation_chunklen(ep, asoc, type, arg,
+						  commands);
+
 	return SCTP_DISPOSITION_VIOLATION;
 }
 
@@ -3716,12 +3757,14 @@ sctp_disposition_t sctp_sf_violation(con
  * Common function to handle a protocol violation.
  */
 static sctp_disposition_t sctp_sf_abort_violation(
+				     const struct sctp_endpoint *ep,
 				     const struct sctp_association *asoc,
 				     void *arg,
 				     sctp_cmd_seq_t *commands,
 				     const __u8 *payload,
 				     const size_t paylen)
 {
+	struct sctp_packet *packet = NULL;
 	struct sctp_chunk *chunk =  arg;
 	struct sctp_chunk *abort = NULL;
 
@@ -3730,22 +3773,41 @@ static sctp_disposition_t sctp_sf_abort_
 	if (!abort)
 		goto nomem;
 
-	sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(abort));
-	SCTP_INC_STATS(SCTP_MIB_OUTCTRLCHUNKS);
+	if (asoc) {
+		sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(abort));
+		SCTP_INC_STATS(SCTP_MIB_OUTCTRLCHUNKS);
 
-	if (asoc->state <= SCTP_STATE_COOKIE_ECHOED) {
-		sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_STOP,
-				SCTP_TO(SCTP_EVENT_TIMEOUT_T1_INIT));
-		sctp_add_cmd_sf(commands, SCTP_CMD_SET_SK_ERR,
-				SCTP_ERROR(ECONNREFUSED));
-		sctp_add_cmd_sf(commands, SCTP_CMD_INIT_FAILED,
-				SCTP_PERR(SCTP_ERROR_PROTO_VIOLATION));
+		if (asoc->state <= SCTP_STATE_COOKIE_ECHOED) {
+			sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_STOP,
+					SCTP_TO(SCTP_EVENT_TIMEOUT_T1_INIT));
+			sctp_add_cmd_sf(commands, SCTP_CMD_SET_SK_ERR,
+					SCTP_ERROR(ECONNREFUSED));
+			sctp_add_cmd_sf(commands, SCTP_CMD_INIT_FAILED,
+					SCTP_PERR(SCTP_ERROR_PROTO_VIOLATION));
+		} else {
+			sctp_add_cmd_sf(commands, SCTP_CMD_SET_SK_ERR,
+					SCTP_ERROR(ECONNABORTED));
+			sctp_add_cmd_sf(commands, SCTP_CMD_ASSOC_FAILED,
+					SCTP_PERR(SCTP_ERROR_PROTO_VIOLATION));
+			SCTP_DEC_STATS(SCTP_MIB_CURRESTAB);
+		}
 	} else {
-		sctp_add_cmd_sf(commands, SCTP_CMD_SET_SK_ERR,
-				SCTP_ERROR(ECONNABORTED));
-		sctp_add_cmd_sf(commands, SCTP_CMD_ASSOC_FAILED,
-				SCTP_PERR(SCTP_ERROR_PROTO_VIOLATION));
-		SCTP_DEC_STATS(SCTP_MIB_CURRESTAB);
+		packet = sctp_ootb_pkt_new(asoc, chunk);
+
+		if (!packet)
+			goto nomem;
+
+		if (sctp_test_T_bit(abort))
+			packet->vtag = ntohl(chunk->sctp_hdr->vtag);
+
+		abort->skb->sk = ep->base.sk;
+
+		sctp_packet_append_chunk(packet, abort);
+
+		sctp_add_cmd_sf(commands, SCTP_CMD_SEND_PKT, 
+			SCTP_PACKET(packet));
+
+		SCTP_INC_STATS(SCTP_MIB_OUTCTRLCHUNKS);
 	}
 
 	sctp_add_cmd_sf(commands, SCTP_CMD_DISCARD_PACKET, SCTP_NULL());
@@ -3786,7 +3848,7 @@ static sctp_disposition_t sctp_sf_violat
 {
 	char err_str[]="The following chunk had invalid length:";
 
-	return sctp_sf_abort_violation(asoc, arg, commands, err_str,
+	return sctp_sf_abort_violation(ep, asoc, arg, commands, err_str,
 					sizeof(err_str));
 }
 
@@ -3805,7 +3867,7 @@ static sctp_disposition_t sctp_sf_violat
 {
 	char err_str[]="The cumulative tsn ack beyond the max tsn currently sent:";
 
-	return sctp_sf_abort_violation(asoc, arg, commands, err_str,
+	return sctp_sf_abort_violation(ep, asoc, arg, commands, err_str,
 					sizeof(err_str));
 }
 
diff -Nurp a/net/sctp/sm_statetable.c b/net/sctp/sm_statetable.c
--- a/net/sctp/sm_statetable.c	2007-08-09 11:58:11.000000000 -0400
+++ b/net/sctp/sm_statetable.c	2007-08-19 05:44:29.000000000 -0400
@@ -110,7 +110,7 @@ const sctp_sm_table_entry_t *sctp_sm_loo
 	/* SCTP_STATE_EMPTY */ \
 	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
-	TYPE_SCTP_FUNC(sctp_sf_tabort_8_4_8), \
+	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
 	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
@@ -173,7 +173,7 @@ const sctp_sm_table_entry_t *sctp_sm_loo
 	/*  SCTP_STATE_EMPTY */ \
 	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
-	TYPE_SCTP_FUNC(sctp_sf_tabort_8_4_8), \
+	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
 	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
@@ -194,7 +194,7 @@ const sctp_sm_table_entry_t *sctp_sm_loo
 	/*  SCTP_STATE_EMPTY */ \
 	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
-	TYPE_SCTP_FUNC(sctp_sf_tabort_8_4_8), \
+	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
 	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
@@ -216,7 +216,7 @@ const sctp_sm_table_entry_t *sctp_sm_loo
 	/*  SCTP_STATE_EMPTY */ \
 	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
-	TYPE_SCTP_FUNC(sctp_sf_tabort_8_4_8), \
+	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
 	TYPE_SCTP_FUNC(sctp_sf_violation), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
@@ -258,7 +258,7 @@ const sctp_sm_table_entry_t *sctp_sm_loo
 	/* SCTP_STATE_EMPTY */ \
 	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
-	TYPE_SCTP_FUNC(sctp_sf_tabort_8_4_8), \
+	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
 	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
@@ -300,7 +300,7 @@ const sctp_sm_table_entry_t *sctp_sm_loo
 	/* SCTP_STATE_EMPTY */ \
 	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
-	TYPE_SCTP_FUNC(sctp_sf_tabort_8_4_8), \
+	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
 	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
@@ -499,7 +499,7 @@ static const sctp_sm_table_entry_t addip
 	/* SCTP_STATE_EMPTY */ \
 	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
-	TYPE_SCTP_FUNC(sctp_sf_tabort_8_4_8), \
+	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_COOKIE_WAIT */ \
 	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
@@ -528,7 +528,7 @@ chunk_event_table_unknown[SCTP_STATE_NUM
 	/* SCTP_STATE_EMPTY */
 	TYPE_SCTP_FUNC(sctp_sf_ootb),
 	/* SCTP_STATE_CLOSED */
-	TYPE_SCTP_FUNC(sctp_sf_tabort_8_4_8),
+	TYPE_SCTP_FUNC(sctp_sf_ootb),
 	/* SCTP_STATE_COOKIE_WAIT */
 	TYPE_SCTP_FUNC(sctp_sf_unk_chunk),
 	/* SCTP_STATE_COOKIE_ECHOED */


