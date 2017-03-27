From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCHv2 net-next 2/7] sctp: implement receiver-side procedures
 for the SSN/TSN Reset Request Parameter
Date: Mon, 27 Mar 2017 12:48:31 +0800
Message-ID: <CADvbK_c5HsfBfA6GPaiHd1GRGRK5GnMY-3GCCGoZJMmHJsVYXg@mail.gmail.com>
References: <cover.1489118815.git.lucien.xin@gmail.com> <f224235b4621ea3a182e959873f6fe0ba78e5416.1489118815.git.lucien.xin@gmail.com>
 <20170320180457.GD23553@localhost.localdomain> <CADvbK_cqZDTDg8xOAwSqdq+L8G85uDyeSoeqfP6PBAbzhZUOhA@mail.gmail.com>
 <20170324235105.GI23553@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        davem <davem@davemloft.net>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:36003 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751794AbdC0Ese (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 00:48:34 -0400
In-Reply-To: <20170324235105.GI23553@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 25, 2017 at 7:52 AM, Marcelo Ricardo Leitner
<marcelo.leitner@gmail.com> wrote:
> On Tue, Mar 21, 2017 at 01:44:32PM +0800, Xin Long wrote:
>> On Tue, Mar 21, 2017 at 2:04 AM, Marcelo Ricardo Leitner
>> <marcelo.leitner@gmail.com> wrote:
>> > On Fri, Mar 10, 2017 at 12:11:07PM +0800, Xin Long wrote:
>> >> This patch is to implement Receiver-Side Procedures for the SSN/TSN
>> >> Reset Request Parameter described in rfc6525 section 6.2.4.
>> >>
>> >> The process is kind of complicate, it's wonth having some comments
>> >> from section 6.2.4 in the codes.
>> >>
>> >> Signed-off-by: Xin Long <lucien.xin@gmail.com>
>> >> ---
>> >>  include/net/sctp/sm.h   |  4 +++
>> >>  net/sctp/sm_statefuns.c |  3 ++
>> >>  net/sctp/stream.c       | 79 +++++++++++++++++++++++++++++++++++++++++++++++++
>> >>  3 files changed, 86 insertions(+)
>> >>
>> >> diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
>> >> index b6f682e..2629d66 100644
>> >> --- a/include/net/sctp/sm.h
>> >> +++ b/include/net/sctp/sm.h
>> >> @@ -293,6 +293,10 @@ struct sctp_chunk *sctp_process_strreset_inreq(
>> >>                               struct sctp_association *asoc,
>> >>                               union sctp_params param,
>> >>                               struct sctp_ulpevent **evp);
>> >> +struct sctp_chunk *sctp_process_strreset_tsnreq(
>> >> +                             struct sctp_association *asoc,
>> >> +                             union sctp_params param,
>> >> +                             struct sctp_ulpevent **evp);
>> >>
>> >>  /* Prototypes for statetable processing. */
>> >>
>> >> diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
>> >> index e03bb1a..6982064 100644
>> >> --- a/net/sctp/sm_statefuns.c
>> >> +++ b/net/sctp/sm_statefuns.c
>> >> @@ -3872,6 +3872,9 @@ sctp_disposition_t sctp_sf_do_reconf(struct net *net,
>> >>               else if (param.p->type == SCTP_PARAM_RESET_IN_REQUEST)
>> >>                       reply = sctp_process_strreset_inreq(
>> >>                               (struct sctp_association *)asoc, param, &ev);
>> >> +             else if (param.p->type == SCTP_PARAM_RESET_TSN_REQUEST)
>> >> +                     reply = sctp_process_strreset_tsnreq(
>> >> +                             (struct sctp_association *)asoc, param, &ev);
>> >>               /* More handles for other types will be added here, by now it
>> >>                * just ignores other types.
>> >>                */
>> >> diff --git a/net/sctp/stream.c b/net/sctp/stream.c
>> >> index 1c6cc04..7e993b0 100644
>> >> --- a/net/sctp/stream.c
>> >> +++ b/net/sctp/stream.c
>> >> @@ -477,3 +477,82 @@ struct sctp_chunk *sctp_process_strreset_inreq(
>> >>
>> >>       return chunk;
>> >>  }
>> >> +
>> >> +struct sctp_chunk *sctp_process_strreset_tsnreq(
>> >> +                             struct sctp_association *asoc,
>> >> +                             union sctp_params param,
>> >> +                             struct sctp_ulpevent **evp)
>> >> +{
>> >> +     __u32 init_tsn = 0, next_tsn = 0, max_tsn_seen;
>> >> +     struct sctp_strreset_tsnreq *tsnreq = param.v;
>> >> +     struct sctp_stream *stream = asoc->stream;
>> >> +     __u32 result = SCTP_STRRESET_DENIED;
>> >> +     __u32 request_seq;
>> >> +     __u16 i;
>> >> +
>> >> +     request_seq = ntohl(tsnreq->request_seq);
>> >> +     if (request_seq > asoc->strreset_inseq) {
>> >> +             result = SCTP_STRRESET_ERR_BAD_SEQNO;
>> >> +             goto out;
>> >> +     } else if (request_seq == asoc->strreset_inseq) {
>> >> +             asoc->strreset_inseq++;
>> >> +     }
>> >
>> > I guess I already asked this, but.. why request_seq <
>> > asoc->strreset_inseq is allowed?
>> we can not just ignore or response with ERR.
>> rfc6525#section-5.2.1:
>>
>>    ... If the received RE-CONFIG chunk contains at least
>>    one request and based on the analysis of the Re-configuration Request
>>    Sequence Numbers this is the last received RE-CONFIG chunk (i.e., a
>                                   ^^^^^^^^^^^^^
>>    retransmission), the same RE-CONFIG chunk MUST to be sent back in
>>    response, as it was earlier.
>
> That means we should only re-process that *last* reconf request, and not
> just any old one. My understanding is that we need something like:
> +     } else if (request_seq < asoc->strreset_inseq-1) {
> +             result = SCTP_STRRESET_ERR_BAD_SEQNO;
> +             goto out;
> +     }
>
> And then this makes it evident that we have to handle request_seq as
> serial numbers (like TSNs are handled).
Got you.

Here is actually also a replay attack. If a duplicate request happens:

In  sender side, If the request is not yet acked, it will just process the
response as usual. If It's acked already, It will drop the duplicate
response as no matched asoc->strreset_chunk any more. It's safe.

But in receiver side. It will process stream/asoc again when receiving
a duplicate request. If receiver side has processed some data chunks
and tsn/ssn have been increased before this.  we shouldn't process
this request, but only send back a response with the original result.
The problem is that we didn't save the result of last request.


>
>
>>
>>
>> >
>> >> +
>> >> +     if (!(asoc->strreset_enable & SCTP_ENABLE_RESET_ASSOC_REQ))
>> >> +             goto out;
>> >> +
>> >> +     if (asoc->strreset_outstanding) {
>> >> +             result = SCTP_STRRESET_ERR_IN_PROGRESS;
>> >> +             goto out;
>> >> +     }
>> >> +
>> >> +     /* G3: The same processing as though a SACK chunk with no gap report
>> >> +      *     and a cumulative TSN ACK of the Sender's Next TSN minus 1 were
>> >> +      *     received MUST be performed.
>> >> +      */
>> >> +     max_tsn_seen = sctp_tsnmap_get_max_tsn_seen(&asoc->peer.tsn_map);
>> >> +     sctp_ulpq_reasm_flushtsn(&asoc->ulpq, max_tsn_seen);
>> >> +     sctp_ulpq_abort_pd(&asoc->ulpq, GFP_ATOMIC);
>> >> +
>> >> +     /* G1: Compute an appropriate value for the Receiver's Next TSN -- the
>> >> +      *     TSN that the peer should use to send the next DATA chunk.  The
>> >> +      *     value SHOULD be the smallest TSN not acknowledged by the
>> >> +      *     receiver of the request plus 2^31.
>> >> +      */
>> >> +     init_tsn = sctp_tsnmap_get_ctsn(&asoc->peer.tsn_map) + (1 << 31);
>> >> +     sctp_tsnmap_init(&asoc->peer.tsn_map, SCTP_TSN_MAP_INITIAL,
>> >> +                      init_tsn, GFP_ATOMIC);
>> >> +
>> >> +     /* G4: The same processing as though a FWD-TSN chunk (as defined in
>> >> +      *     [RFC3758]) with all streams affected and a new cumulative TSN
>> >> +      *     ACK of the Receiver's Next TSN minus 1 were received MUST be
>> >> +      *     performed.
>> >> +      */
>> >> +     sctp_outq_free(&asoc->outqueue);
>> >> +
>> >> +     /* G2: Compute an appropriate value for the local endpoint's next TSN,
>> >> +      *     i.e., the next TSN assigned by the receiver of the SSN/TSN reset
>> >> +      *     chunk.  The value SHOULD be the highest TSN sent by the receiver
>> >> +      *     of the request plus 1.
>> >> +      */
>> >> +     next_tsn = asoc->next_tsn;
>> >> +     asoc->ctsn_ack_point = next_tsn - 1;
>> >> +     asoc->adv_peer_ack_point = asoc->ctsn_ack_point;
>> >> +
>> >> +     /* G5:  The next expected and outgoing SSNs MUST be reset to 0 for all
>> >> +      *      incoming and outgoing streams.
>> >> +      */
>> >> +     for (i = 0; i < stream->outcnt; i++)
>> >> +             stream->out[i].ssn = 0;
>> >> +     for (i = 0; i < stream->incnt; i++)
>> >> +             stream->in[i].ssn = 0;
>> >> +
>> >> +     result = SCTP_STRRESET_PERFORMED;
>> >> +
>> >> +     *evp = sctp_ulpevent_make_assoc_reset_event(asoc, 0, init_tsn,
>> >> +                                                 next_tsn, GFP_ATOMIC);
>> >> +
>> >> +out:
>> >> +     return sctp_make_strreset_tsnresp(asoc, result, request_seq,
>> >> +                                       next_tsn, init_tsn);
>> >> +}
>> >> --
>> >> 2.1.0
>> >>
>> >> --
>> >> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
>> >> the body of a message to majordomo@vger.kernel.org
>> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> >>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
