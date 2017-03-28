From: 'Marcelo Ricardo Leitner' <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net-next 2/2] sctp: add support for MSG_MORE
Date: Tue, 28 Mar 2017 15:12:54 -0300
Message-ID: <20170328181254.GB5879@localhost.localdomain>
References: <cover.1487440272.git.lucien.xin@gmail.com>
 <d6f2835b0bd655a563896e86648cbd9b4e01374e.1487440272.git.lucien.xin@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFE6C9B9@AcuExch.aculab.com>
 <CADvbK_dDgFc78dBCpTkNxM3kU-GAYbh6CCGTtO=r9ZeNyb2X0A@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFE6E5BB@AcuExch.aculab.com>
 <CADvbK_d9dyL0PFPrAyNqFT_URNdq75NPdQe8tqQkFO4aCg2DdA@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFE6EDE0@AcuExch.aculab.com>
 <20170321220405.GF23553@localhost.localdomain>
 <063D6719AE5E284EB5DD2968C1650D6DCFFBFAE6@AcuExch.aculab.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:48624 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752700AbdC1SNA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Mar 2017 14:13:00 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFFBFAE6@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 28, 2017 at 10:29:27AM +0000, David Laight wrote:
> From: Marcelo Ricardo Leitner
> > Sent: 21 March 2017 22:04
> ...
> > > > 3. then if user send more small chunks with MSG_MORE set,
> > > > the queue is like:
> > > >   chkB[set] -> chkA[set] -> chk4[clear] -> chk3 [clear] -> chk2 [clear] -> chk1 [clear]
> > > > so that the new small chunks' flag will not affect the other chunks bundling.
> > >
> > > That isn't really necessary.
> > > The user can't expect to have absolute control over which chunks get bundled
> > > together.
> > 
> > So...?
> > I mean, I'm okay with that but that doesn't explain why we can't do as
> > Xin proposed on previous email here.
> > 
> > > If the above chunks still aren't big enough to fill a frame the code might
> > > as well wait for the next chunk instead of building a packet that contains
> > > chk1 through to chkB.
> > 
> > Our expectations are the same and that's what the proposed solution also
> > achieves, no?
> > 
> > >
> > > Remember you'll only get a queued chunk with MSG_MORE clear if data can't be sent.
> > > As soon as data can be sent, if the first chunk has MSG_MORE clear all of the
> > > queued chunks will be sent.
> > 
> > With the fix proposed by Xin, this would be more like: ... all of the
> > _non-held_ chunks will be sent.
> > After all, application asked to hold them, for whatever reason it had.
> > 
> > >
> > > So immediately after your (3) the application is expected to send a chunk
> > > with MSG_MORE clear - at that point all the queued chunks can be sent in
> > > a single packet.
> > 
> > Yes. Isn't that the idea?
> > 
> > >
> > > So just save the last MSG_MORE on the association as I did.
> > 
> > I don't see the reason to change that. Your reply seem to reject the
> > idea but I cannot get the reason why. The solution proposed is more
> > complex, yes, allows more control, yes, but those aren't real issues
> > here.
> 
> I think I've realised why we were disagreeing....
> 
> For TCP MSG_MORE was implemented as an alternative to 'corking' for
> allocations that used multiple send() calls to send a single application
> level message (eg those that send a length and data separately).
> The real solution is to use sendv() (or writev() if sendv() doesn't exist).
> 
> SCTP is different, every send() generates a separate data chunk.
> The problem in SCTP is that if an application has more than one data
> chunk to send it needs to stop the kernel sending anything until
> it has sent all the data chunks - otherwise they all go out in
> separate ethernet packets.
> 
> A TCP application can avoid this by doing a single send() for all the
> data. This doesn't work for SCTP because it would generate a single
> data chunk.

Yep, it was based on TCP one since day 0. There is also the way MSG_MORE
works for UDP, in which it appends the subsequent write to the same
datagram. But then, for SCTP, we should use EOR flag, as Michael Tuexen
had indicated here on the list a few months ago:
"""
What about adding support for the explicit EOR mode as specified in
https://tools.ietf.org/html/rfc6458#section-8.1.26
"""
Thus why it was very based on TCP implementation, so maybe in the future
we could have both options available for SCTP.

  Marcelo
