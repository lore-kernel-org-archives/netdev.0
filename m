From: Dmitry Yusupov <dmitry_yus@yahoo.com>
Subject: Re: [PATCH] NETLINK_UESTABLISHED notifier event
Date: Wed, 06 Apr 2005 08:16:42 -0700
Message-ID: <1112800602.9213.27.camel@mylaptop>
References: <E1DJ0YI-0003PR-00@gondolin.me.apana.org.au>
	 <1112766901.7488.16.camel@mylaptop>
	 <20050406060343.GA14059@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050406060343.GA14059@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-04-06 at 16:03 +1000, Herbert Xu wrote:
> On Tue, Apr 05, 2005 at 10:55:01PM -0700, Dmitry Yusupov wrote:
> > 
> > main reason for this is to have clear way to notify netlink user that
> > new socket created and bound.
> 
> Why do you want to exclude sockets that listen to multicast
> messages? They can still do unicast transactions.

this probably makes sense. I didn't do that intentionally, all I wanted
is to have the clean way to initialize control structures in proper time
- NETLINK_UESTABLISHED so it will work with my application. If you want
to extent change for multicast - feel free.

> > one reason is for consistency with sock interface. sk_allocation is
> > equal to GFP_KERNEL by default, so nothing changed. but. in some cases
> > application might require non-blocking kmalloc behavior. one real life
> > example is networking block device used for swap partition. this way any
> > GFP_KERENL allocation on recovery path might lead to deadlock condition.
> 
> Setting of sk_allocation is controlled by the protocol itself.  In this
> case this is af_netlink.c.  As you can see, we never set this to anything
> other than GFP_KERNEL.
> 
> Using sk_allocation will only confuse those who are not familiar with
> netlink into thinking that this can be atomic.

I don't think so. It is not clean enough to call alloc_skb() with hard-
coded vm priority. And it limits netlink in the way I described before.
If we want to defer critical processing to the user-space(like number of
applications includes: iscsi, lvm, multipath, fuse...), this change is
essential. Having GFP_KERNEL hard-coded will lead to deadlock on "down"
calls in some cases. So, we do need this change to make a progress.

> Cheers,
