From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net-next 2/2] sctp: add support for MSG_MORE
Date: Mon, 27 Feb 2017 12:49:03 +0800
Message-ID: <CADvbK_fS9bOzoRsY-TBKMUkJJZJ5NuouBcSt1=79kJVTAHc=UQ@mail.gmail.com>
References: <cover.1487440272.git.lucien.xin@gmail.com> <d6f2835b0bd655a563896e86648cbd9b4e01374e.1487440272.git.lucien.xin@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFE6C9B9@AcuExch.aculab.com>
 <CADvbK_dDgFc78dBCpTkNxM3kU-GAYbh6CCGTtO=r9ZeNyb2X0A@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFE6E5BB@AcuExch.aculab.com>
 <CADvbK_d9dyL0PFPrAyNqFT_URNdq75NPdQe8tqQkFO4aCg2DdA@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFE6EDE0@AcuExch.aculab.com> <CADvbK_eauYUyUWMAn8Zkpk5hNnK-GDNO+3NCeuA-y=Y7SFnv5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:33333 "EHLO
        mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751011AbdB0Gf7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 01:35:59 -0500
Received: by mail-qk0-f179.google.com with SMTP id n127so83193931qkf.0
        for <netdev@vger.kernel.org>; Sun, 26 Feb 2017 22:35:11 -0800 (PST)
In-Reply-To: <CADvbK_eauYUyUWMAn8Zkpk5hNnK-GDNO+3NCeuA-y=Y7SFnv5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 25, 2017 at 4:41 PM, Xin Long <lucien.xin@gmail.com> wrote:
> On Fri, Feb 24, 2017 at 6:14 PM, David Laight <David.Laight@aculab.com> wrote:
>>
>> From: Xin Long
>> > Sent: 24 February 2017 06:44
>> ...
>> > > IIRC sctp_packet_can_append_data() is called for the first queued
>> > > data chunk in order to decide whether to generate a message that
>> > > consists only of data chunks.
>> > > If it returns SCTP_XMIT_OK then a message is built collecting the
>> > > rest of the queued data chunks (until the window fills).
>> > >
>> > > So if I send a message with MSG_MORE set (on an idle connection)
>> > > SCTP_XMIT_DELAY is returned and a message isn't sent.
>> > >
>> > > I now send a second small message, this time with MSG_MORE clear.
>> > > The message is queued, then the code looks to see if it can send anything.
>> > >
>> > > sctp_packet_can_append_data() is called for the first queued chunk.
>> > > Since it has force_delay set SCTP_XMIT_DELAY is returned and no
>> > > message is built.
>> > > The second message isn't even looked at.
>> > You're right. I can see the problem now.
>> >
>> > What I expected is it should work like:
>> >
>> > 1, send 3 small chunks with MSG_MORE set, the queue is:
>> >   chk3 [set] -> chk2 [set] -> chk1 [set]
>>
>> Strange way to write a queue! chk1 points to chk2 :-)
> haha, just  a model.
>
>>
>> > 2. send 1 more chunk with MSG_MORE clear, the queue is:
>> >   chk4[clear] -> chk3 [clear] -> chk2 [clear] -> chk1 [clear]
>>
>> I don't think processing the entire queue is a good idea.
>> Both from execution time and the effects on the data cache.
>> The SCTP code is horrid enough as it is.
> you check the codes in last email, it's not processing the entire queue.
>
> 1). only when queue has delay chunk inside by checking queue->has_delay
>     and current chunk has msg_more flag.
>
> 2). will break on the first chunk with clear in the queue.
>
> but yes, in 2), extra work has to be done than before, but not much.
>
>>
>> > 3. then if user send more small chunks with MSG_MORE set,
>> > the queue is like:
>> >   chkB[set] -> chkA[set] -> chk4[clear] -> chk3 [clear] -> chk2 [clear] -> chk1 [clear]
>> > so that the new small chunks' flag will not affect the other chunks bundling.
>>
>> That isn't really necessary.
>> The user can't expect to have absolute control over which chunks get bundled
>> together.
>> If the above chunks still aren't big enough to fill a frame the code might
>> as well wait for the next chunk instead of building a packet that contains
>> chk1 through to chkB.
>>
>> Remember you'll only get a queued chunk with MSG_MORE clear if data can't be sent.
>> As soon as data can be sent, if the first chunk has MSG_MORE clear all of the
>> queued chunks will be sent.
>>
>> So immediately after your (3) the application is expected to send a chunk
>> with MSG_MORE clear - at that point all the queued chunks can be sent in
>> a single packet.
> understand this.
>
> what I'm worried about is if the msg_more is saved in assoc:
>      chk4[clear] -> chk3 [clear] -> chk2 [clear] -> chk1 [clear]
> then when you send a small chkA with MSG_MORE,
> the queue will be like:
>      chkA [set] -> chk4[set] -> chk3 [set] -> chk2 [set] -> chk1 [set]
> because msg_more is saved in assoc, every chunk can look at it.
> chk1 - chk4 are big enough to be packed into a packet, they were
> not sent last time because a lot of chunks are in the retransmit
> queue.
>
> But now even if retransmit queue is null, chk1-chk4 are still blocked.
>
> can you accept that chkA may block the old chunks ?
even also block the retransmit chunks.

>
>>
>> So just save the last MSG_MORE on the association as I did.
> I will think about it, thanks.
>
>>
>>         David
