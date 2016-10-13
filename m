From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: slab corruption with current -git
Date: Thu, 13 Oct 2016 12:49:33 -0700
Message-ID: <CA+55aFynWiz1UWwQVvFrRsVvgcYZ=ctCPou9BL1b9_DOVTqKOQ@mail.gmail.com>
References: <CA+55aFwS1jfnNzU=8CzRyxC79qKrStwmTXYrBHQYcftAg4LT3Q@mail.gmail.com>
 <CA+55aFzcweyWCqq-fRAnJkFB7neKwKsXH=TMcLtRQRs2Wn6XEQ@mail.gmail.com>
 <CA+55aFwhscZcWJVLbq+qUgNaN34VwBxFwUR97ktM-7003PcexQ@mail.gmail.com>
 <20161011.045737.227906000874505402.davem@davemloft.net> <20161013060206.GA310@x4>
 <20161013060659.GB310@x4> <CA+55aFwsUR4-YmOYgJOOO4a2e48M4_tk7YhAo4s5KZQQxUjpZw@mail.gmail.com>
 <20161013062703.GC310@x4>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Christoph Lameter <cl@linux.com>, Jens Axboe <axboe@fb.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Aaron Conole <aconole@redhat.com>,
        David Miller <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        NetFilter <netfilter-devel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Florian Westphal <fw@strlen.de>,
        "Theodore Ts'o" <tytso@mit.edu>
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:33019 "EHLO
        mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751645AbcJMTwk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 15:52:40 -0400
In-Reply-To: <20161013062703.GC310@x4>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 12, 2016 at 11:27 PM, Markus Trippelsdorf
<markus@trippelsdorf.de> wrote:
>
> Yeah.
>
> 105         entry->orig_ops = reg;
> 106         entry->ops      = *reg;
> 107         entry->next     = NULL;

So ipt_register_table() does:

        ret = nf_register_net_hooks(net, ops, hweight32(table->valid_hooks));

and then nf_register_net_hooks() just does

        for (i = 0; i < n; i++) {
                err = nf_register_net_hook(net, &reg[i]);

so if the *reg is uninitialized, it means that it's the 'ops[]' array
that isn't actually really valid in "valid_hooks". Odd. They should
all be initialized by xt_hook_ops_alloc(), no?

That said, xt_hook_ops_alloc() itself is odd. Lookie here, this is the
loop that initializes things:

        for (i = 0, hooknum = 0; i < num_hooks && hook_mask != 0;
             hook_mask >>= 1, ++hooknum) {

and it makes no sense to me how that tests *both* "i < num_hools" and
"hook_mask != 0".

Why? Because

    num_hooks = hweight32(hook_mask);

so it's entirely redundant. num_hooks is already how many bits are on
in hook_mask, so that test is just duplicating the same thing twice
("have we done less than that number of bits" and "do we have any bits
less").

I don't know. There's something odd going on. Regardless, thsi is a
different problem from the nf_register_net_hook() list handling, so
I'll leave it to the networking people. David?

               Linus
