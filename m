From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] sctp: change to save MSG_MORE flag into assoc
Date: Sat, 4 Mar 2017 12:51:43 +0800
Message-ID: <CADvbK_foNe38tNgaRJO5gUxH1cEZMm9M5zhdw3ujA5adJ_wSvw@mail.gmail.com>
References: <ba64767f352e56cfe694af89445fe155cd431cd0.1488522235.git.lucien.xin@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFE74179@AcuExch.aculab.com>
 <CADvbK_cBjR_LXZd1t-7jjkDkfhChJCbDCwPhMqvwJ+vp2UfJOw@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFE7443F@AcuExch.aculab.com> <CADvbK_eBvFkR65ACq1JLgsAnK3TFjD_kKg8KaBtzzgu86-KYWw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:35141 "EHLO
        mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750715AbdCDFAQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Mar 2017 00:00:16 -0500
Received: by mail-qk0-f179.google.com with SMTP id v125so27825392qkh.2
        for <netdev@vger.kernel.org>; Fri, 03 Mar 2017 21:00:15 -0800 (PST)
In-Reply-To: <CADvbK_eBvFkR65ACq1JLgsAnK3TFjD_kKg8KaBtzzgu86-KYWw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 4, 2017 at 1:57 AM, Xin Long <lucien.xin@gmail.com> wrote:
> On Sat, Mar 4, 2017 at 12:31 AM, David Laight <David.Laight@aculab.com> wrote:
>> From: Xin Long
>>> Sent: 03 March 2017 15:43
>> ...
>>> > It is much more important to get MSG_MORE working 'properly' for SCTP
>>> > than for TCP. For TCP an application can always use a long send.
>>
>>> "long send" ?, you mean bigger data, or keeping sending?
>>> I didn't get the difference between SCTP and TCP, they
>>> are similar when sending data.
>>
>> With tcp an application can always replace two send()/write()
>> calls with a single call to writev().
>> For sctp two send() calls must be made in order to generate two
>> data chunks.
>> So it is much easier for a tcp application to generate 'full'
>> ethernet packets.
> okay, it should not be a important reason, and sctp might also support
> it one day. :-)
>
>>
>>>
>>> >
>>> > ...
>>> >> @@ -1982,6 +1982,7 @@ static int sctp_sendmsg(struct sock *sk, struct msghdr *msg, size_t msg_len)
>>> >>        * breaks.
>>> >>        */
>>> >>       err = sctp_primitive_SEND(net, asoc, datamsg);
>>> >> +     asoc->force_delay = 0;
>>> >>       /* Did the lower layer accept the chunk? */
>>> >>       if (err) {
>>> >>               sctp_datamsg_free(datamsg);
>>> >
>>> > I don't think this is right - or needed.
>>> > You only get to the above if some test has decided to send data chunks.
>>> > So it just means that the NEXT time someone tries to send data all the
>>> > queued data gets sent.
>>
>>> the NEXT time someone tries to send data with "MSG_MORE clear",
>>> yes, but with "MSG_MORE set", it will still delay.
>>>
>>> > I'm guessing that the whole thing gets called in a loop (definitely needed
>>> > for very long data chunks, or after the window is opened).
>>
>>> yes, if users keep sending data chunks with MSG_MORE set, no
>>> data with "MSG_MORE clear" gap.
>>>
>>> > Now if an application sends a lot of (say) 100 byte chunks with MSG_MORE
>>> > set it would expect to see a lot of full ethernet frames be sent.
>>
>>> right.
>>
>>> > With the above a frame will be sent (containing all but 1 chunk) when the
>>> > amount of queued data becomes too large for an ethernet frame, and immediately
>>> > followed by a second ethernet frame with 1 chunk in it.
>>
>>> "followed by a second ethernet frame with 1 chunk in it.", I think this's
>>> what you're really worried about, right ?
>>> But sctp flush data queue NOT like what you think, it's not keep traversing
>>> the queue untill the queue is empty.
>>> once a packet with chunks in one ethernet frame is sent, sctp_outq_flush
>>> will return. it will pack chunks and send the next packet again untill some
>>> other 'event' triggers it, like retransmission or data received from peer.
>>> I don't think this is a problem.
>>
>> Erm.... that can't work.
>> I think there is code to convert a large user send into multiple data chunks.
>> So if the user does a 4k (say) send several large chunks get queued.
>> These would need to all be sent at once.
>>
>> Similarly when the transmit window is received.
>> So somewhere there ought to be a loop that will send more than one packet.
> As far as I can see, no loop like you said, mostly, the incoming
> chunk (like SACK) from peer will trigger the next flush out.
> I can try to trace the path in kernel for sure tomorrow.
okay, you are right, I missed sctp_packet_transmit_chunk also call
sctp_packet_transmit to send the current packet. :)

But if we keep sending data with "MSG_MORE", after one ethernet frame
is sent, "followed by a second ethernet frame with 1 chunk in it" will NOT
happen, as in this loop the asoc's msg_more flag is still set, and this flush
is called by sctp_sendmsg(the function msg_more should care more).

did I miss something ?

>
>>
>>> > Now it might be that the flag needs clearing when retransmissions are queued.
>>> > OTOH they might get sent for other reasons.
>>
>>> Before we really overthought about MSG_MORE, no need to care about
>>> retransmissions, define MSG_MORE, in my opinion, it works more for
>>> *inflight is 0*, if it's not 0, we shouldn't stop other places flushing them.
>>
>> Eh? and when nagle disabled.
>> If 'inflight' isn't 0 then most paths don't flush data.
> I knew, but MSG_MORE is different thing, it should only try to work for the
> current and following data.
>
>>
>>> We cannot let asoc's more_more flag work as global, it will block elsewhere
>>> sending data chunks, not only sctp_sendmsg.
>>
>> If the connection was flow controlled off, and more 'credit' arrives and there
>> is less that an ethernet frame's worth of data pending, and the last send
>> said 'MSG_MORE' there is no point sending anything until the application
>> does a send with MSG_MORE clear.
> got you, I think you have different understanding about MSG_MORE
> while this patch just try to make it work like TCP's msg_more, but what
> you mentioned here is the same as TCP thing, seems you also want
> to improve TCP's MSG_MORE :-)
>
>>
>> I'm not sure what causes a retransmission to send data, I suspect that 'inflight'
>> can easily be non-zero at that time.
> The thing that causes a retransmission to send data is that both tx and
> rtx send data through sctp_outq_flush, in which it will try to send rtx queue,
> then rx queue.
>
> yes, once a packet is sent out and not yet be SACKed, "inflight" will not be
> zero, so when retransmiting, "inflight" must be non-zero.
>
>> Likely something causes a packet be generated - which then collects the data chunks.
>>
>>         David
>>
>>
