From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] NETLINK: Use SKB_MAXORDER to calculate NLMSG_GOODSIZE
Date: Sat, 29 Jan 2005 00:40:22 +0100
Message-ID: <20050128234022.GW31837@postel.suug.ch>
References: <20050128230327.GV31837@postel.suug.ch> <E1CufRB-0000zf-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1CufRB-0000zf-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Herbert Xu <E1CufRB-0000zf-00@gondolin.me.apana.org.au> 2005-01-29 10:22
> Thomas Graf <tgraf@suug.ch> wrote:
> > 
> > The current value doesn't make much sense anymore because
> > skb_shared_info isn't taken into account which means that
> > depending on the architecture NLMSG_GOOSIZE can exceed PAGE_SIZE
> > resulting in a waste of almost a complete page.
> 
> You're quite right.
> 
> > Using SKB_MAXORDER solves this potential leak at the cost of
> > slightly smaller but safer sizes for some architectures.
> 
> At first glance it's not clear which of sk_buff or skb_shared_info
> is bigger.  So it might even end up being bigger :)

skb_shared_info is 160 bytes and sk_buff is 196 bytes on my box (x86)
but that's not the point. We need to take SMP_CACHE_BYTES alignment into
account which tends to be quite big. The original NLMSG_GOODSIZE
results in 3908 on my box and gets pumped up to 4128 by skb_alloc
(ALIGN(...,SMP_CACHE_BYTES) + sizeof(struct skb_shared_info)) having
SMP_CACHE_BYTES at 128. 

> > -#define NLMSG_GOODSIZE (PAGE_SIZE - ((sizeof(struct sk_buff)+0xF)&~0xF))
> > +#define NLMSG_GOODORDER 0
> > +#define NLMSG_GOODSIZE (SKB_MAX_ORDER(0, NLMSG_GOODORDER))
> 
> Are we ever going use NLMSG_GOODORDER for anything? If not why don't
> we go straight to NLMSG_GOODSIZE?

My thought behind it is that it clearly documents that we use order-0
allocation and we can easly bump it up if we need more space but it's
basically just cosmetic.
