From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: [PATCH v2 net-next] softirq: reduce latencies
Date: Fri, 04 Jan 2013 00:23:06 -0800
Message-ID: <1357287786.1678.87.camel@edumazet-glaptop>
References: <1357216132.21409.24107.camel@edumazet-glaptop>
	 <1357250880.2685.29.camel@bwh-desktop.uk.solarflarecom.com>
	 <1357252816.21409.26384.camel@edumazet-glaptop>
	 <1357285780.21409.28416.camel@edumazet-glaptop>
	 <1357287351.5452.44.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1357287351.5452.44.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-01-04 at 00:15 -0800, Joe Perches wrote:
> On Thu, 2013-01-03 at 23:49 -0800, Eric Dumazet wrote:
> > In various network workloads, __do_softirq() latencies can be up
> > to 20 ms if HZ=1000, and 200 ms if HZ=100.
> > This patch changes the fallback to ksoftirqd condition to :
> > - A time limit of 2 ms.
> 
> []
> > diff --git a/kernel/softirq.c b/kernel/softirq.c
> []
> > +#define MAX_SOFTIRQ_TIME  max(1, (2*HZ/1000))
> 
> And if HZ is 10000?
>  

Then its OK.  2*10000/1000 -> 20 ticks -> 2 ms


> >  asmlinkage void __do_softirq(void)
> >  {
> []
> > +	unsigned long end = jiffies + MAX_SOFTIRQ_TIME;
> 
> Perhaps MAX_SOFTIRQ_TIME should be
> 
> #define MAX_SOFTIRQ_TIME msecs_to_jiffies(2)
> 
> though it would be nicer if it were a compile time constant.

If you send a patch to convert msecs_to_jiffies() to an inline function
when HZ = 1000, I will gladly use it instead of (2*HZ/1000)

Right now, max(1, msecs_to_jiffies(2)) uses way too many instructions,
while it should be the constant 2, known at compile time.
