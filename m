From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC 0/6] copy aside frags with destructors (was [PATCH
 7/9] net: add skb_orphan_frags to copy aside frags with destructors)
Date: Wed, 9 May 2012 17:56:16 +0300
Message-ID: <20120509145615.GA20399@redhat.com>
References: <cover.1336397823.git.mst@redhat.com>
 <1336569529.25514.109.camel@zakaz.uk.xensource.com>
 <20120509135240.GA19246@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6748 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755249Ab2EIO4S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2012 10:56:18 -0400
Content-Disposition: inline
In-Reply-To: <20120509135240.GA19246@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 09, 2012 at 04:52:40PM +0300, Michael S. Tsirkin wrote:
> On Wed, May 09, 2012 at 02:18:49PM +0100, Ian Campbell wrote:
> > On Mon, 2012-05-07 at 14:53 +0100, Michael S. Tsirkin wrote:
> > > On Fri, May 04, 2012 at 11:51:31AM +0100, Ian Campbell wrote:
> > > > On Fri, 2012-05-04 at 11:03 +0100, Michael S. Tsirkin wrote:
> > > > > On Fri, May 04, 2012 at 02:54:33AM -0400, David Miller wrote:
> > > > > > From: "Michael S. Tsirkin" <mst@redhat.com>
> > > > > > Date: Fri, 4 May 2012 00:10:24 +0300
> > > > > > 
> > > > > > > Hmm we orphan skbs when we loop them back so how about reusing the
> > > > > > > skb->destructor for this?
> > > > > > 
> > > > > > That's one possibility.
> > > 
> > > So originally I thought it would work: destructor would wake the
> > > original owner which would do data copy and modify the fragments.  But
> > > then I unfortunately realized that would be racy: the new owner could be
> > 
> > By "new owner" you mean the owner of some other skb which refernences
> > the same shinfo (so either clone or the original if we currently hold a
> > clone).

Sorry didn't clarify this well enough. We often do something like
the following

	orphan
	set owner

new owner is what is set afterwards.

> > > using the old frags and there appears no way for us to
> > > make sure it doesn't so that we can put the original page.
> > 
> > Right, the key issue is, I think, that cloning etc take an extra dataref
> > on the shinfo but do not take references on the frags. This is obviously
> > sane but does cause the issue above.
> > 
> > > And the same logic applies to modifying the frags at any
> > > other time if the skb is cloned. So it seems we must copy if we
> > > want to clone the skb.
> > 
> > Right. I had been hoping that the frag destructors could avoid this but
> > it seems like this is not going to be the case.
> > 
> > Just as a thought experiment would taking a frag ref on clone help us?
> > (lets assume for now that, iff there are destructors, this is cheaper
> > than the copy). I think this doesn't work -- since although the ref will
> > mean that the page doesn't go away under anyone elses feet after we've
> > orphaned it we will have lost the pointer to the original page by the
> > time that other ref is dropped, so freeing it will be tricky.
> > 
> > So following that train of thought a step further -- would creating a
> > new shinfo entirely on frag orphan buy us anything (and at what cost)?
> > Obviously it an extra allocation -- but we are already allocating N
> > pages of new frag. The others skb's referencing the shared shinfo would
> > still continue to see the old shinfo, pages and refs until they
> > themselves needed to orphan the frags (if they do, they might avoid it).
> 
> So it would address the second problem (cloned skb) but
> not the first one (original owner racing with the first one).

Oh and there's another issue: some code assumes that clones
are always identical. For example tcpdump
might show wrong packet content if the page is modified
while packet gets through networking core, so a malicious
application might confuse anything that relies on
this data to do e.g. security filtering.

I don't know whether anyone cares about tcpdump output
being always correct but it seems nicer to side-step the issue.


> > I think that could work, but I'm not sure it is worth the complexity.
> > Basically all it means that if you are bridging + flooding then you
> > would potentially save some number of a copies depending on the types of
> > devices on each port.
> > 
> > [...]
> > 
> > > Second option is what macvtap zero copy uses and it already
> > > does copy on clone too. So I hacked that to make it support tcp/udp
> > > used by sunrpc.
> > 
> > This does seem like it is the preferable solution.
> > 
> > I haven't read the patches yet, so maybe you already support this, but
> > it would be good to allow the creator of an skb to declare that it
> > doesn't want this behaviour, e.g. because it has some other mechanism
> > for dealing with this copy out for the case where an skb gets held
> > somewhere.
> > 
> > Ian.
> 
> Sure, if we find a way to do that we just don't set ZEROCOPY skb flag.
> 
> So I'll give people a bit more time to review, hope
> you find the time too.
> 
> > > > > > 
> > > > > > But I fear we're about to toss Ian into yet another rabbit hole. :-)
> > > > > > 
> > > > > > Let's try to converge on something quickly as I think integration of
> > > > > > his work has been delayed enough as-is.
> > > 
> > > ...
> > > 
> > > > > It's weekend here, I'll work on a patch like this
> > > > > Sunday.
> > > > 
> > > > Thanks, I was starting to feel my nose twitching and my ears beginning
> > > > to elongate ;-)
> > > > 
> > > > Ian.
> > > 
> > > Here's a first stub at a fix. Basically to be able to modify frags on
> > > the fly we must make sure the skb isn't cloned, so the moment someone
> > > clones the skb we need to trigger the frag copy logic.  And this is
> > > exactly what happens with SKBTX_DEV_ZEROCOPY so it seems to make sense
> > > to reuse that logic.
> > > 
> > > The below patchset replaces patch 7
> > > ([PATCH 7/9] net: add skb_orphan_frags to copy aside frags with destructors)
> > > in Ian's patchset and needs to be applied there.
> > > 
> > > 
> > > Compiled only but I'd like to hear what people think all the same
> > > because it does add a couple of branches on fast path.  On the other
> > > hand this makes it generic so the same logic will be reusable for packet
> > > sockets (which IIRC are currently buggy in the same way as sunrpc) and
> > > for adding zero copy support to tun.
> > > 
> > > Please comment,
> > > Thanks!
> > > 
> > > -- 
> > > MST
> > > 
> > > 
> > > Michael S. Tsirkin (6):
> > >   skbuff: support per-page destructors in copy_ubufs
> > >   skbuff: add an api to orphan frags
> > >   skbuff: convert to skb_orphan_frags
> > >   tun: orphan frags on xmit
> > >   net: orphan frags on receive
> > >   skbuff: set zerocopy flag on frag destructor
> > > 
> > >  drivers/net/tun.c      |    2 ++
> > >  include/linux/skbuff.h |   41 +++++++++++++++++++++++++++++++++++++++++
> > >  net/core/dev.c         |    2 ++
> > >  net/core/skbuff.c      |   43 +++++++++++++++++++++++++------------------
> > >  4 files changed, 70 insertions(+), 18 deletions(-)
> > > 
> > 
