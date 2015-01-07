From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 6/6] driver/net/irda: Replace timeval with ktime_t in vlsi_ir
Date: Wed, 07 Jan 2015 09:59:21 +0100
Message-ID: <25851353.A4KvfMplxB@wuerfel>
References: <1420601978-15866-7-git-send-email-zhang.chunyan@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: samuel@sortiz.org, zhang.lyra@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chunyan Zhang <zhang.chunyan@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420601978-15866-7-git-send-email-zhang.chunyan@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 07 January 2015 11:39:38 Chunyan Zhang wrote:
> This patch changes the 32-bit time type (timeval) to the 64-bit one
> (ktime_t), since 32-bit time types will break in the year 2038.
> So, I use ktime_t instead of all uses of timeval.
> 
> This patch also changes do_gettimeofday() to ktime_get() accordingly,
> since ktime_get returns a ktime_t, but do_gettimeofday returns a
> struct timeval, and the other reason is that ktime_get() uses
> the monotonic clock.
> 
> This patch uses ktime_us_delta to get the elapsed time of microsecond,
> and uses div_s64_rem to get what seconds & microseconds time elapsed
> for printing.
> 
> This patch also changes the code of function 'vlsi_hard_start_xmit' to
> do the same things as the others drivers, that is passing the remaining
> time into udelay() instead of looping until enough time has passed.
> 
> Signed-off-by: Chunyan Zhang <zhang.chunyan@linaro.org>

All six patches look correct to me now, nice work!

I have a few very minor comments still, some of which apply to the
other patches as well:

* Your patch changelog starts each paragraph with 'This patch', which is
  correct but is a little strange to read. You could start the first paragraph
  explaining what the driver currently does and why we want to change it,
  like "The vlsi ir driver uses 'timeval', which we try to remove in the
  kernel because all 32-bit time types will break in the year 2038".

* It would also be good to explain that none of these drivers are actually
  broken regarding y2038 at the moment and that the change is only done to
  remove the need for auditing this fact again.

> @@ -180,8 +181,8 @@ static void vlsi_proc_ndev(struct seq_file *seq, struct net_device *ndev)
>  	vlsi_irda_dev_t *idev = netdev_priv(ndev);
>  	u8 byte;
>  	u16 word;
> -	unsigned delta1, delta2;
> -	struct timeval now;
> +	ktime_t now;
> +	s32 sec, usec;
>  	unsigned iobase = ndev->base_addr;

* you now have a local variable that is only used to be passed into ktime_us_delta.
  While there is no difference to the compiler, I would probably shorten this
  and avoid the local variable by passing the result of ktime_get() directly
  into ktime_us_delta().
  For the drivers that store the 'now' variable in a data structure, doing the
  same change shrinks the driver specific data structure, which is an added
  benefit.

> -		for(;;) {
> -			do_gettimeofday(&now);
> -			if (now.tv_sec > ready.tv_sec ||
> -			    (now.tv_sec==ready.tv_sec && now.tv_usec>=ready.tv_usec))
> -			    	break;
> -			udelay(100);
> -			/* must not sleep here - called under netif_tx_lock! */
> -		}
> +		now = ktime_get();
> +		diff = ktime_us_delta(now, idev->last_rx);
> +		if (mtt > diff)
> +			udelay(mtt - diff);
>  	}

The change looks good, but you remove a useful comment about sleeping inside of
netif_tx_lock. I would not bother adding the same comment to the other drivers,
but it still applies to the udelay call here so I would move it there.
Note that generally we try hard to avoid the use of long 'udelay' calls, but
I wouldn't expect you to change the drivers for this.

When you submit the next version and you have addressed my last comments,
please add

Reviewed-by: Arnd Bergmann <arnd@arndb.de>

	Arnd
