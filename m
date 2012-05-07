From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH RFC 0/6] copy aside frags with destructors (was [PATCH 7/9]
 net: add skb_orphan_frags to copy aside frags with destructors)
Date: Mon, 7 May 2012 16:53:46 +0300
Message-ID: <cover.1336397823.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16895 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756147Ab2EGNxn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2012 09:53:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 04, 2012 at 11:51:31AM +0100, Ian Campbell wrote:
> On Fri, 2012-05-04 at 11:03 +0100, Michael S. Tsirkin wrote:
> > On Fri, May 04, 2012 at 02:54:33AM -0400, David Miller wrote:
> > > From: "Michael S. Tsirkin" <mst@redhat.com>
> > > Date: Fri, 4 May 2012 00:10:24 +0300
> > > 
> > > > Hmm we orphan skbs when we loop them back so how about reusing the
> > > > skb->destructor for this?
> > > 
> > > That's one possibility.

So originally I thought it would work: destructor would wake the
original owner which would do data copy and modify the fragments.  But
then I unfortunately realized that would be racy: the new owner could be
using the old frags and there appears no way for us to
make sure it doesn't so that we can put the original page.
And the same logic applies to modifying the frags at any
other time if the skb is cloned. So it seems we must copy if we
want to clone the skb.

Further, destructor itself can't do the copy because this needs
to allocate memory in atomic context, and destructor
itself can't fail.
For this second problem I see two solutions: either pre-allocate the
copy buffer just in case and track it together with the destructor, or
use an skb flag to make the check for destructors quick (if not
completely free).

Second option is what macvtap zero copy uses and it already
does copy on clone too. So I hacked that to make it support tcp/udp
used by sunrpc.

> > > 
> > > But I fear we're about to toss Ian into yet another rabbit hole. :-)
> > > 
> > > Let's try to converge on something quickly as I think integration of
> > > his work has been delayed enough as-is.

...

> > It's weekend here, I'll work on a patch like this
> > Sunday.
> 
> Thanks, I was starting to feel my nose twitching and my ears beginning
> to elongate ;-)
> 
> Ian.

Here's a first stub at a fix. Basically to be able to modify frags on
the fly we must make sure the skb isn't cloned, so the moment someone
clones the skb we need to trigger the frag copy logic.  And this is
exactly what happens with SKBTX_DEV_ZEROCOPY so it seems to make sense
to reuse that logic.

The below patchset replaces patch 7
([PATCH 7/9] net: add skb_orphan_frags to copy aside frags with destructors)
in Ian's patchset and needs to be applied there.


Compiled only but I'd like to hear what people think all the same
because it does add a couple of branches on fast path.  On the other
hand this makes it generic so the same logic will be reusable for packet
sockets (which IIRC are currently buggy in the same way as sunrpc) and
for adding zero copy support to tun.

Please comment,
Thanks!

-- 
MST


Michael S. Tsirkin (6):
  skbuff: support per-page destructors in copy_ubufs
  skbuff: add an api to orphan frags
  skbuff: convert to skb_orphan_frags
  tun: orphan frags on xmit
  net: orphan frags on receive
  skbuff: set zerocopy flag on frag destructor

 drivers/net/tun.c      |    2 ++
 include/linux/skbuff.h |   41 +++++++++++++++++++++++++++++++++++++++++
 net/core/dev.c         |    2 ++
 net/core/skbuff.c      |   43 +++++++++++++++++++++++++------------------
 4 files changed, 70 insertions(+), 18 deletions(-)

-- 
MST
