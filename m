From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] bnx2x: Replace semaphore stats_lock with mutex
Date: Thu, 20 Oct 2016 11:16:26 +0200
Message-ID: <4099305.ehHuhIimPk@wuerfel>
References: <1476953532-2019-1-git-send-email-binoy.jayan@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Ariel Elior <ariel.elior@qlogic.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Binoy Jayan <binoy.jayan@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476953532-2019-1-git-send-email-binoy.jayan@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, October 20, 2016 2:22:12 PM CEST Binoy Jayan wrote:
> @@ -1976,8 +1973,8 @@ int bnx2x_stats_safe_exec(struct bnx2x *bp,
>         /* Wait for statistics to end [while blocking further requests],
>          * then run supplied function 'safely'.
>          */
> -       rc = down_timeout(&bp->stats_lock, HZ / 10);
> -       if (unlikely(rc)) {
> +       rc = mutex_trylock(&bp->stats_lock);
> +       if (unlikely(!rc)) {
>                 BNX2X_ERR("Failed to take statistics lock for safe execution\n");
>                 goto out_no_lock;
>         }

This conversion looks suspicious, your changelog text does not mention
at all why would be to remove the timeout and fail immediately.

In fact, you don't seem to have any mutex_lock() call left, just
mutex_trylock(), and everything that tries to get the mutex fails
immediately if someone else holds it. The existing behavior of
the driver is not much better (it always gives up after 100ms),
but I think this needs some more thought put into it.

	Arnd
