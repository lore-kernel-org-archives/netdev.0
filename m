From: Willy Tarreau <w@1wt.eu>
Subject: Re: [bisected] kernel panic 2.6.22 -> 2.6.26-rc9+
Date: Wed, 23 Jul 2008 07:06:03 +0200
Message-ID: <20080723050603.GG29189@1wt.eu>
References: <m3d4lisk4i.fsf@maximus.localdomain> <20080713013107.23f060f2.akpm@linux-foundation.org> <m3abgmcb68.fsf@maximus.localdomain> <20080713112230.e86ba9ae.akpm@linux-foundation.org> <m3lk05jvw5.fsf@maximus.localdomain> <20080713145525.51a1ca3a.akpm@linux-foundation.org> <20080723045230.GD29189@1wt.eu> <20080722220056.234af367.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krzysztof Halasa <khc@pm.waw.pl>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Russell King <rmk+lkml@arm.linux.org.uk>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1925 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752389AbYGWFGl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jul 2008 01:06:41 -0400
Content-Disposition: inline
In-Reply-To: <20080722220056.234af367.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 22, 2008 at 10:00:56PM -0700, Andrew Morton wrote:
> On Wed, 23 Jul 2008 06:52:31 +0200 Willy Tarreau <w@1wt.eu> wrote:
> 
> > On Sun, Jul 13, 2008 at 02:55:25PM -0700, Andrew Morton wrote:
> > > On Sun, 13 Jul 2008 23:51:06 +0200 Krzysztof Halasa <khc@pm.waw.pl> wrote:
> > > 
> > > > Andrew Morton <akpm@linux-foundation.org> writes:
> > > > 
> > > > > --- a/include/asm-arm/bitops.h~a
> > > > > +++ a/include/asm-arm/bitops.h
> > > > > @@ -277,9 +277,16 @@ static inline int constant_fls(int x)
> > > > >   * the clz instruction for much better code efficiency.
> > > > >   */
> > > > >  
> > > > > -#define fls(x) \
> > > > > +#define __fls(x) \
> > > > >  	( __builtin_constant_p(x) ? constant_fls(x) : \
> > > > >  	  ({ int __r; asm("clz\t%0, %1" : "=r"(__r) : "r"(x) : "cc"); 32-__r; }) )
> > > > > +
> > > > > +/* Implement fls() in C so that 64-bit args are suitably truncated */
> > > > > +static inline int fls(int x)
> > > > > +{
> > > > > +	return __fls(x);
> > > > > +}
> > > > > +
> > > > 
> > > > Well, I like it more as it fixes all possible places instead of only
> > > > fls64().
> > > > 
> > > > But... can't we just move the #define body into the inline fls(x)?
> > > > Will there be other users of __fls(x)? It seems the
> > > > __builtin_constant_p(x) works for inline functions.
> > > 
> > > Could.  That was a minimal&safe thing.
> > > 
> > > > The above patch fixes the kernel panic, too.
> > > 
> > > OK, thanks.
> > 
> > Andrew,
> > 
> > have you sent your patch to Linus ? I haven't seen it merged yet, and
> > I'd like to get it into -stable too.
> 
> This one?
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> arm's fls() is implemented as a macro, causing it to misbehave when passed
> 64-bit arguments.  Fix.
> 
> Cc: Nickolay Vinogradov <nickolay@protei.ru>
> Tested-by: Krzysztof Halasa <khc@pm.waw.pl>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  include/asm-arm/bitops.h |    9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
> 
> diff -puN include/asm-arm/bitops.h~arm-fix-fls-for-64-bit-arguments include/asm-arm/bitops.h
> --- a/include/asm-arm/bitops.h~arm-fix-fls-for-64-bit-arguments
> +++ a/include/asm-arm/bitops.h
> @@ -277,9 +277,16 @@ static inline int constant_fls(int x)
>   * the clz instruction for much better code efficiency.
>   */
>  
> -#define fls(x) \
> +#define __fls(x) \
>  	( __builtin_constant_p(x) ? constant_fls(x) : \
>  	  ({ int __r; asm("clz\t%0, %1" : "=r"(__r) : "r"(x) : "cc"); 32-__r; }) )
> +
> +/* Implement fls() in C so that 64-bit args are suitably truncated */
> +static inline int fls(int x)
> +{
> +	return __fls(x);
> +}
> +
>  #define ffs(x) ({ unsigned long __t = (x); fls(__t & -__t); })
>  #define __ffs(x) (ffs(x) - 1)
>  #define ffz(x) __ffs( ~(x) )
> _
> 

yes, precisely this one.

> Nope, I'm just kind of sitting on it.  I'll put a stable@kernel.org tag
> on it and send it to Russell I guess.

Perfect, thanks!
Willy

