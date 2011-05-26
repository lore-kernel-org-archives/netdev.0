From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] net/core/filter.c: Fix build error
Date: Thu, 26 May 2011 21:09:39 +0200
Message-ID: <20110526190939.GC3476@elte.hu>
References: <efa062542c692c3f7743bf2d97b5987ab989e27e.1305999731.git.joe@perches.com>
 <20110526123153.GA16002@elte.hu>
 <1306423866.16087.10.camel@Joe-Laptop>
 <20110526.143843.205897228685761536.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: joe@perches.com, greearb@candelatech.com,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	arnd@arndb.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110526.143843.205897228685761536.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* David Miller <davem@davemloft.net> wrote:

> From: Joe Perches <joe@perches.com>
> Date: Thu, 26 May 2011 08:31:06 -0700
> 
> > My suggestion would be to see about again adding
> > #include <linux/ratelimit.h> somehow
> > back to kernel.h which commit 3fff4c42bd0a removed
> > in 2009 because of the spinlock issues.
> > 
> > Any suggestion on how best to fix it generically?
> 
> I don't think we want spinlock_t's definition being sucked
> into kernel.h's dependency food chain.

Agreed.

Also, i don't think it's unreasonable to require code that uses 
DEFINE_RATELIMIT_STATE() to #include ratelimit.h. That's what we 
require from DEFINE_MUTEX() and DEFINE_SPINLOCK() users and many 
other users as well.

The only exception is printk_ratelimit() itself - that should not - 
and currently does not - require the inclusion of ratelimit.h.

The *real* solution here would be to remove the spurious and .config 
dependent inclusion of ratelimit.h in include/linux/net.h.  It's fine 
to provide the net_ratelimit() interface (it'sanalogous to 
printk_ratelimit()), but it's not fine to declare net_ratelimit_state 
in that header and include that header in half of all networking 
code, bringing in ratelimit.h implicitly.

So no, i don't think your patch is the real solution. The problem was 
that the .config's you tested had CONFIG_SYSCTL=y, which brought in 
ratelimit.h into half of the networking code. That's unnecessary and 
problematic - the interface between net/core/sysctl_net_core.c and 
net/core/utils.c should be done via a dedicated header (not included 
by other code), or via explicit extern declared in the .c file (more 
dangerous, but used by pretty much all sysctl code in the kernel).

Thanks,

	Ingo
