From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 0/3] virtio-net: inline header support
Date: Thu, 04 Oct 2012 14:47:59 +0930
Message-ID: <87r4pe24u0.fsf@rustcorp.com.au>
References: <cover.1348824232.git.mst@redhat.com> <87vces2gxq.fsf@rustcorp.com.au> <87sj9vxbnf.fsf@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sasha Levin <levinsasha928@gmail.com>,
	virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, avi@redhat.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: Anthony Liguori <anthony@codemonkey.ws>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Thomas Lendacky <tahm@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87sj9vxbnf.fsf@codemonkey.ws>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Anthony Liguori <anthony@codemonkey.ws> writes:

> Rusty Russell <rusty@rustcorp.com.au> writes:
>
>> "Michael S. Tsirkin" <mst@redhat.com> writes:
>>
>> There's a reason I haven't done this.  I really, really dislike "my
>> implemention isn't broken" feature bits.  We could have an infinite
>> number of them, for each bug in each device.
>>
>> So my plan was to tie this assumption to the new PCI layout.  And have a
>> stress-testing patch like the one below in the kernel (see my virtio-wip
>> branch for stuff like this).  Turn it on at boot with
>> "virtio_ring.torture" on the kernel commandline.
>>
>> BTW, I've fixed lguest, but my kvm here (Ubuntu precise, kvm-qemu 1.0)
>> is too old.  Building the latest git now...
>>
>> Cheers,
>> Rusty.
>>
>> Subject: virtio: CONFIG_VIRTIO_DEVICE_TORTURE
>>
>> Virtio devices are not supposed to depend on the framing of the scatter-gather
>> lists, but various implementations did.  Safeguard this in future by adding
>> an option to deliberately create perverse descriptors.
>>
>> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
>
> Ignore framing is really a bad idea.  You want backends to enforce
> reasonable framing because guest's shouldn't do silly things with framing.
>
> For instance, with virtio-blk, if you want decent performance, you
> absolutely want to avoid bouncing the data.  If you're using O_DIRECT in
> the host to submit I/O requests, then it's critical that all of the s/g
> elements are aligned to a sector boundary and sized to a sector
> boundary.
>
> Yes, QEMU can handle if that's not the case, but it would be insanely
> stupid for a guest not to do this.  This is the sort of thing that ought
> to be enforced in the specification because a guest cannot perform well
> if it doesn't follow these rules.

Lack of imagination is what got us into trouble in the first place; when
presented with one counter-example, it's useful to look for others.

That's our job, not to dismiss them a "insanely stupid".

For example:
1) Perhaps the guest isn't trying to perform well, it's trying to be a
   tiny bootloader?
2) Perhaps the guest is the direct consumer, and aligning buffers is
   redundant.

> A spec isn't terribly useful if the result is guest drivers that are
> slow.  There's very little to gain by not enforcing rules around framing
> and there's a lot to lose if a guest frames incorrectly.

The guest has the flexibility, and gets to decide.  The spec is not
forcing them to perform badly.

> In the rare case where we want to make a framing change, we should use
> feature bits like Michael is proposing.
>
> In this case, we should simply say that with the feature bit, the vnet
> header can be in the same element as the data but not allow the header
> to be spread across multiple elements.

I'd love to split struct virtio_net_hdr_mrg_rxbuf, so the num_buffers
ends up somewhere else.

The simplest rules are "never" or "always".

Cheers,
Rusty.
PS.  Inserting zero-length buffers is something I'd be prepared to rule
     out, my current patch does it just for yuks...
