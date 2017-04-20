From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/1] bonding: use 'M' or 'G' based on the speed
Date: Thu, 20 Apr 2017 14:53:19 -0700
Message-ID: <20170420145319.17ed4296@xeon-e3>
References: <1492679195-19938-1-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
        netdev@vger.kernel.org
To: Zhu Yanjun <yanjun.zhu@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:33920 "EHLO
        mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S947832AbdDTVxZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 17:53:25 -0400
Received: by mail-io0-f179.google.com with SMTP id a103so89575465ioj.1
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 14:53:24 -0700 (PDT)
In-Reply-To: <1492679195-19938-1-git-send-email-yanjun.zhu@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Apr 2017 05:06:35 -0400
Zhu Yanjun <yanjun.zhu@oracle.com> wrote:

> If the speed of the slave netdev is more than 1000M,
> it is better to use 'G' instead of 'M'.
> 
> Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>
> ---
>  drivers/net/bonding/bond_main.c   | 8 ++++++--
>  drivers/net/bonding/bond_procfs.c | 6 +++++-
>  2 files changed, 11 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index af9f0ce..1aad13d 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -2147,9 +2147,13 @@ static void bond_miimon_commit(struct bonding *bond)
>  				bond_set_backup_slave(slave);
>  			}
>  
> -			netdev_info(bond->dev, "link status definitely up for interface %s, %u Mbps %s duplex\n",
> +			netdev_info(bond->dev, "link status definitely up for interface %s, %u%sbps %s duplex\n",
>  				    slave->dev->name,
> -				    slave->speed == SPEED_UNKNOWN ? 0 : slave->speed,
> +				    slave->speed == SPEED_UNKNOWN ? 0 :
> +				    (slave->speed > 1000 ?
> +				    slave->speed / 1000 : slave->speed),
> +				    slave->speed > 1000 ?
> +				    slave->speed % 1000 ? ".5 G" : " G" : " M",
>  				    slave->duplex ? "full" : "half");

Or drop the message all together. This is just log noise in a production system.


>  
>  			/* notify ad that the link status has changed */
> diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
> index f514fe5..4c31055 100644
> --- a/drivers/net/bonding/bond_procfs.c
> +++ b/drivers/net/bonding/bond_procfs.c
> @@ -173,7 +173,11 @@ static void bond_info_show_slave(struct seq_file *seq,
>  	if (slave->speed == SPEED_UNKNOWN)
>  		seq_printf(seq, "Speed: %s\n", "Unknown");
>  	else
> -		seq_printf(seq, "Speed: %d Mbps\n", slave->speed);
> +		seq_printf(seq, "Speed: %d%sbps\n",
> +			   slave->speed > 1000 ?
> +			   slave->speed / 1000 : slave->speed,
> +			   slave->speed > 1000 ?
> +			   (slave->speed % 1000 ? ".5 G" : " G") : " M");
>  
>  	if (slave->duplex == DUPLEX_UNKNOWN)
>  		seq_printf(seq, "Duplex: %s\n", "Unknown");

You can't change output formats of /proc since it technically and kernel/userspace ABI.
