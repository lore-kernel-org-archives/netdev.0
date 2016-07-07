From: Alexander Duyck <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Resurrecting due to huge ipoib perf regression - [BUG] skb
 corruption and kernel panic at forwarding with fragmentation
Date: Thu, 7 Jul 2016 15:57:46 -0700
Message-ID: <CAKgT0UccNQxZAisGyZHzVCLAj5BNz4u9ySeL2obxEUFZ9Vpunw@mail.gmail.com>
References: <CAL1RGDV3u4bzuyGkMZGJQOiXje_qVh7AA-2nJMm2J2TR60H72g@mail.gmail.com>
 <CAKgT0UerNfn9Uas34y6_+Fa4ALCcToQvNdbEkH1erVosa=xvXg@mail.gmail.com> <CAL1RGDVgjRcb23jQQqJ4W-dfm8OkiH6n7hktVLX4mo-oUGj4gA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Konstantin Khlebnikov <koct9i-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>,
	Thadeu Lima de Souza Cascardo <cascardo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAL1RGDVgjRcb23jQQqJ4W-dfm8OkiH6n7hktVLX4mo-oUGj4gA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 7, 2016 at 3:01 PM, Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org> wrote:
>>> struct skb_gso_cb {
>>>         int     mac_offset;
>>>         int     encap_level;
>>>         __u16   csum_start;
>>> };
>
>> This is based on an out-dated version of this struct.  The 4.7 RC
>> kernel has a few more fields that were added to support local checksum
>> offload for encapsulated frames.
>
> Thanks for pointing that out.  I hit the perf regression on 4.4.y
> (stable) and looked at the struct there.  I see that latest upstream
> has changed, and I agree that this struct really can't shrink below 10
> bytes.
>
> Since IP needs 20 bytes, GSO needs 10 bytes and IPoIB needs 20 bytes,
> we're 2 bytes over the 48 that are available in cb[].  So this is
> harder to fix than just changing skb_gso_cb and SKB_SGO_CB_OFFSET
> unfortunately.
>
>>> What is the best way to keep the crash fix but not kill IPoIB performance?
>>
>> It seems like what would probably need to happen is to move where the
>> IPoIB address is stored.  I'm not sure the control buffer is really
>> the best place for it since the cb gets overwritten at various levels,
>> and storing 20 bytes makes it hard to avoid bumping up against the
>> size restrictions of the buffer.  Seeing as how the IPoIB hwaddr is
>> generated around the same time we generate the L2 header for the
>> frame, I wonder if you couldn't get away with using a bit of extra skb
>> headroom to store it and then use a offset from the MAC header to
>> access it.  An added bonus would be that with a few tricks with
>> SKB_GSO_CB(skb)->mac_offset you might even be able to set things up so
>> that you copy the hwaddr when you copy the header for each fragment
>> instead of having to go and copy the hwaddr out of the cb and clone it
>> for each frame.
>
> Can we assume there are 20 bytes of skb headroom available?  What if
> we're forwarding an skb received on an Ethernet device?

The space should be there since a standard Ethernet device should be
reserving about 64B for headroom for Rx traffic assuming it is using
something like napi_alloc_skb.  I'm not sure how much you would need
for Infiniband headers and such, but I know the 20B for the address
would at least be there.

> The reason we moved to the cb storage is that in the past, trying to
> hide some data in the actual skb buffer that we don't actually send
> led to some awkward-at-best code.  (As I recall GRO was difficult to
> handle before commit 936d7de3d736 "IPoIB: Stop lying about
> hard_header_len and use skb->cb to stash LL addresses")  But maybe
> there's a third way to handle this other than the old way and the
> skb->cb way.

Well the description for that patch seems to indicate the problem was
the pseudo header length being included in the hard_header_len.  It
seems like other drivers include the length of such headers in
needed_headroom, although usually those types of headers don't get
added until after the devices ndo_start_xmit is called so I am not
sure if there would be any issues with trying to use needed_headroom
to indicate space needed for a pseudo header added in the header
creation call.

- Alex
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
