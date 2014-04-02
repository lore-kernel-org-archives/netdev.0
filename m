From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH net-next] sh: add missing fpscr_values
Date: Wed, 2 Apr 2014 12:52:41 +0200
Message-ID: <CAMuHMdVDwXYEy1Y93aU+84nmrbNW6L8W6HXcvGwYVA1NWSVCvw@mail.gmail.com>
References: <1396407244-26771-1-git-send-email-ast@plumgrid.com>
	<CAMuHMdW+Pj_y-eiEhxW5EHtPbnZA1xHJK0K0W_uvwvxKiYrzZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Paul Mundt <lethal@linux-sh.org>,
	Fengguang Wu <fengguang.wu@intel.com>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-Next <linux-next@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdW+Pj_y-eiEhxW5EHtPbnZA1xHJK0K0W_uvwvxKiYrzZg@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 2, 2014 at 9:38 AM, Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> On Wed, Apr 2, 2014 at 4:54 AM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>> GCC on SuperH for the following program:
>> int foo(int i)
>> {
>>         static const void *table[2] = {
>>                 [0] = &&label1,
>>                 [1] = &&label2,
>>         };
>>         goto *table[i & 1];
>>
>>         label1:
>>                 return 1;
>>         label2:
>>                 return 2;
>> }
>> generates code:
>>         mov.l   .L9,r1
>>         mov     #1,r0
>>         rts
>>         lds.l   @r1+,fpscr
>> .L9:
>>         .long   __fpscr_values+4
>>
>> so kernel has to provide body of fpscr_values just like glibc does
>>
>> Fixes: bd4cf0ed331a ("net: filter: rework/optimize internal BPF interpreter's instruction set")
>> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>> Cc: Daniel Borkmann <dborkman@redhat.com>
>> ---
>>
>> kernel modules can hit the same problem, so export it
>>
>>  arch/sh/lib/Makefile       |    2 +-
>>  arch/sh/lib/fpscr_values.c |    4 ++++
>>  2 files changed, 5 insertions(+), 1 deletion(-)
>>  create mode 100644 arch/sh/lib/fpscr_values.c
>>
>> diff --git a/arch/sh/lib/Makefile b/arch/sh/lib/Makefile
>> index 3baff31e58cf..0d0c7ae21cfe 100644
>> --- a/arch/sh/lib/Makefile
>> +++ b/arch/sh/lib/Makefile
>> @@ -8,7 +8,7 @@ lib-y  = delay.o memmove.o memchr.o \
>>  # Extracted from libgcc
>>  obj-y += movmem.o ashldi3.o ashrdi3.o lshrdi3.o \
>>          ashlsi3.o ashrsi3.o ashiftrt.o lshrsi3.o \
>> -        udiv_qrnnd.o
>> +        udiv_qrnnd.o fpscr_values.o
>>
>>  udivsi3-y                      := udivsi3_i4i-Os.o
>>
>> diff --git a/arch/sh/lib/fpscr_values.c b/arch/sh/lib/fpscr_values.c
>> new file mode 100644
>> index 000000000000..58153272aba1
>> --- /dev/null
>> +++ b/arch/sh/lib/fpscr_values.c
>> @@ -0,0 +1,4 @@
>> +#include <linux/module.h>
>> +
>> +long __fpscr_values[2] = { 0L, 0x80000L };
>> +EXPORT_SYMBOL(__fpscr_values);
>
> Pardon my ignorance, but according to
> http://www.sourceware.org/ml/libc-alpha/2003-06/msg00027.html
> __fpscr_values is needed for FPU support only.
>
> The kernel is built with -m4-nofpu. If this option is used, gcc doesn't generate
> the reference to __fpscr_values?
>
> Why do we need symbols for userspace FPU support in the kernel?

Ah, so this comes from these build failures in -next:
http://kisskb.ellerman.id.au/kisskb/buildresult/10875446/
http://kisskb.ellerman.id.au/kisskb/buildresult/10875446/

Indeed, SH2A-targets fail when built with a sh4-linux toolchain, as
sh4-linux-gcc doesn't understand -m2a-nofpu, so it's left out:

arch/sh/Makefile:
cflags-$(CONFIG_CPU_SH2A)               += $(call cc-option,-m2a,) \
                                           $(call cc-option,-m2a-nofpu,)

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
