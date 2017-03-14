From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v1 for accelerated IPoIB 05/25] IB/ipoib: Support ipoib
 acceleration options callbacks
Date: Mon, 13 Mar 2017 23:35:38 -0700
Message-ID: <20170314063538.GB79937@knc-06.sc.intel.com>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
 <1489429896-10781-6-git-send-email-erezsh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, valex-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        saedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, erezsh-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org
To: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1489429896-10781-6-git-send-email-erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 13, 2017 at 08:31:16PM +0200, Erez Shitrit wrote:
>+static struct net_device *ipoib_create_netdev_default(struct ib_device *hca,
>+						      const char *name,
>+						      void (*setup)(struct net_device *))
> {
> 	struct net_device *dev;
>+	struct rdma_netdev *rn;
>
>-	dev = alloc_netdev((int)sizeof(struct ipoib_dev_priv), name,
>-			   NET_NAME_UNKNOWN, ipoib_setup);
>+	dev = alloc_netdev((int)sizeof(struct ipoib_rdma_netdev),
>+			   name,
>+			   NET_NAME_UNKNOWN, setup);
> 	if (!dev)
> 		return NULL;
>
>-	return netdev_priv(dev);
>+	rn = netdev_priv(dev);
>+
>+	rn->ib_dev_init = ipoib_dev_init_default;
>+	rn->ib_dev_cleanup = ipoib_dev_uninit_default;
>+	rn->send = ipoib_send;
>+	rn->attach_mcast = ipoib_mcast_attach;
>+	rn->detach_mcast = ipoib_mcast_detach;
>+
>+	dev->netdev_ops = &ipoib_netdev_default_pf;
>+

Probably no need to set netdev_ops here as it gets overwritten.

>+	return dev;
>+}
>+
>+struct ipoib_dev_priv *ipoib_intf_alloc(struct ib_device *hca, u8 port,
>+					const char *name)
>+{
>+	struct net_device *dev;
>+	struct ipoib_dev_priv *priv;
>+	struct rdma_netdev *rn;
>+
>+	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
>+	if (!priv) {
>+		pr_err("%s failed allocting priv\n", __func__);
>+		return NULL;
>+	}
>+
>+	if (!hca->alloc_rdma_netdev)
>+		dev = ipoib_create_netdev_default(hca, name, ipoib_setup_common);
>+	else
>+		dev = hca->alloc_rdma_netdev(hca, port, RDMA_NETDEV_IPOIB,
>+					     name, NET_NAME_UNKNOWN,
>+					     ipoib_setup_common);
>+	if (!dev) {
>+		kfree(priv);
>+		return NULL;
>+	}

This will break ipoib on hfi1 as hfi1 will define alloc_rdma_netdev for 
OPA_VNIC type. We should probably look for a dedicated return type (-ENODEV?) 
to determine of the driver supports specified rdma netdev type. Or use a ib 
device attribute to suggest driver support ipoib rdma netdev.

Niranjana
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
