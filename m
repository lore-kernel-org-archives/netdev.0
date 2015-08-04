From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net_dbg_ratelimited: turn into no-op when !DEBUG
Date: Mon, 03 Aug 2015 20:57:57 -0700
Message-ID: <1438660677.10829.1.camel@perches.com>
References: <1438658773-3220-1-git-send-email-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438658773-3220-1-git-send-email-Jason@zx2c4.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-08-04 at 05:26 +0200, Jason A. Donenfeld wrote:
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

Makes sense, thanks Jason.
