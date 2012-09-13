From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: GRO aggregation
Date: Thu, 13 Sep 2012 14:34:31 +0200
Message-ID: <1347539671.13103.1542.camel@edumazet-glaptop>
References: <504F4063.9030706@mellanox.com>
	 <1347388396.13103.658.camel@edumazet-glaptop>
	 <36F7E4A28C18BE4DB7C86058E7B607241E622022@MTRDAG01.mtl.com>
	 <1347390113.13103.660.camel@edumazet-glaptop>
	 <36F7E4A28C18BE4DB7C86058E7B607241E622083@MTRDAG01.mtl.com>
	 <1347392132.13103.663.camel@edumazet-glaptop>
	 <505054AE.9040901@mellanox.com>
	 <1347442394.13103.703.camel@edumazet-glaptop> <50509F30.30402@mellanox.com>
	 <5050B6FF.5050002@hp.com> <5050B9B2.5070107@mellanox.com>
	 <5050BDB5.8090200@hp.com> <50517F01.9050501@mellanox.com>
	 <1347523865.13103.1423.camel@edumazet-glaptop>
	 <CAJZOPZL8qrqYfAvcQBDB9CFy7WwztWchaMyADGBnwKpW-r1Q4g@mail.gmail.com>
	 <1347537926.13103.1530.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Shlomo Pongartz <shlomop@mellanox.com>,
	Rick Jones <rick.jones2@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:52935 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752573Ab2IMMeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 08:34:37 -0400
Received: by bkwj10 with SMTP id j10so505920bkw.19
        for <netdev@vger.kernel.org>; Thu, 13 Sep 2012 05:34:36 -0700 (PDT)
In-Reply-To: <1347537926.13103.1530.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-13 at 14:05 +0200, Eric Dumazet wrote:

> But there is no real difference in throughput.
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> index 6c4f935..435c35e 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> @@ -96,8 +96,8 @@
>  /* Receive fragment sizes; we use at most 4 fragments (for 9600 byte MTU
>   * and 4K allocations) */
>  enum {
> -	FRAG_SZ0 = 512 - NET_IP_ALIGN,
> -	FRAG_SZ1 = 1024,
> +	FRAG_SZ0 = 1536 - NET_IP_ALIGN,
> +	FRAG_SZ1 = 2048,
>         FRAG_SZ2 = 4096,
>         FRAG_SZ3 = MLX4_EN_ALLOC_SIZE
>  };
> 

Oh well, adding one prefetch() is giving ~10% more throughput.

I guess this mlx4 driver needs some care.

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 5aba5ec..547eec8 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -38,6 +38,7 @@
 #include <linux/if_ether.h>
 #include <linux/if_vlan.h>
 #include <linux/vmalloc.h>
+#include <linux/prefetch.h>
 
 #include "mlx4_en.h"
 
@@ -617,7 +618,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		    !((dev->features & NETIF_F_LOOPBACK) ||
 		      priv->validate_loopback))
 			goto next;
-
+		/* avoid cache miss in tcp_gro_receive() */
+		prefetch((char *)ethh + 64);
 		/*
 		 * Packet is OK - process it.
 		 */
