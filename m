From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [PATCH net-next 12/12] net/mlx5e: Disable link up on INIT HCA
 command
Date: Sat, 23 Apr 2016 19:00:23 +0300
Message-ID: <20160423160023.GA15013@colbert.Home>
References: <1461351647-27412-1-git-send-email-saeedm@mellanox.com>
 <1461351647-27412-13-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Or Gerlitz" <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	"Eran Ben Elisha" <eranbe@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>, <jiri@mellanox.com>,
	<eladr@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0077.outbound.protection.outlook.com ([157.56.112.77]:11006
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751455AbcDWQRu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Apr 2016 12:17:50 -0400
Content-Disposition: inline
In-Reply-To: <1461351647-27412-13-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Fri, Apr 22, 2016 at 10:00:47PM IDT, saeedm@mellanox.com wrote:
>From: Eran Ben Elisha <eranbe@mellanox.com>
>
>Disable link up when initializing the HCA. Link up/down will be changed
>using (Ports Administrative and Operational Status Register) PAOS
>commands.
>
>If link layer is Ethernet, up/down the link in ndo_open/stop.  If link
>layer is IB, up/down the link as part of the mlx5 IB add/remove flow.
>
>Before this patch the link was up when the HCA was initialized, now the
>driver will manage the link.
>
>Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
>Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
>Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
>---

mutt suggests I sent you the following patches a while ago:

net/mlx5e: Set port administrative status in ndo_{open, close}
net/mlx5e: Initialize port administrative status to down

So I'm curious as to why you didn't follow up on them and instead came
up with this patch.

When I initially debugged this I pointed you to the fact that the
firmware also needs to be patched, as setting the administrative status
down via PAOS doesn't really do anything. The operational status will
remain up. I just tested this patchset with the latest release firmware
(12.14.2036) and I'm bumping into the same problem.

Until this is properly fixed the mlx5 driver is blacklisted in our test:
https://github.com/jpirko/lnst/blob/master/recipes/switchdev/basic-001-links.py#L19

Also, why is this directed at net-next?

> drivers/infiniband/hw/mlx5/main.c                  |   11 +++++++++++
> drivers/infiniband/hw/mlx5/mlx5_ib.h               |    5 +++++
> drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c |    4 ++--
> .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |    4 ++--
> drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |    4 ++++
> drivers/net/ethernet/mellanox/mlx5/core/main.c     |    4 ++++
> drivers/net/ethernet/mellanox/mlx5/core/port.c     |    5 +++--
> include/linux/mlx5/port.h                          |    3 ++-
> 8 files changed, 33 insertions(+), 7 deletions(-)
>

[...]

>diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
>index b2db180..f083797 100644
>--- a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
>+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
>@@ -202,12 +202,12 @@ static int mlx5e_dcbnl_ieee_setpfc(struct net_device *dev,
> 
> 	mlx5_query_port_admin_status(mdev, &ps);
> 	if (ps == MLX5_PORT_UP)
>-		mlx5_set_port_admin_status(mdev, MLX5_PORT_DOWN);
>+		mlx5_set_port_admin_status(mdev, MLX5_PORT_DOWN, 1);

Why is this needed? The link doesn't need to go through training when
setting PFC. It's only needed for PAUSE frames when auto-negotiation is
on, but you don't support that anyway.

Thanks.

> 
> 	ret = mlx5_set_port_pfc(mdev, pfc->pfc_en, pfc->pfc_en);
> 
> 	if (ps == MLX5_PORT_UP)
>-		mlx5_set_port_admin_status(mdev, MLX5_PORT_UP);
>+		mlx5_set_port_admin_status(mdev, MLX5_PORT_UP, 1);
> 
> 	return ret;
> }
