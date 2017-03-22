From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 2/2] sctp: add support for MSG_MORE
Date: Wed, 22 Mar 2017 14:07:37 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFB73FD@AcuExch.aculab.com>
References: <cover.1487440272.git.lucien.xin@gmail.com>
 <d6f2835b0bd655a563896e86648cbd9b4e01374e.1487440272.git.lucien.xin@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFE6C9B9@AcuExch.aculab.com>
 <CADvbK_dDgFc78dBCpTkNxM3kU-GAYbh6CCGTtO=r9ZeNyb2X0A@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFE6E5BB@AcuExch.aculab.com>
 <CADvbK_d9dyL0PFPrAyNqFT_URNdq75NPdQe8tqQkFO4aCg2DdA@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFE6EDE0@AcuExch.aculab.com>
 <20170321220405.GF23553@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: 'Xin Long' <lucien.xin@gmail.com>,
        network dev <netdev@vger.kernel.org>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>
To: 'Marcelo Ricardo Leitner' <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.193]:61278 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752237AbdCVOJS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 10:09:18 -0400
In-Reply-To: <20170321220405.GF23553@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner [mailto:marcelo.leitner@gmail.com]
> Sent: 21 March 2017 22:04
> Hi,
...
> > > 2. send 1 more chunk with MSG_MORE clear, the queue is:
> > >   chk4[clear] -> chk3 [clear] -> chk2 [clear] -> chk1 [clear]
> >
> > I don't think processing the entire queue is a good idea.
> > Both from execution time and the effects on the data cache.
> 
> It won't be processing the entire queue if not needed, and it will only
> process it on the last sendmsg() call. As the list is double-linked, it
> can walk backwards as necessary and stop just at the right point.  So
> this doesn't imply on any quadratic or exponential factor here, but
> linear and only if/when finishing the MSG_MORE block.
> 
> If the application is not using MSG_MORE, impact is zero.
> 
> > The SCTP code is horrid enough as it is.
> >
> > > 3. then if user send more small chunks with MSG_MORE set,
> > > the queue is like:
> > >   chkB[set] -> chkA[set] -> chk4[clear] -> chk3 [clear] -> chk2 [clear] -> chk1 [clear]
> > > so that the new small chunks' flag will not affect the other chunks bundling.
> >
> > That isn't really necessary.
> > The user can't expect to have absolute control over which chunks get bundled
> > together.
> 
> So...?
> I mean, I'm okay with that but that doesn't explain why we can't do as
> Xin proposed on previous email here.
> 
> > If the above chunks still aren't big enough to fill a frame the code might
> > as well wait for the next chunk instead of building a packet that contains
> > chk1 through to chkB.
> 
> Our expectations are the same and that's what the proposed solution also
> achieves, no?

Not really.

> > Remember you'll only get a queued chunk with MSG_MORE clear if data can't be sent.
> > As soon as data can be sent, if the first chunk has MSG_MORE clear all of the
> > queued chunks will be sent.
> 
> With the fix proposed by Xin, this would be more like: ... all of the
> _non-held_ chunks will be sent.
> After all, application asked to hold them, for whatever reason it had.

You are mis-understanding what I think MSG_MORE is for.
It isn't the application saying 'don't send this packet', but rather
'there is no point sending ANY data because I've more data to send'.
There is also the inference that the application will immediately
send the next piece of data.

So it isn't a property of the queued chunk, it is an indication that
the application is going to send more data immediately.

> > So immediately after your (3) the application is expected to send a chunk
> > with MSG_MORE clear - at that point all the queued chunks can be sent in
> > a single packet.
> 
> Yes. Isn't that the idea?
> 
> >
> > So just save the last MSG_MORE on the association as I did.
> 
> I don't see the reason to change that. Your reply seem to reject the
> idea but I cannot get the reason why. The solution proposed is more
> complex, yes, allows more control, yes, but those aren't real issues
> here.

I think you are trying to provide control of chunking that is neither
necessary nor desirable and may give a false indication of what it
might be sensible for the application to have control over.

Regardless of the MSG_MORE flags associated with any specific send()
request there will always be protocol effects (like retransmissions
or flow control 'on') that will generate different 'chunking'.

	David
