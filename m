From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 06/10] {NET,IB}/mlx4: Add device managed flow
 steering firmware API
Date: Mon, 2 Jul 2012 11:28:18 +0300
Message-ID: <4FF15BA2.5000104@mellanox.com>
References: <1341135823-29039-7-git-send-email-ogerlitz@mellanox.com> <20120701.033055.489908836962064737.davem@davemloft.net> <4FF042B5.1000303@mellanox.com> <20120701.144252.792146486861614931.davem@davemloft.net> <4FF153F0.8080707@mellanox.com> <CAG4TOxNyxP8FpzNdMZR3WMvFCQtEx_r3oLh6s7sZOcBnqN=6tA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <yevgenyp@mellanox.com>,
	<oren@mellanox.com>, <netdev@vger.kernel.org>,
	<hadarh@mellanox.co.il>
To: Roland Dreier <roland@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:56251 "HELO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753161Ab2GBI20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 04:28:26 -0400
In-Reply-To: <CAG4TOxNyxP8FpzNdMZR3WMvFCQtEx_r3oLh6s7sZOcBnqN=6tA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/2/2012 11:14 AM, Roland Dreier wrote:
> What was wrong with Dave's initial suggestion of ethtool? All the 
> other steering stuff is configured that way, why not this hash?

Roland, as I wrote earlier on this thread -->  [...] pointed out in the 
change-log, note that this policy is **global** to the HCA, that is 
effects all the Ethernet (and down the road, also when adding support 
for IPoIB flow-steering, under a config of card with one IB port and one 
Eth port) net-devices that relate to that mlx4 device instance.

In a system with (say) one card and two Ethernet ports, where for each 
port there's corresponding ethN interface, **both** mlx4_en net-devices 
use the same instance of struct mlx4_device, which means that if we let 
the user to set through ethtool the flow steering hash of ethN1 this 
will evetually change also the hash used for packets going to ethN2, or 
in other words, in mlx4 language this param belong to the mlx4_core 
module. In that respect, I was  thinking on using sysfs as we do for the 
port link type and IB mtu, hope this makes things clearer, SB  the 
relevant code, now with the global module param which can change to 
using per mlx4_core device sysfs.

Or.



> --- a/drivers/net/ethernet/mellanox/mlx4/main.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
> @@ -1231,6 +1236,21 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
>   			goto err_stop_fw;
>   		}
>   
> +		priv->fs_hash_mode = mlx4_flow_steering_hash;
> +
> +		switch (priv->fs_hash_mode) {
> +		case MLX4_FS_L2_HASH:
> +			init_hca.fs_hash_enable_bits = 0;
> +			break;
> +
> +		case MLX4_FS_L2_L3_L4_HASH:
> +			/* Enable flow steering with
> +			   udp unicast and tcp unicast*/
> +			init_hca.fs_hash_enable_bits =
> +				MLX4_FS_UDP_UC_EN | MLX4_FS_TCP_UC_EN;
> +			break;
> +		}
> +
>   		profile = default_profile;
>   		if (dev->caps.steering_mode ==
>   		    MLX4_STEERING_MODE_DEVICE_MANAGED)
