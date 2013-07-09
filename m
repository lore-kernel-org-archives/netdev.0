From: Li Zefan <lizefan@huawei.com>
Subject: Re: [PATCH v2] bonding:fix speed unknown,lacp bonding failed
Date: Tue, 9 Jul 2013 09:42:40 +0800
Message-ID: <51DB6A90.3010108@huawei.com>
References: <1373331122-10052-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <zhangdianfang@huawei.com>
To: Wangyufen <wangyufen@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:25453 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245Ab3GIBmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jul 2013 21:42:53 -0400
In-Reply-To: <1373331122-10052-1-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/7/9 8:52, Wangyufen wrote:
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
> 	

Normally one should explain the changes from v1 to v2.

> 	
> Signed-off-by: Wang Yufen <wangyufen@huawei.com>
> ---
>  drivers/net/bonding/bond_main.c | 16 +++++++++++++++-
>  1 file changed, 15 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index f975696..4ccc173 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -2301,8 +2301,22 @@ static int bond_miimon_inspect(struct bonding *bond)
>  
>  		switch (slave->link) {
>  		case BOND_LINK_UP:
> -			if (link_state)
> +			if (link_state) {
> +				if (slave->speed == SPEED_UNKNOWN) {
> +					rtnl_lock();

You should have CCed those who made comments to your previous version, and that's
Ben here.

"bond_update_sleep_duplex() must not be called in atomic context."

You didn't address his comment.

> +					bond_update_speed_duplex(slave);
> +					if (slave->speed != SPEED_UNKNOWN

Firstly you checked slave->speed == SPEED_UNKNOWN, and now slave->speed != SPEED_UNKNOWN ??

> +					&& bond->params.mode
> +					== BOND_MODE_8023AD) {

The codingstyle is awful...

if (slave->speed != SPEED_UNKNOWN &&
    bond->params.mode == BOND_MODE_8023AD) {
	...

Even if it breaks 80 chars limit a bit.

> +						bond_3ad_adapter_speed_changed(
> +						slave);

ditto,

> +						bond_3ad_adapter_duplex_changed(
> +						slave);

ditto

> +					}
> +					rtnl_unlock();
> +				}
>  				continue;
> +			}
>  
>  			slave->link = BOND_LINK_FAIL;
>  			slave->delay = bond->params.downdelay;
> 
