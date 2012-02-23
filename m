From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: [PATCH v10 05/11] seccomp: add system call filtering using BPF
Date: Thu, 23 Feb 2012 01:25:06 +0100
Message-ID: <bd2dbba59cd4b106014741cf687bf8af.squirrel@webmail.greenhost.nl>
References: <1329845435-2313-1-git-send-email-wad@chromium.org>
    <1329845435-2313-5-git-send-email-wad@chromium.org>
    <38d58caa17befe422065efe5dc451a34.squirrel@webmail.greenhost.nl>
    <CABqD9hYTLNrQKzYiRV6yN-z_mYyfPR=3W1P6nC+VmYmFGE1vQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org, keescook@chromium.org
To: "Will Drewry" <wad@chromium.org>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <CABqD9hYTLNrQKzYiRV6yN-z_mYyfPR=3W1P6nC+VmYmFGE1vQg@mail.gmail.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, February 22, 2012 20:47, Will Drewry wrote:
> On Wed, Feb 22, 2012 at 2:19 AM, Indan Zupancic <indan@nul.nu> wrote:
>> I highly disagree with every filter having to check the mode: Filter=
s that
>> don't check the arch on e.g. x86 are buggy, so they have to check it=
, even
>> if it's a 32-bit or 64-bit only system, the filters can't know that =
and
>> needs to check the arch at every syscall entry. All other info in th=
e data
>> depends on the arch, because of this there isn't much code to share =
between
>> the two archs, so you can as well have one filter for each arch.
>>
>> Alternative approach: Tell the arch at filter install time and only =
run the
>> filters with the same arch as the current system call. If no filters=
 are run,
>> deny the systemcall.
>
> This was roughly how I first implemented compat and non-compat
> support.  It causes some implicit behavior across inheritance that is
> not nice though.

Same implicit behaviour Ben mentioned or something else?

Yeah, that's a bit of a problem. It can be solved within filters, but
it's starting to get more obscure than just checking the arch for every
syscall.

>
>> Advantages:
>>
>> - Filters don't have to check the arch every syscall entry.
>
> This I like.
>
>> - Secure by default. Filters don't have to do anything arch specific=
 to
>> =C2=A0be secure, no surprises possible.
>
> This is partially true, but it is exactly why I hid compat before.
>
>> - If a new arch comes into existence, there is no chance of old filt=
ers
>> =C2=A0becoming buggy and insecure. This is especially true for archs=
 that
>> =C2=A0had only one mode, but added another one later on: Old filters=
 had no
>> =C2=A0need to check the mode at all.
>
> Perhaps.  A buggy filter that works on x86-64 might be exposed on a
> new x32 ABI.  It's hard to predict how audit_arch and the syscall abi
> will develop with new platforms.

It doesn't matter, if the filter assumes there are only two archs possi=
ble
and those two archs need different treatment, then the new arch at best
will only match one of them and it depends on which arch the filter che=
cks
for. E.g. whether it does:

if (arch =3D=3D AUDIT_ARCH_I386)
	...
else /* assume x86_64 */
	...

versus

if (arch =3D=3D AUDIT_ARCH_X86_64)
	...
else /* assume i386 */
	...

>> - For kernels supporting only one arch, the check can be optimised a=
way,
>> =C2=A0by not installing unsupported arch filters at all.
>
> Somewhat.  Without having a dedicated arch helper, you'd have to gues=
s
> that arches only support one or two arches (if compat is supported),
> but I don't know if that is a safe assumption to make.

Well, if you want to optimise all checks away, then you obviously need
arch helpers. Without it, you have to install all filters, even the one=
s
you'll never run.

>> It's more secure, faster and simpler for the filters.
>>
>> If something like this is implemented it's fine to expose the arch i=
nfo
>> in the syscall data too, and have a way to install filters for all a=
rchs,
>> for the few cases where that might be useful, although I can't think=
 of
>> any reason why people would like to do unnecessary work in the filte=
rs.
>
> It seems to just add complexity to support both. I think we'll
> probably end up with it in the filters for better or worse.  Possibly
> JITing will be useful since at least a 32-bit load and je is pretty
> cheap in native instructions.

Yeah, except that you can't easily do that because you don't have direc=
t
access to the arch.

>> All that's needed is an extra argument to the prctl() call. I propos=
e
>> 0 for the current arch, -1 for all archs and anything else to specif=
y
>> the arch. Installing a filter for an unsupported arch could return
>> ENOEXEC.
>
> Without adding a per-arch call, there is no way to know all the
> supported arches at install time.  Current arch, at least, can be
> determined with a call to syscall_get_arch().

True.

> As is, I'm not sure it makes sense to try to reserve two extra input
> types: 0 and -1.  0 would be sane to treat as either a wildcard or
> current because it is unlikely to be used by AUDIT_ARCH_* ever since
> EM_NONE is assigned to 0.  However, I have no such insight into
> whether it will ever be possible to compose 0xffffffff as an
> AUDIT_ARCH_.

That seems impossible.

>> As far as the implementation goes, either have a list per supported =
arch
>> or store the arch per filter and check that before running the filte=
r.
>
> You can't do it per arch without adding even more per-arch
> dependencies.  Keeping them annotated in the same list is the cleares=
t
> way I've seen so far, but it comes with its own burdens.

You could have a list per installed arch, so there is no need to know a=
ll
supported archs, if you don't have the per arch helpers.

I don't see how keeping the arch in the filter itself comes with a burd=
en,
that's what you were basically doing with the compat flag anyway.

But keeping the check within the filter is the simplest solution it see=
ms,
so ignore my objections and just let's live with the extra hassle at th=
e
user space side.

>> What use is the instruction pointer considering it tells nothing abo=
ut
>> the call path?

My fear of exposing the IP is that people will erroneously assume that =
it
says anything about the call path, and hence write insecure security co=
de
that's easily bypassed by just jumping to the right instruction address=
=2E
And if the vDSO is used, the IP will always be the same.

So what use is knowing the IP?

>> Wouldn't it make sense to allow going from mode 2 to 1?
>> After all, the filter could have blocked it if it didn't
>> want to permit it, and mode 1 is more restrictive than
>> mode 2.
>
> Nope - that might allow a downgrade that bypasses write/read
> restrictions.  E.g., a filter could only allow a read to a certain bu=
f
> or of a certain size.  Allowing a downgrade would allow bypassing
> those filters, whether they are the most sane things or not :)

But now you enforce that decision while the filter could make that
choice itself instead. If the filter doesn't allow read() and write(),
I really doubt it would allow prctl().

>> Out of curiosity, did you measure the kernel size differences before=
 and
>> after these patches? Would be sad if sharing it with the networking =
code
>> didn't reduce the actual kernel size.
>
> Oh yeah - it was a serious reduction.  Initially, seccomp_filter.o
> added 8kb by itself.  With the merged seccomp.o, continued code
> trimming (as suggested), and all the SECCOMP_RET_* variations, the
> total kernel growth is 2972 bytes for the same kernel config.  This i=
s
> shared across ~2000 bytes in seccomp.o and ~800 bytes in filter.o.

Looks good, though the 800 extra bytes for filter.o seems high, it
used to be 292 bytes according to your email from January the 30th.
You said the run filter function added 861 bytes, so sharing doesn't
seem to reduce the kernel size any more?

Greetings,

Indan
