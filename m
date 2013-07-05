From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] bonding:fix speed unknown,lacp bonding failed
Date: Fri, 5 Jul 2013 15:54:16 +0100
Message-ID: <1373036056.1913.0.camel@bwh-desktop.uk.level5networks.com>
References: <1373005979-10196-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <lizefan@huawei.com>,
	<zhangdianfang@huawei.com>
To: Wangyufen <wangyufen@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:31420 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757363Ab3GEOyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jul 2013 10:54:21 -0400
In-Reply-To: <1373005979-10196-1-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-07-05 at 14:32 +0800, Wangyufen wrote:
> From: "Wang Yufen" <wangyufen@huawei.com>
> 
> We bonded nic using LACP mode repeatedly, occasionally LACP bonding failed,
> because a slave nic port speed was unknown. But when we used ethtool to 
> check the slave NIC status, the nic status was normal,speed was 10000Mb/s.
> 	
> Bonding get the NIC speed from NIC drivers,just when enslave nic 
> and receive NETDEV_CHANGE event.We call bond_update_speed_duplex to 
> update speed and duplex when miimon inspect slave link is OK and slave 
> speed is unknown.

bond_update_sleep_duplex() must not be called in atomic context.

Ben.

> Signed-off-by: Wang Yufen <wangyufen@huawei.com>
> ---
>  drivers/net/bonding/bond_main.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index f975696..d288a98 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -2301,8 +2301,11 @@ static int bond_miimon_inspect(struct bonding *bond)
>  
>  		switch (slave->link) {
>  		case BOND_LINK_UP:
> -			if (link_state)
> +			if (link_state) {
> +				if (slave->speed == SPEED_UNKNOWN)
> +					bond_update_speed_duplex(slave);
>  				continue;
> +			}
>  
>  			slave->link = BOND_LINK_FAIL;
>  			slave->delay = bond->params.downdelay;

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
