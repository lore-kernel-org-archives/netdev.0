From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] sctp: remove temporary variable confirm from sctp_packet_transmit
Date: Sun, 19 Mar 2017 00:26:50 +0800
Message-ID: <CADvbK_fnC3VHL6QM=Xj+kxW9jRuB8e7ZFbb3CTVApu+mRU+vhA@mail.gmail.com>
References: <a1bef2ad80e5a7338fc5c6786ea61835014b8c61.1489835542.git.lucien.xin@gmail.com>
 <alpine.LFD.2.20.1703181323280.7390@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:33687 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751087AbdCRQ0w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Mar 2017 12:26:52 -0400
In-Reply-To: <alpine.LFD.2.20.1703181323280.7390@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 18, 2017 at 7:48 PM, Julian Anastasov <ja@ssi.bg> wrote:
>
>         Hello,
>
> On Sat, 18 Mar 2017, Xin Long wrote:
>
>> Commit c86a773c7802 ("sctp: add dst_pending_confirm flag") introduced
>> a temporary variable "confirm" in sctp_packet_transmit.
>>
>> But it broke the rule that longer lines should be above shorter ones.
>> Besides, this variable is not necessary, so this patch is to just
>> remove it and use tp->dst_pending_confirm directly.
>>
>> Fixes: c86a773c7802 ("sctp: add dst_pending_confirm flag")
>> Signed-off-by: Xin Long <lucien.xin@gmail.com>
>> ---
>>  net/sctp/output.c | 7 +++----
>>  1 file changed, 3 insertions(+), 4 deletions(-)
>>
>> diff --git a/net/sctp/output.c b/net/sctp/output.c
>> index 71ce6b9..1224421 100644
>> --- a/net/sctp/output.c
>> +++ b/net/sctp/output.c
>> @@ -546,7 +546,6 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
>>       struct sctp_association *asoc = tp->asoc;
>>       struct sctp_chunk *chunk, *tmp;
>>       int pkt_count, gso = 0;
>> -     int confirm;
>>       struct dst_entry *dst;
>>       struct sk_buff *head;
>>       struct sctphdr *sh;
>> @@ -625,13 +624,13 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
>>                       asoc->peer.last_sent_to = tp;
>>       }
>>       head->ignore_df = packet->ipfragok;
>> -     confirm = tp->dst_pending_confirm;
>> -     if (confirm)
>> +     if (tp->dst_pending_confirm)
>>               skb_set_dst_pending_confirm(head, 1);
>>       /* neighbour should be confirmed on successful transmission or
>>        * positive error
>>        */
>> -     if (tp->af_specific->sctp_xmit(head, tp) >= 0 && confirm)
>> +     if (tp->af_specific->sctp_xmit(head, tp) >= 0 &&
>> +         tp->dst_pending_confirm)
>>               tp->dst_pending_confirm = 0;
>>
>>  out:
>> --
>
>         I played safe here, I was not sure if currently
> or some day in the future the SCTP stack can allow another
> thread to set tp->dst_pending_confirm concurrently with the
> sending. My idea was only when skb was used to confirm
> neighbour only then to clear the indication. I guess, your
> patch is ok because we should be locking the socket
> everywhere.
Yeps, It's safe, as all the codes for dst_pending_confirm are
under the sock lock protection.

>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
