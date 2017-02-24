From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net-next 2/2] sctp: add support for MSG_MORE
Date: Fri, 24 Feb 2017 14:43:58 +0800
Message-ID: <CADvbK_d9dyL0PFPrAyNqFT_URNdq75NPdQe8tqQkFO4aCg2DdA@mail.gmail.com>
References: <cover.1487440272.git.lucien.xin@gmail.com> <d6f2835b0bd655a563896e86648cbd9b4e01374e.1487440272.git.lucien.xin@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFE6C9B9@AcuExch.aculab.com>
 <CADvbK_dDgFc78dBCpTkNxM3kU-GAYbh6CCGTtO=r9ZeNyb2X0A@mail.gmail.com> <063D6719AE5E284EB5DD2968C1650D6DCFE6E5BB@AcuExch.aculab.com>
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
Received: from mail-qk0-f169.google.com ([209.85.220.169]:32978 "EHLO
        mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751005AbdBXHQB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 02:16:01 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFE6E5BB@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 24, 2017 at 12:04 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Xin Long
>> Sent: 23 February 2017 03:46
>> On Tue, Feb 21, 2017 at 10:27 PM, David Laight <David.Laight@aculab.com> wrote:
>> > From: Xin Long
>> >> Sent: 18 February 2017 17:53
>> >> This patch is to add support for MSG_MORE on sctp.
>> >>
>> >> It adds force_delay in sctp_datamsg to save MSG_MORE, and sets it after
>> >> creating datamsg according to the send flag. sctp_packet_can_append_data
>> >> then uses it to decide if the chunks of this msg will be sent at once or
>> >> delay it.
>> >>
>> >> Note that unlike [1], this patch saves MSG_MORE in datamsg, instead of
>> >> in assoc. As sctp enqueues the chunks first, then dequeue them one by
>> >> one. If it's saved in assoc,the current msg's send flag (MSG_MORE) may
>> >> affect other chunks' bundling.
>> >
>> > I thought about that and decided that the MSG_MORE flag on the last data
>> > chunk was the only one that mattered.
>> > Indeed looking at any others is broken.
>> >
>> > Consider what happens if you have two small chunks queued, the first
>> > with MSG_MORE set, the second with it clear.
>> >
>> > I think that sctp_outq_flush() will look at the first chunk and decide it
>> > doesn't need to do anything because sctp_packet_transmit_chunk()
>> > returns SCTP_XMIT_DELAY.
>> > The data chunk with MSG_MORE clear won't even be looked at.
>> > So the data will never be sent.
>
>> It's not that bad as you thought, in sctp_packet_can_append_data():
>> when inflight == 0 || sctp_sk(asoc->base.sk)->nodelay, the chunks
>> would be still sent out.
>
> One of us isn't understanding the other :-)
>
> IIRC sctp_packet_can_append_data() is called for the first queued
> data chunk in order to decide whether to generate a message that
> consists only of data chunks.
> If it returns SCTP_XMIT_OK then a message is built collecting the
> rest of the queued data chunks (until the window fills).
>
> So if I send a message with MSG_MORE set (on an idle connection)
> SCTP_XMIT_DELAY is returned and a message isn't sent.
>
> I now send a second small message, this time with MSG_MORE clear.
> The message is queued, then the code looks to see if it can send anything.
>
> sctp_packet_can_append_data() is called for the first queued chunk.
> Since it has force_delay set SCTP_XMIT_DELAY is returned and no
> message is built.
> The second message isn't even looked at.
You're right. I can see the problem now.

What I expected is it should work like:

1, send 3 small chunks with MSG_MORE set, the queue is:
  chk3 [set] -> chk2 [set] -> chk1 [set]
2. send 1 more chunk with MSG_MORE clear, the queue is:
  chk4[clear] -> chk3 [clear] -> chk2 [clear] -> chk1 [clear]
3. then if user send more small chunks with MSG_MORE set,
the queue is like:
  chkB[set] -> chkA[set] -> chk4[clear] -> chk3 [clear] -> chk2
[clear] -> chk1 [clear]
so that the new small chunks' flag will not affect the other chunks bundling.

is it ok to you to work like that ?
if yes, I propose the fix for this issue is:

@@ -303,6 +303,17 @@ void sctp_outq_tail(struct sctp_outq *q, struct
sctp_chunk *chunk, gfp_t gfp)
                         sctp_cname(SCTP_ST_CHUNK(chunk->chunk_hdr->type)) :
                         "illegal chunk");

+               if (q->has_delay && !chunk->msg->force_delay) {
+                       struct sctp_chunk *chk;
+
+                       list_for_each_entry(chk, &q->out_chunk_list, list) {
+                               if (!chk->msg->force_delay)
+                                       break;
+                               chk->msg->force_delay = 0;
+                       }
+               }
+               q->has_delay = chunk->msg->force_delay;
+

Thanks.

>
>> What MSG_MORE flag actually does is ignore inflight == 0 and
>> sctp_sk(asoc->base.sk)->nodelay to delay the chunks, but still
>> it has to respect the original logic (like !chunk->msg->can_delay
>> || !sctp_packet_empty(packet) || ...)
>>
>> To delay the chunks with MSG_MORE set even when inflight is 0
>> it especially important here for users.
>
> I'm not too worried about that.
> Sending the first message was a cheap way to ensure something got
> sent if the application lied and didn't send a subsequent message.
>
> The change has hit Linus's tree, I'll should be able to test that
> and confirm what I think is going on.
>
>         David
>
