From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: SCTP data chunk bundling when SCTP_NODELAY is set
Date: Wed, 18 Jun 2014 13:47:38 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1725E88C@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1725DD38@AcuExch.aculab.com>
 <53A062A9.70806@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1725DF55@AcuExch.aculab.com>
 <53A071A2.20909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Vlad Yasevich' <vyasevich@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:43954 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751310AbaFRNsz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 09:48:55 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 32192-08 for <netdev@vger.kernel.org>;
 Wed, 18 Jun 2014 14:48:45 +0100 (BST)
In-Reply-To: <53A071A2.20909@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich 
...
> >> I suppose we could implement SCTP_CORK to do the right thing.
> >>
> >> I thought is possibly utilizing something like sendmmsg() and passing
> >> an extra flag to let it be know that this is a multi-message send
> >> that should be queued up by sctp..
> >
> > It would be as easy to expose the extra flag to the 'application'
> > allowing it to use sendmsg() or sendmmsg().
> > While sendmmsg() saves a system call, it is fairly horrid to use.
> > (and I'm sending from a kernel driver so don't care about the
> > system call cost!)
> >
> > Possibly MSG_MORE with Nagle disabled could invoke the Nagle send
> > delay - but you'd need to know whether any chunks in the queue
> > had MSG_MORE clear.
> 
> That's why doing this with cork would be simpler.  The ULP can just
> queue up a bunch of small data and if we pass nagle checks, it will be
> flushed.  If not, uncork will flush it.

I think you need only care about the 'MSG_MORE' flag of the last data chunk.
Any earlier data (with MSG_MORE clear) will usually have been sent (unless
prevented by Nagle or flow control), so you probably wouldn't be able to
send it regardless of the state of MSG_MORE on a chunk being queued.
There is also the expectation that another send without MSG_MORE will
happen almost immediately.

So MSG_MORE could have the same effect as corking the socket.
Although you'd need separate bits - but uncork could clear both.

What I would like to implement (from M3UA) is to hold data for a maximum
of (say) 5ms awaiting M3UA data chunks. To do this properly requires
knowledge of the actual ethernet packet boundaries.

The problem is there are (at least) three cases:
1) This data should be sent as soon as possible.
2) Send this data some time soonish.
3) I've got another data block I'm going to give you after this one.

> I could work up a patch for you if you want.

I was thinking I might try to write one.
But I've been asked to look at something else for a bit.

	David
