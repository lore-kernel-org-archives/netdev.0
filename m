From: Yishai Hadas <yishaih@dev.mellanox.co.il>
Subject: Re: [PATCH 3/5] net/mlx4: fix some error handling in
 mlx4_multi_func_init()
Date: Wed, 10 Feb 2016 11:40:07 +0200
Message-ID: <56BB0577.8000000@dev.mellanox.co.il>
References: <1455048677-19882-1-git-send-email-linux@rasmusvillemoes.dk>
 <1455048677-19882-4-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yishai Hadas <yishaih@mellanox.com>, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	"jackm@mellanox.com" <jackm@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455048677-19882-4-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/9/2016 10:11 PM, Rasmus Villemoes wrote:
> The while loop after err_slaves should use post-decrement; otherwise
> we'll fail to do the kfrees for i==0, and will run into out-of-bounds
> accesses if the setup above failed already at i==0.
>
> The predecrement in the --port is ok, since ->vlan_filter is
> (bizarrely) 1-indexed. But I'm changing 'if' to 'while' since it's a
> bit ugly to rely on MLX4_MAX_PORTS being 2.
>
> [I'm not sure why one even bothers populating the ->vlan_filter array:
> mlx4.h isn't #included by anything outside
> drivers/net/ethernet/mellanox/mlx4/, and "git grep -C2 -w vlan_filter
> drivers/net/ethernet/mellanox/mlx4/" seems to suggest that the
> vlan_filter elements aren't used at all.]
>
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
> ---
>   drivers/net/ethernet/mellanox/mlx4/cmd.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
> index d48d5793407d..bfe8234abbba 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
> @@ -2369,7 +2369,7 @@ int mlx4_multi_func_init(struct mlx4_dev *dev)
>   					kzalloc(sizeof(struct mlx4_vlan_fltr),
>   						GFP_KERNEL);
>   				if (!s_state->vlan_filter[port]) {
> -					if (--port)
> +					while (--port)

Prefer to leave as-is. There is no way that mlx4 will ever have more 
than 2 ports.

>   						kfree(s_state->vlan_filter[port]);
>   					goto err_slaves;
>   				}
> @@ -2429,7 +2429,7 @@ err_thread:
>   	flush_workqueue(priv->mfunc.master.comm_wq);
>   	destroy_workqueue(priv->mfunc.master.comm_wq);
>   err_slaves:
> -	while (--i) {
> +	while (i--) {

This fix is wrong as it hits the case that i arrived the last value then 
below code will access to a non valid entry in the array.

The expected fix should be:
while (--i >= 0)

>   		for (port = 1; port <= MLX4_MAX_PORTS; port++)
>   			kfree(priv->mfunc.master.slave_state[i].vlan_filter[port]);
>   	}
>
