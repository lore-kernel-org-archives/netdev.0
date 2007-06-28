From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [NET]: gen_estimator: fix locking and timer related bugs [Re: [Bugme-new] [Bug 8668] New: HTB Deadlock]
Date: Thu, 28 Jun 2007 11:13:40 +0200
Message-ID: <20070628091339.GC1618@ff.dom.local>
References: <20070627114521.GA3762@ff.dom.local> <46824D88.1090300@trash.net> <20070627121013.GB3762@ff.dom.local> <468279FC.3070502@trash.net> <46827DB1.3060509@trash.net> <46828179.5030404@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	"bugme-daemon\@kernel-bugs\.osdl\.org"
	<bugme-daemon@kernel-bugs.osdl.org>, ranko@spidernet.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:43431 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762909AbXF1JF1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jun 2007 05:05:27 -0400
Content-Disposition: inline
In-Reply-To: <46828179.5030404@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 27, 2007 at 05:25:45PM +0200, Patrick McHardy wrote:
...
> Additionally there are a few more related problems that seem to be
> relicts from the timer when the estimator was qdisc specific and
> could rely on the rtnl or dev->qdisc_lock:
> 
> - the check whether the list is empty and a timer needs to be started
>   when adding a new estimator doesn't take the lock, so it races
>   against concurrent additions, which can result in the timer beeing
>   added twice or getting reinitialized after being added.
> 
> - the new estimator's next pointer is also set without holding the
>   lock, again racing against concurrent additions with possible
>   list corruption as a result.
> 
> - the timer deletion when killing an estimator is also not under
>   the lock and races against timer arming when adding a new estimator.
> 
> Fix by holding the lock around the entire list addition and initial
> timer arming. Removal is not done explicitly anymore, instead the
> timer function only rearms the timer when there are still estimators
> present.
...
> @@ -202,7 +201,6 @@ void gen_kill_estimator(struct gnet_stats_basic *bstats,
>  	struct gen_estimator *est, **pest;
>  
>  	for (idx=0; idx <= EST_MAX_INTERVAL; idx++) {
> -		int killed = 0;
>  		pest = &elist[idx].list;
>  		while ((est=*pest) != NULL) {

So, maybe this list walking here needs some locking too?

Jarek P.
