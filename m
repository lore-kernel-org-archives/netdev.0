From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: netlink: Add barrier to netlink_connect for theoretical case
Date: Thu, 24 Sep 2015 20:24:56 -0700
Message-ID: <CA+55aFxSqK1dcuKapCkn+VaN0E1XwxGrz_5WzrJB5Ej52zsn9w@mail.gmail.com>
References: <20150921133415.GA1740@gondor.apana.org.au>
	<20150921182022.GB13263@mtj.duckdns.org>
	<20150922033856.GA7851@gondor.apana.org.au>
	<20150924.121142.870602292135442487.davem@davemloft.net>
	<20150924200510.GE25415@mtj.duckdns.org>
	<20150925014327.GA3725@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tejun Heo <tj@kernel.org>, David Miller <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>,
	Tom Herbert <tom@herbertland.com>, kafai@fb.com,
	kernel-team@fb.com,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>, Scott Feldman <sfeldma@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150925014327.GA3725@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 24, 2015 at 6:43 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Thu, Sep 24, 2015 at 04:05:10PM -0400, Tejun Heo wrote:
>
> +static inline bool netlink_bound(struct netlink_sock *nlk)
> +{
> +       /* Ensure nlk is hashed and visible. */
> +       if (nlk->bound)
> +               smp_rmb();
> +
> +       return nlk->bound;
> +}

The above looks very suspicious.

If "nlk->bound" isn't stable, then you might read 0 the first time,
not do the smp_rmb(), and then read 1 on the second access to
nlk->bound.

In other words, you just ended up returning 1 without actually doing
the mb, so there will be no serialization between the "bound" variable
and reading the portid afterwards.

That makes no sense.

And if nlk->bound *is* stable, then the smp_rmb() doesn't make any
sense that I can see.

So for the code to actually make sense, it should either do:

   int bound = nlk->bound;
   smp_rmb();
   return bound;

which is fine on x86, but might be expensive on other architectures
due to the unconditional rmb.

So you *could* write it with a conditional rmb, but then you need to
use a READ_ONCE(), to make sure that gcc really does the read exactly
once, because at that point the "rmb" no longer keeps gcc from playing
tricks. So

   int bound = READ_ONCE(nlk->bound);
   if (bound)
      smp_rmb();
   return bound;

could also be correct. Sadly, while "smp_rmb()" is a no-op on x86, it
*is* a barrier, so the above conditional smp_rmb() actually sucks on
x86, because I suspect that gcc will create a jump around an empty
asm. So the unconditional rmb is actually simpler better on at least
x86.

But the function as you wrote it does not make sense. When you do a
barrier, you really have to think about where the accesses are.

             Linus
