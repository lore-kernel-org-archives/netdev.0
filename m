From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: slab corruption with current -git (was Re: [git pull] vfs pile 1 (splice))
Date: Sun, 9 Oct 2016 19:49:43 -0700
Message-ID: <CA+55aFzntXuUyL85A68ghS-D-t3VdgKo9-FiqQBG3efW2xns3A@mail.gmail.com>
References: <CA+55aFz2U83pG0v12E--nd5c6GZAUpVnT3jHuAwHCFk5XbVX0w@mail.gmail.com>
 <20161010005105.GA18349@breakpoint.cc> <f7tbmytkmtr.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Westphal <fw@strlen.de>, Al Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>,
        Jens Axboe <axboe@fb.com>, "Ted Ts'o" <tytso@mit.edu>,
        Christoph Lameter <cl@linux.com>,
        David Miller <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        NetFilter <netfilter-devel@vger.kernel.org>
To: Aaron Conole <aconole@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <f7tbmytkmtr.fsf@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 9, 2016 at 6:35 PM, Aaron Conole <aconole@redhat.com> wrote:
>
> I was just about to build and test something similar:

So I haven't actually tested that one, but looking at the code, it
really looks very bogus. In fact, that code just looks like crap. It
does *not* do a proper "remove singly linked list entry". It's exactly
the kind of code that I rail against, and that people should never
write.

Any code that can't even traverse a linked list is not worth looking at.

There is one *correct* way to remove an entry from a singly linked
list, and it looks like this:

    struct entry **pp, *p;

    pp = &head;
    while ((p = *pp) != NULL) {
        if (right_entry(p)) {
            *pp = p->next;
            break;
        }
        pp = &p->next;
    }

and that's it. Nothing else. The above code exits the loop with "p"
containing the entry that was removed, or NULL if nothing was. It
can't get any simpler than that, but more importantly, anything more
complicated than that is WRONG.

Seriously, nothing else is acceptable. In particular, any linked list
traversal that makes a special case of the first entry or the last
entry should not be allowed to exist. Note how there is not a single
special case in the above correct code. It JustWorks(tm).

That nf_unregister_net_hook() code has all the signs of exactly that
kind of broken list-handling code: special-casing the head of the
loop, and having the loop condition test both current and that odd
"next to next" pointer etc. It's all very very wrong.

So I really see two options:

 - do that singly-linked list traversal right (and I'm serious:
nothing but the code above can ever be right)

 - don't make up your own list handling code at all, and use the
standard linux list code.

So either e3b37f11e6e4 needs to be reverted, or it needs to be taught
to use real list handling.  If the code doesn't want to use the
regular list.h (either the doubly linked one, or the hlist one), it
needs to at least learn to do list removal right.

               Linus
