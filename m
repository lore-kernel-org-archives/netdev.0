From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net-next 2/2] sctp: add support for MSG_MORE
Date: Tue, 21 Mar 2017 19:04:05 -0300
Message-ID: <20170321220405.GF23553@localhost.localdomain>
References: <cover.1487440272.git.lucien.xin@gmail.com>
 <d6f2835b0bd655a563896e86648cbd9b4e01374e.1487440272.git.lucien.xin@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFE6C9B9@AcuExch.aculab.com>
 <CADvbK_dDgFc78dBCpTkNxM3kU-GAYbh6CCGTtO=r9ZeNyb2X0A@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFE6E5BB@AcuExch.aculab.com>
 <CADvbK_d9dyL0PFPrAyNqFT_URNdq75NPdQe8tqQkFO4aCg2DdA@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFE6EDE0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Xin Long' <lucien.xin@gmail.com>,
        network dev <netdev@vger.kernel.org>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39236 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757096AbdCUWFH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 21 Mar 2017 18:05:07 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFE6EDE0@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Feb 24, 2017 at 10:14:09AM +0000, David Laight wrote:
> From: Xin Long
> > Sent: 24 February 2017 06:44
> ...
> > > IIRC sctp_packet_can_append_data() is called for the first queued
> > > data chunk in order to decide whether to generate a message that
> > > consists only of data chunks.
> > > If it returns SCTP_XMIT_OK then a message is built collecting the
> > > rest of the queued data chunks (until the window fills).
> > >
> > > So if I send a message with MSG_MORE set (on an idle connection)
> > > SCTP_XMIT_DELAY is returned and a message isn't sent.
> > >
> > > I now send a second small message, this time with MSG_MORE clear.
> > > The message is queued, then the code looks to see if it can send anything.
> > >
> > > sctp_packet_can_append_data() is called for the first queued chunk.
> > > Since it has force_delay set SCTP_XMIT_DELAY is returned and no
> > > message is built.
> > > The second message isn't even looked at.
> > You're right. I can see the problem now.
> > 
> > What I expected is it should work like:
> > 
> > 1, send 3 small chunks with MSG_MORE set, the queue is:
> >   chk3 [set] -> chk2 [set] -> chk1 [set]
> 
> Strange way to write a queue! chk1 points to chk2 :-)

Strictly speaking, it's actually both together, as it's a double-linked
list. :-)

> 
> > 2. send 1 more chunk with MSG_MORE clear, the queue is:
> >   chk4[clear] -> chk3 [clear] -> chk2 [clear] -> chk1 [clear]
> 
> I don't think processing the entire queue is a good idea.
> Both from execution time and the effects on the data cache.

It won't be processing the entire queue if not needed, and it will only
process it on the last sendmsg() call. As the list is double-linked, it
can walk backwards as necessary and stop just at the right point.  So
this doesn't imply on any quadratic or exponential factor here, but
linear and only if/when finishing the MSG_MORE block.

If the application is not using MSG_MORE, impact is zero.

> The SCTP code is horrid enough as it is.
> 
> > 3. then if user send more small chunks with MSG_MORE set,
> > the queue is like:
> >   chkB[set] -> chkA[set] -> chk4[clear] -> chk3 [clear] -> chk2 [clear] -> chk1 [clear]
> > so that the new small chunks' flag will not affect the other chunks bundling.
> 
> That isn't really necessary.
> The user can't expect to have absolute control over which chunks get bundled
> together.

So...?
I mean, I'm okay with that but that doesn't explain why we can't do as
Xin proposed on previous email here.

> If the above chunks still aren't big enough to fill a frame the code might
> as well wait for the next chunk instead of building a packet that contains
> chk1 through to chkB.

Our expectations are the same and that's what the proposed solution also
achieves, no?

> 
> Remember you'll only get a queued chunk with MSG_MORE clear if data can't be sent.
> As soon as data can be sent, if the first chunk has MSG_MORE clear all of the
> queued chunks will be sent.

With the fix proposed by Xin, this would be more like: ... all of the
_non-held_ chunks will be sent.
After all, application asked to hold them, for whatever reason it had.

> 
> So immediately after your (3) the application is expected to send a chunk
> with MSG_MORE clear - at that point all the queued chunks can be sent in
> a single packet.

Yes. Isn't that the idea?

> 
> So just save the last MSG_MORE on the association as I did.

I don't see the reason to change that. Your reply seem to reject the
idea but I cannot get the reason why. The solution proposed is more
complex, yes, allows more control, yes, but those aren't real issues
here.

  Marcelo
