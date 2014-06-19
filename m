From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: SCTP data chunk bundling when SCTP_NODELAY is set
Date: Thu, 19 Jun 2014 13:45:09 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1725F13F@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1725DD38@AcuExch.aculab.com>
 <53A062A9.70806@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1725DF55@AcuExch.aculab.com>
 <53A071A2.20909@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1725E88C@AcuExch.aculab.com>
 <063D6719AE5E284EB5DD2968C1650D6D1725EB40@AcuExch.aculab.com>
 <53A2E53A.3030302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Vlad Yasevich' <vyasevich@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:35817 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1756199AbaFSNqa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2014 09:46:30 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 18273-08 for <netdev@vger.kernel.org>;
 Thu, 19 Jun 2014 14:46:21 +0100 (BST)
In-Reply-To: <53A2E53A.3030302@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich
> On 06/18/2014 12:38 PM, David Laight wrote:
> > From: David Laight
> >> From: Vlad Yasevich
> >> ...
> >>>>> I suppose we could implement SCTP_CORK to do the right thing.
> >>>>>
> >>>>> I thought is possibly utilizing something like sendmmsg() and passing
> >>>>> an extra flag to let it be know that this is a multi-message send
> >>>>> that should be queued up by sctp..
> >>>>
> >>>> It would be as easy to expose the extra flag to the 'application'
> >>>> allowing it to use sendmsg() or sendmmsg().
> >>>> While sendmmsg() saves a system call, it is fairly horrid to use.
> >>>> (and I'm sending from a kernel driver so don't care about the
> >>>> system call cost!)
> >>>>
> >>>> Possibly MSG_MORE with Nagle disabled could invoke the Nagle send
> >>>> delay - but you'd need to know whether any chunks in the queue
> >>>> had MSG_MORE clear.
> >>>
> >>> That's why doing this with cork would be simpler.  The ULP can just
> >>> queue up a bunch of small data and if we pass nagle checks, it will be
> >>> flushed.  If not, uncork will flush it.
> >>
> >> I think you need only care about the 'MSG_MORE' flag of the last data chunk.
> >> Any earlier data (with MSG_MORE clear) will usually have been sent (unless
> >> prevented by Nagle or flow control), so you probably wouldn't be able to
> >> send it regardless of the state of MSG_MORE on a chunk being queued.
> >> There is also the expectation that another send without MSG_MORE will
> >> happen almost immediately.
> >>
> >> So MSG_MORE could have the same effect as corking the socket.
> >> Although you'd need separate bits - but uncork could clear both.
> >>
> >> What I would like to implement (from M3UA) is to hold data for a maximum
> >> of (say) 5ms awaiting M3UA data chunks. To do this properly requires
> >> knowledge of the actual ethernet packet boundaries.
> >>
> >> The problem is there are (at least) three cases:
> >> 1) This data should be sent as soon as possible.
> >> 2) Send this data some time soonish.
> >> 3) I've got another data block I'm going to give you after this one.
> >>
> >>> I could work up a patch for you if you want.
> >>
> >> I was thinking I might try to write one.
> >
> > Actually this might work for what I'm trying to do.
> > (untested).
> >
> > diff --git a/net/sctp/output.c b/net/sctp/output.c
> > index 0f4d15f..51030bc 100644
> > --- a/net/sctp/output.c
> > +++ b/net/sctp/output.c
> > @@ -691,7 +691,7 @@ static sctp_xmit_t sctp_packet_can_append_data(struct sctp_packet *packet,
> >  	 * if any previously transmitted data on the connection remains
> >  	 * unacknowledged.
> >  	 */
> > -	if (!sctp_sk(asoc->base.sk)->nodelay && sctp_packet_empty(packet) &&
> > +	if (sctp_sk(asoc->base.sk)->nodelay != 1 && sctp_packet_empty(packet) &&
> >  	    inflight && sctp_state(asoc, ESTABLISHED)) {
> >  		unsigned int max = transport->pathmtu - packet->overhead;
> >  		unsigned int len = chunk->skb->len + q->out_qlen;
> > diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> > index fee06b9..084b957 100644
> > --- a/net/sctp/socket.c
> > +++ b/net/sctp/socket.c
> > @@ -1928,7 +1928,10 @@ static int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
> >  	}
> >
> >  	/* Break the message into multiple chunks of maximum size. */
> > +	if (msg->msg_flags & MSG_MORE)
> > +		sp->nodelay |= 2;
> >  	datamsg = sctp_datamsg_from_user(asoc, sinfo, msg, msg_len);
> > +	sp->nodelay &= 1;
> 
> I think you reset it too early.  You have to reset after the call to
> sctp_primitive_SEND().  This way, you queue up the data and go through
> the state machine with nodelay != 1, thus triggering the updated code
> on output.

I changed it to clear the flag if MSG_MORE is clear before I tested it.

I'll post a patch after net-next opens.

> > Ideally MSG_MORE should delay sending even if 'inflight' is false.
> > But that would require 'flush on timeout'.
> 
> You can use a lack of MSG_MORE to be an indication of a flush.  Thus
> MSG_MORE would always queue up data until MSG_MORE is 0, at which point
> flush should happen.

With Nagle disabled. If MSG_MORE was clear on the previous send then there
will normally be nothing queued (would have to be flow control limited).

> 
> > I'd prefer that, and with a configurable timeout.
> > But I can implement the timeout in the 'application'.
> >
> > Given the way Nagle is implemented in sctp, I could keep flipping
> > it on and off - but that probably has undocumented behaviour
> > (ie it might suddenly change).
> 
> With the above MSG_MORE, I think you can just turn off nagle once and
> use MSG_MORE and when you drain your application queue, clear MSG_MORE
> on the last write.

That is what I've done.
When my test application sends 100 messages through M3UA I now see a
small number of ethernet packets - rather than 100.
The whole thing does rather rely on the lengths of various code
paths in order to get multiple messages queued at the point that
sendmsg() is finally called.

I'm not worried about sending 2 packets at the start of a burst of data.
It seems safer than not sending data because the application send
a single block with MSG_MORE set.

I do need to do some testing with simulated network delays.
Someone posted how to set that up earlier today.

I noticed that the TCP code is documented to eventually send data after 200ms.
It would be better if that interval were settable per-socket.
I'd set it to 1ms (or next tick).

	David
