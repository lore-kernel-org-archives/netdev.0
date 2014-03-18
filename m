From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/9] ptp: introduce programmable pins.
Date: Mon, 17 Mar 2014 21:25:34 -0400 (EDT)
Message-ID: <20140317.212534.579591104509436501.davem@davemloft.net>
References: <cover.1394975663.git.richardcochran@gmail.com>
	<5faff8ea096044a48e4edcc6391844f8d428383f.1394975663.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ben@decadent.org.uk, christian.riesch@omicron.at,
	stefan.sorensen@spectralink.com
To: richardcochran@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5faff8ea096044a48e4edcc6391844f8d428383f.1394975663.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Cochran <richardcochran@gmail.com>
Date: Sun, 16 Mar 2014 14:29:22 +0100

> +	/* Check to see if any other pin previously had this function. */
> +	if (mutex_lock_interruptible(&ptp->pincfg_mux))
> +		return -ERESTARTSYS;
> +	for (i = 0; i < info->n_pins; i++) {
> +		if (info->pin_config[i].func == func &&
> +		    info->pin_config[i].chan == chan) {
> +			pin1 = &info->pin_config[i];
> +			break;
> +		}
> +	}
> +	mutex_unlock(&ptp->pincfg_mux);
 ...
> +	if (mutex_lock_interruptible(&ptp->pincfg_mux))
> +		return -ERESTARTSYS;
> +	pin2->func = func;
> +	pin2->chan = chan;
> +	if (pin1) {
> +		pin1->func = PTP_PF_NONE;
> +		pin1->chan = 0;
> +	}
> +	mutex_unlock(&ptp->pincfg_mux);
> +
> +	return 0;

This locking seems unnecessarily complex to me.  You should be able to
do the stateless sanity checks, take the mutex, then do all of the
rest of the operations until the end of the function before
dropping the lock.

So just take the lock once over the operations that need it.
