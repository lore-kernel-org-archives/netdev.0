From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: [PATCH v8 3/8] seccomp: add system call filtering using BPF
Date: Fri, 17 Feb 2012 01:48:08 +0100
Message-ID: <501858544d264abc6526f2b25a224f2b.squirrel@webmail.greenhost.nl>
References: <1329422549-16407-1-git-send-email-wad@chromium.org>
    <1329422549-16407-3-git-send-email-wad@chromium.org>
    <4F3D61CB.2000301@zytor.com>
    <CABqD9hb3WxKxLZ2GuUrbDM--koW+a3ser5TU8y6+e0sAhOT9dw@mail.gmail.com>
    <4F3D7250.6040504@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain;charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "Will Drewry" <wad@chromium.org>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, davem@davemloft.net,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
	luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org, keescook@chromium.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F3D7250.6040504@zytor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, February 16, 2012 22:17, H. Peter Anvin wrote:
> On 02/16/2012 12:25 PM, Will Drewry wrote:
>>
>> I agree :)  BPF being a 32-bit creature introduced some edge cases.  I
>> has started with a
>>      union { u32 args32[6]; u64 args64[6]; }
>>
>> This was somewhat derailed by CONFIG_COMPAT behavior where
>> syscall_get_arguments always writes to argument of register width --
>> not bad, just irritating (since a copy isn't strictly necessary nor
>> actually done in the patch).  Also, Indan pointed out that while BPF
>> programs expect constants in the machine-local endian layout, any
>> consumers would need to change how they accessed the arguments across
>> big/little endian machines since a load of the low-order bits would
>> vary.
>>
>> In a second pass, I attempted to resolve this like aio_abi.h:
>>     union {
>>       struct {
>>          u32 ENDIAN_SWAP(lo32, hi32);
>>        };
>>        u64 arg64;
>>      } args[6];
>> It wasn't clear that this actually made matters better (though it did
>> mean syscall_get_arguments() could write directly to arg64).  Usings
>> offsetof() in the user program would be fine, but any offsets set
>> another way would be invalid.  At that point, I moved to Indan's
>> proposal to stabilize low order and high order offsets -- what is in
>> the patch series.  Now a BPF program can reliably index into the low
>> bits of an argument and into the high bits without endianness changing
>> the filter program structure.
>>
>> I don't feel strongly about any given data layout, and this one seems
>> to balance the 32-bit-ness of BPF and the impact that has on
>> endianness.  I'm happy to hear alternatives that might be more
>> aesthetically pleasing :)
>>
>
> I would have to say I think native endian is probably the sane thing
> still, out of several bad alternatives.  Certainly splitting the high
> and low halves of arguments is insane.

Yes it is. But it can't be avoided because BPF programs are always 32-bit.
So they have to access the high and low halves separately, one way or the
other, even on 64-bit machines. With that in mind splitting up the halves
explicitly seems the best way.

I would go for something like:

struct seccomp_data {
	int nr;
	__u32 arg_low[6];
	__u32 arg_high[6];
	__u32 instruction_pointer_low;
	__u32 instruction_pointer_high;
	__u32 __reserved[3];
};

(Not sure what use the IP is because that doesn't tell anything about how
the system call instruction was reached.)

The only way to avoid splitting args is to add 64-bit support to BPF.
That is probably the best way forwards, but would require breaking the
BPF ABI by either adding a 64-bit version directly or adding extra
instructions.

This mismatch between 32-bit BPF programs and 64-bit machines is the main
reason why I'm not perfectly happy with BPF for syscall filtering. It gets
the job done, but it's not great.

> The other thing that you really need in addition to system call number
> is ABI identifier, since a syscall number may mean different things for
> different entry points.  For example, on x86-64 system call number 4 is
> write() if called via int $0x80 but stat() if called via syscall64.
> This is a local property of the system call, not a global per process.

The problem of doing this is that you then force every filter to check for
the path and do something path specific. The filters that don't do this
check will be buggy. So the best way is really to install filters per mode
and call the right filter. If filters are installed but not for the current
path, the task should be killed.

prctl() should take one more argument which says for which mode the filter
will be installed for, with 0 for the current mode.

But pushing that info into the filters themselves is not a good idea.

Greetings,

Indan
