From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 5/5] skbuff: skb_segment: orphan frags before copying
Date: Tue, 11 Mar 2014 00:30:01 +0200
Message-ID: <20140310223001.GA7218@redhat.com>
References: <1394468807-25980-1-git-send-email-mst@redhat.com>
 <1394468807-25980-6-git-send-email-mst@redhat.com>
 <20140310213404.GB15352@gondor.apana.org.au>
 <20140310215236.GA7052@redhat.com>
 <20140310215640.GA15684@gondor.apana.org.au>
 <20140310220717.GA7150@redhat.com>
 <20140310221223.GA15839@gondor.apana.org.au>
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
In-Reply-To: <20140310221223.GA15839@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 11, 2014 at 06:12:23AM +0800, Herbert Xu wrote:
> On Tue, Mar 11, 2014 at 12:07:17AM +0200, Michael S. Tsirkin wrote:
> > 
> > Once one skb completes the callback is invoked and userspace
> > reuses this buffer for something else.
> > At that point it's too late to do the copy.
> 
> OK, would it be possible to delay the callback until all generated
> skbs are completed?

Hmm this won't be easy since devices can complete them in any order.
See below for some ideas.

> > > IOW if we pass along SKBTX_SHARED_FRAG will it work?
> > 
> > I don't see how would SKBTX_SHARED_FRAG help with this at all.
> > That only works for pages gifted to kernel by e.g. vmsplice
> > that aren't reused by userspace.
> 
> Sorry cut-n-paste error, I meant SKBTX_DEV_ZEROCOPY.
> 
> Cheers,

Ah ok. Well we'd need to reference-count them somehow.
Maybe skb_get and stick the pointer in ubuf callback for the
new skbs, make ubuf callback kfree_skb?
Not sure if that's too much memory ...

I also worry a bit that we'll lose the success flag value which is used
to disable zero copy on OOM errors more aggressively.

How about we do the simple thing as the first step and try to optimize
as a separate patch on top?

> -- 
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
