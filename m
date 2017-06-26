From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v3 07/11] tty: improve tty_insert_flip_char() fast path
Date: Mon, 26 Jun 2017 15:58:16 +0200
Message-ID: <CAK8P3a32RGDagfymTTG_KhhVkkWJYQdguvLaDUPzJjA7vxXqEw@mail.gmail.com>
References: <20170622171355.267192-1-arnd@arndb.de> <20170622171355.267192-8-arnd@arndb.de>
 <20170623160758.GA19961@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Andrew Morton <akpm@linux-foundation.org>,
        kasan-dev <kasan-dev@googlegroups.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Alexander Potapenko <glider@google.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Michal Marek <mmarek@suse.com>,
        Kees Cook <keescook@chromium.org>,
        Ingo Molnar <mingo@kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>,
        Samuel Thibault <samuel.thibault@ens-lyon.org>,
        Jiri Slaby <jslaby@suse.com>,
        "# 3.4.x" <stable@vger.kernel.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <20170623160758.GA19961@kroah.com>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 23, 2017 at 6:07 PM, Greg Kroah-Hartman
<gregkh@linuxfoundation.org> wrote:
> On Thu, Jun 22, 2017 at 07:13:51PM +0200, Arnd Bergmann wrote:
>> kernelci.org reports a crazy stack usage for the VT code when CONFIG_KASAN
>> is enabled:
>>
>> drivers/tty/vt/keyboard.c: In function 'kbd_keycode':
>> drivers/tty/vt/keyboard.c:1452:1: error: the frame size of 2240 bytes is larger than 2048 bytes [-Werror=frame-larger-than=]
>>
>> The problem is that tty_insert_flip_char() gets inlined many times into
>> kbd_keycode(), and also into other functions, and each copy requires 128
>> bytes for stack redzone to check for a possible out-of-bounds access on
>> the 'ch' and 'flags' arguments that are passed into
>> tty_insert_flip_string_flags as a variable-length string.
>>
>> This introduces a new __tty_insert_flip_char() function for the slow
>> path, which receives the two arguments by value. This completely avoids
>> the problem and the stack usage goes back down to around 100 bytes.
>>
>> Without KASAN, this is also slightly better, as we don't have to
>> spill the arguments to the stack but can simply pass 'ch' and 'flag'
>> in registers, saving a few bytes in .text for each call site.
>>
>> This should be backported to linux-4.0 or later, which first introduced
>> the stack sanitizer in the kernel.
>>
>> Cc: stable@vger.kernel.org
>> Fixes: c420f167db8c ("kasan: enable stack instrumentation")
>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>> ---
>> I already submitted this separately to Greg, but he hasn't replied
>> yet. I assume that it's fine if Andrew picks it up along with the
>> other patches and drops it again in case Greg applies it to linux-next.
>
> I've been traveling in China this week, give me a chance to catch up
> please.

Sorry about the rush, I thought the new version was going to be
uncontroversial.

Having sent a broken patch (unused variable unless tty patch 2/2 is
applied, but that wasn't part of this series) certainly didn't make me
look any better :(

> And no, I don't like this patch either, I think kasan needs to be fixed
> here, not work around it in odd ways in code that is completly
> acceptable to "sane" compilers.  But give me a week to catch up on my
> pending stuff first...

I have done some more research, and in particular found out more about
what the compiler does, and why it shows up with some compilers
but not others for this particular file:

* when CONFIG_OPTIMIZE_INLINING is set, gcc-5 and higher decide
  to inline put_queue() in keyboard.c, regardless of architecture. gcc-4.9
  does not do this, and without CONFIG_OPTIMIZE_INLINING,
  put_queue() remains out of line for all versions of gcc. clang-3.9 always
  inlines put_queue(), regardless of CONFIG_OPTIMIZE_INLINING.

* with -fsanitize=kernel-address enabled (regardless of asan-stack), both
  clang and gcc give each local variable in an inline function a separate
  stack address when it gets passed by reference. Clang normally tries
  to overlap the addresses (without kasan), gcc apparently does not.

* With asan-stack=1, gcc uses at least 64 bytes per such variable
  (two times ASAN_RED_ZONE_SIZE), while clang only uses 16 bytes
  (2 * (1<<kDefaultShadowScale)). With asan-stack=0, they do not
  use any more space than with kasan completely disabled
  (no -fsanitize=kernel-address).

Can you say which behavior you find 'sane' or 'not sane' here,
specifically? Maybe we can make future gcc releases use a
smaller redzone like clang does.

If we find a way to improve gcc so it uses less stack here, we still
have a problem with existing compilers still producing dangerously
high stack usage, as well as annoying warnings for an allmodconfig
build as soon as we start warning about this again.

       Arnd
