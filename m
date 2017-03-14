From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v1 for accelerated IPoIB 04/25] IB/verb: Add ipoib_options
 struct and API
Date: Mon, 13 Mar 2017 23:44:09 -0700
Message-ID: <20170314064409.GC79937@knc-06.sc.intel.com>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
 <1489429896-10781-5-git-send-email-erezsh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, valex-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        saedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, erezsh-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org
To: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1489429896-10781-5-git-send-email-erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 13, 2017 at 08:31:15PM +0200, Erez Shitrit wrote:
>+struct ipoib_rdma_netdev {
>+	struct rdma_netdev rn;  /* keep this first */
>+	/* followed by device private data */
>+	char *dev_priv[0];
>+};
>+
>+static inline void *ipoib_priv(const struct net_device *dev)
>+{
>+	struct rdma_netdev *rn = netdev_priv(dev);
>+
>+	return rn->clnt_priv;
>+}
>+
>+static inline void *ipoib_dev_priv(const struct net_device *dev)
>+{
>+	struct ipoib_rdma_netdev *ipoib_rn = netdev_priv(dev);
>+
>+	return ipoib_rn->dev_priv;
>+}
>+

It can be confusing to see return of ipoib_priv() getting assigned to 
ipoib_dev_priv (legacy name). May be we should change ipoib_dev_priv() to 
ipoib_hw_priv()?


>+#endif /* IB_IPOIB_ACCEL_OPS_H */
>diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
>index 85b9034c8cfc..9b090efccdba 100644
>--- a/include/rdma/ib_verbs.h
>+++ b/include/rdma/ib_verbs.h
>@@ -1901,6 +1901,41 @@ struct ib_port_immutable {
> 	u32                           max_mad_size;
> };
>
>+/* rdma netdev type - specifies protocol type */
>+enum rdma_netdev_t {
>+	RDMA_NETDEV_OPA_VNIC,
>+	RDMA_NETDEV_IPOIB
>+};
>+
>+struct ipoib_ah;
>+
>+/**
>+ * struct rdma_netdev - rdma netdev
>+ * For cases where netstack interfacing is required.
>+ */
>+struct rdma_netdev {
>+	void *clnt_priv;
>+
>+	/* control functions */
>+	void (*set_id)(struct net_device *netdev, int id);
>+	/* IB resource allocation function, returns new UD QP */
>+	int (*ib_dev_init)(struct net_device *dev, struct ib_device *hca,
>+			   int *qp_num);
>+	void (*ib_dev_cleanup)(struct net_device *dev, struct ib_device *hca);
>+
>+	/* send packet */
>+	void (*send)(struct net_device *dev, struct sk_buff *skb,
>+		     struct ipoib_ah *address, u32 dqpn, u32 dqkey);
>+
>+	/* multicast */
>+	int (*attach_mcast)(struct net_device *dev, struct ib_device *hca,
>+			    union ib_gid *gid, u16 lid, int set_qkey);
>+	int (*detach_mcast)(struct net_device *dev, struct ib_device *hca,
>+			    union ib_gid *gid, u16 lid);
>+	int qp_num;

May be ipoib_rdma_netdev structure is the right place for these functions?

>+	void *context;

No context should be necessary here.

>+};
>+
> struct ib_device {
> 	struct device                *dma_device;
>
>@@ -2149,6 +2184,7 @@ struct ib_device {
> 						struct ib_wq_attr *attr,
> 						u32 wq_attr_mask,
> 						struct ib_udata *udata);
>+	struct ib_ipoib_accel_ops * (*get_ipoib_accel_ops)(struct ib_device *device);

old code, needs fix.

Niranjana
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
