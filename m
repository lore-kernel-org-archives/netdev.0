From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Wed, 14 Oct 2009 22:17:06 +0200
Message-ID: <20091014201706.GA24298@1wt.eu>
References: <20091013050705.GA2194@1wt.eu> <20091013.001106.226276168.davem@davemloft.net> <20091013071955.GA3587@1wt.eu> <Pine.LNX.4.58.0910132335390.3095@u.domain.uli> <20091014045226.GA15655@1wt.eu> <Pine.LNX.4.58.0910140912420.2714@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:50221 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755872AbZJNUSA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2009 16:18:00 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0910140912420.2714@u.domain.uli>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Julian,

On Wed, Oct 14, 2009 at 10:27:50AM +0300, Julian Anastasov wrote:
> 	There were attempts to switch the server socket to
> established state, no SYN-ACK retransmissions after client ACK
> and send FIN (or RST) to client on TCP_DEFER_ACCEPT expiration
> but due to some locking problems it was reverted:
> 
> http://marc.info/?t=121318919000001&r=1&w=2

interesting lecture, thanks for the link.

> 	Current handling is as before: drop client ACKs before DATA,
> stay in SYN_RECV state, send RST on outdated ACKs.

OK, that's what I observed too.

(...)
> > > 	This works properly in 2.6.31.3, I set TCP_SYNCNT=1
> > > and TCP_DEFER_ACCEPT then only 2 SYN-ACKs are sent.
> > 
> > That's what I observe too, but the connection is silently dropped
> > afterwards and I'm clearly not sure this was the intended behaviour.
> 
> 	Yes, bad only for firewalls. Note that if
> TCP_SYNCNT/TCP_DEFER_ACCEPT is shorter the client still gets
> RST on next ACK. So, the problem is when client is silent
> after first ACK.

Not only, we have the problem that the application layer has no way
to be informed that someone connected and failed to send anything.

I have added the defer_accept feature in haproxy (http load balancer),
just as an optimization to avoid a EAGAIN upon first recv() attempt
to read the HTTP request after an accept. But users rely on stats and
logs a lot to check if their site works. If clients really connect and
fail to send a request (most often because of PPPoE outgoing MTU issues),
they want to see that in the stats in order to monitor their quality of
service. Also, having the ability to return a "408 request timeout" to
the users is a lot cleaner and easier to debug than not responding
anything at all, especially when there are reverse-proxies between
both ends.

So this behaviour has visible effects to the end user, that are not
expected at all when reading the doc.

> > So clearly this is in order to improve chances that the application
> > will receive the connection, no ?
> 
> 	Yes, it is not logical to configure
> TCP_DEFER_ACCEPT < TCP_SYNCNT with the idea TCP_DEFER_ACCEPT
> to reduce the SYN_RECV period. TCP_DEFER_ACCEPT does not
> reduce the SYN_RECV period (before ACK), may be this is lacking
> in man page. The idea to optionally give more time for DATA
> to come after ACK is more logical. If TCP_DEFER_ACCEPT
> switches state to ESTABLISHED may be then the TCP_DEFER_ACCEPT
> period should start after ACK, eg. "wait for DATA 10 seconds after
> ACK" sounds logical, it will need new name...

I don't even need to wait for 10 seconds after first ACK, being
able to drop only the first ACK is already excellent IMHO.

> Note that
> TCP_DEFER_ACCEPT is used also as flag for clients but you can do
> the same with TCP_QUICKACK=0 (to delay first ACK and to send
> DATA with first ACK).

Yes and I already use that, this gives substantial performance
boosts on small HTTP requests ; unfortunately I have no control
over the end-user's browser !

> > Yes this is what happens right now, but reading the man again
> > does not imply to me that the connection will not be accepted
> > once we reach the retransmit limit.
> > 
> > Maybe we have different usages and different interpretations of
> > the man can satisfy either, but I don't see what this would be
> > useful to in case we silently drop instead of finally accepting.
> 
> 	May be we want the same but currently TCP_DEFER_ACCEPT
> works as ACK dropper which is easier for implementation.

That's what I like too. No timer, very light requirements, just drop
the first empty ACK I'm not interested in, and that's all. That's
really what I understood from the man page.

> The semantic 'TCP_DEFER_ACCEPT extends the period after ACK'
> is good, you can tune it together with TCP_SYNCNT, to
> extend or not to extend the period. What happens on
> TCP_DEFER_ACCEPT expiration after ACK - we all prefer to
> see FIN, so we have to wait someone to come with new
> implementation.

Well, too much complicated for very little gain IMHO.

Regards,
Willy

