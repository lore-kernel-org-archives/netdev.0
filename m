From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [Lksctp-developers] SCTP: Fix dead loop while received unexpected
 chunk with length set to zero
Date: Wed, 29 Aug 2007 11:26:20 -0400
Message-ID: <46D5901C.3010802@hp.com>
References: <46D223A0.3080604@cn.fujitsu.com> <46D44630.8070802@hp.com> <46D51F91.90101@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:41501 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756607AbXH2P0d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Aug 2007 11:26:33 -0400
In-Reply-To: <46D51F91.90101@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wei Yongjun wrote:
> Vlad Yasevich wrote:
>>
>> NACK
>>
>> Section 8.4:
>>
>>    An SCTP packet is called an "out of the blue" (OOTB) packet if it is
>>    correctly formed (i.e., passed the receiver's CRC32c check; see
>>    Section 6.8), but the receiver is not able to identify the
>>    association to which this packet belongs.
>>
>>
>> I would argue that the packet is not correctly formed in this case
>> and deserves a protocol violation ABORT in return.
>>
>> -vlad
>>   
> As your comment, patch has been changed.
> Patch has been split to two, one is resolve this dead loop problem in
> this mail.
> And the other is come in another mail to discard partial chunk which
> chunk length is set to zero.


I am starting to question the entire OOTB packet handling.  There are way
too many function that do almost the same thing and all handle OOTB a little
different.

> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> 
> --- a/net/sctp/sm_statefuns.c    2007-08-17 06:17:14.000000000 -0400
> +++ b/net/sctp/sm_statefuns.c    2007-08-17 09:57:17.000000000 -0400
> @@ -98,6 +98,7 @@ static sctp_disposition_t sctp_stop_t1_a
>                        struct sctp_transport *transport);
> 
> static sctp_disposition_t sctp_sf_abort_violation(
> +                     const struct sctp_endpoint *ep,
>                      const struct sctp_association *asoc,
>                      void *arg,
>                      sctp_cmd_seq_t *commands,
> @@ -192,6 +193,11 @@ sctp_disposition_t sctp_sf_do_4_C(const     if
> (!sctp_vtag_verify_either(chunk, asoc))
>         return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
> 
> +    /* Make sure that the SHUTDOWN_COMPLETE chunk has a valid length. */
> +    if (!sctp_chunk_length_valid(chunk, sizeof(sctp_chunkhdr_t)))
> +        return sctp_sf_violation_chunklen(ep, asoc, type, arg,
> +                          commands);
> +
>     /* RFC 2960 10.2 SCTP-to-ULP
>      *
>      * H) SHUTDOWN COMPLETE notification
> @@ -2495,6 +2501,11 @@ sctp_disposition_t sctp_sf_do_9_2_reshut
>     struct sctp_chunk *chunk = (struct sctp_chunk *) arg;
>     struct sctp_chunk *reply;
> 
> +    /* Make sure that the INIT chunk has a valid length */
> +    if (!sctp_chunk_length_valid(chunk, sizeof(sctp_init_chunk_t)))
> +        return sctp_sf_violation_chunklen(ep, asoc, type, arg,
> +                          commands);
> +

sctp_sf_do_9_2_reshutack() is also called during sctp_sf_do_dupcook_a()
processing, so checking for INIT chunk is wrong.  Checking for just the
chunkhdr_t should be enough.


>     /* Since we are not going to really process this INIT, there
>      * is no point in verifying chunk boundries.  Just generate
>      * the SHUTDOWN ACK.
> @@ -2938,6 +2949,11 @@ sctp_disposition_t sctp_sf_tabort_8_4_8(
>     struct sctp_chunk *chunk = arg;
>     struct sctp_chunk *abort;
> 
> +    /* Make sure that the chunk has a valid length. */
> +    if (!sctp_chunk_length_valid(chunk, sizeof(sctp_chunkhdr_t)))
> +        return sctp_sf_violation_chunklen(ep, asoc, type, arg,
> +                          commands);
> +
>     packet = sctp_ootb_pkt_new(asoc, chunk);

sctp_sf_tabort_8_4_8 is used directly as well (not just through the state
machine).  Not sure if the header verification is appropriate.

> 
>     if (packet) {
> @@ -3185,6 +3201,11 @@ static sctp_disposition_t sctp_sf_shut_8
>     struct sctp_chunk *chunk = arg;
>     struct sctp_chunk *shut;
> 
> +    /* Make sure that the SHUTDOWN_ACK chunk has a valid length. */
> +    if (!sctp_chunk_length_valid(chunk, sizeof(sctp_chunkhdr_t)))
> +        return sctp_sf_violation_chunklen(ep, asoc, type, arg,
> +                          commands);
> +
>     packet = sctp_ootb_pkt_new(asoc, chunk);

This is a static function, so any verifications should already have been
done.

> 
>     if (packet) {
> @@ -3240,6 +3261,13 @@ sctp_disposition_t sctp_sf_do_8_5_1_E_sa
>                       void *arg,
>                       sctp_cmd_seq_t *commands)
> {
> +    struct sctp_chunk *chunk = arg;
> +
> +    /* Make sure that the SHUTDOWN_ACK chunk has a valid length. */
> +    if (!sctp_chunk_length_valid(chunk, sizeof(sctp_chunkhdr_t)))
> +        return sctp_sf_violation_chunklen(ep, asoc, type, arg,
> +                          commands);
> +
>     /* Although we do have an association in this case, it corresponds
>      * to a restarted association. So the packet is treated as an OOTB
>      * packet and the state function that handles OOTB SHUTDOWN_ACK is
> @@ -3654,6 +3682,16 @@ sctp_disposition_t sctp_sf_discard_chunk
>                      void *arg,
>                      sctp_cmd_seq_t *commands)
> {
> +    struct sctp_chunk *chunk = arg;
> +
> +    /* Make sure that the chunk has a valid length.
> +     * Since we don't know the chunk type, we use a general
> +     * chunkhdr structure to make a comparison.
> +     */
> +    if (!sctp_chunk_length_valid(chunk, sizeof(sctp_chunkhdr_t)))
> +        return sctp_sf_violation_chunklen(ep, asoc, type, arg,
> +                          commands);
> +
>     SCTP_DEBUG_PRINTK("Chunk %d is discarded\n", type.chunk);
>     return SCTP_DISPOSITION_DISCARD;
> }
> @@ -3709,6 +3747,13 @@ sctp_disposition_t sctp_sf_violation(con
>                      void *arg,
>                      sctp_cmd_seq_t *commands)
> {
> +    struct sctp_chunk *chunk = arg;
> +
> +    /* Make sure that the chunk has a valid length. */
> +    if (!sctp_chunk_length_valid(chunk, sizeof(sctp_chunkhdr_t)))
> +        return sctp_sf_violation_chunklen(ep, asoc, type, arg,
> +                          commands);
> +
>     return SCTP_DISPOSITION_VIOLATION;
> }
> 
> @@ -3716,12 +3761,14 @@ sctp_disposition_t sctp_sf_violation(con
>  * Common function to handle a protocol violation.
>  */
> static sctp_disposition_t sctp_sf_abort_violation(
> +                     const struct sctp_endpoint *ep,
>                      const struct sctp_association *asoc,
>                      void *arg,
>                      sctp_cmd_seq_t *commands,
>                      const __u8 *payload,
>                      const size_t paylen)
> {
> +    struct sctp_packet *packet = NULL;
>     struct sctp_chunk *chunk =  arg;
>     struct sctp_chunk *abort = NULL;
> 
> @@ -3730,22 +3777,41 @@ static sctp_disposition_t sctp_sf_abort_
>     if (!abort)
>         goto nomem;
> 
> -    sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(abort));
> -    SCTP_INC_STATS(SCTP_MIB_OUTCTRLCHUNKS);
> +    if (asoc) {
> +        sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(abort));
> +        SCTP_INC_STATS(SCTP_MIB_OUTCTRLCHUNKS);
> 
> -    if (asoc->state <= SCTP_STATE_COOKIE_ECHOED) {
> -        sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_STOP,
> -                SCTP_TO(SCTP_EVENT_TIMEOUT_T1_INIT));
> -        sctp_add_cmd_sf(commands, SCTP_CMD_SET_SK_ERR,
> -                SCTP_ERROR(ECONNREFUSED));
> -        sctp_add_cmd_sf(commands, SCTP_CMD_INIT_FAILED,
> -                SCTP_PERR(SCTP_ERROR_PROTO_VIOLATION));
> +        if (asoc->state <= SCTP_STATE_COOKIE_ECHOED) {
> +            sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_STOP,
> +                    SCTP_TO(SCTP_EVENT_TIMEOUT_T1_INIT));
> +            sctp_add_cmd_sf(commands, SCTP_CMD_SET_SK_ERR,
> +                    SCTP_ERROR(ECONNREFUSED));
> +            sctp_add_cmd_sf(commands, SCTP_CMD_INIT_FAILED,
> +                    SCTP_PERR(SCTP_ERROR_PROTO_VIOLATION));
> +        } else {
> +            sctp_add_cmd_sf(commands, SCTP_CMD_SET_SK_ERR,
> +                    SCTP_ERROR(ECONNABORTED));
> +            sctp_add_cmd_sf(commands, SCTP_CMD_ASSOC_FAILED,
> +                    SCTP_PERR(SCTP_ERROR_PROTO_VIOLATION));
> +            SCTP_DEC_STATS(SCTP_MIB_CURRESTAB);
> +        }
>     } else {
> -        sctp_add_cmd_sf(commands, SCTP_CMD_SET_SK_ERR,
> -                SCTP_ERROR(ECONNABORTED));
> -        sctp_add_cmd_sf(commands, SCTP_CMD_ASSOC_FAILED,
> -                SCTP_PERR(SCTP_ERROR_PROTO_VIOLATION));
> -        SCTP_DEC_STATS(SCTP_MIB_CURRESTAB);
> +        packet = sctp_ootb_pkt_new(asoc, chunk);
> +
> +        if (!packet)
> +            goto nomem;
> +
> +        if (sctp_test_T_bit(abort))
> +            packet->vtag = ntohl(chunk->sctp_hdr->vtag);
> +
> +        abort->skb->sk = ep->base.sk;
> +
> +        sctp_packet_append_chunk(packet, abort);
> +
> +        sctp_add_cmd_sf(commands, SCTP_CMD_SEND_PKT, +           
> SCTP_PACKET(packet));
> +
> +        SCTP_INC_STATS(SCTP_MIB_OUTCTRLCHUNKS);
>     }
> 
>     sctp_add_cmd_sf(commands, SCTP_CMD_DISCARD_PACKET, SCTP_NULL());
> @@ -3786,7 +3852,7 @@ static sctp_disposition_t sctp_sf_violat
> {
>     char err_str[]="The following chunk had invalid length:";
> 
> -    return sctp_sf_abort_violation(asoc, arg, commands, err_str,
> +    return sctp_sf_abort_violation(ep, asoc, arg, commands, err_str,
>                     sizeof(err_str));
> }
> 
> @@ -3805,7 +3871,7 @@ static sctp_disposition_t sctp_sf_violat
> {
>     char err_str[]="The cumulative tsn ack beyond the max tsn currently
> sent:";
> 
> -    return sctp_sf_abort_violation(asoc, arg, commands, err_str,
> +    return sctp_sf_abort_violation(ep, asoc, arg, commands, err_str,
>                     sizeof(err_str));
> }
> 
> 
> 

