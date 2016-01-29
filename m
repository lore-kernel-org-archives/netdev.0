From: "'Marcelo Ricardo Leitner'" <marcelo.leitner@gmail.com>
Subject: Re: [RFC PATCH net-next 0/3] sctp: add GSO support
Date: Fri, 29 Jan 2016 16:53:25 -0200
Message-ID: <20160129185325.GE6604@mrl.redhat.com>
References: <cover.1453913331.git.marcelo.leitner@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CCCEDE4@AcuExch.aculab.com>
 <20160128155323.GB6602@mrl.redhat.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CCD0160@AcuExch.aculab.com>
 <20160128205551.GC6602@mrl.redhat.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CCD119A@AcuExch.aculab.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:48428 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932495AbcA2Sxc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jan 2016 13:53:32 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CCD119A@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 29, 2016 at 03:51:52PM +0000, David Laight wrote:
> From: 'Marcelo Ricardo Leitner'
> > Sent: 28 January 2016 20:56
> > On Thu, Jan 28, 2016 at 05:30:24PM +0000, David Laight wrote:
> > > From: 'Marcelo Ricardo Leitner'
> > > > Sent: 28 January 2016 15:53
> > > > On Thu, Jan 28, 2016 at 01:51:02PM +0000, David Laight wrote:
> ...
> > > > > With Nagle disabled (and it probably has to be since the data flow
> > > > > is unlikely to be 'command-response' or 'unidirectional bulk')
> > > > > it is currently almost impossible to get more than one chunk
> > > > > into an ethernet frame.
> > > > >
> > > > > Support for MSG_MORE would help.
> > > > >
> > > > > Given the current implementation you can get almost the required
> > > > > behaviour by turning nagle off and on repeatedly.
> > > >
> > > > That's pretty much expected, I think. Without Nagle, if bandwidth and
> > > > cwnd allow, segment will be sent. GSO by itself shouldn't cause a
> > > > buffering to protect from that.
> > > >
> > > > If something causes a bottleneck, tx may get queue up.  Like if I do a
> > > > stress test in my system, generally receiver side is slower than sender,
> > > > so I end up having tx buffers pretty easily. It mimics bandwidth
> > > > restrictions.
> > >
> > > Imagine a using M2UA to connect local machines (one running mtp3, the other mtp2).
> > > Configure two linksets of 16 signalling links and perform a double-reflect
> > > loopback test.
> > > The SCTP connection won't ever saturate, so every msu ends up in its own
> > > ethernet packet.
> > > It is easy to generate 1000's of ethernet frames/sec on a single connection.
> > >
> > > (We do this with something not entirely quite like M2UA over TCP,
> > > even then it is very hard to get multiple message into a single
> > > ethernet frame.)
> > >
> > 
> > Agreed, GSO won't help much in there without a corking feature like
> > MSG_MORE or that on/off switch on Nagle you mentioned.
> > 
> > Thing about this (and also GRO) is on identifying how much can be spent
> > on waiting for the next chunk/packet without causing issues to the
> > application. Nagle is there and helps quite a lot, but timing-sensitive
> > applications will turn it off.
> 
> Nagle is only any good for unidirectional data (think file transfer)
> and command-response (think telnet or rlogin), for anything else
> it generates 200ms+ delays.
> The SIGTRAN protocols (M3UA etc) are all specified to use SCTP
> and have no real relationship between the send and receive data.
> SCTP is being used to replace 64kb/s links so a few milliseconds
> of delay (1ms is 8 byte times) probably don't matter.
> The Nagle timeout is, however far too long - so has to be disabled.
> 
> So never mind GSO to improve 'bulk' output, the big SCTP performance
> issue (as I see it) is the inability for a lot of workloads to
> ever get more than one small data chunk into an ethernet frame.
> 
> Which other (application) protocols are using SCTP?
> It doesn't seem an appropriate protocol for bulk data.

David I agree with most of what you said here and before, sorry if I
didn't make it clear before. I put MSG_MORE on my ToDo and I'll check
what I can do about it. I got your link from the other email, thanks.

Just the usage you mention on SCTP, is limited to SIGTRAN work. DLM,
distributed lock manager, filesystem stuff, uses SCTP just because it
has multi-homing out of the box and it improves the cluster resilience.
I'd like SCTP to be more adopted in projects like DLM did. It has plenty
of features that are very often re-impemented by applications, like
message boundaries and ordering. 

GSO should not, in any way, objects to MSG_MORE. I don't see we having
conflicting goals here. Do you?

  Marcelo
