From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [patch 4/5] net: hip04: Make tx coalesce timer actually work
Date: Mon, 13 Apr 2015 23:24:58 +0200
Message-ID: <9614284.QjZ4xls6zV@wuerfel>
References: <20150413210009.682000343@linutronix.de> <20150413210035.274411419@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	dingtianhong <dingtianhong@huawei.com>,
	Zhangfei Gao <zhangfei.gao@linaro.org>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	netdev@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150413210035.274411419@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 13 April 2015 21:02:23 Thomas Gleixner wrote:
> The code sets the expiry value of the timer to a relative value and
> starts it with hrtimer_start_expires. That's fine, but that only works
> once. The timer is started in relative mode, so the expiry value gets
> overwritten with the absolut expiry time (now + expiry).
> 
> So once the timer expired, a new call to hrtimer_start_expires results
> in an immidiately expired timer, because the expiry value is
> already in the past.
> 
> Use the proper mechanisms to (re)start the timer in the intended way.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: dingtianhong <dingtianhong@huawei.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Zhangfei Gao <zhangfei.gao@linaro.org>
> Cc: Dan Carpenter <dan.carpenter@oracle.com>
> Cc: netdev@vger.kernel.org

Thanks a lot for the fix. The mistake was clearly mine, as I had sent
a patch to introduce the tx coalesce timer without access to hardware
or a way to test that what I did was correct.

There are other known problems in the version of the driver that got
merged, and I believe that someone is now looking at them.

What I think we really want here is a way for user space to configure
both the minimum and maximum coalesce timer separately rather than
assuming half the time is what we want.

	Arnd

> @@ -413,6 +413,15 @@ out:
>  	return count;
>  }
>  
> +static void hip04_start_tx_timer(struct hip04_priv *priv)
> +{
> +	ktime_t t;
> +
> +	/* allow timer to fire after half the time at the earliest */
> +	t = ktime_set(0, priv->tx_coalesce_usecs * NSEC_PER_USEC / 2);
> +	hrtimer_start(&priv->tx_coalesce_timer, t, HRTIMER_MODE_REL);
> +}

Question: this looks to me like it sets both the minimum and maximum
time to priv->tx_coalesce_usecs/2, when the intention was to set
the minimum to priv->tx_coalesce_usecs/2 and the maximum to
priv->tx_coalesce_usecs. Am I missing something subtle here, or did
you just misread my original intention from the botched code?

	Arnd
