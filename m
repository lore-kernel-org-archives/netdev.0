From: Julian Anastasov <ja@ssi.bg>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Wed, 14 Oct 2009 10:27:50 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0910140912420.2714@u.domain.uli>
References: <20091013050705.GA2194@1wt.eu> <20091013.001106.226276168.davem@davemloft.net>
 <20091013071955.GA3587@1wt.eu> <Pine.LNX.4.58.0910132335390.3095@u.domain.uli>
 <20091014045226.GA15655@1wt.eu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:37707 "EHLO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751467AbZJNH1r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2009 03:27:47 -0400
In-Reply-To: <20091014045226.GA15655@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 14 Oct 2009, Willy Tarreau wrote:

> > > I was trying to use TCP_DEFER_ACCEPT and noticed that if the
> > > client does not talk, the connection is never accepted and
> > > remains in SYN_RECV state until the retransmits expire, where
> > > it finally is deleted. This is bad when some firewall such as
> > 
> > 	I think, this is by design, there is big comment in
> > tcp_check_req().
> 
> I'm not sure. That would considerably reduce the usefulness of
> the feature. The comment I see there is just a one line explaining
> why we drop the ACK. It does not indicate any strategy on what to
> do when the counter expires.

	There were attempts to switch the server socket to
established state, no SYN-ACK retransmissions after client ACK
and send FIN (or RST) to client on TCP_DEFER_ACCEPT expiration
but due to some locking problems it was reverted:

http://marc.info/?t=121318919000001&r=1&w=2

	Current handling is as before: drop client ACKs before DATA,
stay in SYN_RECV state, send RST on outdated ACKs.

> > > netfilter sits between the client and the server because the
> > > firewall sees the connection in ESTABLISHED state while the
> > > server will finally silently drop it without sending an RST.
> > 
> > 	Client can stay ESTABLISHED for long time but
> > RST will be sent when client sends DATA or FIN.
> 
> Yes you're right. In fact, this only weakens firewalls in case of
> pure scans, but attacks on SYN cookies do that too, as well as
> TTL-based attacks.

	Hm, yes, may be firewalls should be better here.
They should know which server ports send welcome and which
do no not.

> > 	This works properly in 2.6.31.3, I set TCP_SYNCNT=1
> > and TCP_DEFER_ACCEPT then only 2 SYN-ACKs are sent.
> 
> That's what I observe too, but the connection is silently dropped
> afterwards and I'm clearly not sure this was the intended behaviour.

	Yes, bad only for firewalls. Note that if
TCP_SYNCNT/TCP_DEFER_ACCEPT is shorter the client still gets
RST on next ACK. So, the problem is when client is silent
after first ACK.

> > > But in tcp_minisocks.c, this counter is only checked. And in
> > > fact, I have found no location which updates it. So I think
> > > that what was intended was to decrease it in tcp_minisocks
> > > whenever it is checked, which the trivial patch below does.
> > 
> > 	You can check net/ipv4/inet_connection_sock.c,
> > inet_csk_reqsk_queue_prune() where TCP_DEFER_ACCEPT can extend
> > the retransmission threshold for acked sockets above the
> > applied 'thresh'.
> 
> So clearly this is in order to improve chances that the application
> will receive the connection, no ?

	Yes, it is not logical to configure
TCP_DEFER_ACCEPT < TCP_SYNCNT with the idea TCP_DEFER_ACCEPT
to reduce the SYN_RECV period. TCP_DEFER_ACCEPT does not
reduce the SYN_RECV period (before ACK), may be this is lacking
in man page. The idea to optionally give more time for DATA
to come after ACK is more logical. If TCP_DEFER_ACCEPT
switches state to ESTABLISHED may be then the TCP_DEFER_ACCEPT
period should start after ACK, eg. "wait for DATA 10 seconds after
ACK" sounds logical, it will need new name... Note that
TCP_DEFER_ACCEPT is used also as flag for clients but you can do
the same with TCP_QUICKACK=0 (to delay first ACK and to send
DATA with first ACK).

> Yes this is what happens right now, but reading the man again
> does not imply to me that the connection will not be accepted
> once we reach the retransmit limit.
> 
> Maybe we have different usages and different interpretations of
> the man can satisfy either, but I don't see what this would be
> useful to in case we silently drop instead of finally accepting.

	May be we want the same but currently TCP_DEFER_ACCEPT
works as ACK dropper which is easier for implementation.
The semantic 'TCP_DEFER_ACCEPT extends the period after ACK'
is good, you can tune it together with TCP_SYNCNT, to
extend or not to extend the period. What happens on
TCP_DEFER_ACCEPT expiration after ACK - we all prefer to
see FIN, so we have to wait someone to come with new
implementation.

Regards

--
Julian Anastasov <ja@ssi.bg>
