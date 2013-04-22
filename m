From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V2 5/5] net/mlx4_en: Add a service task
Date: Mon, 22 Apr 2013 12:01:10 -0700
Message-ID: <1366657270.16391.87.camel@edumazet-glaptop>
References: <1366631767-16493-1-git-send-email-amirv@mellanox.com>
	 <1366631767-16493-6-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Richard Cochran <richardcochran@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:59672 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755004Ab3DVTBN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 15:01:13 -0400
Received: by mail-pd0-f180.google.com with SMTP id q11so3780660pdj.39
        for <netdev@vger.kernel.org>; Mon, 22 Apr 2013 12:01:12 -0700 (PDT)
In-Reply-To: <1366631767-16493-6-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-22 at 14:56 +0300, Amir Vadai wrote:
> Add a service task to run tasks that needed to be executed periodically.
> Currently the only task is a watchdog to catch NIC clock overflow, to make
> timestamping accurate.
> Will move the statistics task into this framework in a later patch.
> 
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_clock.c  |   20 ++++++++++++++++++++
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   24 ++++++++++++++++++++++++
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    4 ++++
>  3 files changed, 48 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_clock.c b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
> index 6d8227d..c1982a4 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_clock.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
> @@ -126,4 +126,24 @@ void mlx4_en_init_timestamp(struct mlx4_en_dev *mdev)
>  
>  	timecounter_init(&mdev->clock, &mdev->cycles,
>  			 ktime_to_ns(ktime_get_real()));
> +
> +	/* Calculate period in seconds to call the overflow watchdog. Doing
> +	 * that, by dividing the maximal cycles value in nano-seconds, convert
> +	 * it to seconds, and divide by 2 - to make sure counter is checked at
> +	 * least once every wrap around.
> +	 */
> +	mdev->overflow_period =
> +		cyclecounter_cyc2ns(&mdev->cycles,
> +				    mdev->cycles.mask) / 1000000 / 2;
> +}
> +

So this 1000000 looks like NSEC_PER_SEC/HZ ?

What if HZ=100 ?
