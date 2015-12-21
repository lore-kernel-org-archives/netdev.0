From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next V2 3/4] net/mlx5e: Add HW timestamping (TS)
 support
Date: Mon, 21 Dec 2015 10:15:09 +0100
Message-ID: <20151221091509.GA2297@localhost.localdomain>
References: <1450647991-13736-1-git-send-email-saeedm@mellanox.com>
 <1450647991-13736-4-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>, saeedm@dev.mellanox.co.il
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:35400 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751424AbbLUJPO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2015 04:15:14 -0500
Received: by mail-wm0-f44.google.com with SMTP id l126so60236598wml.0
        for <netdev@vger.kernel.org>; Mon, 21 Dec 2015 01:15:13 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1450647991-13736-4-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 20, 2015 at 11:46:30PM +0200, Saeed Mahameed wrote:
> +/* Should run once every mlx5e_tstamp->overflow_period */
> +static void mlx5e_timestamp_overflow(struct work_struct *work)
> +{
> +	struct delayed_work *dwork = to_delayed_work(work);
> +	struct mlx5e_tstamp *tstamp = container_of(dwork, struct mlx5e_tstamp, overflow_work);
> +	unsigned long flags;
> +
> +	write_lock_irqsave(&tstamp->lock, flags);
> +	timecounter_read(&tstamp->clock);
> +	if (tstamp->overflow_period)
> +		schedule_delayed_work(&tstamp->overflow_work, tstamp->overflow_period);

You don't need this test, and the call to schedule_delayed_work can be
outside of the lock.

> +	write_unlock_irqrestore(&tstamp->lock, flags);
> +}

> +void mlx5e_timestamp_cleanup(struct mlx5e_priv *priv)
> +{
> +	struct mlx5e_tstamp *tstamp = &priv->tstamp;
> +
> +	if (!MLX5_CAP_GEN(priv->mdev, device_frequency_khz))
> +		return;
> +
> +	write_lock(&tstamp->lock);
> +	tstamp->overflow_period = 0; /* Signal overflow_check to stop */
> +	write_unlock(&tstamp->lock);

This is unnecessary because

> +
> +	cancel_delayed_work_sync(&tstamp->overflow_work);

this will block until the work is cancelled.

> +}

Thanks,
Richard
