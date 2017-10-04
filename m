From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: multi producer / multi consumer lock-free queue with ptr_ring
Date: Wed, 4 Oct 2017 19:23:18 +0300
Message-ID: <20171004171019-mutt-send-email-mst@kernel.org>
References: <CAHmME9qPYL-wzyX0Q7RG7Uk9kAeWbzNN5=0YrmbniUR2O3rSxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
        Netdev <netdev@vger.kernel.org>,
        Samuel Holland <samuel@sholland.org>,
        WireGuard mailing list <wireguard@lists.zx2c4.com>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAHmME9qPYL-wzyX0Q7RG7Uk9kAeWbzNN5=0YrmbniUR2O3rSxA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 04, 2017 at 01:18:24PM +0200, Jason A. Donenfeld wrote:
> Hey Michael,
> 
> Thanks for your work on ptr_ring.h. I'm interested in using it, but in
> a multi-producer, multi-consumer context. I realize it's been designed
> for a single-producer, single-consumer context, and thus uses a
> spinlock. I'm wondering if you'd be happy to receive patches that
> implement things in a lock-free way, in order to make the data
> structure more broadly usable.
> 
> In case you're curious, this would be used for the multi-core
> algorithms in WireGuard.
> 
> Thanks,
> Jason

Hi!
We'll have to look at the performance and how much code is shared.
Especially resize support might be tricky without a lock.

One interesting consideration is that currently we use spinlocks which
are very expensive but fair when contended.

And lock-free mechanisms are very rarely fair.

Further ring isn't really fair when full in the sense that
you might get the lock first but the result will only
be that you see a full ring and can not add an entry.

So maybe replacing (optionally?) a spinlock with just a trylock and fail
on contention would already speed up things for multi-consumer/producer
without the overhead and complexity of lock-free.

Or tweak spin lock to poll for a bit until going slow path
or until failure.

Or even try a bit lock.

I hope these ideas help.

One area where we definitely could share effort is adding some
micro-benchmarks under tools/. I currently (ab)use
tools/virtio/ringtest.

-- 
MST
