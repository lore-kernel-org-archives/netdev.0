From: "'Marcelo Ricardo Leitner'" <marcelo.leitner@gmail.com>
Subject: Re: [RFC PATCH net-next 0/3] sctp: add GSO support
Date: Thu, 28 Jan 2016 18:55:52 -0200
Message-ID: <20160128205551.GC6602@mrl.redhat.com>
References: <cover.1453913331.git.marcelo.leitner@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CCCEDE4@AcuExch.aculab.com>
 <20160128155323.GB6602@mrl.redhat.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CCD0160@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>,
	"brouer@redhat.com" <brouer@redhat.com>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
	"alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>,
	"borkmann@iogearbox.net" <borkmann@iogearbox.net>,
	"marek@cloudflare.com" <marek@cloudflare.com>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>,
	"fw@strlen.de" <fw@strlen.de>,
	"pabeni@redhat.com" <pabeni@redhat.com>,
	"john.r.fastabend@intel.com" <john.r.fastabend@intel.com>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56596 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750794AbcA1Uz5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jan 2016 15:55:57 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CCD0160@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 28, 2016 at 05:30:24PM +0000, David Laight wrote:
> From: 'Marcelo Ricardo Leitner'
> > Sent: 28 January 2016 15:53
> > On Thu, Jan 28, 2016 at 01:51:02PM +0000, David Laight wrote:
> > > From: Marcelo Ricardo Leitner
> > > > Sent: 27 January 2016 17:07
> > > > This patchset is merely a RFC for the moment. There are some
> > > > controversial points that I'd like to discuss before actually proposing
> > > > the patches.
> > >
> > > You also need to look at how a 'user' can actually get SCTP to
> > > merge data chunks in the first place.
> > >
> > > With Nagle disabled (and it probably has to be since the data flow
> > > is unlikely to be 'command-response' or 'unidirectional bulk')
> > > it is currently almost impossible to get more than one chunk
> > > into an ethernet frame.
> > >
> > > Support for MSG_MORE would help.
> > >
> > > Given the current implementation you can get almost the required
> > > behaviour by turning nagle off and on repeatedly.
> > 
> > That's pretty much expected, I think. Without Nagle, if bandwidth and
> > cwnd allow, segment will be sent. GSO by itself shouldn't cause a
> > buffering to protect from that.
> > 
> > If something causes a bottleneck, tx may get queue up.  Like if I do a
> > stress test in my system, generally receiver side is slower than sender,
> > so I end up having tx buffers pretty easily. It mimics bandwidth
> > restrictions.
> 
> Imagine a using M2UA to connect local machines (one running mtp3, the other mtp2).
> Configure two linksets of 16 signalling links and perform a double-reflect
> loopback test.
> The SCTP connection won't ever saturate, so every msu ends up in its own
> ethernet packet.
> It is easy to generate 1000's of ethernet frames/sec on a single connection.
> 
> (We do this with something not entirely quite like M2UA over TCP,
> even then it is very hard to get multiple message into a single
> ethernet frame.)
> 

Agreed, GSO won't help much in there without a corking feature like
MSG_MORE or that on/off switch on Nagle you mentioned.

Thing about this (and also GRO) is on identifying how much can be spent
on waiting for the next chunk/packet without causing issues to the
application. Nagle is there and helps quite a lot, but timing-sensitive
applications will turn it off.

GSO will then rely on a bottleneck for causing tx to get buffered (hmm
there goes the timing sensitivity), which then can be GSOed without
problems, or it will require that application to provide some tips, like
MSG_MORE. But well, GSO is mainly meant for bulk stuff.

> > There is also the case of sending large data chunks, where
> > sctp_sendmsg() will segment it into smaller chunks already.
> 
> I presume they are merged before being passed to the receiving socket?

Yes. SCTP will reassemble the chunk and only deliver it to receiving
application when all pieces needed are there.

> > But yes, agreed, MSG_MORE is at least a welcomed compliment here,
> > specially for applications generating a train of chunks. Will put that in
> > my ToDo here, thanks.
> 
> I've posted a patch in the past for MSG_MORE, didn't quite work.

Ahh cool. Can you share the archive link please? Maybe I can take it
from there then.

> > > I did wonder whether the queued data could actually be picked up
> > > be a Heartbeat chunk that is probing a different remote address
> > > (which would be bad news).
> > 
> > I don't follow. You mean if a heartbeat may get stuck in queue or if
> > sending of a heartbeat can end up carrying additional data by accident?
> 
> My suspicion was that the heartbeat would carry the queued data.

I'm afraid I'm  still not following, sorry. You mean that this GSO patch
would cause the heartbeat to carry queued data? If yes, no, because for
SCTP side of it it mangles the packet size and make it look bigger
instead of handling multiple packets. It will then break this large
sctp_packet into several sk_buff and glue them together as if they were
GROed, allowing skb_segment to just split them back. The reason the
sctp_packet is generated, being it due to user data or control chunks
like heartbeats, is not modified.

  Marcelo
