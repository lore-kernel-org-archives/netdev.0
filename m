From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: move nla_put_{u8,u16,u32} out of line
Date: Thu, 09 Feb 2017 16:31:23 -0500 (EST)
Message-ID: <20170209.163123.1938061993523088894.davem@davemloft.net>
References: <20170208211843.2822208-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@aculab.com, netdev@vger.kernel.org,
        johannes.berg@intel.com, aryabinin@virtuozzo.com,
        glider@google.com, dvyukov@google.com, kasan-dev@googlegroups.com,
        nicolas.dichtel@6wind.com, adobriyan@gmail.com,
        daniel@iogearbox.net, tgraf@suug.ch, edumazet@google.com,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170208211843.2822208-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed,  8 Feb 2017 22:18:26 +0100

> When CONFIG_KASAN is enabled, the "--param asan-stack=1" causes rather large
> stack frames in some functions. This goes unnoticed normally because
> CONFIG_FRAME_WARN is disabled with CONFIG_KASAN by default as of commit
> 3f181b4d8652 ("lib/Kconfig.debug: disable -Wframe-larger-than warnings with
> KASAN=y").
> 
> The kernelci.org build bot however has the warning enabled and that led
> me to investigate it a little further, as every build produces these warnings:
> 
> net/wireless/nl80211.c:4389:1: warning: the frame size of 2240 bytes is larger than 2048 bytes [-Wframe-larger-than=]
> net/wireless/nl80211.c:1895:1: warning: the frame size of 3776 bytes is larger than 2048 bytes [-Wframe-larger-than=]
> net/wireless/nl80211.c:1410:1: warning: the frame size of 2208 bytes is larger than 2048 bytes [-Wframe-larger-than=]
> net/bridge/br_netlink.c:1282:1: warning: the frame size of 2544 bytes is larger than 2048 bytes [-Wframe-larger-than=]
> 
> It turns out that there is a relatively simple workaround for the netlink
> users that currently use a local variable in order to do the type conversion:
> Moving the three functions (for each of the typical sizes) to lib/nlattr.c
> avoids using local variables in the caller, which drastically reduces the
> stack usage for nl80211 and br_netlink.
> 
> It would be good if we could enable the frame size check after that again,
> but that should be a separate patch and it requires some more testing
> to see which the largest acceptable frame size should be.
> 
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Alexander Potapenko <glider@google.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: kasan-dev@googlegroups.com
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

You should only extern these things when KASAN is enabled.

The reason is that uninlining these routines makes attribute emission
more expensive and for some applications performance of this matters.
