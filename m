From: David Miller <davem@davemloft.net>
Subject: Re: slab corruption with current -git
Date: Mon, 10 Oct 2016 04:24:01 -0400 (EDT)
Message-ID: <20161010.042401.637964142015887598.davem@davemloft.net>
References: <CA+55aFzntXuUyL85A68ghS-D-t3VdgKo9-FiqQBG3efW2xns3A@mail.gmail.com>
        <CA+55aFwS1jfnNzU=8CzRyxC79qKrStwmTXYrBHQYcftAg4LT3Q@mail.gmail.com>
        <20161009.235745.860945462339053703.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aconole@redhat.com, fw@strlen.de, viro@zeniv.linux.org.uk,
        akpm@linux-foundation.org, axboe@fb.com, tytso@mit.edu,
        cl@linux.com, pablo@netfilter.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
        netfilter-devel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161009.235745.860945462339053703.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Sun, 09 Oct 2016 23:57:45 -0400 (EDT)

> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Sun, 9 Oct 2016 20:41:17 -0700
> 
>> Note that the "correct way" of doing list operations also almost
>> inevitably is the shortest way by far, since it gets rid of all the
>> special cases. So the patch looks nice. It gets rid of the magic
>> "nf_set_hooks_head()" thing too, because once you do list following
>> right, the head is no different from any other pointer in the list.
> 
> Perhaps we should have some "slist" primitives added to
> include/linux/list.h but since the comparison differs for each user I
> guess it's hard to abstract in a way that's generic and inlines
> properly.
> 
> I'll start taking a look at your patch and this stuff as well, thanks
> Linus.

So I've been reviewing this patch and it looks fine, but I also want
to figure out what is actually causing the OOPS and I can't spot it
yet.

One possible way to see that oops is to free the head entry of the
chain without unlinking it.  The next unregister will dereference a
POISON pointer.

Actually...

The POISON value comes not from a hook entry, but from the array of
pointers in the per-netns datastructure.

This means that the netns is possibly getting freed up before we
unregister the netfilter hooks.
