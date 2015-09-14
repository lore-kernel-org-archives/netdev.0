From: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH v2 2/5] seccomp: make underlying bpf ref counted as well
Date: Mon, 14 Sep 2015 11:30:11 -0600
Message-ID: <20150914173011.GE31864@smitten>
References: <1441930862-14347-1-git-send-email-tycho.andersen@canonical.com>
 <1441930862-14347-3-git-send-email-tycho.andersen@canonical.com>
 <55F2D0EC.9090004@iogearbox.net>
 <20150911144400.GI27574@smitten>
 <55F2FB6F.7050708@iogearbox.net>
 <20150911173311.GB7244@smitten>
 <55F31D43.5080001@iogearbox.net>
 <20150914160030.GC31864@smitten>
 <55F6FA6B.1060108@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <55F6FA6B.1060108-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 14, 2015 at 06:48:43PM +0200, Daniel Borkmann wrote:
> On 09/14/2015 06:00 PM, Tycho Andersen wrote:
> >On Fri, Sep 11, 2015 at 08:28:19PM +0200, Daniel Borkmann wrote:
> >>I think due to the given insns restrictions on classic seccomp, this
> >>could work for "most cases" (see below) for the time being until pointer
> >>sanitation is resolved and that seccomp-only restriction from the dump
> >>could be removed,
> >
> >Ok, thanks.
> >
> >>BUT there's one more stone in the road which you still
> >>need to take care of with this whole 'giving classic seccomp-BPF -> eBPF
> >>transforms an fd, dumping and restoring that via bpf(2)' approach:
> >>
> >>If you have JIT enabled on ARM32, and add a classic seccomp-BPF filter,
> >>and dump that via your bpf(2) interface based on the current patches, what
> >>you'll get is not eBPF opcodes but classic (!) BPF opcodes as ARM32 classic
> >>JIT supports compilation of seccomp, since commit 24e737c1ebac ("ARM: net:
> >>add JIT support for loads from struct seccomp_data.").
> >>
> >>So in that case, bpf_prepare_filter() will not call into bpf_migrate_filter()
> >>as there's simply no need for it, because the classic code could already
> >>be JITed there. I guess other archs where JIT support for eBPF in not yet
> >>within near sight might sooner or later support this insn for their classic
> >>JITs, too ...
> >
> >Thanks for pointing this out.
> >
> >What if we legislate that the output of bpf(BPF_PROG_DUMP, ...) is
> >always eBPF? As near as I can tell there is no way to determine if a
> >struct bpf_prog is classic or eBPF, so we'd need to add a bit to
> >indicate whether or not the prog has been converted so that
> >BPF_PROG_DUMP knows when to convert it.
> 
> As I said, you have bpf_prog_was_classic() function to determine exactly
> this (so without your type re-assignment you have a way to distinguish it).

I don't think this is the same thing, though. IIUC, when the classic
jit succeeds, bpf_prog_was_classic() will still return true even
though prog->insnsi points to classic instructions instead of eBPF
ones, and (I think) this situation is impossible to distinguish.
Anyway, it sounds like this doesn't matter, as we have...

> Wouldn't it be much easier to rip this set apart into multiple ones, solving
> one individual thing at a time, f.e. starting out simple and 1) only add
> native eBPF support to seccomp, after that 2) add a method to dump native-only
> eBPF programs for criu, then 3) think about a right interface for classic
> BPF seccomp dumping, etc, etc? Currently, it tries to solve everything at
> once, and with some early assumptions that have non-trivial side-effects.

The primary motivation for this set is your bullet 3, c/r of programs
with classic bpf programs (i.e. what seccomp supports now). Initially,
I thought it was best to try and dump the eBPFs directly, but it seems
there are a lot of complications I wasn't aware of. Perhaps I'll look
at a bpf_prog_store_orig_filter() style approach.

Thanks,

Tycho
