From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCHv4 iproute2 2/2] lib/libnetlink: update rtnl_talk to
 support malloc buff at run time
Date: Fri, 13 Oct 2017 12:31:21 +0200
Message-ID: <20171013103121.GI11332@orbyte.nwl.cc>
References: <1506605626-1744-1-git-send-email-haliu@redhat.com>
 <1506605626-1744-3-git-send-email-haliu@redhat.com>
 <20171002103708.0572704b@xeon-e3>
 <20171009202525.GR32278@orbyte.nwl.cc>
 <20171010064117.ipyarf5ml7fwnzdv@unicorn.suse.cz>
 <20171010094743.6ae2baa8@shemminger-XPS-13-9360>
 <20171011111007.GA11332@orbyte.nwl.cc>
 <20171012090706.04c00ab5@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Kubecek <mkubecek@suse.cz>, Hangbin Liu <haliu@redhat.com>,
        netdev@vger.kernel.org, Hangbin Liu <liuhangbin@gmail.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:55538 "EHLO orbyte.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751575AbdJMKb0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 13 Oct 2017 06:31:26 -0400
Content-Disposition: inline
In-Reply-To: <20171012090706.04c00ab5@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 12, 2017 at 09:07:06AM -0700, Stephen Hemminger wrote:
> On Wed, 11 Oct 2017 13:10:07 +0200
> Phil Sutter <phil@nwl.cc> wrote:
> 
> > On Tue, Oct 10, 2017 at 09:47:43AM -0700, Stephen Hemminger wrote:
> > > On Tue, 10 Oct 2017 08:41:17 +0200
> > > Michal Kubecek <mkubecek@suse.cz> wrote:
> > > 
> > > > On Mon, Oct 09, 2017 at 10:25:25PM +0200, Phil Sutter wrote:
> > > > > Hi Stephen,
> > > > > 
> > > > > On Mon, Oct 02, 2017 at 10:37:08AM -0700, Stephen Hemminger wrote:  
> > > > > > On Thu, 28 Sep 2017 21:33:46 +0800
> > > > > > Hangbin Liu <haliu@redhat.com> wrote:
> > > > > >   
> > > > > > > From: Hangbin Liu <liuhangbin@gmail.com>
> > > > > > > 
> > > > > > > This is an update for 460c03f3f3cc ("iplink: double the buffer size also in
> > > > > > > iplink_get()"). After update, we will not need to double the buffer size
> > > > > > > every time when VFs number increased.
> > > > > > > 
> > > > > > > With call like rtnl_talk(&rth, &req.n, NULL, 0), we can simply remove the
> > > > > > > length parameter.
> > > > > > > 
> > > > > > > With call like rtnl_talk(&rth, nlh, nlh, sizeof(req), I add a new variable
> > > > > > > answer to avoid overwrite data in nlh, because it may has more info after
> > > > > > > nlh. also this will avoid nlh buffer not enough issue.
> > > > > > > 
> > > > > > > We need to free answer after using.
> > > > > > > 
> > > > > > > Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> > > > > > > Signed-off-by: Phil Sutter <phil@nwl.cc>
> > > > > > > ---  
> > > > > > 
> > > > > > Most of the uses of rtnl_talk() don't need to this peek and dynamic sizing.
> > > > > > Can only those places that need that be targeted?  
> > > > > 
> > > > > We could probably do that, by having a buffer on stack in __rtnl_talk()
> > > > > which will be used instead of the allocated one if 'answer' is NULL. Or
> > > > > maybe even introduce a dedicated API call for the dynamically allocated
> > > > > receive buffer. But I really doubt that's feasible: AFAICT, that stack
> > > > > buffer still needs to be reasonably sized since the reply might be
> > > > > larger than the request (reusing the request buffer would be the most
> > > > > simple way to tackle this), also there is support for extack which may
> > > > > bloat the response to arbitrary size. Hangbin has shown in his benchmark
> > > > > that the overhead of the second syscall is negligible, so why care about
> > > > > that and increase code complexity even further?
> > > > > 
> > > > > Not saying it's not possible, but I just doubt it's worth the effort.  
> > > > 
> > > > Agreed. Current code is based on the assumption that we can estimate the
> > > > maximum reply length in advance and the reason for this series is that
> > > > this assumption turned out to be wrong. I'm afraid that if we replace
> > > > it by an assumption that we can estimate the maximum reply length for
> > > > most requests with only few exceptions, it's only matter of time for us
> > > > to be proven wrong again.
> > > > 
> > > > Michal Kubecek
> > > > 
> > > 
> > > For query responses, yes the response may be large. But for the common cases of
> > > add address or add route, the response should just be ack or error.
> > 
> > And with extack, error is comprised of the original request plus an
> > arbitrarily sized error message, so we can't just reuse the request
> > buffer and are back to "guessing" the right length again.
> > 
> > To get an idea of what we're talking about, I wrote a simple benchmark
> > which adds 256 * 254 (= 65024) addresses to an interface, then removes
> > them again one by one and measured the time that takes for binaries with
> > and without Hangbin's patches:
> > 
> > OP	Vanilla		Hangbin		Delta
> > --------------------------------------------------------
> > add	real 2m16.244s	real 2m27.964s	+11.72s	(108.6%)
> > 	user 0m15.241s	user 0m17.295s	+2.054s	(113.5%)
> > 	sys  1m40.229s	sys  1m48.239s	+8.01s	(108.0%)
> > 
> > remove	real 1m44.950s	real 1m47.044s	+2.094s	(102.0%)
> > 	user 0m13.899s	user 0m14.723s	+0.824s (105.9%)
> > 	sys  1m30.798s	sys  1m31.938s	+1.140s (101.3%)
> > 
> > So the overhead of the second syscall and dynamic memory allocation is
> > less than 10% overall. Given the short time a single call to 'ip'
> > typically takes, I don't think the difference is noticeable even in
> > highly performance critical applications.
> > 
> > Cheers, Phil
> 
> For a better benchmark, I generated 4 Million routes
> then did: 
> 	# ip ---batch routes.txt

Ah, batch mode. Nice trick!

> OP	Vanilla		Hangbin		Delta
> -----------------------------------------------------
> add	real 1:25.840	1:33.677	+9.13%
> 	user   10.690	   6.078	-56.85%
> 	sys  1:00.920	1:13.109	+20.00%	
> 
> remove	real 2:29.881	2:25.872	-2.67%
> 	user   12.862	   7.942	-38.25%
> 	sys    44.127	  44.633	+1.15%
> 
> 
> So the answer is addition is slower but deletion appears faster?

Yeah, that's funny. Hangbin's tests show the same in his 'ip link show'
test. I can imagine a performance improvement in some situations since
the patches eliminate that memcpy() of the reply buffer in
__rtnl_talk(), but neither 'route add' nor 'route del' trigger that code
path.

> If I rerun the Vanilla test, get about the same times.
> 
> The slowdown won't impact me, but what about large scale users
> like Cumulus.

If they delete routes as often as they add them, things don't look too
bad at least. :)

Cheers, Phil
