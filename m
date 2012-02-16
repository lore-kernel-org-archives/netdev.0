From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v8 3/8] seccomp: add system call filtering using BPF
Date: Thu, 16 Feb 2012 14:25:49 -0600
Message-ID: <CABqD9hb3WxKxLZ2GuUrbDM--koW+a3ser5TU8y6+e0sAhOT9dw@mail.gmail.com>
References: <1329422549-16407-1-git-send-email-wad@chromium.org>
	<1329422549-16407-3-git-send-email-wad@chromium.org>
	<4F3D61CB.2000301@zytor.com>
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
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <4F3D61CB.2000301@zytor.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 16, 2012 at 2:06 PM, H. Peter Anvin <hpa@zytor.com> wrote:
> On 02/16/2012 12:02 PM, Will Drewry wrote:
>> +
>> +/* Format of the data the BPF program executes over. */
>> +struct seccomp_data {
>> + =A0 =A0 int nr;
>> + =A0 =A0 __u32 __reserved[3];
>> + =A0 =A0 struct {
>> + =A0 =A0 =A0 =A0 =A0 =A0 __u32 =A0 lo;
>> + =A0 =A0 =A0 =A0 =A0 =A0 __u32 =A0 hi;
>> + =A0 =A0 } instruction_pointer;
>> + =A0 =A0 __u32 lo32[6];
>> + =A0 =A0 __u32 hi32[6];
>> +};
>>
>
> This seems more than a bit odd, no?
>
> =A0 =A0 =A0 =A0-hpa

I agree :)  BPF being a 32-bit creature introduced some edge cases.  I
has started with a
    union { u32 args32[6]; u64 args64[6]; }

This was somewhat derailed by CONFIG_COMPAT behavior where
syscall_get_arguments always writes to argument of register width --
not bad, just irritating (since a copy isn't strictly necessary nor
actually done in the patch).  Also, Indan pointed out that while BPF
programs expect constants in the machine-local endian layout, any
consumers would need to change how they accessed the arguments across
big/little endian machines since a load of the low-order bits would
vary.

In a second pass, I attempted to resolve this like aio_abi.h:
   union {
     struct {
        u32 ENDIAN_SWAP(lo32, hi32);
      };
      u64 arg64;
    } args[6];
It wasn't clear that this actually made matters better (though it did
mean syscall_get_arguments() could write directly to arg64).  Using
offsetof() in the user program would be fine, but any offsets set
another way would be invalid.  At that point, I moved to Indan's
proposal to stabilize low order and high order offsets -- what is in
the patch series.  Now a BPF program can reliably index into the low
bits of an argument and into the high bits without endianness changing
the filter program structure.

I don't feel strongly about any given data layout, and this one seems
to balance the 32-bit-ness of BPF and the impact that has on
endianness.  I'm happy to hear alternatives that might be more
aesthetically pleasing :)

cheers!
will
