From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [PATCH] tun: make sure interface usage can not overflow
Date: Tue, 30 Sep 2014 14:03:59 +0200
Message-ID: <1412078639.7155.30.camel@localhost>
References: <20140928232753.GA31180@www.outflux.net>
	 <063D6719AE5E284EB5DD2968C1650D6D1749FC70@AcuExch.aculab.com>
	 <CAGXu5jKL13qdCBet3yqpc3vLYh_LifBACzL+NP8n-A+E8RMZXw@mail.gmail.com>
	 <1412021098.14757.6.camel@localhost>
	 <063D6719AE5E284EB5DD2968C1650D6D174A0C5C@AcuExch.aculab.com>
	 <1412075023.7155.21.camel@localhost>
	 <063D6719AE5E284EB5DD2968C1650D6D174A0ECF@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kees Cook <keescook@chromium.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Tom Herbert <therbert@google.com>,
	Masatake YAMATO <yamato@redhat.com>, Xi Wang <xii@google.com>,
	stephen hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D174A0ECF@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Di, 2014-09-30 at 11:18 +0000, David Laight wrote:
> From: Hannes Frederic 
> > On Di, 2014-09-30 at 08:20 +0000, David Laight wrote:
> > > From: Hannes Frederic
> > > > On Mo, 2014-09-29 at 12:41 -0700, Kees Cook wrote:
> > > > > On Mon, Sep 29, 2014 at 4:04 AM, David Laight <David.Laight@aculab.com> wrote:
> > > > > > From: Kees Cook
> > > > > >> This makes the size argument a const, since it is always populated by
> > > > > >> the caller.
> > > > > >
> > > > > > There is almost no point making parameters 'const.
> > > > > > ('const foo *' makes sense).
> > > > > >
> > > > > >> Additionally double-checks to make sure the copy_from_user
> > > > > >> can never overflow, keeping CONFIG_DEBUG_STRICT_USER_COPY_CHECKS happy:
> > > > > >>
> > > > > >>    In function 'copy_from_user',
> > > > > >>        inlined from '__tun_chr_ioctl' at drivers/net/tun.c:1871:7:
> > > > > >>        ... copy_from_user() buffer size is not provably correct
> > > > > >
> > > > > > If 'ifreq_len' could be too big then you want to error the ioctl, not panic.
> > > > > > If it can't be too big you don't need the check.
> > > > >
> > > > > The ifreq_len comes from the callers, and is the output of "sizeof"
> > > > > which is const. Changing the function parameter to "const" means any
> > > > > changes made in the future where the incoming value isn't const, the
> > > > > compiler will throw a warning.
> > > >
> > > > Hmmm, I think you want something like BUILD_BUG_ON(!
> > > > __builtin_constant_p(var)). const in function argument only ensures that
> > > > the value cannot be modified in the function.
> > >
> > > You'd have to do something in the header file - nothing in the function
> > > body can do that check.
> > 
> > Sure, it should work. You only need to make sure that gcc inlines the
> > function, so the value is constant (it is not enough that gcc knows the
> > value range, one specific constant is needed). So the simplest fix for
> > this is to specify __tun_chr_ioctl as __always_inline. ;)
> 
> You are joking aren't you???

It would propagate the value from the compat and non-compat helper
functions to __tun_chr_ioctl and the __builtin_constant_p checks would
be true in the inlined copy_from/to_user, so no, I was not joking, but
because of my smiley I didn't considered this fix seriously.

> Look at the code.

I did.

> I'd suggest fixing whatever implements CONFIG_DEBUG_STRICT_USER_COPY_CHECKS
> to be less picky.

This might involve gcc changes. E.g. on my gcc I don't get any errors.
But by looking at the code it might be plausible wrong estimations are
being made.

But somehow I really cannot follow the original bug report. Looks like
Kees' __builtin_object_size is broken?

I also checked my tun.i file, I really use gcc __builtin_object_size.

Strange...

Bye,
Hannes
