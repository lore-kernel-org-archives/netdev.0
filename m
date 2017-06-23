From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v3 07/11] tty: improve tty_insert_flip_char() fast path
Date: Sat, 24 Jun 2017 00:07:58 +0800
Message-ID: <20170623160758.GA19961@kroah.com>
References: <20170622171355.267192-1-arnd@arndb.de>
 <20170622171355.267192-8-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
        kasan-dev@googlegroups.com, Dmitry Vyukov <dvyukov@google.com>,
        Alexander Potapenko <glider@google.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Michal Marek <mmarek@suse.com>,
        Kees Cook <keescook@chromium.org>,
        Ingo Molnar <mingo@kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        linux-kbuild@vger.kernel.org,
        Samuel Thibault <samuel.thibault@ens-lyon.org>,
        Jiri Slaby <jslaby@suse.com>, stable@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170622171355.267192-8-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 22, 2017 at 07:13:51PM +0200, Arnd Bergmann wrote:
> kernelci.org reports a crazy stack usage for the VT code when CONFIG_KASAN
> is enabled:
> 
> drivers/tty/vt/keyboard.c: In function 'kbd_keycode':
> drivers/tty/vt/keyboard.c:1452:1: error: the frame size of 2240 bytes is larger than 2048 bytes [-Werror=frame-larger-than=]
> 
> The problem is that tty_insert_flip_char() gets inlined many times into
> kbd_keycode(), and also into other functions, and each copy requires 128
> bytes for stack redzone to check for a possible out-of-bounds access on
> the 'ch' and 'flags' arguments that are passed into
> tty_insert_flip_string_flags as a variable-length string.
> 
> This introduces a new __tty_insert_flip_char() function for the slow
> path, which receives the two arguments by value. This completely avoids
> the problem and the stack usage goes back down to around 100 bytes.
> 
> Without KASAN, this is also slightly better, as we don't have to
> spill the arguments to the stack but can simply pass 'ch' and 'flag'
> in registers, saving a few bytes in .text for each call site.
> 
> This should be backported to linux-4.0 or later, which first introduced
> the stack sanitizer in the kernel.
> 
> Cc: stable@vger.kernel.org
> Fixes: c420f167db8c ("kasan: enable stack instrumentation")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> I already submitted this separately to Greg, but he hasn't replied
> yet. I assume that it's fine if Andrew picks it up along with the
> other patches and drops it again in case Greg applies it to linux-next.

I've been traveling in China this week, give me a chance to catch up
please.

And no, I don't like this patch either, I think kasan needs to be fixed
here, not work around it in odd ways in code that is completly
acceptable to "sane" compilers.  But give me a week to catch up on my
pending stuff first...

thanks,

greg k-h
