From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v2] netlink: Replace rhash_portid with bound
Date: Tue, 22 Sep 2015 11:42:33 -0700
Message-ID: <CA+55aFyvPLD5tNsuxFAA4GgOZpamULJe7R90dXf5qSC6aBYzTw@mail.gmail.com>
References: <20150918111650.GA7508@gondor.apana.org.au>
	<20150920.225521.1063980101511317898.davem@davemloft.net>
	<20150921060636.GA30807@gondor.apana.org.au>
	<20150920.231104.525285577747035896.davem@davemloft.net>
	<20150921133415.GA1740@gondor.apana.org.au>
	<20150921182022.GB13263@mtj.duckdns.org>
	<20150922033856.GA7851@gondor.apana.org.au>
	<20150922161056.GB9761@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>, tom@herbertland.com,
	kafai@fb.com, kernel-team@fb.com,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>, Scott Feldman <sfeldma@gmail.com>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150922161056.GB9761@mtj.duckdns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 22, 2015 at 9:10 AM, Tejun Heo <tj@kernel.org> wrote:
>
> That's a pentium pro era errata.  Virtually no working machine is
> affected by that anymore and nobody builds kernel with that option.
> In most cases, store_release and load_acquire are cheaper as they're
> more specific.  On x86, store_release and load_acquire boil down to
> compiler reordering barriers.  You're running in the opposite
> direction.

Well, to be fair, there are lots of machines where acquire/release is
actually quite expensive.

In general, the cheapest barrier there is (apart from the "no barrier
at all" or just "compiler barrier") is "smp_wmb()".  If an
architecture gets that one wrong, the architects were f*cking morons.
It should be a fundamentally cheap operation, since writes are
buffered and it should simply be a buffer barrier.

The acquire/release things are generally fairly cheap on modern
architectures. Not free (except on x86), but fairly low-cost. HOWEVER,
they are not at all free on some older architectures, including 32-bit
ARM.

smp_rmb() should generally be about the same cost as an acquire. It
can go either way.

So *if* the algorithm is amenable to smp_wmb()/smp_rmb() kind of
barriers, that's actually quite possibly better than acquire/release.

smp_mb() is expensive pretty much everywhere.

Looking forward, I suspect long-term acquire/release is what hardware
is going to be "reasonably good at", but as things are right now, you
can't necessarily rely on them being fast.

                   Linus
