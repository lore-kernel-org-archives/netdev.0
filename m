From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 5/5] skbuff: skb_segment: orphan frags before copying
Date: Mon, 10 Mar 2014 23:52:36 +0200
Message-ID: <20140310215236.GA7052@redhat.com>
References: <1394468807-25980-1-git-send-email-mst@redhat.com>
 <1394468807-25980-6-git-send-email-mst@redhat.com>
 <20140310213404.GB15352@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, jbenc@redhat.com,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Simon Horman <horms@verge.net.au>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	Thomas Graf <tgraf@suug.ch>, Miklos Szeredi <mszeredi@suse.cz>,
	=?us-ascii?B?PT9VVEYtOD9xP1BldGVyPTIwUGFuPTI4PUU2PUJEPTk4PUU1PThEPUFC?=
	 =?us-ascii?B?PUU1PUI5PUIzPTI5Pz0=?= <panweiping3@gmail.com>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140310213404.GB15352@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 11, 2014 at 05:34:05AM +0800, Herbert Xu wrote:
> On Mon, Mar 10, 2014 at 06:29:36PM +0200, Michael S. Tsirkin wrote:
> > skb_segment copies frags around, so we need
> > to copy them carefully to avoid accessing
> > user memory after reporting completion to userspace
> > through a callback.
> > 
> > skb_segment doesn't normally happen on datapath:
> > TSO needs to be disabled - so disabling zero copy
> > in this case does not look like a big deal.
> > 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> 
> Why do we need this patch at all?

The cover letter has more detail:
	skb_segment ... moves frags
	between skbs without orphaning them.
	This causes userspace to assume it's safe to
	reuse the buffer, and receiver gets corrupted data.
	This further might leak information from the
	transmitter on the wire.

if still unclear, pls let me know.


> Contrary to what you said,
> this path is definitely performance-critical since the basis
> of being able to enable GSO by default is that it causes no
> regressions in non-TSO cases.
> 
> Cheers,

Well it's a single non taken branch.
If the branch is taken it's more expensive, but once we
take it once callback is invoked and zero copy is
disabled for future users, so it will be non taken from here on.


> -- 
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
