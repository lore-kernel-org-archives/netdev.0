From: Josh Poimboeuf <jpoimboe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 00/33] Compile-time stack metadata validation
Date: Fri, 22 Jan 2016 14:47:44 -0600
Message-ID: <20160122204744.GI20502@treble.redhat.com>
References: <cover.1453405861.git.jpoimboe@redhat.com>
 <20160122174348.GB29221@canonical.com>
 <20160122191447.GH20502@treble.redhat.com>
 <20160122204034.GA5826@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, live-patching-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Michal Marek <mmarek-AlSwsSmVLrQ@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>,
	Pedro Alves <palves-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Namhyung Kim <namhyung-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Bernd Petrovitsch <bernd-JY8rjfDgnXcb9sJ47jD7nuTv7YV0F9Eg@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	David Vrabel <david.vrabel-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>,
	Borislav Petkov <bp-l3A5Bk7waGM@public.gmane.org>,
	Konrad Rzeszutek Wilk <konrad.wilk-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	Boris Ostrovsky <boris.ostrovsky-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	Jeremy Fitzhardinge <jeremy-TSDbQ3PG+2Y@public.gmane.org>,
	Chris Wright <chrisw-69jw2NvuJkxg9hUCZPvPmw@public.gmane.org>,
	Alok
To: Chris J Arges <chris.j.arges-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-watchdog-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160122204034.GA5826-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-watchdog-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 22, 2016 at 02:40:35PM -0600, Chris J Arges wrote:
> On Fri, Jan 22, 2016 at 01:14:47PM -0600, Josh Poimboeuf wrote:
> > On Fri, Jan 22, 2016 at 11:43:48AM -0600, Chris J Arges wrote:
> > > On Thu, Jan 21, 2016 at 04:49:04PM -0600, Josh Poimboeuf wrote:
> > > > This is v16 of the compile-time stack metadata validation patch set,
> > > > along with proposed fixes for most of the warnings it found.  It's based
> > > > on the tip/master branch.
> > > >
> > > Josh,
> > > 
> > > Looks good, with my config [1] I do still get a few warnings building
> > > linux/linux-next.
> > > 
> > > Here are the warnings:
> > > $ grep ^stacktool build.log | grep -v staging
> > 
> > Thanks for reporting these!
> > 
> > > stacktool: arch/x86/kvm/vmx.o: vmx_handle_external_intr()+0x67: call without frame pointer save/setup
> > 
> > This can be fixed by setting the stack pointer as an output operand for
> > the inline asm call in vmx_handle_external_intr().
> > 
> > Feel free to submit a patch, or I'll get around to it eventually.
> > 
> > > stacktool: fs/reiserfs/namei.o: set_de_name_and_namelen()+0x9e: return without frame pointer restore
> > > stacktool: fs/reiserfs/namei.o: set_de_name_and_namelen()+0x89: duplicate frame pointer save
> > > stacktool: fs/reiserfs/namei.o: set_de_name_and_namelen()+0x8a: duplicate frame pointer setup
> > > stacktool: fs/reiserfs/namei.o: set_de_name_and_namelen()+0x9e: frame pointer state mismatch
> > > stacktool: fs/reiserfs/namei.o: set_de_name_and_namelen()+0x0: frame pointer state mismatch
> > 
> > These are false positives.  Stacktool is confused by the use of a
> > "noreturn" function which it doesn't know about (__reiserfs_panic).
> > 
> > Unfortunately the only solution I currently have for dealing with global
> > noreturn functions is to just hard-code a list of them.  So the short
> > term fix would be to add "__reiserfs_panic" to the global_noreturns list
> > in tools/stacktool/builtin-check.c.
> > 
> > I'm still trying to figure out a better way to deal with this type of
> > issue, as it's a pain to have to keep a hard-coded list of noreturn
> > functions.  Unfortunately that info isn't available in the ELF.
> > 
> 
> Josh,
> Ok I'll hack on the patches above.
> 
> > > stacktool: fs/reiserfs/ibalance.o: .text: unexpected end of section
> > > stacktool: fs/reiserfs/tail_conversion.o: .text: unexpected end of section
> > 
> > For some reason I'm not able to recreate these warnings...  Can you
> > share one of the .o files?
> 
> Binaries are here:
> http://people.canonical.com/~arges/stacktool/

Thanks, looks like the same __reiserfs_panic() noreturn fix for those.

-- 
Josh
--
To unsubscribe from this list: send the line "unsubscribe linux-watchdog" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
