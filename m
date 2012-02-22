From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: [PATCH v10 05/11] seccomp: add system call filtering using BPF
Date: Thu, 23 Feb 2012 00:46:35 +0100
Message-ID: <60d94ae06f380ff088f6270c3a536ee9.squirrel@webmail.greenhost.nl>
References: <1329845435-2313-1-git-send-email-wad@chromium.org>
    <1329845435-2313-5-git-send-email-wad@chromium.org>
    <38d58caa17befe422065efe5dc451a34.squirrel@webmail.greenhost.nl>
    <1329920626.3258.174.camel@deadeye>
    <CABqD9hYRPQbAY2KejstrutEO_jXU3QgBB9og_ByAaFcXZx4GHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "Ben Hutchings" <bhutchings@solarflare.com>,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
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
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CABqD9hYRPQbAY2KejstrutEO_jXU3QgBB9og_ByAaFcXZx4GHg@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, February 22, 2012 20:47, Will Drewry wrote:
> On Wed, Feb 22, 2012 at 8:23 AM, Ben Hutchings
>> I would have thought the way to make sure the architecture is always
>> checked is to pack it together with the syscall number.

I missed that suggestion, putting the syscall number and arch in one
data field would indeed make it harder to not check the arch.

> If the current patchset used the elf machine only and not the
> AUDIT_ARCH_* that might be possible since e_machine is only 16 bits.

Using AUDIT_ARCH_ has the advantage that it contains the endianness and
width of the arch, which is crucial info for archs that support multiple
modes with the same arch. E.g. MIPS got:

#define AUDIT_ARCH_MIPS         (EM_MIPS)
#define AUDIT_ARCH_MIPSEL       (EM_MIPS|__AUDIT_ARCH_LE)
#define AUDIT_ARCH_MIPS64       (EM_MIPS|__AUDIT_ARCH_64BIT)
#define AUDIT_ARCH_MIPSEL64     (EM_MIPS|__AUDIT_ARCH_64BIT|__AUDIT_ARCH_LE)

So just EM_MIPS isn't enough info.

> However, that would still assume that an arch wouldn't introduce a
> syscall number above 65535 which is most likely not a safe assumption.
>  Am I wrong there?

No, it's not a safe assumption. E.g. look at arm_syscall() in
arch/arm/kernel/traps.c:

"0x9f0000 - 0x9fffff are some more esoteric system calls"

You could check if the filter read the 'arch' field and deny it if it
didn't when it returns though. Or check it in the filter check function.
Wouldn't be the nicest code ever, but it would give the same assurance
as packing it with the syscall number.

Greetings,

Indan


