From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: Re: [RFC PATCH net-next] bridge: allow setting hash_max +
 multicast_router if interface is down
Date: Fri, 22 May 2015 02:53:17 +0200
Message-ID: <20150522005317.GA3382@odroid>
References: <1432177162-9573-1-git-send-email-linus.luessing@c0d3.blue>
 <20150521034921.GA20427@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.passe0815.de ([188.40.49.9]:49588 "EHLO mail.passe0815.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754061AbbEVAxW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2015 20:53:22 -0400
Content-Disposition: inline
In-Reply-To: <20150521034921.GA20427@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 21, 2015 at 11:49:21AM +0800, Herbert Xu wrote:
> The timer operations are all supposed to be idempotent.  So enabling
> a port twice or stopping it twice should be OK.

Oki doki.

> 
> > * Might calls to br_multicast_add_router() via br_multicast_enable_port()
> >   cause unintended side-effects?
> 
> What do you mean? How does add_router get called from enable_port?

Sorry, ment br_multicast_add_router() via
br_multicast_set_port_router(). But it's not modifying any timers,
and other modifications are locked by the multicast lock, right.

> See above.  It's there so that you don't readd a timer when we're
> calling del_timer_sync.  del_timer_sync has to be called without
> the multicast lock so that's why we need another mechanism to
> prevent the timers from being readded.

Right, all the touched functions never rearm a timer. The
multicast_router timer may only get readded upon receiving a
multicast query.
(br_multicast_query_received()->br_multicast_mark_router() )
By removing the netif_running check we might only delete a timer
which wasn't running anyway which as you said already is safe.

> 
> AFAICS the spots you patched aren't adding timers so they *should*
> be OK.

Okay, thanks for your thorough explanations about the timers and
how the locking is supposed to work. After your explanations I
went over the code a few more times and am fairly confident too
now, that this patch is supposed to work fine.

Going to resend this patch without the RFC tag.

Cheers, Linus
