From: Lawrence Brakmo <brakmo@fb.com>
Subject: Re: [RFC PATCH net-next] tcp: add NV congestion control
Date: Tue, 7 Jul 2015 00:17:33 +0000
Message-ID: <D1C056D1.47B8%brakmo@fb.com>
References: <1435886484-1709996-1-git-send-email-brakmo@fb.com>
 <CALx6S35pRq_Z32R3xWTj4PpQJ4YkC-MzxzeYb8+vH=cfTibwcQ@mail.gmail.com>
 <CADVnQykDpuO991cv43=1=A4mBJJD5pbE6paF3okXnZzeTOUs9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>,
	"Yuchung Cheng" <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:50847 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754855AbbGGARk convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jul 2015 20:17:40 -0400
In-Reply-To: <CADVnQykDpuO991cv43=1=A4mBJJD5pbE6paF3okXnZzeTOUs9g@mail.gmail.com>
Content-Language: en-US
Content-ID: <19C65EFC552AFE4AA4BC3127A2400DA5@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 7/3/15, 1:30 PM, "Neal Cardwell" <ncardwell@google.com> wrote:

>> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
>> index 48c3696..05e0da5 100644
>> --- a/include/linux/tcp.h
>> +++ b/include/linux/tcp.h
>> @@ -254,6 +254,10 @@ struct tcp_sock {
>>         u32     lost_out;       /* Lost packets                 */
>>         u32     sacked_out;     /* SACK'd packets
>>*/
>>         u32     fackets_out;    /* FACK'd packets
>>*/
>> +       u32     ack_in_flight;  /* This field is populated when new =
acks
>> +                                * are received. It contains the num=
ber
>>of
>> +                                * bytes in flight when the last pac=
ket
>> +                                * acked was sent. Used by tcp-nv. *=
/
>
>AFAICT the tcp_sock struct does not really need to grow to hold the
>ack_in_flight field, because this field does not need to be remembered
>between ACKs. I would recommend putting it in a small struct ("struct
>ack_sample"?) that is allocated on the stack in tcp_ack() and passed
>into the pkts_acked() function for congestion control modules that
>want extra info beyond the number of packets ACKed and the RTT.
>
>In fact it might be cleaner to put the number of packets ACKed and the
>RTT in that struct as well, so in the future we don't have to modify
>all the congestion control modules' pkts_acked() function
>every time a new piece of info is provided by the core TCP stack.

It makes sense. I just wasn=B9t sure if it made sense to add one more
parameter
to pkts_acked() until I heard if there was interest to have it in the
kernel.
However, I like your idea of passing a structure since it would simplif=
y
future changes. I=B9ll get to it.
=20
>
>>  /* This is what the send packet queuing engine uses to pass
>>   * TCP per-packet control information to the transmission code.
>>   * We also store the host-order sequence numbers in here too.
>> - * This is 44 bytes if IPV6 is enabled.
>> + * This is 48 bytes if IPV6 is enabled.
>>   * If this grows please adjust skbuff.h:skbuff->cb[xxx] size
>>appropriately.
>>   */
>>  struct tcp_skb_cb {
>>         __u32           seq;            /* Starting sequence number
>>*/
>>         __u32           end_seq;        /* SEQ + FIN + SYN + datalen
>>*/
>> +       __u32           in_flight;      /* bytes in flight when this
>>packet
>> +                                        * was sent. */
>
>AFAICT this patch would not require an increase in the size of sk_buff
>cb[] if it were to take advantage of the fact that the tcp_skb_cb
>header.h4 and header.h6 fields are only used in the packet reception
>code path, and this in_flight field is only used on the transmit
>side. So the in_flight field could be placed in a struct that is
>itself placed in a union with the "header" union. Like this:
>
>        union {
>                struct {
>                        /* bytes in flight when this packet was sent *=
/
>                        __u32 in_flight;
>                } tx;   /* only used for outgoing skbs */
>
>                union {
>                        struct inet_skb_parm    h4;
>#if IS_ENABLED(CONFIG_IPV6)
>                        struct inet6_skb_parm   h6;
>#endif
>                } header;  /* only used for incoming skbs */
>        };
>
>That way the sender code can remember the in_flight value
>without requiring any extra space. And in the future other
>sender-side info could be stored in the "tx" struct, if needed.
>
>neal

Great idea, thanks Neal! I=B9ll look into it.
