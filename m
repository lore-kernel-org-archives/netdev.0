From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Fri, 16 Oct 2009 13:08:45 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0910160053001.22897@melkinkari.cs.Helsinki.FI>
References: <20091013050705.GA2194@1wt.eu> <20091013.001106.226276168.davem@davemloft.net> <20091013071955.GA3587@1wt.eu> <Pine.LNX.4.58.0910132335390.3095@u.domain.uli> <20091014045226.GA15655@1wt.eu> <Pine.LNX.4.58.0910140912420.2714@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:51104 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460AbZJPKJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 06:09:22 -0400
In-Reply-To: <Pine.LNX.4.58.0910140912420.2714@u.domain.uli>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Oct 2009, Julian Anastasov wrote:

> 
> 	Hello,
> 
> On Wed, 14 Oct 2009, Willy Tarreau wrote:
> 
> > > > I was trying to use TCP_DEFER_ACCEPT and noticed that if the
> > > > client does not talk, the connection is never accepted and
> > > > remains in SYN_RECV state until the retransmits expire, where
> > > > it finally is deleted. This is bad when some firewall such as
> > > 
> > > 	I think, this is by design, there is big comment in
> > > tcp_check_req().
> > 
> > I'm not sure. That would considerably reduce the usefulness of
> > the feature. The comment I see there is just a one line explaining
> > why we drop the ACK. It does not indicate any strategy on what to
> > do when the counter expires.
> 
> 	There were attempts to switch the server socket to
> established state, no SYN-ACK retransmissions after client ACK
> and send FIN (or RST) to client on TCP_DEFER_ACCEPT expiration
> but due to some locking problems it was reverted:
> 
> http://marc.info/?t=121318919000001&r=1&w=2

For the record,

I think you underestimate that particular change by putting it like that. 
After being there and figuring out all the what that change did I'd say it 
attempted even more ambitious goal, ie., to allow ofo data to be queued. 
And that was the cause for all the troubles as the full state was created 
without a wakeup resulting in plurality in locks that one had to acquire 
when waking up and all the havoc broke loose due to lack of locking (or 
deadlockish ordering)...

...So the problem is not in the "ESTABLISHED" (or like) state itself, but 
in the fact that full state was created before the wakeup which needs to 
access the listening socket state too.

-- 
 i.
