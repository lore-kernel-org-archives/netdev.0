From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net-next 2/2] sctp: add support for MSG_MORE
Date: Thu, 23 Feb 2017 11:45:56 +0800
Message-ID: <CADvbK_dDgFc78dBCpTkNxM3kU-GAYbh6CCGTtO=r9ZeNyb2X0A@mail.gmail.com>
References: <cover.1487440272.git.lucien.xin@gmail.com> <d6f2835b0bd655a563896e86648cbd9b4e01374e.1487440272.git.lucien.xin@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFE6C9B9@AcuExch.aculab.com>
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
Received: from mail-qt0-f175.google.com ([209.85.216.175]:35234 "EHLO
        mail-qt0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750828AbdBWDp5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 22:45:57 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFE6C9B9@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 21, 2017 at 10:27 PM, David Laight <David.Laight@aculab.com> wrote:
> From: Xin Long
>> Sent: 18 February 2017 17:53
>> This patch is to add support for MSG_MORE on sctp.
>>
>> It adds force_delay in sctp_datamsg to save MSG_MORE, and sets it after
>> creating datamsg according to the send flag. sctp_packet_can_append_data
>> then uses it to decide if the chunks of this msg will be sent at once or
>> delay it.
>>
>> Note that unlike [1], this patch saves MSG_MORE in datamsg, instead of
>> in assoc. As sctp enqueues the chunks first, then dequeue them one by
>> one. If it's saved in assoc,the current msg's send flag (MSG_MORE) may
>> affect other chunks' bundling.
>
> I thought about that and decided that the MSG_MORE flag on the last data
> chunk was the only one that mattered.
> Indeed looking at any others is broken.
>
> Consider what happens if you have two small chunks queued, the first
> with MSG_MORE set, the second with it clear.
>
> I think that sctp_outq_flush() will look at the first chunk and decide it
> doesn't need to do anything because sctp_packet_transmit_chunk()
> returns SCTP_XMIT_DELAY.
> The data chunk with MSG_MORE clear won't even be looked at.
> So the data will never be sent.
It's not that bad as you thought, in sctp_packet_can_append_data():
when inflight == 0 || sctp_sk(asoc->base.sk)->nodelay, the chunks
would be still sent out.

What MSG_MORE flag actually does is ignore inflight == 0 and
sctp_sk(asoc->base.sk)->nodelay to delay the chunks, but still
it has to respect the original logic (like !chunk->msg->can_delay
|| !sctp_packet_empty(packet) || ...)

To delay the chunks with MSG_MORE set even when inflight is 0
it especially important here for users.

>
> I wouldn't worry about having messages queued that have MSG_MORE clean
> when the final message has it set.
Yeah, It's an old optimization for bundling. MSG_MORE should NOT
break that.

> While it might be 'nice' to send the data (would have to be tx credit)
> waiting for the next data chunk shouldn't be a problem.
sorry, you mean it shouldn't send the data if it's waiting for the
next data whenever ?

>
> I'm not sure I even want to test the current patch!
>
>         David
>
