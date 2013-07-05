From: Veaceslav Falico <darkmag@gmail.com>
Subject: Re: [PATCH] bonding:fix speed unknown,lacp bonding failed
Date: Fri, 5 Jul 2013 11:20:24 +0200
Message-ID: <CAE3RKN=dy8t0W-pvq7yro643i-0AZziOw+7BQ5fc4z7JquC__Q@mail.gmail.com>
References: <1373005979-10196-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>, lizefan@huawei.com,
	zhangdianfang@huawei.com
To: Wangyufen <wangyufen@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:40400 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753344Ab3GEJUp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jul 2013 05:20:45 -0400
Received: by mail-pb0-f48.google.com with SMTP id ma3so1979204pbc.21
        for <netdev@vger.kernel.org>; Fri, 05 Jul 2013 02:20:44 -0700 (PDT)
In-Reply-To: <1373005979-10196-1-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 5, 2013 at 8:32 AM, Wangyufen <wangyufen@huawei.com> wrote:
> From: "Wang Yufen" <wangyufen@huawei.com>
>
> We bonded nic using LACP mode repeatedly, occasionally LACP bonding failed,
> because a slave nic port speed was unknown. But when we used ethtool to
> check the slave NIC status, the nic status was normal,speed was 10000Mb/s.

Can you give a bit more details on how did you test? And which nic was it?

I've tried to reproduce it with with while :; do echo +/- >
/sys/.../bonding/slaves; done
but failed.

>
> Bonding get the NIC speed from NIC drivers,just when enslave nic
> and receive NETDEV_CHANGE event.We call bond_update_speed_duplex to
> update speed and duplex when miimon inspect slave link is OK and slave
> speed is unknown.
>
>
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
>                 switch (slave->link) {
>                 case BOND_LINK_UP:
> -                       if (link_state)
> +                       if (link_state) {
> +                               if (slave->speed == SPEED_UNKNOWN)
> +                                       bond_update_speed_duplex(slave);
>                                 continue;
> +                       }
>
>                         slave->link = BOND_LINK_FAIL;
>                         slave->delay = bond->params.downdelay;
> --
> 1.8.0
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--
Best regards,
Veaceslav Falico
