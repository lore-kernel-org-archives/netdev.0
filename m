From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: [PATCH v8 3/8] seccomp: add system call filtering using BPF
Date: Fri, 17 Feb 2012 03:00:16 +0100
Message-ID: <f2d1a14c965cea740d688c574c6006bb.squirrel@webmail.greenhost.nl>
References: <1329422549-16407-1-git-send-email-wad@chromium.org>
    <1329422549-16407-3-git-send-email-wad@chromium.org>
    <4F3D61CB.2000301@zytor.com>
    <CABqD9hb3WxKxLZ2GuUrbDM--koW+a3ser5TU8y6+e0sAhOT9dw@mail.gmail.com>
    <4F3D7250.6040504@zytor.com>
    <501858544d264abc6526f2b25a224f2b.squirrel@webmail.greenhost.nl>
    <4F3DAE5D.3080000@zytor.com>
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
In-Reply-To: <4F3DAE5D.3080000@zytor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, February 17, 2012 02:33, H. Peter Anvin wrote:
> On 02/16/2012 04:48 PM, Indan Zupancic wrote:
>> On Thu, February 16, 2012 22:17, H. Peter Anvin wrote:
>>
>> I would go for something like:
>>
>> struct seccomp_data {
>> 	int nr;
>> 	__u32 arg_low[6];
>> 	__u32 arg_high[6];
>> 	__u32 instruction_pointer_low;
>> 	__u32 instruction_pointer_high;
>> 	__u32 __reserved[3];
>> };
>>
>
> Uh, that is the absolutely WORST way to do it - not only are you
> creating two fields, they're not even adjacent.

You want:

struct seccomp_data {
	int nr;
	__u32 __reserved[3];
	__u64 arg[6];
	__u64 instruction_pointer;
};

And I agree it looks a lot nicer.

You can pretend a 64-bit arg will be one field, but it won't be. It will
be always two fields no matter what. Making them adjacent is only good
because seccomp_data won't have to change if 64-bit support is ever added
to BPF.

It looks nicer, but it only makes it harder to know the right offset for
the fields for the 32-bit only BPF programs. You can try to hide reality,
but that won't change it.

>> (Not sure what use the IP is because that doesn't tell anything about how
>> the system call instruction was reached.)
>>
>> The only way to avoid splitting args is to add 64-bit support to BPF.
>> That is probably the best way forwards, but would require breaking the
>> BPF ABI by either adding a 64-bit version directly or adding extra
>> instructions.
>
> Or the compiler or whatever generates the BPF code just is going to have
> to generate two instructions -- just like we always have to handle
> [u]int64_t on 32-bit platforms.  There is no difference here.

Except that if you don't hide the platform differences your compiler
or whatever needs to generate different instructions depending on the
endianess, while it could always generate the same instructions instead.

My impression is that you want to push all extra complexity into the
compiler or whatever instead of making the ABI cross-platform, because
it looks nicer. I don't care that much, but I think you're just pushing
the ugliness around instead of getting rid of it.

Greetings,

Indan
