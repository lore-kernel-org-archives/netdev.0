From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2] jhash: Deinline jhash, jhash2 and __jhash_nwords
Date: Fri, 17 Jul 2015 15:53:59 -0700
Message-ID: <1437173639.2495.74.camel@perches.com>
References: <1437050416-13295-1-git-send-email-dvlasenk@redhat.com>
	 <CALx6S367jArRC3eKSKsv7gFrgPxyDHWdtvfeO1SmQR91eYxwSw@mail.gmail.com>
	 <20150716.111729.822179499552193763.davem@davemloft.net>
	 <1437074611.2495.39.camel@perches.com>
	 <2035533471.2349.1437140685694.JavaMail.open-xchange@ox1app>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, tom <tom@herbertland.com>,
	herbert <herbert@gondor.apana.org.au>, tgraf <tgraf@suug.ch>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	dvlasenk <dvlasenk@redhat.com>,
	"alexander.h.duyck" <alexander.h.duyck@redhat.com>,
	kadlec <kadlec@blackhole.kfki.hu>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2035533471.2349.1437140685694.JavaMail.open-xchange@ox1app>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-07-17 at 15:44 +0200, Hagen Paul Pfeifer wrote:
> > On July 16, 2015 at 9:23 PM Joe Perches <joe@perches.com> wrote:
> > 
> > It might be useful to have these performance impacting
> > changes guarded by something like CONFIG_CC_OPTIMIZE_FOR_SIZE
> > with another static __always_inline __<func> and a function &
> > EXPORT_SYMBOL or just a static inline so that where code size
> > is critical it's uninlined.
> 
> But keep in mind that jhash, jhash2 and __jhash_nwords are *not*
> one-instruction long functions. We duplicate code over and over resulting
> probably in more cache misses. __always_inline__ is probably too strict
> and a vanilla inline is already for 99% of all distribution builds a
>  __always_inline__, see ARCH_SUPPORTS_OPTIMIZED_INLINING and
> CONFIG_CC_OPTIMIZE_FOR_SIZE.

Hello.

Perhaps I wasn't clear/explicit enough.

I tried to suggest using a single __always_inline like this:

Two #ifdef CONFIG_CC_OPTIMIZE_FOR_SIZE (or some other
CONFIG_FOO) functions, one in a .h for the existing behavior
and another in a .c for more code space compact uses.

jhash.h

static __always_inline u32 __jhash(const void *key, u32 length, u32 initval)
{
	[current jhash implementation...]
}

#ifdef CONFIG_CC_OPTIMIZE_FOR_SIZE
u32 jhash(const void *key, u32 length, u32 initval);
#else
static inline u32 jhash(const void *key, u32 length, u32 initval)
{
	return __jhash(key, length, initval);	
}
#endif

jhash.c:

#ifdef CONFIG_CC_OPTIMIZE_FOR_SIZE
u32 jhash(const void *key, u32 length, u32 initval)
{
	return __jhash(key, length, initval);	
}
EXPORT_SYMBOL(jhash)
#endif

etc...

Perhaps the additional code complexity is not worth it.
