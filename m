From: Chang <changxiangzhong@gmail.com>
Subject: Re: [PATCH] For for each TSN t being newly acked (Not only cumulatively,
 but also SELECTIVELY) cacc_saw_newack should be set to 1.
Date: Tue, 15 Oct 2013 19:39:35 +0200
Message-ID: <525D7DD7.4070708@gmail.com>
References: <1381856348-15503-1-git-send-email-changxiangzhong@gmail.com> <525D7A72.70200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, davem@davemloft.net,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <525D7A72.70200@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 10/15/2013 07:25 PM, Vlad Yasevich wrote:
> On 10/15/2013 12:59 PM, Chang Xiangzhong wrote:
>> Signed-off-by: Xiangzhong Chang <changxiangzhong@gmail.com>
>> ---
>>   net/sctp/outqueue.c |  142 
>> ++++++++++++++++++++++++---------------------------
>>   1 file changed, 68 insertions(+), 74 deletions(-)
>>
>> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
>> index 94df758..f10d848 100644
>> --- a/net/sctp/outqueue.c
>> +++ b/net/sctp/outqueue.c
>> @@ -1357,84 +1357,78 @@ static void sctp_check_transmitted(struct 
>> sctp_outq *q,
>>
>>           tsn = ntohl(tchunk->subh.data_hdr->tsn);
>>           if (sctp_acked(sack, tsn)) {
>> -            /* If this queue is the retransmit queue, the
>> -             * retransmit timer has already reclaimed
>> -             * the outstanding bytes for this chunk, so only
>> -             * count bytes associated with a transport.
>> -             */
>> -            if (transport) {
>> -                /* If this chunk is being used for RTT
>> -                 * measurement, calculate the RTT and update
>> -                 * the RTO using this value.
>> -                 *
>> -                 * 6.3.1 C5) Karn's algorithm: RTT measurements
>> -                 * MUST NOT be made using packets that were
>> -                 * retransmitted (and thus for which it is
>> -                 * ambiguous whether the reply was for the
>> -                 * first instance of the packet or a later
>> -                 * instance).
>> -                 */
>> -                if (!tchunk->tsn_gap_acked &&
>> -                    tchunk->rtt_in_progress) {
>> -                    tchunk->rtt_in_progress = 0;
>> -                    rtt = jiffies - tchunk->sent_at;
>> -                    sctp_transport_update_rto(transport,
>> -                                  rtt);
>> -                }
>> -            }
>> -
>> -            /* If the chunk hasn't been marked as ACKED,
>> -             * mark it and account bytes_acked if the
>> -             * chunk had a valid transport (it will not
>> -             * have a transport if ASCONF had deleted it
>> -             * while DATA was outstanding).
>> -             */
>>               if (!tchunk->tsn_gap_acked) {
>> -                tchunk->tsn_gap_acked = 1;
>> -                *highest_new_tsn_in_sack = tsn;
>> -                bytes_acked += sctp_data_size(tchunk);
>> -                if (!tchunk->transport)
>> -                    migrate_bytes += sctp_data_size(tchunk);
>> -                forward_progress = true;
>> +                /* If this queue is the retransmit queue, the
>> +                 * retransmit timer has already reclaimed
>> +                 * the outstanding bytes for this chunk, so only
>> +                 * count bytes associated with a transport.
>> +                 *
>> +                 * If this chunk is being used for RTT
>> +                 * measurement, calculate the RTT and update
>> +                 * the RTO using this value.
>> +                 *
>> +                 * 6.3.1 C5) Karn's algorithm: RTT measurements
>> +                 * MUST NOT be made using packets that were
>> +                 * retransmitted (and thus for which it is
>> +                 * ambiguous whether the reply was for the
>> +                 * first instance of the packet or a later
>> +                 * instance).
>> +                 */
>> +                if (transport && tchunk->rtt_in_progress) {
>> +                tchunk->rtt_in_progress = 0;
>> +                rtt = jiffies - tchunk->sent_at;
>> +                sctp_transport_update_rto(transport,
>> +                    rtt);
>> +                }
>> +
>> +                /* If the chunk hasn't been marked as ACKED,
>> +                 * mark it and account bytes_acked if the
>> +                 * chunk had a valid transport (it will not
>> +                 * have a transport if ASCONF had deleted it
>> +                 * while DATA was outstanding).
>> +                 */
>> +                tchunk->tsn_gap_acked = 1;
>> +                *highest_new_tsn_in_sack = tsn;
>> +                bytes_acked += sctp_data_size(tchunk);
>> +                if (!tchunk->transport)
>> +                migrate_bytes += sctp_data_size(tchunk);
>> +                forward_progress = true;
>> +
>> +                /*
>> +                 * SFR-CACC algorithm:
>> +                 * 2) If the SACK contains gap acks
>> +                 * and the flag CHANGEOVER_ACTIVE is
>> +                 * set the receiver of the SACK MUST
>> +                 * take the following action:
>> +                 *
>> +                 * B) For each TSN t being acked that
>> +                 * has not been acked in any SACK so
>> +                 * far, set cacc_saw_newack to 1 for
>> +                 * the destination that the TSN was
>> +                 * sent to.
>> +                 */
>> +                if (transport &&
>> +                    sack->num_gap_ack_blocks &&
>> +                    q->asoc->peer.primary_path->cacc.
>> +                    changeover_active)
>> +                transport->cacc.cacc_saw_newack = 1;
>>               }
>
> Indents should be tab based.
> This is a bit more of a re-write that is needed for the this 
> particualar patch.  What's wrong with just doing this?
>
I'm pretty new of kernel dev. So I've make a new patch. What's the 
correct way of doing this? just attach the new patch to this email?
-Chang

> @@ -1396,6 +1396,25 @@ static void sctp_check_transmitted(struct 
> sctp_outq *q,
>                                 if (!tchunk->transport)
>                                         migrate_bytes += 
> sctp_data_size(tchunk);
>                                 forward_progress = true;
> +
> +                               /*
> +                                * SFR-CACC algorithm:
> +                                * 2) If the SACK contains gap acks
> +                                * and the flag CHANGEOVER_ACTIVE is
> +                                * set the receiver of the SACK MUST
> +                                * take the following action:
> +                                *
> +                                * B) For each TSN t being acked that
> +                                * has not been acked in any SACK so
> +                                * far, set cacc_saw_newack to 1 for
> +                                * the destination that the TSN was
> +                                * sent to.
> +                                */
> +                               if (transport &&
> +                                   sack->num_gap_ack_blocks &&
> + q->asoc->peer.primary_path->cacc.
> +                                   changeover_active)
> + transport->cacc.cacc_saw_newack = 1;
>                         }
>
>
>                         if (TSN_lte(tsn, sack_ctsn)) {
>
> -vlad
>
>>
>>               if (TSN_lte(tsn, sack_ctsn)) {
>> -                /* RFC 2960  6.3.2 Retransmission Timer Rules
>> -                 *
>> -                 * R3) Whenever a SACK is received
>> -                 * that acknowledges the DATA chunk
>> -                 * with the earliest outstanding TSN
>> -                 * for that address, restart T3-rtx
>> -                 * timer for that address with its
>> -                 * current RTO.
>> -                 */
>> -                restart_timer = 1;
>> -                forward_progress = true;
>> -
>> -                if (!tchunk->tsn_gap_acked) {
>> -                    /*
>> -                     * SFR-CACC algorithm:
>> -                     * 2) If the SACK contains gap acks
>> -                     * and the flag CHANGEOVER_ACTIVE is
>> -                     * set the receiver of the SACK MUST
>> -                     * take the following action:
>> -                     *
>> -                     * B) For each TSN t being acked that
>> -                     * has not been acked in any SACK so
>> -                     * far, set cacc_saw_newack to 1 for
>> -                     * the destination that the TSN was
>> -                     * sent to.
>> -                     */
>> -                    if (transport &&
>> -                        sack->num_gap_ack_blocks &&
>> - q->asoc->peer.primary_path->cacc.
>> -                        changeover_active)
>> -                        transport->cacc.cacc_saw_newack
>> -                            = 1;
>> -                }
>> -
>> -                list_add_tail(&tchunk->transmitted_list,
>> -                          &q->sacked);
>> +                /* RFC 2960  6.3.2 Retransmission Timer Rules
>> +                 *
>> +                 * R3) Whenever a SACK is received
>> +                 * that acknowledges the DATA chunk
>> +                 * with the earliest outstanding TSN
>> +                 * for that address, restart T3-rtx
>> +                 * timer for that address with its
>> +                 * current RTO.
>> +                 */
>> +                restart_timer = 1;
>> +                forward_progress = true;
>> +
>> +                list_add_tail(&tchunk->transmitted_list,
>> +                    &q->sacked);
>>               } else {
>>                   /* RFC2960 7.2.4, sctpimpguide-05 2.8.2
>>                    * M2) Each time a SACK arrives reporting
>>
>
