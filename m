From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] virtio_net: fix PAGE_SIZE > 64k
Date: Tue, 24 Jan 2017 16:10:46 -0500 (EST)
Message-ID: <20170124.161046.824400071485171478.davem@davemloft.net>
References: <20170124221114-mutt-send-email-mst@kernel.org>
        <20170124.155331.1409241818867862249.davem@davemloft.net>
        <20170124225502-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, jasowang@redhat.com,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        john.fastabend@gmail.com
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170124225502-mutt-send-email-mst@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Tue, 24 Jan 2017 23:07:51 +0200

> On Tue, Jan 24, 2017 at 03:53:31PM -0500, David Miller wrote:
>> From: "Michael S. Tsirkin" <mst@redhat.com>
>> Date: Tue, 24 Jan 2017 22:45:37 +0200
>> 
>> > On Tue, Jan 24, 2017 at 03:09:59PM -0500, David Miller wrote:
>> >> From: "Michael S. Tsirkin" <mst@redhat.com>
>> >> Date: Tue, 24 Jan 2017 21:53:13 +0200
>> >> 
>> >> > I didn't realise. Why can't we? I thought that adjust_header is an
>> >> > optional feature that userspace can test for, so no rush.
>> >> 
>> >> No, we want the base set of XDP features to be present in all drivers
>> >> supporting XDP.
>> > 
>> > I see, I didn't realize this. In light of this, is there any
>> > guidance *how much* head room is required to be considered
>> > valid? We already have 12 bytes of headroom.
>> 
>> The idea is to allow programs to implement arbitrary kinds of
>> encapsulation, so we need to be able to allow them to push headers for
>> all kinds of software tunnels, with allowance for a few depths in some
>> extreme cases.
>> 
>> In that light, a nice round power of 2 number such as 256 seems quite
>> reasonable to me.
>> 
>> This seems to be what other XDP implementations in drivers use at the
>> moment as well.
> 
> It bothers me that this becomes a part of userspace ABI.
> Apps will see that everyone does 256 and will assume it,
> we'll never be able to go back.
> 
> This does mean that XDP_PASS will use much more memory
> for small packets and by extension need a higher rmem limit.
> Would all admins be comfortable with this? Why would they want
> to if all their XDP does is DROP?
> Why not teach applications to query the headroom?

This works in the regimen that XDP packets always live in exactly one
page.  That will be needed to mmap the RX ring into userspace, and it
helps make adjust_header trivial as well.

MTU 1500, PAGESIZE >= 4096, so a headroom of 256 is no problem, and
we still have enough tailroom for skb_shared_info should we wrap
the buffer into a real SKB and push it into the stack.

If you are trying to do buffering differently for virtio_net, well...
that's a self inflicted wound as far as I can tell.
