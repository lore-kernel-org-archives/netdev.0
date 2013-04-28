From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH v2] x86: make DR*_RESERVED unsigned long
Date: Sun, 28 Apr 2013 02:58:16 +0200
Message-ID: <20130428005814.GB10354@somewhere>
References: <CA+55aFwpLu0qNms=hkQr43yqD0K9DgESNm91OEWKT1ZuT8MU6Q@mail.gmail.com>
 <20130424072630.GB1780@gmail.com>
 <20130424170702.GA1867@redhat.com>
 <5178282D.9030902@zytor.com>
 <20130425144818.GA25921@redhat.com>
 <20130426163802.GA30351@redhat.com>
 <517AAED5.7040400@zytor.com>
 <20130426171526.GA30875@redhat.com>
 <20130427144537.GA24256@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	Theodore Ts'o <tytso@mit.edu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	the arch/x86 maintainers <x86@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <linux-ext4-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130427144537.GA24256@redhat.com>
Sender: linux-ext4-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 27, 2013 at 04:45:37PM +0200, Oleg Nesterov wrote:
> On 04/26, Oleg Nesterov wrote:
> 
> > On 04/26, H. Peter Anvin wrote:
> > >
> > > On 04/26/2013 09:38 AM, Oleg Nesterov wrote:
> > > >
> > > > 	- do_debug:
> > > >
> > > > 		dr6 &= ~DR6_RESERVED;
> > > >
> > > > 	  this also wrongly clears 32-63 bits. Fortunately these
> > > > 	  bits are reserved and must be zero.
> > >
> > > I don't think this is wrongly at all.
> >
> > OK, I meant that it also clears the bits that are not specified in
> > DR6_RESERVED mask.
> >
> > > The whole point is to mask out
> > > the bits that the handler doesn't want to deal with, so masking out the
> > > reserved bits [63:32] seems reasonable to me.
> >
> > Then we should do
> >
> > 	- #define DR6_RESERVED    0xFFFF0FF0
> > 	+ #define DR6_RESERVED    0xFFFFFFFFFFFF0FF0
> >
> > ?
> >
> > or what? (just in case, I will happily agree with "do nothing" ;)
> 
> Or we can do the s/reserved/mask/ change and avoid any "unexpected"
> effect of "long &= ~int". This allso allows to kill ifdef(__i386__).
> 
> But this is include/uapi, I do not know if I can simply remove the
> old define's.
> 
> In short: whatever you prefer, including "leave it alone".
> 
> Oleg.
> 
> diff --git a/arch/x86/include/uapi/asm/debugreg.h b/arch/x86/include/uapi/asm/debugreg.h
> index 3c0874d..2678b23 100644
> --- a/arch/x86/include/uapi/asm/debugreg.h
> +++ b/arch/x86/include/uapi/asm/debugreg.h
> @@ -14,8 +14,7 @@
>     which debugging register was responsible for the trap.  The other bits
>     are either reserved or not of interest to us. */
>  
> -/* Define reserved bits in DR6 which are always set to 1 */
> -#define DR6_RESERVED	(0xFFFF0FF0)
> +#define DR6_MASK	(0xF00FU)	/* Everything else is reserved */

I'm personally fine either with that or with Peter's suggestion to do:

-#define DR6_RESERVED (0xFFFF0FF0)
+#define DR6_RESERVED (~0xF00FUL)

If this should stay stable UAPI, we probably want Peter's solution. Otherwise
I really don't mind.

Thanks.
