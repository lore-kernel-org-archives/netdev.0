From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v3 07/11] tty: improve tty_insert_flip_char() fast path
Date: Tue, 27 Jun 2017 22:43:55 +0200
Message-ID: <CAK8P3a0VFdK6TqXVfnnZ3JVMNW8-4VfDeWAwfgsNCdno_8uJgA@mail.gmail.com>
References: <20170622171355.267192-1-arnd@arndb.de> <20170622171355.267192-8-arnd@arndb.de>
 <20170623160758.GA19961@kroah.com> <CAK8P3a32RGDagfymTTG_KhhVkkWJYQdguvLaDUPzJjA7vxXqEw@mail.gmail.com>
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
In-Reply-To: <CAK8P3a32RGDagfymTTG_KhhVkkWJYQdguvLaDUPzJjA7vxXqEw@mail.gmail.com>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 26, 2017 at 3:58 PM, Arnd Bergmann <arnd@arndb.de> wrote:

> * With asan-stack=1, gcc uses at least 64 bytes per such variable
>   (two times ASAN_RED_ZONE_SIZE), while clang only uses 16 bytes
>   (2 * (1<<kDefaultShadowScale)). With asan-stack=0, they do not
>   use any more space than with kasan completely disabled
>   (no -fsanitize=kernel-address).

I asked around the Linaro toolchain team today, and arrived at this commit
in llvm: https://github.com/llvm-mirror/llvm/commit/daa1bf3b74054

Prior to this, the llvm behavior was the same as gcc, using 64 bytes
for each small (<= 16 byte) variable instead of just 16 or 32 as it
does now. llvm now also uses a larger redzone (up to 256 bytes) for
very large stack objects, which also seems like a good idea.

While it would be hard to argue that the gcc behavior is a bug,
it should be possible to implement the same optimization in gcc,
and that would solve a lot of the stack size issues with KASAN.

> Can you say which behavior you find 'sane' or 'not sane' here,
> specifically? Maybe we can make future gcc releases use a
> smaller redzone like clang does.
>
> If we find a way to improve gcc so it uses less stack here, we still
> have a problem with existing compilers still producing dangerously
> high stack usage, as well as annoying warnings for an allmodconfig
> build as soon as we start warning about this again.

This problem obviously still stands.

          Arnd
