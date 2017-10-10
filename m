From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCHv4 iproute2 2/2] lib/libnetlink: update rtnl_talk to
 support malloc buff at run time
Date: Tue, 10 Oct 2017 08:41:17 +0200
Message-ID: <20171010064117.ipyarf5ml7fwnzdv@unicorn.suse.cz>
References: <1506605626-1744-1-git-send-email-haliu@redhat.com>
 <1506605626-1744-3-git-send-email-haliu@redhat.com>
 <20171002103708.0572704b@xeon-e3>
 <20171009202525.GR32278@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Phil Sutter <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Hangbin Liu <haliu@redhat.com>, netdev@vger.kernel.org,
        Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40041 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750950AbdJJGlU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Oct 2017 02:41:20 -0400
Content-Disposition: inline
In-Reply-To: <20171009202525.GR32278@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 09, 2017 at 10:25:25PM +0200, Phil Sutter wrote:
> Hi Stephen,
> 
> On Mon, Oct 02, 2017 at 10:37:08AM -0700, Stephen Hemminger wrote:
> > On Thu, 28 Sep 2017 21:33:46 +0800
> > Hangbin Liu <haliu@redhat.com> wrote:
> > 
> > > From: Hangbin Liu <liuhangbin@gmail.com>
> > > 
> > > This is an update for 460c03f3f3cc ("iplink: double the buffer size also in
> > > iplink_get()"). After update, we will not need to double the buffer size
> > > every time when VFs number increased.
> > > 
> > > With call like rtnl_talk(&rth, &req.n, NULL, 0), we can simply remove the
> > > length parameter.
> > > 
> > > With call like rtnl_talk(&rth, nlh, nlh, sizeof(req), I add a new variable
> > > answer to avoid overwrite data in nlh, because it may has more info after
> > > nlh. also this will avoid nlh buffer not enough issue.
> > > 
> > > We need to free answer after using.
> > > 
> > > Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> > > Signed-off-by: Phil Sutter <phil@nwl.cc>
> > > ---
> > 
> > Most of the uses of rtnl_talk() don't need to this peek and dynamic sizing.
> > Can only those places that need that be targeted?
> 
> We could probably do that, by having a buffer on stack in __rtnl_talk()
> which will be used instead of the allocated one if 'answer' is NULL. Or
> maybe even introduce a dedicated API call for the dynamically allocated
> receive buffer. But I really doubt that's feasible: AFAICT, that stack
> buffer still needs to be reasonably sized since the reply might be
> larger than the request (reusing the request buffer would be the most
> simple way to tackle this), also there is support for extack which may
> bloat the response to arbitrary size. Hangbin has shown in his benchmark
> that the overhead of the second syscall is negligible, so why care about
> that and increase code complexity even further?
> 
> Not saying it's not possible, but I just doubt it's worth the effort.

Agreed. Current code is based on the assumption that we can estimate the
maximum reply length in advance and the reason for this series is that
this assumption turned out to be wrong. I'm afraid that if we replace
it by an assumption that we can estimate the maximum reply length for
most requests with only few exceptions, it's only matter of time for us
to be proven wrong again.

Michal Kubecek
