From: Yishai Hadas <yishaih@dev.mellanox.co.il>
Subject: Re: [PATCH] mlx4_core: Fix fallback from MSI-X to INTx
Date: Wed, 27 May 2015 12:43:04 +0300
Message-ID: <556591A8.6050602@dev.mellanox.co.il>
References: <1432336346-20290-1-git-send-email-bpoirier@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Amir Vadai <amirv@mellanox.com>, Ido Shamay <idos@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Benjamin Poirier <bpoirier@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:36662 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291AbbE0JnJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 05:43:09 -0400
Received: by wizk4 with SMTP id k4so105016323wiz.1
        for <netdev@vger.kernel.org>; Wed, 27 May 2015 02:43:08 -0700 (PDT)
In-Reply-To: <1432336346-20290-1-git-send-email-bpoirier@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/23/2015 2:12 AM, Benjamin Poirier wrote:
> The test in mlx4_load_one() to remove MLX4_FLAG_MSI_X expects mlx4_NOP() to
> fail with -EBUSY. It is also necessary to avoid the reset since the device
> is not fully reinitialized before calling mlx4_start_hca() a second time.
>
> Note that this will also affect mlx4_test_interrupts(), the only other user
> of MLX4_CMD_NOP.
>
> Fixes: f5aef5a ("net/mlx4_core: Activate reset flow upon fatal command cases")
> Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
> ---
>   drivers/net/ethernet/mellanox/mlx4/cmd.c | 9 +++++++--
>   1 file changed, 7 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
> index 4f7dc04..529ef05 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
> @@ -714,8 +714,13 @@ static int mlx4_cmd_wait(struct mlx4_dev *dev, u64 in_param, u64 *out_param,
>   					 msecs_to_jiffies(timeout))) {
>   		mlx4_warn(dev, "command 0x%x timed out (go bit not cleared)\n",
>   			  op);
> -		err = -EIO;
> -		goto out_reset;
> +		if (op == MLX4_CMD_NOP) {
> +			err = -EBUSY;
> +			goto out;
> +		} else {
> +			err = -EIO;
> +			goto out_reset;
> +		}
>   	}
>
>   	err = context->result;
>

It looks fine, a private case that should not trigger the reset flow.
