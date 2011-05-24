From: Joe Perches <joe@perches.com>
Subject: Re: linux-next: Tree for May 24 (ratelimits, CONFIG_PRINTK not
 enabled)
Date: Tue, 24 May 2011 12:49:40 -0700
Message-ID: <1306266580.2298.55.camel@Joe-Laptop>
References: <20110524140212.a4f19769.sfr@canb.auug.org.au>
	 <20110524113328.e3d5867b.randy.dunlap@oracle.com>
	 <1306262988.2298.49.camel@Joe-Laptop>
	 <20110524.153222.1953796640575918161.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, sfr@canb.auug.org.au,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110524.153222.1953796640575918161.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-05-24 at 15:32 -0400, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Tue, 24 May 2011 11:49:48 -0700
> > On Tue, 2011-05-24 at 11:33 -0700, Randy Dunlap wrote:
> >> Adding <linux/ratelimit.h> to <asm-generic/bug.h> causes other problems:
> > Yup, that's not a good solution.
> Please come up with a fix or I'll have to revert, thanks Joe.

I have some errands to run for awhile.

Probably a revert today and another patch set tomorrow
might be best.

This seems to work and doesn't cause any extra state to be
instantiated when !CONFIG_PRINTK.  What do you think?

#ifdef CONFIG_PRINTK

#define WARN_ON_RATELIMIT(condition, state)			\
	WARN_ON((condition) && __ratelimit(state))

#define __WARN_RATELIMIT(condition, state, format...)		\
({								\
	int rtn = 0;						\
	if (unlikely(__ratelimit(state)))			\
		rtn = WARN(condition, format);			\
	rtn;							\
})

#define WARN_RATELIMIT(condition, format...)			\
({								\
	static DEFINE_RATELIMIT_STATE(_rs,			\
				      DEFAULT_RATELIMIT_INTERVAL,	\
				      DEFAULT_RATELIMIT_BURST);	\
	__WARN_RATELIMIT(condition, &_rs, format);		\
})

#else

#define WARN_ON_RATELIMIT(condition, state)			\
	WARN_ON(condition)

#define __WARN_RATELIMIT(condition, state, format...)		\
({								\
	int rtn = WARN(condition, format);			\
	rtn;							\
})

#define WARN_RATELIMIT(condition, format...)			\
({								\
	int rtn = WARN(condition, format);			\
	rtn;							\
})

#endif
