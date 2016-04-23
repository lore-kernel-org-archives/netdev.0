From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 12/12] net/mlx5e: Disable link up on INIT HCA command
Date: Sat, 23 Apr 2016 23:21:45 +0300
Message-ID: <CALzJLG-AWFHnba=ysCAQLqCjFHo3L-sQTeW+NbpMg-X6PRtRPQ@mail.gmail.com>
References: <1461351647-27412-1-git-send-email-saeedm@mellanox.com>
 <1461351647-27412-13-git-send-email-saeedm@mellanox.com> <20160423160023.GA15013@colbert.Home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>, eladr@mellanox.com
To: Ido Schimmel <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:35762 "EHLO
	mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751835AbcDWUWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Apr 2016 16:22:06 -0400
Received: by mail-yw0-f194.google.com with SMTP id v81so18780831ywa.2
        for <netdev@vger.kernel.org>; Sat, 23 Apr 2016 13:22:05 -0700 (PDT)
In-Reply-To: <20160423160023.GA15013@colbert.Home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 23, 2016 at 7:00 PM, Ido Schimmel <idosch@mellanox.com> wrote:
> mutt suggests I sent you the following patches a while ago:
>
> net/mlx5e: Set port administrative status in ndo_{open, close}
> net/mlx5e: Initialize port administrative status to down
>
> So I'm curious as to why you didn't follow up on them and instead came
> up with this patch.
>
> When I initially debugged this I pointed you to the fact that the
> firmware also needs to be patched, as setting the administrative status
> down via PAOS doesn't really do anything. The operational status will
> remain up. I just tested this patchset with the latest release firmware
> (12.14.2036) and I'm bumping into the same problem.
>

Hi Ido,

I do remember that patch, and back then i told you that your patch is
not cooked enough and that we were working on a solution:

1. you need to negotiate with the FW on if the FW can give up port
ownership to SW, you can find that in handle_hca_cap,
MLX5_CAP_GEN_MAX(dev, disable_link_up).
2. you need to configure the FW to give up port ownership via NVconfig
(mlxconfig tool)  i think it is PORT_OWNER bit, Eran can elaborate
more if needed.
3.1 and 2 are required for  mlx5_set_port_admin_status to take effect,
otherwise it is a NOOP.

Eran tested this patch and it works for him, maybe you missed step 2.
Step 2 will not be required in future FW (it will be the FW default).
Other than this patch, nothing more is required for driver to assume
ownership on port's link status.

> Until this is properly fixed the mlx5 driver is blacklisted in our test:
> https://github.com/jpirko/lnst/blob/master/recipes/switchdev/basic-001-links.py#L19
>
> Also, why is this directed at net-next?
>

it is kind of new behavior, and not a bug fix.

>> drivers/infiniband/hw/mlx5/main.c                  |   11 +++++++++++
>> drivers/infiniband/hw/mlx5/mlx5_ib.h               |    5 +++++
>> drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c |    4 ++--
>> .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |    4 ++--
>> drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |    4 ++++
>> drivers/net/ethernet/mellanox/mlx5/core/main.c     |    4 ++++
>> drivers/net/ethernet/mellanox/mlx5/core/port.c     |    5 +++--
>> include/linux/mlx5/port.h                          |    3 ++-
>> 8 files changed, 33 insertions(+), 7 deletions(-)
>>
>
> [...]
>
>>diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
>>index b2db180..f083797 100644
>>--- a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
>>+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
>>@@ -202,12 +202,12 @@ static int mlx5e_dcbnl_ieee_setpfc(struct net_device *dev,
>>
>>       mlx5_query_port_admin_status(mdev, &ps);
>>       if (ps == MLX5_PORT_UP)
>>-              mlx5_set_port_admin_status(mdev, MLX5_PORT_DOWN);
>>+              mlx5_set_port_admin_status(mdev, MLX5_PORT_DOWN, 1);
>
> Why is this needed? The link doesn't need to go through training when
> setting PFC. It's only needed for PAUSE frames when auto-negotiation is
> on, but you don't support that anyway.
>
> Thanks.
>

The code was there before this patch, only the function prototype was changed.
Maybe you have a valid point here, but this need to be fixed in a
different patch, it has nothing to do with this one.
Eran and Team please check this on Sunday, I found nothing re this
matter in PRM.
