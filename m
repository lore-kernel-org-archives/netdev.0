From: Andi Kleen <ak@suse.de>
Subject: Re: Tigon3 5701 PCI-X recv performance problem
Date: Wed, 8 Oct 2003 22:22:48 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031008202248.GA15611@oldwotan.suse.de>
References: <3F844578.40306@sgi.com> <20031008101046.376abc3b.davem@redhat.com> <3F8455BE.8080300@sgi.com> <20031008183742.GA24822@wotan.suse.de> <20031008122223.1ba5ac79.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, modica@sgi.com, johnip@sgi.com,
        netdev@oss.sgi.com, jgarzik@pobox.com, jes@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031008122223.1ba5ac79.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> But I don't like any of these solutions (and I know Linus will never
> accept a set of changes that puts netdev_get_unaligned() macro usage
> all over the entire networking layer).  Instead, we should do what
> you proposed long ago.  Seperating the protocol headers from the
> packet data.  Then we need only align the protocol headers.

I agree that it would be the best solution, but isn't it a bit late
in 2.6 now for that? Sounds more like a great 2.7.0 project.

It's not that it's a new problem - we had this since the Alpha port
and it hasn't gotten more urgent suddenly.

For 2.6 short term probably some bandaid like the CONFIG_UNALIGNMENT_COSTLY 
and doing driver copies is better.

> 
> In fact, I can suggest a very efficient implementation:
> 
> 1) Driver allocates paged SKBs.  There is ~128 bytes of skb->data
>    buffer area, and pages are chopped up into MTU'ish sized chunks
>    and hung onto SKBs in the frag list.

Hmm - you mean it allocates a full page and does suballocation by itself?

The suballocation would need to be per CPU to be SMP efficient I guess,
which would complicate it.

Another drawback that the page allocators per CPU allocator is not as
strong as slabs, so it may perform not as good.

And it would require the skb driver accessible destructor that was resisted
against for so long to manage the suballocation lists ;-)

But with such a destructor you would actually not need to do own allocation,
because you could just convert the memory areas returned by slab to
(struct page *, offset) 

-Andi
