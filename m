From: Palmer Dabbelt <palmer@dabbelt.com>
Subject: Re: [PATCH] Remove #ifdef CONFIG_64BIT from all asm-generic/fcntl.h
Date: Wed,  9 Sep 2015 14:08:09 -0700
Message-ID: <1441832902-28993-1-git-send-email-palmer@dabbelt.com>
References: <2644177.lVCYzIBfPW@wuerfel>
Cc: 3chas3@gmail.com
To: arnd@arndb.de
Return-path: <linux-arch-owner@vger.kernel.org>
Cc: hpa@zytor.com
Cc: mingo@redhat.com
Cc: plagnioj@jcrosoft.com
Cc: jikos@kernel.org
Cc: linux-api@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-atm-general@lists.sourceforge.net
Cc: linux-fbdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: tglx@linutronix.de
Cc: tomi.valkeinen@ti.com
Cc: x86@kernel.org
In-Reply-To: <2644177.lVCYzIBfPW@wuerfel>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I cut the RISC-V stuff, but I intend to reply to it later.  As you
said, it's just a different topic.

>>> However, I did see a lot of similar bugs now that you point me to it:
>>>
>>> $  grep -r \\\<CONFIG obj-tmp/usr/include/
>>> obj-tmp/usr/include/asm-generic/fcntl.h:#ifndef CONFIG_64BIT
>>> obj-tmp/usr/include/asm-generic/mman-common.h:#ifdef CONFIG_MMAP_ALLOW_UNINITIALIZED
>>> obj-tmp/usr/include/asm-generic/unistd.h:#ifdef CONFIG_MMU
>>> obj-tmp/usr/include/asm-generic/unistd.h:#endif /* CONFIG_MMU */
>>> obj-tmp/usr/include/linux/atmdev.h:#ifdef CONFIG_COMPAT
>>> obj-tmp/usr/include/linux/elfcore.h:#ifdef CONFIG_BINFMT_ELF_FDPIC
>>> obj-tmp/usr/include/linux/eventpoll.h:#ifdef CONFIG_PM_SLEEP
>>> obj-tmp/usr/include/linux/fb.h:#ifdef CONFIG_FB_BACKLIGHT
>>> obj-tmp/usr/include/linux/flat.h:#ifdef CONFIG_BINFMT_SHARED_FLAT
>>> obj-tmp/usr/include/linux/hw_breakpoint.h:#ifdef CONFIG_HAVE_MIXED_BREAKPOINTS_REGS
>>> obj-tmp/usr/include/linux/pktcdvd.h:#if defined(CONFIG_CDROM_PKTCDVD_WCACHE)
>>> obj-tmp/usr/include/linux/raw.h:#define MAX_RAW_MINORS CONFIG_MAX_RAW_DEVS
>>> obj-tmp/usr/include/asm/ptrace.h:#ifdef CONFIG_CPU_ENDIAN_BE8
>>>
>>> These all have the same problem, and we should fix them, as well as
>>> (probably) adding an automated check to scripts/headers_install.sh.
>>
>> Well, I was going to go fix them all and ran a very similar grep, but
>> I think I got a lot of false-positives.  If I understand correctly,
>> it's allowed to have CONFIG_* when guarded by __KERNEL__ in
>> user-visible headers?
>
> That is right.

It turns out there was actually a header checking script
(scripts/headers_check.pl), and it already had a check for this.  The
check was just disabled because there was "too much noise".  Rather
than putting it in headers_install I've just fixed that script.  I'm
definately lacking in perl powers, so I have no idea if what I've done
is sane.  Specifically: there's a global variable and a line over 80
characters, but since there's a bunch of other violations I figure
it's fine.

>> Now that I've written that, I realize it'd be pretty easy to just use
>> cpp to drop everything inside __KERNEL__ and then look for CONFIG_*.
>
> The lines quoted above are from the output of 'make headers_install',
> which already drops everything inside of __KERNEL__. A lot of them
> probably just need to add that #ifdef, or move the portion of the
> header file to the normal (non-uabi) file.
>
>> If you want, I can try to do that, fix what triggers the check, and
>> re-submit everything together?
>
> That would be great, yes.

OK.  I think this has turned into more of a RFC than a PATCH,
though...  I've just #ifdef'd things for now to reduce the diff size,
though I think it might be cleaner to move some of them to the
non-user headers (ep_take_care_of_epollwakeup(), USE_WCACHING,
MAX_RAW_MINORS).

I'm pretty far out of my depth here, so these should all be carefully
considered, but there's a few that scare me more ("struct
elf_prstatus", "enum by_type_idx", AT_VECTOR_SIZE_ARCH).  I think
there's only one actual bug here (MAP_UNINITIALIZED), the rest just
quiet the checking script.  Each patch has my rationale for what I
did.

Since this touches a whole lot of stuff, I've added a whole bunch of
CCs.
