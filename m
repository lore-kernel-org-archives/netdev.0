From: =?UTF-8?Q?Sjur_Br=C3=A6ndeland?= <sjurbr@gmail.com>
Subject: Re: [RFC virtio-next 0/4] Introduce CAIF Virtio and reversed Vrings
Date: Mon, 5 Nov 2012 13:12:00 +0100
Message-ID: <CANHm3PgrsTD4uYuXN0AMuZFX794CJmmus4AST=G0+nP1ha3VyQ@mail.gmail.com>
References: <1351723614-4145-1-git-send-email-sjur@brendeland.net>
	<87wqy54vo0.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Linus Walleij <linus.walleij@linaro.org>,
	Ohad Ben-Cohen <ohad@wizery.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	dmitry.tarnyagin@stericsson.com
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87wqy54vo0.fsf@rustcorp.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Rusty,

> So, this adds another host-side virtqueue implementation.
>
> Can we combine them together conveniently?  You pulled out more stuff
> into vring.h which is a start, but it's a bit overloaded.
> Perhaps we should separate the common fields into struct vring, and use
> it to build:
>
>         struct vring_guest {
>                 struct vring vr;
>                 u16 last_used_idx;
>         };
>
>         struct vring_host {
>                 struct vring vr;
>                 u16 last_avail_idx;
>         };
> I haven't looked closely at vhost to see what it wants, but I would
> think we could share more code.

I have played around with the code in vhost.c to explore your idea.
The main issue I run into is that vhost.c is accessing user data while my new
code does not. So I end up with some quirky code testing if the ring lives in
user memory or not.  Another issue is sparse warnings when
accessing user memory.

With your suggested changes I end up sharing about 100 lines of code.
So in sum, I feel this add more complexity than what we gain by sharing.

Below is an initial draft of the re-usable code. I added "is_uaccess" to struct
virtio_ring in order to know if the ring lives in user memory.

Let me know what you think.

[snip]
int virtqueue_add_used(struct vring_host *vr, unsigned int head, int len,
		    struct vring_used_elem  **used)
{
	/* The virtqueue contains a ring of used buffers.  Get a pointer to the
	 * next entry in that used ring. */
	*used = &vr->vring.used->ring[vr->last_used_idx % vr->vring.num];
	if (vr->is_uaccess) {
		if(unlikely(__put_user(head, &(*used)->id))) {
			pr_debug("Failed to write used id");
			return -EFAULT;
		}
		if (unlikely(__put_user(len, &(*used)->len))) {
			pr_debug("Failed to write used len");
			return -EFAULT;
		}
		smp_wmb();
		if (__put_user(vr->last_used_idx + 1,
			       &vr->vring.used->idx)) {
			pr_debug("Failed to increment used idx");
			return -EFAULT;
		}
	} else {
		(*used)->id = head;
		(*used)->len = len;
		smp_wmb();
		vr->vring.used->idx = vr->last_used_idx + 1;
	}
	vr->last_used_idx++;
	return 0;
}

/* Each buffer in the virtqueues is actually a chain of descriptors.  This
 * function returns the next descriptor in the chain,
 * or -1U if we're at the end. */
unsigned virtqueue_next_desc(struct vring_desc *desc)
{
	unsigned int next;

	/* If this descriptor says it doesn't chain, we're done. */
	if (!(desc->flags & VRING_DESC_F_NEXT))
		return -1U;

	/* Check they're not leading us off end of descriptors. */
	next = desc->next;
	/* Make sure compiler knows to grab that: we don't want it changing! */
	/* We will use the result as an index in an array, so most
	 * architectures only need a compiler barrier here. */
	read_barrier_depends();

	return next;
}

static int virtqueue_next_avail_desc(struct vring_host *vr)
{
	int head;
	u16 last_avail_idx;

	/* Check it isn't doing very strange things with descriptor numbers. */
	last_avail_idx = vr->last_avail_idx;
	if (vr->is_uaccess) {
		if (__get_user(vr->avail_idx, &vr->vring.avail->idx)) {
			pr_debug("Failed to access avail idx at %p\n",
				 &vr->vring.avail->idx);
			return -EFAULT;
		}
	} else
		vr->avail_idx = vr->vring.avail->idx;

	if (unlikely((u16)(vr->avail_idx - last_avail_idx) > vr->vring.num)) {
		pr_debug("Guest moved used index from %u to %u",
		       last_avail_idx, vr->avail_idx);
		return -EFAULT;
	}

	/* If there's nothing new since last we looked, return invalid. */
	if (vr->avail_idx == last_avail_idx)
		return vr->vring.num;

	/* Only get avail ring entries after they have been exposed by guest. */
	smp_rmb();

	/* Grab the next descriptor number they're advertising, and increment
	 * the index we've seen. */
	if (vr->is_uaccess) {
		if (unlikely(__get_user(head,
				&vr->vring.avail->ring[last_avail_idx
						       % vr->vring.num]))) {
			pr_debug("Failed to read head: idx %d address %p\n",
				 last_avail_idx,
				 &vr->vring.avail->ring[last_avail_idx %
							vr->vring.num]);
			return -EFAULT;
		}
	} else
		head = vr->vring.avail->ring[last_avail_idx % vr->vring.num];

	/* If their number is silly, that's an error. */
	if (unlikely(head >= vr->vring.num)) {
		pr_debug("Guest says index %u > %u is available",
		       head, vr->vring.num);
		return -EINVAL;
	}

	return head;
}

Thanks,
Sjur
