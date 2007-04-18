From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: + ppp_generic-fix-lockdep-warning.patch added to -mm tree
Date: Wed, 18 Apr 2007 08:40:11 +0200
Message-ID: <20070418064011.GA1680@ff.dom.local>
References: <20070411000932.1f00f395.akpm@linux-foundation.org> <028701c77c16$bcd68a90$0202fea9@Jura> <20070417073744.GA1976@ff.dom.local> <4624CB08.2070005@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Yuriy N\. Shkandybin" <jura@netams.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Paul Mackerras <paulus@samba.org>, netdev@vger.kernel.org,
	Michal Ostrowski <mostrows@speakeasy.net>
To: Michal Ostrowski <mostrows@earthlink.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:45481 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932500AbXDRGeh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Apr 2007 02:34:37 -0400
Content-Disposition: inline
In-Reply-To: <4624CB08.2070005@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 17, 2007 at 08:26:32AM -0500, Michal Ostrowski wrote:
> The "xmit" function of a PPP channel is a synchronous operation.  If the 
> transmission fails, we must notify the caller and let them re-submit the 
> skb later.  The return status of dev_queue_xmit is needed to determine 
> the return code passed back to the caller and thus the call is made 
> synchronously and not in a tasklet.

Sure! But on the other hand:

- the return code from dev_queue_xmit doesn't guarantee
the transmission won't fail,

- similar code in ppp_async: ppp_async_send isn't so
truthful and doesn't even check the return from
ppp_async_push; BTW - probably other layers should
care for transmission errors and re-submiting,

- maybe I'm wrong here, but I think every "layer" should
look (work) similarly here: dev_queue_xmit (or qdisc_run)
thinks it's talking to some independent network device,
which after dev_hard_start_xmit (and dev->hard_start_xmit)
does some transmission; if, instead of this, next
dev_queue_xmits are called with xmit locks held from
previous "devs", then it looks like logical recursion and
locking is really hard to follow (even if it's OK).

> Looking at the stack traces earlier in this thread, it seems to me that 
> even if the PPPoE call was made in a tasklet, this same warning could be 
> generated.

Of course a tasklet by itself isn't a cure, but if
dev_queue_xmit is done from tasklet - only locks got
within this tasklet should be counted.

Thanks for response & best regards,
Jarek P.
