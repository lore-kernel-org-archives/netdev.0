From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [RFC PATCH net-next 0/3] sctp: add GSO support
Date: Thu, 28 Jan 2016 17:30:24 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CCD0160@AcuExch.aculab.com>
References: <cover.1453913331.git.marcelo.leitner@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CCCEDE4@AcuExch.aculab.com>
 <20160128155323.GB6602@mrl.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
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
To: 'Marcelo Ricardo Leitner' <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.182]:54179 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754277AbcA1Rd1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 12:33:27 -0500
In-Reply-To: <20160128155323.GB6602@mrl.redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: 'Marcelo Ricardo Leitner'
> Sent: 28 January 2016 15:53
> On Thu, Jan 28, 2016 at 01:51:02PM +0000, David Laight wrote:
> > From: Marcelo Ricardo Leitner
> > > Sent: 27 January 2016 17:07
> > > This patchset is merely a RFC for the moment. There are some
> > > controversial points that I'd like to discuss before actually proposing
> > > the patches.
> >
> > You also need to look at how a 'user' can actually get SCTP to
> > merge data chunks in the first place.
> >
> > With Nagle disabled (and it probably has to be since the data flow
> > is unlikely to be 'command-response' or 'unidirectional bulk')
> > it is currently almost impossible to get more than one chunk
> > into an ethernet frame.
> >
> > Support for MSG_MORE would help.
> >
> > Given the current implementation you can get almost the required
> > behaviour by turning nagle off and on repeatedly.
> 
> That's pretty much expected, I think. Without Nagle, if bandwidth and
> cwnd allow, segment will be sent. GSO by itself shouldn't cause a
> buffering to protect from that.
> 
> If something causes a bottleneck, tx may get queue up.  Like if I do a
> stress test in my system, generally receiver side is slower than sender,
> so I end up having tx buffers pretty easily. It mimics bandwidth
> restrictions.

Imagine a using M2UA to connect local machines (one running mtp3, the other mtp2).
Configure two linksets of 16 signalling links and perform a double-reflect
loopback test.
The SCTP connection won't ever saturate, so every msu ends up in its own
ethernet packet.
It is easy to generate 1000's of ethernet frames/sec on a single connection.

(We do this with something not entirely quite like M2UA over TCP,
even then it is very hard to get multiple message into a single
ethernet frame.)


> There is also the case of sending large data chunks, where
> sctp_sendmsg() will segment it into smaller chunks already.

I presume they are merged before being passed to the receiving socket?

> But yes, agreed, MSG_MORE is at least a welcomed compliment here,
> specially for applications generating a train of chunks. Will put that in
> my ToDo here, thanks.

I've posted a patch in the past for MSG_MORE, didn't quite work.

> > I did wonder whether the queued data could actually be picked up
> > be a Heartbeat chunk that is probing a different remote address
> > (which would be bad news).
> 
> I don't follow. You mean if a heartbeat may get stuck in queue or if
> sending of a heartbeat can end up carrying additional data by accident?

My suspicion was that the heartbeat would carry the queued data.

	David
