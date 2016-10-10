From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: slab corruption with current -git
Date: Mon, 10 Oct 2016 09:15:10 -0700
Message-ID: <CA+55aFxB2Q8mp36-xRGGxms2Xqegohn=Y5c-N3oYWiknDBEGuw@mail.gmail.com>
References: <CA+55aFzntXuUyL85A68ghS-D-t3VdgKo9-FiqQBG3efW2xns3A@mail.gmail.com>
 <CA+55aFwS1jfnNzU=8CzRyxC79qKrStwmTXYrBHQYcftAg4LT3Q@mail.gmail.com>
 <20161009.235745.860945462339053703.davem@davemloft.net> <20161010.042401.637964142015887598.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Aaron Conole <aconole@redhat.com>, Florian Westphal <fw@strlen.de>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>,
        Jens Axboe <axboe@fb.com>, "Theodore Ts'o" <tytso@mit.edu>,
        Christoph Lameter <cl@linux.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        NetFilter <netfilter-devel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161010.042401.637964142015887598.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 10, 2016 at 1:24 AM, David Miller <davem@davemloft.net> wrote:
>
> So I've been reviewing this patch and it looks fine, but I also want
> to figure out what is actually causing the OOPS and I can't spot it
> yet.

Yeah, I'm not actually sure the old linked list implementation is
buggy - it might just be ugly. I tried to follow the old code, and I
couldn't.

So the patch I sent out was a combination of "that's not how you
should do singly linked lists" and "those special cases make me
worry". In particular, the old code really ended up doing odd things
in the "can't find entry" case, because it would exit the loop with a
non-NULL 'entry' just because the next entry was NULL..

> One possible way to see that oops is to free the head entry of the
> chain without unlinking it.  The next unregister will dereference a
> POISON pointer.
>
> Actually...
>
> The POISON value comes not from a hook entry, but from the array of
> pointers in the per-netns datastructure.
>
> This means that the netns is possibly getting freed up before we
> unregister the netfilter hooks.

That is certainly one possible explanation for it, yes. However, I
didn't think that part had changed, had it?

The other thing I find a bit odd in that new single-linked list code is this:

 - nf_hook_slow():
        ...
        RCU_INIT_POINTER(state->hook_entries, entry);

which makes me worried..  It copies the head entry of the list, and
maybe it will then (later) end up being used stale. I don't know. But
it looks a bit iffy.

              Linus
