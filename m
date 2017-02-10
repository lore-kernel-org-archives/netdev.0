From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] netlink: move nla_put_{u8,u16,u32} out of line
Date: Fri, 10 Feb 2017 12:06:56 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0283526@AcuExch.aculab.com>
References: <20170208211843.2822208-1-arnd@arndb.de>
 <20170209.163123.1938061993523088894.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "johannes.berg@intel.com" <johannes.berg@intel.com>,
        "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>,
        "glider@google.com" <glider@google.com>,
        "dvyukov@google.com" <dvyukov@google.com>,
        "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>,
        "nicolas.dichtel@6wind.com" <nicolas.dichtel@6wind.com>,
        "adobriyan@gmail.com" <adobriyan@gmail.com>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>,
        "tgraf@suug.ch" <tgraf@suug.ch>,
        "edumazet@google.com" <edumazet@google.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'David Miller' <davem@davemloft.net>,
        "arnd@arndb.de" <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170209.163123.1938061993523088894.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller
> Sent: 09 February 2017 21:31
> From: Arnd Bergmann <arnd@arndb.de>
> Date: Wed,  8 Feb 2017 22:18:26 +0100
> 
> > When CONFIG_KASAN is enabled, the "--param asan-stack=1" causes rather large
> > stack frames in some functions. This goes unnoticed normally because
> > CONFIG_FRAME_WARN is disabled with CONFIG_KASAN by default as of commit
> > 3f181b4d8652 ("lib/Kconfig.debug: disable -Wframe-larger-than warnings with
> > KASAN=y").
> >
> > The kernelci.org build bot however has the warning enabled and that led
> > me to investigate it a little further, as every build produces these warnings:
> >
> > net/wireless/nl80211.c:4389:1: warning: the frame size of 2240 bytes is larger than 2048 bytes [-
...
> >
> > It turns out that there is a relatively simple workaround for the netlink
> > users that currently use a local variable in order to do the type conversion:
> > Moving the three functions (for each of the typical sizes) to lib/nlattr.c
> > avoids using local variables in the caller, which drastically reduces the
> > stack usage for nl80211 and br_netlink.
> >
> > It would be good if we could enable the frame size check after that again,
> > but that should be a separate patch and it requires some more testing
> > to see which the largest acceptable frame size should be.
...
> You should only extern these things when KASAN is enabled.
> 
> The reason is that uninlining these routines makes attribute emission
> more expensive and for some applications performance of this matters.

If performance of nla_put() matters, then adding 1, 2 and 4 byte attributes
ought to be doable without writing the values to memory and later doing
(I presume) a memcpy().

I also can't help feeling that the gcc KASAN stuff needs some way to
annotate an 'extern' to say that a value passed by reference isn't
treated as an array.
Otherwise I suspect you get a lot of bloat all over the place.

	David
