From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v8 3/8] seccomp: add system call filtering using BPF
Date: Thu, 16 Feb 2012 15:31:08 -0600
Message-ID: <CABqD9hY1_Y_-hZY3jRBvDrJ-cspJR4cJRNR_2zfLFOgWaHHQDw@mail.gmail.com>
References: <1329422549-16407-1-git-send-email-wad@chromium.org>
	<1329422549-16407-3-git-send-email-wad@chromium.org>
	<4F3D61CB.2000301@zytor.com>
	<CABqD9hb3WxKxLZ2GuUrbDM--koW+a3ser5TU8y6+e0sAhOT9dw@mail.gmail.com>
	<4F3D7250.6040504@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, mingo@redhat.com, oleg@redhat.com,
	peterz@infradead.org, rdunlap@xenotime.net, mcgrathr@chromium.org,
	tglx@linutronix.de, luto@mit.edu, eparis@redhat.com,
	serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
	indan@nul.nu, pmoore@redhat.com, akpm@linux-foundation.org,
	corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
	keescook@chromium.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <4F3D7250.6040504@zytor.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 16, 2012 at 3:17 PM, H. Peter Anvin <hpa@zytor.com> wrote:
> On 02/16/2012 12:25 PM, Will Drewry wrote:
>>
>>
>> I agree :) =A0BPF being a 32-bit creature introduced some edge cases=
=2E =A0I
>> has started with a
>> =A0 =A0 union { u32 args32[6]; u64 args64[6]; }
>>
>> This was somewhat derailed by CONFIG_COMPAT behavior where
>> syscall_get_arguments always writes to argument of register width --
>> not bad, just irritating (since a copy isn't strictly necessary nor
>> actually done in the patch). =A0Also, Indan pointed out that while B=
PF
>> programs expect constants in the machine-local endian layout, any
>> consumers would need to change how they accessed the arguments acros=
s
>> big/little endian machines since a load of the low-order bits would
>> vary.
>>
>> In a second pass, I attempted to resolve this like aio_abi.h:
>> =A0 =A0union {
>> =A0 =A0 =A0struct {
>> =A0 =A0 =A0 =A0 u32 ENDIAN_SWAP(lo32, hi32);
>> =A0 =A0 =A0 };
>> =A0 =A0 =A0 u64 arg64;
>> =A0 =A0 } args[6];
>> It wasn't clear that this actually made matters better (though it di=
d
>> mean syscall_get_arguments() could write directly to arg64). =A0Usin=
gs
>>
>> offsetof() in the user program would be fine, but any offsets set
>> another way would be invalid. =A0At that point, I moved to Indan's
>> proposal to stabilize low order and high order offsets -- what is in
>> the patch series. =A0Now a BPF program can reliably index into the l=
ow
>> bits of an argument and into the high bits without endianness changi=
ng
>> the filter program structure.
>>
>> I don't feel strongly about any given data layout, and this one seem=
s
>> to balance the 32-bit-ness of BPF and the impact that has on
>> endianness. =A0I'm happy to hear alternatives that might be more
>> aesthetically pleasing :)
>>
>
> I would have to say I think native endian is probably the sane thing =
still,
> out of several bad alternatives. =A0Certainly splitting the high and =
low
> halves of arguments is insane.

I'll push the bits around and see how well it plays out in sample/test
code.  Right now, the patch never even populates the data itself - it
just returns four bytes at the requested offset on-demand, so
kernel-side it's pretty simple to do it whatever way seems the least
hideous for the ABI.

> The other thing that you really need in addition to system call numbe=
r is
> ABI identifier, since a syscall number may mean different things for
> different entry points. =A0For example, on x86-64 system call number =
4 is
> write() if called via int $0x80 but stat() if called via syscall64. T=
his is
> a local property of the system call, not a global per process.

Looks like Markus just replied to this part.  I can certainly populate
a compat bit if the current approach is overconstrained, but I much
prefer to avoid making every user of seccomp need to know about the
subtleties of the calling conventions.

thanks!
will
