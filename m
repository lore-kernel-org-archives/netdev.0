From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 4/6] net/mlx4_core: Do not BUG_ON during reset when
 PCI is offline
Date: Wed, 17 Feb 2016 21:50:02 +0300
Message-ID: <56C4C0DA.8050002@cogentembedded.com>
References: <1455634911-31206-1-git-send-email-ogerlitz@mellanox.com>
 <1455634911-31206-5-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Daniel Jurgens <danielj@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:33416 "EHLO
	mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030261AbcBQSuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 13:50:06 -0500
Received: by mail-lf0-f42.google.com with SMTP id m1so17362751lfg.0
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 10:50:05 -0800 (PST)
In-Reply-To: <1455634911-31206-5-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 02/16/2016 06:01 PM, Or Gerlitz wrote:

> From: Daniel Jurgens <danielj@mellanox.com>
>
> The PCI channel could go offline during reset due to EEH.  Don't bug on in
> this case, the error is recoverable.
>
> Fixes: f6bc11e42646 ('net/mlx4_core: Enhance the catas flow to support device reset')
> Signed-off-by: Daniel Jurgens <danielj@mellanox.com>
> Reviewed-by: Yishai Hadas <yishaih@mellanox.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/catas.c | 11 +++++++++--
>   1 file changed, 9 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/catas.c b/drivers/net/ethernet/mellanox/mlx4/catas.c
> index 715de8a..e866082 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/catas.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/catas.c
> @@ -182,10 +182,17 @@ void mlx4_enter_error_state(struct mlx4_dev_persistent *persist)
>   		err = mlx4_reset_slave(dev);
>   	else
>   		err = mlx4_reset_master(dev);
> -	BUG_ON(err != 0);
> +
> +	if (!err)
> +		mlx4_err(dev, "device was reset successfully\n");
> +	else
> +		/* EEH could have disabled the PCI channel during reset. That's
> +		 * recoverable and the PCI error flow will handle it.
> +		 */
> +		if (!pci_channel_offline(dev->persist->pdev))
> +			BUG_ON(1);

    BTW, why not just BUG_ON(!pci_channel_offline(dev->persist->pdev));

WBR, Sergei
