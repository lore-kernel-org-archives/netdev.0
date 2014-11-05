From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH V1 net-next 5/5] net/mlx4_core: Add retrieval of CONFIG_DEV
 parameters
Date: Wed, 5 Nov 2014 11:19:46 +0200
Message-ID: <5459EBB2.1040609@mellanox.com>
References: <1414938377-421-1-git-send-email-ogerlitz@mellanox.com>	 <1414938377-421-6-git-send-email-ogerlitz@mellanox.com> <1415119714.1005.3.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Matan Barak" <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:37271 "EHLO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751408AbaKEJUE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 04:20:04 -0500
In-Reply-To: <1415119714.1005.3.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/4/2014 6:48 PM, Eric Dumazet wrote:

> This added following warnings :
>
>    CC      drivers/net/ethernet/mellanox/mlx4/fw.o
> drivers/net/ethernet/mellanox/mlx4/fw.c: In function 'mlx4_config_dev_retrieval':
> drivers/net/ethernet/mellanox/mlx4/fw.c:1944:12: warning: 'config_dev.rx_checksum_val' may be used uninitialized in this function [-Wmaybe-uninitialized]
> In file included from include/linux/swab.h:4:0,
>                   from include/uapi/linux/byteorder/little_endian.h:12,
>                   from include/linux/byteorder/little_endian.h:4,
>                   from ./arch/x86/include/uapi/asm/byteorder.h:4,
>                   from include/asm-generic/bitops/le.h:5,
>                   from ./arch/x86/include/asm/bitops.h:504,
>                   from include/linux/bitops.h:33,
>                   from include/linux/kernel.h:10,
>                   from include/linux/skbuff.h:17,
>                   from include/linux/if_ether.h:23,
>                   from include/linux/etherdevice.h:25,
>                   from drivers/net/ethernet/mellanox/mlx4/fw.c:35:
> include/uapi/linux/swab.h:53:93: warning: 'config_dev.vxlan_udp_dport' may be used uninitialized in this function [-Wmaybe-uninitialized]
> drivers/net/ethernet/mellanox/mlx4/fw.c:1922:25: note: 'config_dev.vxlan_udp_dport' was declared here
>
>

Oh, missed that since we build with CONFIG_CC_OPTIMIZE_FOR_SIZE which 
for some reason cause the kernel Makefile to mask away that warning?!

> ifdef CONFIG_CC_OPTIMIZE_FOR_SIZE
> KBUILD_CFLAGS   += -Os $(call cc-disable-warning,maybe-uninitialized,)
> else
> KBUILD_CFLAGS   += -O2
> endif

Anyway, this seems as false positive since just before using the struct 
mlx4_config_dev instance we go through mlx4_CONFIG_DEV_get() which 
either fills in values for the fields or return error and in that case, 
we don't use them... the below patch makes gcc (4.8.2) happy, but it's 
not really needed... thoughts?

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c 
b/drivers/net/ethernet/mellanox/mlx4/fw.c
index d6dba77..9a4703f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -1929,7 +1929,7 @@ int mlx4_config_dev_retrieval(struct mlx4_dev *dev,

         if (!(dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_CONFIG_DEV))
                 return -ENOTSUPP;
-
+       memset(&config_dev, 0, sizeof(config_dev));
         err = mlx4_CONFIG_DEV_get(dev, &config_dev);
         if (err)
                 return err;

Or.
