From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net-next 2/2] sctp: add support for MSG_MORE
Date: Thu, 23 Feb 2017 14:40:21 -0300
Message-ID: <20170223174021.GO3414@localhost.localdomain>
References: <cover.1487440272.git.lucien.xin@gmail.com>
 <d6f2835b0bd655a563896e86648cbd9b4e01374e.1487440272.git.lucien.xin@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFE6C9B9@AcuExch.aculab.com>
 <CADvbK_dDgFc78dBCpTkNxM3kU-GAYbh6CCGTtO=r9ZeNyb2X0A@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFE6E5BB@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Xin Long'" <lucien.xin@gmail.com>,
        network dev <netdev@vger.kernel.org>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51914 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751275AbdBWRmp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Feb 2017 12:42:45 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFE6E5BB@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 23, 2017 at 04:04:10PM +0000, David Laight wrote:
> From: Xin Long
> > Sent: 23 February 2017 03:46
> > On Tue, Feb 21, 2017 at 10:27 PM, David Laight <David.Laight@aculab.com> wrote:
> > > From: Xin Long
> > >> Sent: 18 February 2017 17:53
> > >> This patch is to add support for MSG_MORE on sctp.
> > >>
> > >> It adds force_delay in sctp_datamsg to save MSG_MORE, and sets it after
> > >> creating datamsg according to the send flag. sctp_packet_can_append_data
> > >> then uses it to decide if the chunks of this msg will be sent at once or
> > >> delay it.
> > >>
> > >> Note that unlike [1], this patch saves MSG_MORE in datamsg, instead of
> > >> in assoc. As sctp enqueues the chunks first, then dequeue them one by
> > >> one. If it's saved in assoc,the current msg's send flag (MSG_MORE) may
> > >> affect other chunks' bundling.
> > >
> > > I thought about that and decided that the MSG_MORE flag on the last data
> > > chunk was the only one that mattered.
> > > Indeed looking at any others is broken.
> > >
> > > Consider what happens if you have two small chunks queued, the first
> > > with MSG_MORE set, the second with it clear.
> > >
> > > I think that sctp_outq_flush() will look at the first chunk and decide it
> > > doesn't need to do anything because sctp_packet_transmit_chunk()
> > > returns SCTP_XMIT_DELAY.
> > > The data chunk with MSG_MORE clear won't even be looked at.
> > > So the data will never be sent.
> 
> > It's not that bad as you thought, in sctp_packet_can_append_data():
> > when inflight == 0 || sctp_sk(asoc->base.sk)->nodelay, the chunks
> > would be still sent out.
> 
> One of us isn't understanding the other :-)
> 
> IIRC sctp_packet_can_append_data() is called for the first queued
> data chunk in order to decide whether to generate a message that

Perhaps here lies the source of the confusion?
sctp_packet_can_append_data() is called for all queued data chunks, and
not just the first one.

sctp_outq_flush
  (retransmissions here, omitted for simplicity)
  /* Finally, transmit new packets.  */
  while ((chunk = sctp_outq_dequeue_data(q)) != NULL) {
    sctp_packet_transmit_chunk
      sctp_packet_append_chunk
        sctp_packet_can_append_data
        __sctp_packet_append_chunk

So chunks are checked one by one.

> consists only of data chunks.

That's not really its purpose. It's to check if it can append a data
chunk to the packet being prepared, while respecting asoc state, cwnd,
etc.

HTH!

  Marcelo

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
> 
> > What MSG_MORE flag actually does is ignore inflight == 0 and
> > sctp_sk(asoc->base.sk)->nodelay to delay the chunks, but still
> > it has to respect the original logic (like !chunk->msg->can_delay
> > || !sctp_packet_empty(packet) || ...)
> > 
> > To delay the chunks with MSG_MORE set even when inflight is 0
> > it especially important here for users.
> 
> I'm not too worried about that.
> Sending the first message was a cheap way to ensure something got
> sent if the application lied and didn't send a subsequent message.
> 
> The change has hit Linus's tree, I'll should be able to test that
> and confirm what I think is going on.
> 
> 	David
> 
