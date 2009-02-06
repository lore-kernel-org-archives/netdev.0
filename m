From: David Miller <davem@davemloft.net>
Subject: Re: Deadlock with icmpv6fuzz
Date: Fri, 06 Feb 2009 00:50:34 -0800 (PST)
Message-ID: <20090206.005034.193709323.davem@davemloft.net>
References: <20090205143143.GA18734@alice>
	<adafxisjzel.fsf@cisco.com>
	<20090205234318.GA1929@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, snakebyte@gmx.de, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47663
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752138AbZBFIui (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 03:50:38 -0500
In-Reply-To: <20090205234318.GA1929@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 6 Feb 2009 10:43:18 +1100

> On Thu, Feb 05, 2009 at 02:24:02PM -0800, Roland Dreier wrote:
> >
> > >From a quick scan of the code, it looks as if optlen is never sanity
> > checked in the case of setsockopt(IPV6_FLOWLABEL_MGR), and
> > ipv6_flowlabel_opt() calls into fl_create() with whatever value
> > userspace passes in, which then pretty much does kmalloc(optlen).
> > So if icmpv6fuzz passes some big random value, it can cause this failure.
> > 
> > I don't know what the appropriate limit should be, so no patch, sorry.
> 
> Well it is legal (though unlikely) to pass very long options.
> So the real fix would be to avoid copying the control message
> at all and modify all the code involved to read user pointers
> directly.  Someone with a lot of patience is required for this :)

That's a little bit overboard I think.

We already impose limits for pktoptions specified by the user
directly, so we should impose the same limit for this pktoption
blob sitting after the flowlabel entry.

I'll add the following to net-2.6

--------------------
ipv6: Disallow rediculious flowlabel option sizes.

Just like PKTINFO, limit the options area to 64K.

Based upon report by Eric Sesterhenn and analysis by
Roland Dreier.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/ip6_flowlabel.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index c62dd24..7712578 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -323,17 +323,21 @@ static struct ip6_flowlabel *
 fl_create(struct net *net, struct in6_flowlabel_req *freq, char __user *optval,
 	  int optlen, int *err_p)
 {
-	struct ip6_flowlabel *fl;
+	struct ip6_flowlabel *fl = NULL;
 	int olen;
 	int addr_type;
 	int err;
 
+	olen = optlen - CMSG_ALIGN(sizeof(*freq));
+	err = -EINVAL;
+	if (olen > 64 * 1024)
+		goto done;
+
 	err = -ENOMEM;
 	fl = kzalloc(sizeof(*fl), GFP_KERNEL);
 	if (fl == NULL)
 		goto done;
 
-	olen = optlen - CMSG_ALIGN(sizeof(*freq));
 	if (olen > 0) {
 		struct msghdr msg;
 		struct flowi flowi;
-- 
1.6.1.2.253.ga34a

