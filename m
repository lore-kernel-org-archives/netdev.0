From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] softirq: punt to ksoftirqd if __do_softirq recently
 looped
Date: Fri, 11 Apr 2014 16:33:42 -0400 (EDT)
Message-ID: <20140411.163342.1319748709214614224.davem@davemloft.net>
References: <20140410115706.662fb5e7@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jbenc@redhat.com, peterz@infradead.org, tglx@linutronix.de,
	fweisbec@gmail.com
To: riel@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140410115706.662fb5e7@annuminas.surriel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rik van Riel <riel@redhat.com>
Date: Thu, 10 Apr 2014 11:57:06 -0400

> @@ -330,7 +334,11 @@ void irq_enter(void)
>  
>  static inline void invoke_softirq(void)
>  {
> -	if (!force_irqthreads) {
> +	/*
> +	 * If force_irqthreads is set, or if we looped in __do_softirq this
> +	 * jiffie, punt to ksoftirqd to prevent userland starvation.
> +	 */
> +	if (!force_irqthreads && this_cpu_read(softirq_looped) != jiffies) {

If we do this, which I'm not convinced of yet, I think we should use two
jiffies as the cutoff.

Because if we are at the tail end of one jiffie we'll prematurely go to
ksoftirqd when we really have no reason to do so.
