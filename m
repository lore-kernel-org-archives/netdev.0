From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next] net/mlx4: use one page fragment per incoming
 frame
Date: Tue, 4 Jun 2013 11:40:59 +0300
Message-ID: <51ADA81B.1040305@mellanox.com>
References: <1370282095.24311.171.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:37453 "EHLO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751241Ab3FDIlF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 04:41:05 -0400
In-Reply-To: <1370282095.24311.171.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/06/2013 20:54, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> mlx4 driver has a suboptimal memory allocation strategy for regular
> MTU=1500 frames, as it uses two page fragments :
> 
> One of 512 bytes and one of 1024 bytes.
> 
> This makes GRO less effective, as each GSO packet contains 8 MSS instead
> of 16 MSS.
> 
> Performance of a single TCP flow gains 25 % increase with the following
> patch.
> 
> Before patch :
> 
> A:~# netperf -H 192.168.0.2 -Cc
> MIGRATED TCP STREAM TEST ...
> Recv   Send    Send                          Utilization       Service Demand
> Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
> Size   Size    Size     Time     Throughput  local    remote   local   remote
> bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB
> 
>  87380  16384  16384    10.00      13798.47   3.06     4.20     0.436   0.598  
> 
> After patch :
> 
> A:~# netperf -H 192.68.0.2 -Cc
> MIGRATED TCP STREAM TEST ...
> Recv   Send    Send                          Utilization       Service Demand
> Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
> Size   Size    Size     Time     Throughput  local    remote   local   remote
> bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB
> 
>  87380  16384  16384    10.00      17273.80   3.44     4.19     0.391   0.477  
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Amir Vadai <amirv@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> index b1d7657..b1f51c1 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> @@ -98,11 +98,11 @@
>  #define MLX4_EN_ALLOC_SIZE	PAGE_ALIGN(16384)
>  #define MLX4_EN_ALLOC_ORDER	get_order(MLX4_EN_ALLOC_SIZE)
>  
> -/* Receive fragment sizes; we use at most 4 fragments (for 9600 byte MTU
> +/* Receive fragment sizes; we use at most 3 fragments (for 9600 byte MTU
>   * and 4K allocations) */
>  enum {
> -	FRAG_SZ0 = 512 - NET_IP_ALIGN,
> -	FRAG_SZ1 = 1024,
> +	FRAG_SZ0 = 1536 - NET_IP_ALIGN,
> +	FRAG_SZ1 = 4096,
>  	FRAG_SZ2 = 4096,
>  	FRAG_SZ3 = MLX4_EN_ALLOC_SIZE
>  };
> 
> 

Acked-By: Amir Vadai <amirv@mellanox.com>

We are currently working on a patch to change the skb allocation scheme
for the RX side, because the current mlx4_en architecture is behaving
very bad when IOMMU is enabled.
After this change, the driver will use one fragment, among other
improvements. The most important will be fragments recycling to save
alloc/free and dma_map/unmap.

But, I think it will be a good idea to apply your fix now in case there
will be delays.

Thanks,
Amir
