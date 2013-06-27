From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [netlink] WARNING: at mm/vmalloc.c:1487 __vunmap()
Date: Thu, 27 Jun 2013 01:30:35 -0700
Message-ID: <1372321835.3301.221.camel@edumazet-glaptop>
References: <20130614220119.GA12954@localhost>
	 <20130617200938.GA14567@localhost>
	 <1372250558.3301.194.camel@edumazet-glaptop>
	 <20130627082238.GA6346@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Fengguang Wu <fengguang.wu@intel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130627082238.GA6346@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-06-27 at 10:22 +0200, Pablo Neira Ayuso wrote:
> Hi Eric,
> 
> Thanks for looking into this.
> 
> On Wed, Jun 26, 2013 at 05:42:38AM -0700, Eric Dumazet wrote:
> [...]
> > Nope there are several issues :
> > 
> > 1) bug in netlink_alloc_large_skb() because it doesn't account
> > for sizeof(struct skb_shared_info) overhead and initialization.
> 
> Indeed, I can send a fix for this.
> 
> > 2) Also, skb_clone() on such skb should be forbidden.
> > 
> >    Example, nl_fib_input() does a nskb = skb_clone(skb)
> >
> > If skb is freed before nskb, then nskb wont know skb->head must be freed
> > by vfree()
> > 
> > I don't know...
> > 
> > 3) Do we really need this vmalloc stuff, because it sounds like we are
> > going to add yet another test in fast path (in skb_free_head())
> 
> We want to send atomic rule-set updates via netlink in one single
> batch message to kernel space. Without vmalloc, I can send up to
> ~20000 rule updates in one single batch.
> 
> We considered splitting the updates in smaller batches to make netlink
> happy, but then a process has to own the rule-set base until it has
> finished the update to avoid any interference. However, a broken
> user-space program may (ab)use such ownership to prevents others from
> updating the rule-set.
> 
> > 4) Or we must track all skb_clone() netlink calls to attach a destructor
> > to properly to the vfree()
> 
> Perhaps we can add a new specific function for this, netlink_skb_clone?
> 

You have also to track the kfree_skb() calls done before
you set skb->destructor.

Or set skb->destructor right after netlink_alloc_large_skb()

> I'll be fine to track skb_clone in existing netlink families and
> replace it by such call in case you don't find this solution too
> hackish.

Let see if you can do that, I'll test and review the patches.

I suggest you use build_skb() as in :

static struct sk_buff *netlink_alloc_large_skb(unsigned int size, bool broadcast)
{
        struct sk_buff *skb;
        void *data;

        if (size <= NLMSG_GOODSIZE || broadcast)
                return alloc_skb(size, GFP_KERNEL);

        size = SKB_DATA_ALIGN(size) +
               SKB_DATA_ALIGN(sizeof(struct skb_shared_info));

        data = vmalloc(size);
        if (!data)
                return NULL;
        skb = build_skb(data, size);
        if (!skb)
                vfree(data);
        else
                skb->head_frag = 0;
        return skb;
}
