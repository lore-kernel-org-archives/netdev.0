From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: SCTP data chunk bundling when SCTP_NODELAY is set
Date: Tue, 17 Jun 2014 16:07:50 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1725DF55@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1725DD38@AcuExch.aculab.com>
 <53A062A9.70806@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Vlad Yasevich' <vyasevich@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:53819 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755414AbaFQQJE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 12:09:04 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 15317-01 for <netdev@vger.kernel.org>;
 Tue, 17 Jun 2014 17:08:53 +0100 (BST)
In-Reply-To: <53A062A9.70806@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich
> On 06/17/2014 10:17 AM, David Laight wrote:
> > If SCTP_NODELAY is set it is difficult to get SCTP to bundle
> > data chunks into ethernet packets.
> > This leads to very high packet rates which bundling could easily
> > reduce by a factor or 8 or 10.
> >
> > Nagle can't really be enabled because it generates unwanted delays
> > when traffic is light (Nagle only really works for unidirectional bulk
> > data and command-response when the messages are smaller than the mtu).
> >
> > Even if the sending application knows it has more data to send,
> > there isn't much it can do to get the chunks bundled.
> >
> > AFAICT 'corking' the socket even stops full sized packets being
> > sent - so the application will deadlock if the socket write
> > buffer size is reached before the socket is 'uncorked'.
> > This also means that the application can't send back to back
> > full sized packets unless it uncorks the socket at exactly
> > the right places.
> >
> > MSG_MORE isn't supported by SCTP, but I'm not sure it would help.
> > You really need a MSG_NO_MORE flag and to leave Nagle enabled.
> >
> > About the only thing I can think of is to normally have Nagle
> > enabled, and then perform the following sequence to force the
> > buffered data chunks be sent:
> > 1) disable Nagle
> > 2) cork the socket
> > 3) uncork the socket
> > 4) enable Nagle
> > Four socket calls is a little excessive!
> 
> First, how are you corking an SCTP socket?  There is no SCTP_CORK
> and looking at the code, I don't see how an SCTP queue can be
> cored by user...

I only looked as far as seeing that the code in sm_sideffect.c
allows someone else to have corked the socket, and the effect
that the 'cork' had.

> I suppose we could implement SCTP_CORK to do the right thing.
> 
> I thought is possibly utilizing something like sendmmsg() and passing
> an extra flag to let it be know that this is a multi-message send
> that should be queued up by sctp..

It would be as easy to expose the extra flag to the 'application'
allowing it to use sendmsg() or sendmmsg().
While sendmmsg() saves a system call, it is fairly horrid to use.
(and I'm sending from a kernel driver so don't care about the 
system call cost!)

Possibly MSG_MORE with Nagle disabled could invoke the Nagle send
delay - but you'd need to know whether any chunks in the queue
had MSG_MORE clear.
It would also be nice to have a 'send on local timeout', rather than
Nagle's 'wait for everything to be acked'.

	David
