From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 4 Jul 2016 13:07:22 +1000
Message-ID: <20160704130722.735f94c9@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Jurgens <danielj@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/ethernet/mellanox/mlx5/core/en_main.c

between commit:

  29429f3300a3 ("net/mlx5e: Timeout if SQ doesn't flush during close")

from the net tree and commit:

  507f0c817f7a ("net/mlx5e: Add TXQ set max rate support")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 7a0dca29c642,96ec53a6a595..000000000000
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@@ -39,16 -39,10 +39,17 @@@
  #include "eswitch.h"
  #include "vxlan.h"
  
 +enum {
 +	MLX5_EN_QP_FLUSH_TIMEOUT_MS	= 5000,
 +	MLX5_EN_QP_FLUSH_MSLEEP_QUANT	= 20,
 +	MLX5_EN_QP_FLUSH_MAX_ITER	= MLX5_EN_QP_FLUSH_TIMEOUT_MS /
 +					  MLX5_EN_QP_FLUSH_MSLEEP_QUANT,
 +};
 +
  struct mlx5e_rq_param {
- 	u32                        rqc[MLX5_ST_SZ_DW(rqc)];
- 	struct mlx5_wq_param       wq;
+ 	u32			rqc[MLX5_ST_SZ_DW(rqc)];
+ 	struct mlx5_wq_param	wq;
+ 	bool			am_enabled;
  };
  
  struct mlx5e_sq_param {
@@@ -574,8 -543,9 +582,10 @@@ static void mlx5e_close_rq(struct mlx5e
  	/* avoid destroying rq before mlx5e_poll_rx_cq() is done with it */
  	napi_synchronize(&rq->channel->napi);
  
+ 	cancel_work_sync(&rq->am.work);
+ 
  	mlx5e_disable_rq(rq);
 +	mlx5e_free_rx_descs(rq);
  	mlx5e_destroy_rq(rq);
  }
  
@@@ -835,19 -810,12 +853,19 @@@ static void mlx5e_close_sq(struct mlx5e
  		if (mlx5e_sq_has_room_for(sq, 1))
  			mlx5e_send_nop(sq, true);
  
 -		mlx5e_modify_sq(sq, MLX5_SQC_STATE_RDY, MLX5_SQC_STATE_ERR,
 -				false, 0);
 +		err = mlx5e_modify_sq(sq, MLX5_SQC_STATE_RDY,
- 				      MLX5_SQC_STATE_ERR);
++				      MLX5_SQC_STATE_ERR, false, 0);
 +		if (err)
 +			set_bit(MLX5E_SQ_STATE_TX_TIMEOUT, &sq->state);
  	}
  
 -	while (sq->cc != sq->pc) /* wait till sq is empty */
 -		msleep(20);
 +	/* wait till sq is empty, unless a TX timeout occurred on this SQ */
 +	while (sq->cc != sq->pc &&
 +	       !test_bit(MLX5E_SQ_STATE_TX_TIMEOUT, &sq->state)) {
 +		msleep(MLX5_EN_QP_FLUSH_MSLEEP_QUANT);
 +		if (tout++ > MLX5_EN_QP_FLUSH_MAX_ITER)
 +			set_bit(MLX5E_SQ_STATE_TX_TIMEOUT, &sq->state);
 +	}
  
  	/* avoid destroying sq before mlx5e_poll_tx_cq() is done with it */
  	napi_synchronize(&sq->channel->napi);
