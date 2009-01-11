From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Sun, 11 Jan 2009 19:05:48 +0300
Message-ID: <20090111160548.GA362@ioremap.net>
References: <20090109212400.GA3727@1wt.eu> <20090109220737.GA4111@1wt.eu> <4967CBB9.1060403@cosmosbay.com> <20090109221744.GA4819@1wt.eu> <20090109224258.GA10257@ioremap.net> <496850D5.8040907@cosmosbay.com> <20090111125759.GB24173@ioremap.net> <4969F0D1.8020504@cosmosbay.com> <20090111133533.GB25337@ioremap.net> <496A17A5.7010200@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
	ben@zeus.com, jarkao2@gmail.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tservice.net.ru ([195.178.208.66]:59903 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751936AbZAKQFu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jan 2009 11:05:50 -0500
Content-Disposition: inline
In-Reply-To: <496A17A5.7010200@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 11, 2009 at 05:00:37PM +0100, Eric Dumazet (dada1@cosmosbay.com) wrote:
> >>>> 1) the release_sock/lock_sock done in tcp_splice_read() is not necessary
> >>>> to process backlog. Its already done in skb_splice_bits()
> >>> Yes, in the tcp_splice_read() they are added to remove a deadlock.
> >> Could you elaborate ? A deadlock only if !SPLICE_F_NONBLOCK ?
> > 
> > Sorry, I meant that we drop lock in skb_splice_bits() to prevent the deadlock,
> > and tcp_splice_read() needs it to process the backlog.
> 
> While we drop lock in skb_splice_bits() to prevent the deadlock, we
> also process backlog at this stage. No need to process backlog
> again in the higher level function.

Yes, but having it earlier allows to receive new skb while processing
already received.

> > I think that even with non-blocking splice that release_sock/lock_sock
> > is needed, since we are able to do a parallel job: to receive new data
> > (scheduled by early release_sock backlog processing) in bh and to
> > process already received data via splice codepath.
> > Maybe in non-blocking splice mode this is not an issue though, but for
> > the blocking mode this allows to grab more skbs at once in skb_splice_bits.
> 
> skb_splice_bits() operates on one skb, you lost me :)

Exactly, and to have it we earlier release a socket so that it could be
acked and while we copy it or doing anything else, the next one would
received.

-- 
	Evgeniy Polyakov
