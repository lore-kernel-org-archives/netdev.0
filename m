From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net_dbg_ratelimited: turn into no-op when !DEBUG
Date: Thu, 06 Aug 2015 23:51:45 -0700 (PDT)
Message-ID: <20150806.235145.838510256404062404.davem@davemloft.net>
References: <1438703465.10829.20.camel@perches.com>
	<1438705579-18461-1-git-send-email-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, joe@perches.com
To: Jason@zx2c4.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438705579-18461-1-git-send-email-Jason@zx2c4.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Tue,  4 Aug 2015 18:26:19 +0200

> The pr_debug family of functions turns into a no-op when -DDEBUG is not
> specified, opting instead to call "no_printk", which gets compiled to a
> no-op (but retains gcc's nice warnings about printf-style arguments).
> 
> The problem with net_dbg_ratelimited is that it is defined to be a
> variant of net_ratelimited_function, which expands to essentially:
> 
>     if (net_ratelimit())
>         pr_debug(fmt, ...);
> 
> When DEBUG is not defined, then this becomes,
> 
>     if (net_ratelimit())
>         ;
> 
> This seems benign, except it isn't. Firstly, there's the obvious
> overhead of calling net_ratelimit needlessly, which does quite some book
> keeping for the rate limiting. Given that the pr_debug and
> net_dbg_ratelimited family of functions are sprinkled liberally through
> performance critical code, with developers assuming they'll be compiled
> out to a no-op most of the time, we certainly do not want this needless
> book keeping. Secondly, and most visibly, even though no debug message
> is printed when DEBUG is not defined, if there is a flood of
> invocations, dmesg winds up peppered with messages such as
> "net_ratelimit: 320 callbacks suppressed". This is because our
> aforementioned net_ratelimit() function actually prints this text in
> some circumstances. It's especially odd to see this when there isn't any
> other accompanying debug message.
> 
> So, in sum, it doesn't make sense to have this function's current
> behavior, and instead it should match what every other debug family of
> functions in the kernel does with !DEBUG -- nothing.
> 
> This patch replaces calls to net_dbg_ratelimited when !DEBUG with
> no_printk, keeping with the idiom of all the other debug print helpers.
> 
> Also, though not strictly neccessary, it guards the call with an if (0)
> so that all evaluation of any arguments are sure to be compiled out.
> 
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>

Applied to net-next, thanks.
