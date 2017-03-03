From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] sctp: change to save MSG_MORE flag into assoc
Date: Fri, 3 Mar 2017 23:42:49 +0800
Message-ID: <CADvbK_cBjR_LXZd1t-7jjkDkfhChJCbDCwPhMqvwJ+vp2UfJOw@mail.gmail.com>
References: <ba64767f352e56cfe694af89445fe155cd431cd0.1488522235.git.lucien.xin@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFE74179@AcuExch.aculab.com>
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
Received: from mail-qk0-f181.google.com ([209.85.220.181]:34743 "EHLO
        mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751917AbdCCPvK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 10:51:10 -0500
Received: by mail-qk0-f181.google.com with SMTP id s186so181459452qkb.1
        for <netdev@vger.kernel.org>; Fri, 03 Mar 2017 07:50:21 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFE74179@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 3, 2017 at 8:49 PM, David Laight <David.Laight@aculab.com> wrote:
> From: Xin Long
>> Sent: 03 March 2017 06:24
>> David Laight noticed the support for MSG_MORE with datamsg->force_day
>> didn't really work as we expected, as the first msg with MSG_MORE set
>> would always block the following chunks' dequeuing.
>>
>> This Patch is to rewrite it by saving the MSG_MORE flag into assoc as
>> Divid Laight suggested.
>    ^ typo
ah, sorry. :P
>
>> asoc->force_delay is used to save MSG_MORE flag before a msg is sent.
>> Once this msg is queued, asoc->force_delay is set back to 0, so that
>> it will not affect other places flushing out queue.
>
> That doesn't seem right nor make sense.
>
>> asoc->force_delay works as a 'local param' here as the msg sending is
>> under protection of sock lock.  It would make sctp's MSG_MORE work as
>> tcp's.
>
> It is much more important to get MSG_MORE working 'properly' for SCTP
> than for TCP. For TCP an application can always use a long send.
"long send" ?, you mean bigger data, or keeping sending?
I didn't get the difference between SCTP and TCP, they
are similar when sending data.

>
> ...
>> @@ -1982,6 +1982,7 @@ static int sctp_sendmsg(struct sock *sk, struct msghdr *msg, size_t msg_len)
>>        * breaks.
>>        */
>>       err = sctp_primitive_SEND(net, asoc, datamsg);
>> +     asoc->force_delay = 0;
>>       /* Did the lower layer accept the chunk? */
>>       if (err) {
>>               sctp_datamsg_free(datamsg);
>
> I don't think this is right - or needed.
> You only get to the above if some test has decided to send data chunks.
> So it just means that the NEXT time someone tries to send data all the
> queued data gets sent.
the NEXT time someone tries to send data with "MSG_MORE clear",
yes, but with "MSG_MORE set", it will still delay.

> I'm guessing that the whole thing gets called in a loop (definitely needed
> for very long data chunks, or after the window is opened).
yes, if users keep sending data chunks with MSG_MORE set, no
data with "MSG_MORE clear" gap.

> Now if an application sends a lot of (say) 100 byte chunks with MSG_MORE
> set it would expect to see a lot of full ethernet frames be sent.
right.
> With the above a frame will be sent (containing all but 1 chunk) when the
> amount of queued data becomes too large for an ethernet frame, and immediately
> followed by a second ethernet frame with 1 chunk in it.
"followed by a second ethernet frame with 1 chunk in it.", I think this's
what you're really worried about, right ?
But sctp flush data queue NOT like what you think, it's not keep traversing
the queue untill the queue is empty.
once a packet with chunks in one ethernet frame is sent, sctp_outq_flush
will return. it will pack chunks and send the next packet again untill some
other 'event' triggers it, like retransmission or data received from peer.
I don't think this is a problem.

>
> Now it might be that the flag needs clearing when retransmissions are queued.
> OTOH they might get sent for other reasons.
Before we really overthought about MSG_MORE, no need to care about
retransmissions, define MSG_MORE, in my opinion, it works more for
*inflight is 0*, if it's not 0, we shouldn't stop other places flushing them.

We cannot let asoc's more_more flag work as global, it will block elsewhere
sending data chunks, not only sctp_sendmsg.

Thanks

>
>         David
>
>
