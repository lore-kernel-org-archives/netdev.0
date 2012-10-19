From: Willy Tarreau <w@1wt.eu>
Subject: Re: [stable 2.6.32.y PATCH 0/6] net: fixes for cached dsts are never invalidated
Date: Fri, 19 Oct 2012 22:53:00 +0200
Message-ID: <20121019205300.GJ17417@1wt.eu>
References: <20121019195557.GG17417@1wt.eu> <20121019.160104.115897882147794932.davem@davemloft.net> <20121019200318.GH17417@1wt.eu> <20121019.160711.1159467896676133280.davem@davemloft.net> <20121019201430.GI17417@1wt.eu> <20121019202244.GH8315@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, stable@vger.kernel.org,
	netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:33815 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753526Ab2JSUxH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2012 16:53:07 -0400
Content-Disposition: inline
In-Reply-To: <20121019202244.GH8315@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 19, 2012 at 04:22:44PM -0400, Benjamin LaHaise wrote:
> On Fri, Oct 19, 2012 at 10:14:31PM +0200, Willy Tarreau wrote:
> ...
> > So maybe in the end we should just merge d11a4dc18 that Ben found to be
> > the least invasive one fixing the issues, and we'd be in sync with the
> > rest of the stable branches, even if, as you noted a few days ago, it's
> > only a partial fix for the issue.
> > 
> > Ben, what's your opinion on this ? I know it's never fun to do backports
> > and not merge them later, but I trust David more than anyone else on the
> > network part, so if he decided that while incomplete, the patch above
> > was all that was needed for other stable branches, maybe we should just
> > stay on the safe side and do the same ?
> 
> There is a caveat to the minimally invasive fix: doing so will result in 
> cached routes always being lookup up when the check occurs.  This could 
> potentially result in a performance regression from some users.  The 
> tradeoffs here are really murky.

I see. Then users will have the same issue when upgrading from 2.6.32 to 3.0.

OK let's bisect the situation :
  - current 2.6.32 users are facing a routing bug that needs be fixed.

  - 2.6.34 and onwards do not have this bug but are probably affected by
    lower performance due to the minimal fix.

  - if we apply the minimal fix alone, some 2.6.32 users will suddenly
    experience a performance regression (what order of magnitude would
    be nice to estimate).

  - if we apply all the fixes, 2.6.32 will experience the performance
    regression only when the upgrade to newer kernels which don't have
    these fixes.

  - the fixes come with a risk of regression (as usual).


Note that everything is tied to the level of performance regression to
expect from the fix when jumping from current 2.6.32 to next LTS. For
example, if some other improvements in 3.0 compensate for the performance
loss caused by the fix, it might be OK to have the other fixes only in
2.6.32. But if it is an important enough performance drop, would the
following plan be acceptable to you and David ?

  - we merge the minimal fix now in order to get rid of this nasty issue
    and to be in sync with other stable kernels ; a performance regression
    will happen, but users will face it anyway when upgrading.

  - some of us confident enough in the other fixes use them in their
    environment for some time to ensure they don't cause unexpected
    regressions.

  - if past some delay (weeks, months ?) no issue is uncovered, patches
    are proposed for inclusion in more recent branches and we merge them
    into older branches.


An alternative solution could be the following one if the performance
regression is supposed not to be that important :

  - we only merge the minimal patch now to fix the issue and cross fingers
    hoping nobody complains ;

  - if someone complains, we submit him the other patches then merge them
    if they address the regression and do not cause a new one ;

  - depending on the importance of the observed performance regression,
    the patches may or may not be adopted by more recent kernels.

BTW, do you have an idea of how to test the performance drop due to the
patch on a test platform ? I mean, I can inject packets and change routes,
but doing so randomly can prove nothing.

Thanks,
Willy
