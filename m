From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: Re: [PATCH net-next] mlx4: support __GFP_MEMALLOC for rx
Date: Wed, 18 Jan 2017 12:31:18 +0300
Message-ID: <2696ea05-bb39-787b-2029-33b729fd88e0@yandex-team.ru>
References: <1484712850.13165.86.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Tariq Toukan <tariqt@mellanox.com>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>, David Miller <davem@davemloft.net>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1484712850.13165.86.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 18.01.2017 07:14, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Commit 04aeb56a1732 ("net/mlx4_en: allocate non 0-order pages for RX
> ring with __GFP_NOMEMALLOC") added code that appears to be not needed at
> that time, since mlx4 never used __GFP_MEMALLOC allocations anyway.
>
> As using memory reserves is a must in some situations (swap over NFS or
> iSCSI), this patch adds this flag.

AFAIK __GFP_MEMALLOC is used for TX, not for RX: for allocations which are required by memory reclaimer to free some pages.

Allocation RX buffers with __GFP_MEMALLOC is a straight way to depleting all reserves by flood from network.

>
> Note that this driver does not reuse pages (yet) so we do not have to
> add anything else.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Cc: Tariq Toukan <tariqt@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> index eac527e25ec902c2a586e9952272b9e8e599e2c8..e362f99334d03c0df4d88320977670015870dd9c 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> @@ -706,7 +706,8 @@ static bool mlx4_en_refill_rx_buffers(struct mlx4_en_priv *priv,
>  	do {
>  		if (mlx4_en_prepare_rx_desc(priv, ring,
>  					    ring->prod & ring->size_mask,
> -					    GFP_ATOMIC | __GFP_COLD))
> +					    GFP_ATOMIC | __GFP_COLD |
> +					    __GFP_MEMALLOC))
>  			break;
>  		ring->prod++;
>  	} while (--missing);
>
>


-- 
Konstantin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
