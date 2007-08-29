From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: [PATCH] make _minimum_ TCP retransmission timeout configurable
Date: Thu, 30 Aug 2007 10:10:37 +1200
Message-ID: <5640c7e00708291510p778f387w51d50e981ba49a25@mail.gmail.com>
References: <200708292052.NAA21975@tardy.cup.hp.com>
	 <5640c7e00708291432q6acde704od52247647a6b453@mail.gmail.com>
	 <20070829.144656.104048365.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.178]:10353 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755746AbXH2WKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 18:10:39 -0400
Received: by el-out-1112.google.com with SMTP id j27so201665elf
        for <netdev@vger.kernel.org>; Wed, 29 Aug 2007 15:10:38 -0700 (PDT)
In-Reply-To: <20070829.144656.104048365.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/30/07, David Miller <davem@davemloft.net> wrote:
> From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
> Date: Thu, 30 Aug 2007 09:32:38 +1200
>
> > So I'm suspecting that the default should be changed to 1000 to match
> > the RFC which would solve this issue. I note that the RFC is a SHOULD
> > rather than a MUST. I had a quick look around and not sure why Linux
> > overrides the RFC on this one.
>
> Everyone uses this value, even BSD since ancient times.
>
> None of the research folks want to commit to saying a lower value is
> OK, even though it's quite clear that on a local 10 gigabit link a
> minimum value of even 200 is absolutely and positively absurd.
>
Understand what you are saying. That is why I questioned as 200 msecs
makes no sense on a LAN with < 1 msec RTT. So if the current is
ridiculous and 1000 is even more so, why do we use? Just because that
is how TCP is written I'm guessing.

I know that in DCCP CCID3 the RTO is 4 x RTT (from memory - it might
be a slight variation) but we ended up putting a minimum on it as you
also face a problem if it fires too frequently (i.e. link is in
usecs).

I might ask around on research lists and see why this issue has never
been revisited.

Now to the original issue - high RTT links. If that is an issue, and I
believe it would be, then it's probably better to do this on a per
route basis or similar, although then we're becoming a defacto X x rtt
type setup. Rereading the RFC this actually doesn't seem prohibited
and here is the code from DCCP CCID3 that we use:

		/*
		 * Update timeout interval for the nofeedback timer.
		 * We use a configuration option to increase the lower bound.
		 * This can help avoid triggering the nofeedback timer too
		 * often ('spinning') on LANs with small RTTs.
		 */
		hctx->ccid3hctx_t_rto = max_t(u32, 4 * hctx->ccid3hctx_rtt,
						   CONFIG_IP_DCCP_CCID3_RTO *
						   (USEC_PER_SEC/1000));
		/*
		 * Schedule no feedback timer to expire in
		 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
		 */
		t_nfb = max(hctx->ccid3hctx_t_rto, 2 * hctx->ccid3hctx_t_ipi);

		ccid3_pr_debug("%s(%p), Scheduled no feedback timer to "
			       "expire in %lu jiffies (%luus)\n",
			       dccp_role(sk),
			       sk, usecs_to_jiffies(t_nfb), t_nfb);

		sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer,
				   jiffies + usecs_to_jiffies(t_nfb));

Maybe the TCP code could do this also (with a sysctl to turn behaviour
off and on) and then it would save system administrators having to
"tune" the TCP stack if they want this sort of behaviour.

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
