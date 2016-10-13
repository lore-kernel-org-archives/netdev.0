From: Florian Westphal <fw@strlen.de>
Subject: Re: slab corruption with current -git
Date: Thu, 13 Oct 2016 22:43:14 +0200
Message-ID: <20161013204314.GA32753@breakpoint.cc>
References: <CA+55aFwS1jfnNzU=8CzRyxC79qKrStwmTXYrBHQYcftAg4LT3Q@mail.gmail.com>
 <CA+55aFzcweyWCqq-fRAnJkFB7neKwKsXH=TMcLtRQRs2Wn6XEQ@mail.gmail.com>
 <CA+55aFwhscZcWJVLbq+qUgNaN34VwBxFwUR97ktM-7003PcexQ@mail.gmail.com>
 <20161011.045737.227906000874505402.davem@davemloft.net>
 <20161013060206.GA310@x4>
 <20161013060659.GB310@x4>
 <CA+55aFwsUR4-YmOYgJOOO4a2e48M4_tk7YhAo4s5KZQQxUjpZw@mail.gmail.com>
 <20161013062703.GC310@x4>
 <CA+55aFynWiz1UWwQVvFrRsVvgcYZ=ctCPou9BL1b9_DOVTqKOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>,
        Christoph Lameter <cl@linux.com>, Jens Axboe <axboe@fb.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Aaron Conole <aconole@redhat.com>,
        David Miller <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        NetFilter <netfilter-devel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Florian Westphal <fw@strlen.de>, Theodore Ts'o <tytso@mit.edu>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFynWiz1UWwQVvFrRsVvgcYZ=ctCPou9BL1b9_DOVTqKOQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus Torvalds <torvalds@linux-foundation.org> wrote:
> On Wed, Oct 12, 2016 at 11:27 PM, Markus Trippelsdorf
> <markus@trippelsdorf.de> wrote:
> >
> > Yeah.
> >
> > 105         entry->orig_ops = reg;
> > 106         entry->ops      = *reg;
> > 107         entry->next     = NULL;
> 
> So ipt_register_table() does:
> 
>         ret = nf_register_net_hooks(net, ops, hweight32(table->valid_hooks));
> 
> and then nf_register_net_hooks() just does
> 
>         for (i = 0; i < n; i++) {
>                 err = nf_register_net_hook(net, &reg[i]);
> 
> so if the *reg is uninitialized, it means that it's the 'ops[]' array
> that isn't actually really valid in "valid_hooks". Odd. They should
> all be initialized by xt_hook_ops_alloc(), no?

Its only partially initialized.  Looking at Markus' splat
its complaining about first 16 bytes (list_head), whose contents are indeed
undefined when it gets copied to entry->ops.

For the time being this seems like the most simple "fix", until we
disentangle the hook description (which should be const) from run-time
allocated data.

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index e0aa7c1d0224..fc4977456c30 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -1513,7 +1513,7 @@ xt_hook_ops_alloc(const struct xt_table *table,
		nf_hookfn *fn)
        if (!num_hooks)
		return ERR_PTR(-EINVAL);
 
-       ops = kmalloc(sizeof(*ops) * num_hooks, GFP_KERNEL);
+       ops = kcalloc(num_hooks, sizeof(*ops), GFP_KERNEL);
        if (ops == NULL)
		return ERR_PTR(-ENOMEM);

I'll pass such a patch to Pablo.

> That said, xt_hook_ops_alloc() itself is odd. Lookie here, this is the
> loop that initializes things:
> 
>         for (i = 0, hooknum = 0; i < num_hooks && hook_mask != 0;
>              hook_mask >>= 1, ++hooknum) {
> 
> and it makes no sense to me how that tests *both* "i < num_hools" and
> "hook_mask != 0".

Right, one of these is enough.
