From: Dmitry Yusupov <dmitry_yus@yahoo.com>
Subject: Re: [PATCH] NETLINK_UESTABLISHED notifier event
Date: Wed, 06 Apr 2005 15:26:25 -0700
Message-ID: <1112826385.16753.99.camel@beastie>
References: <E1DJ0YI-0003PR-00@gondolin.me.apana.org.au>
	 <42540CF3.7070501@cs.wisc.edu> <20050406212906.GA24775@gondor.apana.org.au>
	 <1112823442.16753.68.camel@beastie>
	 <20050406220417.GA4443@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Mike Christie <michaelc@cs.wisc.edu>, netdev@oss.sgi.com,
        davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050406220417.GA4443@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-04-07 at 08:04 +1000, Herbert Xu wrote:
> On Wed, Apr 06, 2005 at 02:37:21PM -0700, Dmitry Yusupov wrote:
> >
> > > In that case it's not enough to just use sk_allocation here.
> > > You'll need a way to actually set it to GFP_ATOMIC.
> > 
> > That's why in my patch I provided NETLINK_UESTABLISHED event. It is a
> > right way and time to set sk->sk_allocation to GFP_ATOMIC for newly
> > established netlink connection. imho.
> 
> Right.  In that case I think you're going about this the wrong way.
> It's unmanageable to have some external kernel module fiddle with
> netlink's sk_allocation upon the receipt of a notification.
>
> If you really want to do this, do it as a setsockopt.  It's the owner
> of the socket that wants the GFP_ATOMIC, not anybody else.

I see. yes. either way is OK for me. yours is cleaner. We probably
should provide new optname for netlink proto.

> However, I'd like to know more about how open-iscsi uses this.  In
> particular, what are these messages and what do you do when the
> GFP_ATOMIC alloc_skb fails?

Messages from kernel are asynchronous and there are no alloc_skb on "up"
calls. It is "mempooled out" on interface level. (see Open-iSCSI
interface). Messages to kernel requires copy_from_user to newly
allocated skb, here is where we need sk_allocation bit set. Those
messages are synchronous from daemon perspective. If "down" call fails,
we will re-try later or take some other management action. We assuming
that later OOM-killer will free some memory for us and atomic allocation
will succeed eventually.

Dmitry
