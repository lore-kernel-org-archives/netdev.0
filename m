From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [RFC v1 for accelerated IPoIB 25/25] mlx5_ib: skeleton for
 mlx5_ib to support ipoib_ops
Date: Mon, 13 Mar 2017 14:27:20 -0600
Message-ID: <20170313202720.GC2738@obsidianresearch.com>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
 <1489429896-10781-26-git-send-email-erezsh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, valex-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        saedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, erezsh-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org
To: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1489429896-10781-26-git-send-email-erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 13, 2017 at 08:31:36PM +0200, Erez Shitrit wrote:

> +struct net_device *mlx5_alloc_rdma_netdev(struct ib_device *hca,
> +				     u8 port_num,
> +				     enum rdma_netdev_t type,
> +				     const char *name,
> +				     unsigned char name_assign_type,
> +				     void (*setup)(struct net_device *));
> +void mlx5_free_rdma_netdev(struct net_device *netdev);

Seems like OK signatures to me..

> +	dev->ib_dev.alloc_rdma_netdev	= mlx5_alloc_rdma_netdev;
> +	dev->ib_dev.free_rdma_netdev	= mlx5_free_rdma_netdev;

Since mlx5_free_rdma_netdev is empty this should just be NULL

> +int mlx5_ib_dev_init(struct net_device *dev, struct ib_device *hca,
> +		     int *qp_num)
> +{
> +	void *next_priv = ipoib_dev_priv(dev);
> +	struct rdma_netdev *rn = netdev_priv(dev);
> +	struct mlx5_ib_dev *ib_dev = to_mdev(hca);
> +	int ret;
> +
> +	ret = mlx5i_attach(ib_dev->mdev, next_priv);
> +	if (ret) {
> +		pr_err("Failed resources allocation for device: %s ret: %d\n",
> +		       dev->name, ret);
> +		return ret;
> +	}
> +
> +	*qp_num = rn->qp_num;
> +
> +	pr_debug("resources allocated for device: %s\n", dev->name);
> +
> +	return 0;
> +}
> +
> +void mlx5_ib_dev_cleanup(struct net_device *dev, struct ib_device *hca)
> +{
> +	void *next_priv = ipoib_dev_priv(dev);
> +	struct rdma_netdev *rn = netdev_priv(dev);
> +	struct mlx5_ib_dev *ib_dev = to_mdev(hca);
> +	struct mlx5_qp_context context;
> +	int ret;
> +
> +	/* detach qp from flow-steering by reset it */
> +	ret = mlx5_core_qp_modify(ib_dev->mdev,
> +				  MLX5_CMD_OP_2RST_QP, 0, &context,
> +				  (struct mlx5_core_qp *)rn->context);
> +	if (ret)
> +		pr_err("%s failed (ret: %d) to reset QP\n", __func__, ret);
> +
> +	mlx5i_detach(ib_dev->mdev, next_priv);
> +
> +	mlx5_ib_clean_qp(ib_dev, (struct mlx5_core_qp *)rn->context);
> +}

Why isn't this stuff in open/close?

> +void mlx5_ib_send(struct net_device *dev, struct sk_buff *skb,
> +		  struct ipoib_ah *address, u32 dqpn, u32 dqkey)
> +{
> +	void *next_priv = ipoib_dev_priv(dev);
> +
> +	mlx5i_xmit(skb, next_priv, &to_mah(address->ah)->av, dqpn, dqkey);

How come the qkey is not available via ipoib_ah ?

to_mah(address->ah)->av->key.qkey.qkey

?

> +static const struct net_device_ops ipoib_netdev_default_pf = {

That is a weird name for a mlx5 specific structure.

> +	param.size_base_priv = sizeof(struct ipoib_rdma_netdev);

This is really weird, the code in mlx5i_create_netdev calls
ipoib_dev_priv so it must assume the struct is a ipoib_rdma_netdev.

> +	/* set func pointers */
> +	rn = netdev_priv(dev);
> +	rn->qp_num = qp->qpn;
> +	rn->context = qp;

No for using context.. You need your own driver priv, like this:

struct mlx4_rn_priv
{
    struct mlx5e_priv priv;
    struct mlx5_core_qp *qp;
};

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
