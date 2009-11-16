From: Eli Cohen <eli-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCHv6 10/10] mlx4: Add RDMAoE support - allow interfaces to
 correspond to each other
Date: Mon, 16 Nov 2009 17:54:15 +0200
Message-ID: <20091116155415.GK2463@mtls03>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux RDMA list <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, ewg <ewg-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org>
To: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <ewg-bounces-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/ewg>,
	<mailto:ewg-request-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/ewg>
List-Post: <mailto:ewg-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org>
List-Help: <mailto:ewg-request-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/ewg>,
	<mailto:ewg-request-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org?subject=subscribe>
Sender: ewg-bounces-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org
Errors-To: ewg-bounces-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds RDMAoE support for mlx4. Since mlx4_ib now needs to reference
mlx4_en netdevices, a new mechanism was added. Two new fields were added to
struct mlx4_interface to define a protocol and a get_prot_dev method to
retrieve the corresponding protocol's net device.  An implementation of the new
verb ib_get_port_link_type() - mlx4_ib_get_port_link_type - was added.
mlx4_ib_query_port() has been modified to support eth link types. An interface
is considered to be active if its corresponding eth interface is active. Code
for setting the GID table of a port has been added. Currently, each IB port has
a single GID entry in its table and that GID entery equals the link local IPv6
address.

Signed-off-by: Eli Cohen <eli-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
---
 drivers/infiniband/hw/mlx4/main.c    |  436 +++++++++++++++++++++++++++++++---
 drivers/infiniband/hw/mlx4/mlx4_ib.h |   11 +
 drivers/infiniband/hw/mlx4/qp.c      |   27 ++-
 drivers/net/mlx4/en_main.c           |   15 +-
 drivers/net/mlx4/en_port.c           |    4 +-
 drivers/net/mlx4/en_port.h           |    3 +-
 drivers/net/mlx4/intf.c              |   20 ++
 drivers/net/mlx4/main.c              |    6 +
 drivers/net/mlx4/mlx4.h              |    1 +
 include/linux/mlx4/cmd.h             |    1 +
 include/linux/mlx4/driver.h          |   16 +-
 11 files changed, 493 insertions(+), 47 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index e596537..df52e57 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -34,9 +34,13 @@
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/errno.h>
+#include <linux/netdevice.h>
+#include <linux/inetdevice.h>
+#include <linux/rtnetlink.h>
 
 #include <rdma/ib_smi.h>
 #include <rdma/ib_user_verbs.h>
+#include <rdma/ib_addr.h>
 
 #include <linux/mlx4/driver.h>
 #include <linux/mlx4/cmd.h>
@@ -57,6 +61,15 @@ static const char mlx4_ib_version[] =
 	DRV_NAME ": Mellanox ConnectX InfiniBand driver v"
 	DRV_VERSION " (" DRV_RELDATE ")\n";
 
+struct update_gid_work {
+	struct work_struct work;
+	union ib_gid gids[128];
+	int port;
+	struct mlx4_ib_dev *dev;
+};
+
+static struct workqueue_struct *wq;
+
 static void init_query_mad(struct ib_smp *mad)
 {
 	mad->base_version  = 1;
@@ -152,28 +165,19 @@ out:
 	return err;
 }
 
-static int mlx4_ib_query_port(struct ib_device *ibdev, u8 port,
-			      struct ib_port_attr *props)
+static enum rdma_transport_type
+mlx4_ib_port_get_transport(struct ib_device *device, u8 port_num)
 {
-	struct ib_smp *in_mad  = NULL;
-	struct ib_smp *out_mad = NULL;
-	int err = -ENOMEM;
-
-	in_mad  = kzalloc(sizeof *in_mad, GFP_KERNEL);
-	out_mad = kmalloc(sizeof *out_mad, GFP_KERNEL);
-	if (!in_mad || !out_mad)
-		goto out;
-
-	memset(props, 0, sizeof *props);
+	struct mlx4_dev *dev = to_mdev(device)->dev;
 
-	init_query_mad(in_mad);
-	in_mad->attr_id  = IB_SMP_ATTR_PORT_INFO;
-	in_mad->attr_mod = cpu_to_be32(port);
-
-	err = mlx4_MAD_IFC(to_mdev(ibdev), 1, 1, port, NULL, NULL, in_mad, out_mad);
-	if (err)
-		goto out;
+	return dev->caps.port_mask & (1 << (port_num - 1)) ?
+		RDMA_TRANSPORT_IB : RDMA_TRANSPORT_RDMAOE;
+}
 
+static void ib_link_query_port(struct ib_device *ibdev, u8 port,
+			       struct ib_port_attr *props,
+			       struct ib_smp *out_mad)
+{
 	props->lid		= be16_to_cpup((__be16 *) (out_mad->data + 16));
 	props->lmc		= out_mad->data[34] & 0x7;
 	props->sm_lid		= be16_to_cpup((__be16 *) (out_mad->data + 18));
@@ -193,6 +197,67 @@ static int mlx4_ib_query_port(struct ib_device *ibdev, u8 port,
 	props->subnet_timeout	= out_mad->data[51] & 0x1f;
 	props->max_vl_num	= out_mad->data[37] >> 4;
 	props->init_type_reply	= out_mad->data[41] >> 4;
+	props->transport	= RDMA_TRANSPORT_IB;
+}
+
+static void eth_link_query_port(struct ib_device *ibdev, u8 port,
+				struct ib_port_attr *props,
+				struct ib_smp *out_mad)
+{
+	struct mlx4_ib_rdmaoe *rdmaoe = &to_mdev(ibdev)->rdmaoe;
+	struct net_device *ndev;
+
+	props->port_cap_flags	= IB_PORT_CM_SUP;
+	props->gid_tbl_len	= to_mdev(ibdev)->dev->caps.gid_table_len[port];
+	props->max_msg_sz	= to_mdev(ibdev)->dev->caps.max_msg_sz;
+	props->pkey_tbl_len	= 1;
+	props->bad_pkey_cntr	= be16_to_cpup((__be16 *) (out_mad->data + 46));
+	props->qkey_viol_cntr	= be16_to_cpup((__be16 *) (out_mad->data + 48));
+	props->active_width	= 0;
+	props->active_speed	= 0;
+	props->max_mtu		= out_mad->data[41] & 0xf;
+	props->subnet_timeout	= 0;
+	props->max_vl_num	= out_mad->data[37] >> 4;
+	props->init_type_reply	= 0;
+	props->transport	= RDMA_TRANSPORT_RDMAOE;
+	spin_lock(&rdmaoe->lock);
+	ndev = rdmaoe->netdevs[port - 1];
+	if (!ndev)
+		goto out;
+
+	props->active_mtu	= rdmaoe_get_mtu(ndev->mtu);
+	props->state		= netif_running(ndev) &&  netif_oper_up(ndev) ?
+					IB_PORT_ACTIVE : IB_PORT_DOWN;
+	props->phys_state	= props->state;
+out:
+	spin_unlock(&rdmaoe->lock);
+}
+
+static int mlx4_ib_query_port(struct ib_device *ibdev, u8 port,
+			      struct ib_port_attr *props)
+{
+	struct ib_smp *in_mad  = NULL;
+	struct ib_smp *out_mad = NULL;
+	int err = -ENOMEM;
+
+	in_mad  = kzalloc(sizeof *in_mad, GFP_KERNEL);
+	out_mad = kmalloc(sizeof *out_mad, GFP_KERNEL);
+	if (!in_mad || !out_mad)
+		goto out;
+
+	memset(props, 0, sizeof *props);
+
+	init_query_mad(in_mad);
+	in_mad->attr_id  = IB_SMP_ATTR_PORT_INFO;
+	in_mad->attr_mod = cpu_to_be32(port);
+
+	err = mlx4_MAD_IFC(to_mdev(ibdev), 1, 1, port, NULL, NULL, in_mad, out_mad);
+	if (err)
+		goto out;
+
+	mlx4_ib_port_get_transport(ibdev, port) == RDMA_TRANSPORT_IB ?
+		ib_link_query_port(ibdev, port, props, out_mad) :
+		eth_link_query_port(ibdev, port, props, out_mad);
 
 out:
 	kfree(in_mad);
@@ -201,8 +266,8 @@ out:
 	return err;
 }
 
-static int mlx4_ib_query_gid(struct ib_device *ibdev, u8 port, int index,
-			     union ib_gid *gid)
+static int __mlx4_ib_query_gid(struct ib_device *ibdev, u8 port, int index,
+			       union ib_gid *gid)
 {
 	struct ib_smp *in_mad  = NULL;
 	struct ib_smp *out_mad = NULL;
@@ -239,6 +304,25 @@ out:
 	return err;
 }
 
+static int rdmaoe_query_gid(struct ib_device *ibdev, u8 port, int index,
+			    union ib_gid *gid)
+{
+	struct mlx4_ib_dev *dev = to_mdev(ibdev);
+
+	*gid = dev->rdmaoe.gid_table[port - 1][index];
+
+	return 0;
+}
+
+static int mlx4_ib_query_gid(struct ib_device *ibdev, u8 port, int index,
+			     union ib_gid *gid)
+{
+	if (rdma_port_get_transport(ibdev, port) == RDMA_TRANSPORT_IB)
+		return __mlx4_ib_query_gid(ibdev, port, index, gid);
+	else
+		return rdmaoe_query_gid(ibdev, port, index, gid);
+}
+
 static int mlx4_ib_query_pkey(struct ib_device *ibdev, u8 port, u16 index,
 			      u16 *pkey)
 {
@@ -287,6 +371,7 @@ static int mlx4_SET_PORT(struct mlx4_ib_dev *dev, u8 port, int reset_qkey_viols,
 {
 	struct mlx4_cmd_mailbox *mailbox;
 	int err;
+	u8 is_eth = dev->dev->caps.port_type[port] == MLX4_PORT_TYPE_ETH;
 
 	mailbox = mlx4_alloc_cmd_mailbox(dev->dev);
 	if (IS_ERR(mailbox))
@@ -302,7 +387,7 @@ static int mlx4_SET_PORT(struct mlx4_ib_dev *dev, u8 port, int reset_qkey_viols,
 		((__be32 *) mailbox->buf)[1] = cpu_to_be32(cap_mask);
 	}
 
-	err = mlx4_cmd(dev->dev, mailbox->dma, port, 0, MLX4_CMD_SET_PORT,
+	err = mlx4_cmd(dev->dev, mailbox->dma, port, is_eth, MLX4_CMD_SET_PORT,
 		       MLX4_CMD_TIME_CLASS_B);
 
 	mlx4_free_cmd_mailbox(dev->dev, mailbox);
@@ -445,18 +530,131 @@ static int mlx4_ib_dealloc_pd(struct ib_pd *pd)
 	return 0;
 }
 
+static int add_gid_entry(struct ib_qp *ibqp, union ib_gid *gid)
+{
+	struct mlx4_ib_qp *mqp = to_mqp(ibqp);
+	struct mlx4_ib_dev *mdev = to_mdev(ibqp->device);
+	struct gid_entry *ge;
+
+	ge = kzalloc(sizeof *ge, GFP_KERNEL);
+	if (!ge)
+		return -ENOMEM;
+
+	ge->gid = *gid;
+	if (mlx4_ib_add_mc(mdev, mqp, gid)) {
+		ge->port = mqp->port;
+		ge->added = 1;
+	}
+
+	mutex_lock(&mqp->mutex);
+	list_add_tail(&ge->list, &mqp->gid_list);
+	mutex_unlock(&mqp->mutex);
+
+	return 0;
+}
+
+int mlx4_ib_add_mc(struct mlx4_ib_dev *mdev, struct mlx4_ib_qp *mqp,
+		   union ib_gid *gid)
+{
+	u8 mac[6];
+	struct net_device *ndev;
+	int ret = 0;
+
+	if (!mqp->port)
+		return 0;
+
+	spin_lock(&mdev->rdmaoe.lock);
+	ndev = mdev->rdmaoe.netdevs[mqp->port - 1];
+	if (ndev)
+		dev_hold(ndev);
+	spin_unlock(&mdev->rdmaoe.lock);
+	if (ndev) {
+		rdma_get_mcast_mac((struct in6_addr *)gid, mac);
+		rtnl_lock();
+		dev_mc_add(mdev->rdmaoe.netdevs[mqp->port - 1], mac, 6, 0);
+		ret = 1;
+		rtnl_unlock();
+		dev_put(ndev);
+	}
+
+	return ret;
+}
+
 static int mlx4_ib_mcg_attach(struct ib_qp *ibqp, union ib_gid *gid, u16 lid)
 {
-	return mlx4_multicast_attach(to_mdev(ibqp->device)->dev,
-				     &to_mqp(ibqp)->mqp, gid->raw,
-				     !!(to_mqp(ibqp)->flags &
-					MLX4_IB_QP_BLOCK_MULTICAST_LOOPBACK));
+	int err;
+	struct mlx4_ib_dev *mdev = to_mdev(ibqp->device);
+	struct mlx4_ib_qp *mqp = to_mqp(ibqp);
+
+	err = mlx4_multicast_attach(mdev->dev, &mqp->mqp, gid->raw, !!mqp->flags &
+				    MLX4_IB_QP_BLOCK_MULTICAST_LOOPBACK);
+	if (err)
+		return err;
+
+	err = add_gid_entry(ibqp, gid);
+	if (err)
+		goto err_add;
+
+	return 0;
+
+err_add:
+	mlx4_multicast_detach(mdev->dev, &mqp->mqp, gid->raw);
+	return err;
+}
+
+struct gid_entry *find_gid_entry(struct mlx4_ib_qp *qp, u8 *raw)
+{
+	struct gid_entry *ge;
+	struct gid_entry *tmp;
+	struct gid_entry *ret = NULL;
+
+	list_for_each_entry_safe(ge, tmp, &qp->gid_list, list) {
+		if (!memcmp(raw, ge->gid.raw, 16)) {
+			ret = ge;
+			break;
+		}
+	}
+
+	return ret;
 }
 
 static int mlx4_ib_mcg_detach(struct ib_qp *ibqp, union ib_gid *gid, u16 lid)
 {
-	return mlx4_multicast_detach(to_mdev(ibqp->device)->dev,
-				     &to_mqp(ibqp)->mqp, gid->raw);
+	int err;
+	struct mlx4_ib_dev *mdev = to_mdev(ibqp->device);
+	struct mlx4_ib_qp *mqp = to_mqp(ibqp);
+	u8 mac[6];
+	struct net_device *ndev;
+	struct gid_entry *ge;
+
+	err = mlx4_multicast_detach(mdev->dev,
+				    &mqp->mqp, gid->raw);
+	if (err)
+		return err;
+
+	mutex_lock(&mqp->mutex);
+	ge = find_gid_entry(mqp, gid->raw);
+	if (ge) {
+		spin_lock(&mdev->rdmaoe.lock);
+		ndev = ge->added ? mdev->rdmaoe.netdevs[ge->port - 1] : NULL;
+		if (ndev)
+			dev_hold(ndev);
+		spin_unlock(&mdev->rdmaoe.lock);
+		rdma_get_mcast_mac((struct in6_addr *)gid, mac);
+		if (ndev) {
+			rtnl_lock();
+			dev_mc_delete(mdev->rdmaoe.netdevs[ge->port - 1], mac, 6, 0);
+			rtnl_unlock();
+			dev_put(ndev);
+		}
+		list_del(&ge->list);
+		kfree(ge);
+	} else
+		printk(KERN_WARNING "could not find mgid entry\n");
+
+	mutex_unlock(&mqp->mutex);
+
+	return 0;
 }
 
 static int init_node_data(struct mlx4_ib_dev *dev)
@@ -541,15 +739,143 @@ static struct device_attribute *mlx4_class_attributes[] = {
 	&dev_attr_board_id
 };
 
+static void mlx4_addrconf_ifid_eui48(u8 *eui, struct net_device *dev)
+{
+	memcpy(eui, dev->dev_addr, 3);
+	memcpy(eui + 5, dev->dev_addr + 3, 3);
+	eui[3] = 0xFF;
+	eui[4] = 0xFE;
+	eui[0] ^= 2;
+}
+
+static void update_gids_task(struct work_struct *work)
+{
+	struct update_gid_work *gw = container_of(work, struct update_gid_work, work);
+	struct mlx4_cmd_mailbox *mailbox;
+	union ib_gid *gids;
+	int err;
+	struct mlx4_dev	*dev = gw->dev->dev;
+	struct ib_event event;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox)) {
+		printk(KERN_WARNING "update gid table failed %ld\n", PTR_ERR(mailbox));
+		return;
+	}
+
+	gids = mailbox->buf;
+	memcpy(gids, gw->gids, sizeof gw->gids);
+
+	err = mlx4_cmd(dev, mailbox->dma, MLX4_SET_PORT_GID_TABLE << 8 | gw->port,
+		       1, MLX4_CMD_SET_PORT, MLX4_CMD_TIME_CLASS_B);
+	if (err)
+		printk(KERN_WARNING "set port command failed\n");
+	else {
+		memcpy(gw->dev->rdmaoe.gid_table[gw->port - 1], gw->gids, sizeof gw->gids);
+		event.device = &gw->dev->ib_dev;
+		event.element.port_num = gw->port;
+		event.event    = IB_EVENT_LID_CHANGE;
+		ib_dispatch_event(&event);
+	}
+
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	kfree(gw);
+}
+
+static int update_ipv6_gids(struct mlx4_ib_dev *dev, int port, int clear)
+{
+	struct net_device *ndev = dev->rdmaoe.netdevs[port - 1];
+	struct update_gid_work *work;
+
+	work = kzalloc(sizeof *work, GFP_ATOMIC);
+	if (!work)
+		return -ENOMEM;
+
+	if (!clear) {
+		mlx4_addrconf_ifid_eui48(&work->gids[0].raw[8], ndev);
+		work->gids[0].global.subnet_prefix = cpu_to_be64(0xfe80000000000000LL);
+	}
+
+	INIT_WORK(&work->work, update_gids_task);
+	work->port = port;
+	work->dev = dev;
+	queue_work(wq, &work->work);
+
+	return 0;
+}
+
+static void handle_en_event(struct mlx4_ib_dev *dev, int port, unsigned long event)
+{
+	switch (event) {
+	case NETDEV_UP:
+		update_ipv6_gids(dev, port, 0);
+		break;
+
+	case NETDEV_DOWN:
+		update_ipv6_gids(dev, port, 1);
+		dev->rdmaoe.netdevs[port - 1] = NULL;
+	}
+}
+
+static void netdev_added(struct mlx4_ib_dev *dev, int port)
+{
+	update_ipv6_gids(dev, port, 0);
+}
+
+static void netdev_removed(struct mlx4_ib_dev *dev, int port)
+{
+	update_ipv6_gids(dev, port, 1);
+}
+
+static int mlx4_ib_netdev_event(struct notifier_block *this, unsigned long event,
+				void *ptr)
+{
+	struct net_device *dev = ptr;
+	struct mlx4_ib_dev *ibdev;
+	struct net_device *oldnd;
+	struct mlx4_ib_rdmaoe *rdmaoe;
+	int port;
+
+	if (!net_eq(dev_net(dev), &init_net))
+		return NOTIFY_DONE;
+
+	ibdev = container_of(this, struct mlx4_ib_dev, rdmaoe.nb);
+	rdmaoe = &ibdev->rdmaoe;
+
+	spin_lock(&rdmaoe->lock);
+	mlx4_foreach_ib_transport_port(port, ibdev->dev) {
+		oldnd = rdmaoe->netdevs[port - 1];
+		rdmaoe->netdevs[port - 1] = mlx4_get_prot_dev(ibdev->dev, MLX4_PROT_EN, port);
+		if (oldnd != rdmaoe->netdevs[port - 1]) {
+			if (rdmaoe->netdevs[port - 1])
+				netdev_added(ibdev, port);
+			else
+				netdev_removed(ibdev, port);
+		}
+	}
+
+	if (dev == rdmaoe->netdevs[0])
+		handle_en_event(ibdev, 1, event);
+	else if (dev == rdmaoe->netdevs[1])
+		handle_en_event(ibdev, 2, event);
+
+	spin_unlock(&rdmaoe->lock);
+
+	return NOTIFY_DONE;
+}
+
 static void *mlx4_ib_add(struct mlx4_dev *dev)
 {
 	struct mlx4_ib_dev *ibdev;
 	int num_ports = 0;
 	int i;
+	int err;
+	int port;
+	struct mlx4_ib_rdmaoe *rdmaoe;
 
 	printk_once(KERN_INFO "%s", mlx4_ib_version);
 
-	mlx4_foreach_port(i, dev, MLX4_PORT_TYPE_IB)
+	mlx4_foreach_ib_transport_port(i, dev)
 		num_ports++;
 
 	/* No point in registering a device with no ports... */
@@ -562,6 +888,8 @@ static void *mlx4_ib_add(struct mlx4_dev *dev)
 		return NULL;
 	}
 
+	rdmaoe = &ibdev->rdmaoe;
+
 	if (mlx4_pd_alloc(dev, &ibdev->priv_pdn))
 		goto err_dealloc;
 
@@ -606,10 +934,12 @@ static void *mlx4_ib_add(struct mlx4_dev *dev)
 		(1ull << IB_USER_VERBS_CMD_CREATE_SRQ)		|
 		(1ull << IB_USER_VERBS_CMD_MODIFY_SRQ)		|
 		(1ull << IB_USER_VERBS_CMD_QUERY_SRQ)		|
-		(1ull << IB_USER_VERBS_CMD_DESTROY_SRQ);
+		(1ull << IB_USER_VERBS_CMD_DESTROY_SRQ)		|
+		(1ull << IB_USER_VERBS_CMD_GET_MAC);
 
 	ibdev->ib_dev.query_device	= mlx4_ib_query_device;
 	ibdev->ib_dev.query_port	= mlx4_ib_query_port;
+	ibdev->ib_dev.get_port_transport = mlx4_ib_port_get_transport;
 	ibdev->ib_dev.query_gid		= mlx4_ib_query_gid;
 	ibdev->ib_dev.query_pkey	= mlx4_ib_query_pkey;
 	ibdev->ib_dev.modify_device	= mlx4_ib_modify_device;
@@ -653,15 +983,26 @@ static void *mlx4_ib_add(struct mlx4_dev *dev)
 	ibdev->ib_dev.map_phys_fmr	= mlx4_ib_map_phys_fmr;
 	ibdev->ib_dev.unmap_fmr		= mlx4_ib_unmap_fmr;
 	ibdev->ib_dev.dealloc_fmr	= mlx4_ib_fmr_dealloc;
+	ibdev->ib_dev.get_mac		= mlx4_ib_get_mac;
+
+	mlx4_foreach_ib_transport_port(port, dev)
+		rdmaoe->netdevs[port - 1] = mlx4_get_prot_dev(dev, MLX4_PROT_EN, port);
+	spin_lock_init(&rdmaoe->lock);
+	if (dev->caps.flags & MLX4_DEV_CAP_FLAG_RDMAOE && !rdmaoe->nb.notifier_call) {
+		rdmaoe->nb.notifier_call = mlx4_ib_netdev_event;
+		err = register_netdevice_notifier(&rdmaoe->nb);
+		if (err)
+			goto err_map;
+	}
 
 	if (init_node_data(ibdev))
-		goto err_map;
+		goto err_notif;
 
 	spin_lock_init(&ibdev->sm_lock);
 	mutex_init(&ibdev->cap_mask_mutex);
 
 	if (ib_register_device(&ibdev->ib_dev))
-		goto err_map;
+		goto err_notif;
 
 	if (mlx4_ib_mad_init(ibdev))
 		goto err_reg;
@@ -679,6 +1020,10 @@ static void *mlx4_ib_add(struct mlx4_dev *dev)
 err_reg:
 	ib_unregister_device(&ibdev->ib_dev);
 
+err_notif:
+	unregister_netdevice_notifier(&rdmaoe->nb);
+	flush_workqueue(wq);
+
 err_map:
 	iounmap(ibdev->uar_map);
 
@@ -701,11 +1046,16 @@ static void mlx4_ib_remove(struct mlx4_dev *dev, void *ibdev_ptr)
 
 	mlx4_ib_mad_cleanup(ibdev);
 	ib_unregister_device(&ibdev->ib_dev);
+	if (ibdev->rdmaoe.nb.notifier_call) {
+		unregister_netdevice_notifier(&ibdev->rdmaoe.nb);
+		flush_workqueue(wq);
+		ibdev->rdmaoe.nb.notifier_call = NULL;
+	}
+	iounmap(ibdev->uar_map);
 
-	for (p = 1; p <= ibdev->num_ports; ++p)
+	mlx4_foreach_port(p, dev, MLX4_PORT_TYPE_IB)
 		mlx4_CLOSE_PORT(dev, p);
 
-	iounmap(ibdev->uar_map);
 	mlx4_uar_free(dev, &ibdev->priv_uar);
 	mlx4_pd_free(dev, ibdev->priv_pdn);
 	ib_dealloc_device(&ibdev->ib_dev);
@@ -747,17 +1097,31 @@ static void mlx4_ib_event(struct mlx4_dev *dev, void *ibdev_ptr,
 static struct mlx4_interface mlx4_ib_interface = {
 	.add	= mlx4_ib_add,
 	.remove	= mlx4_ib_remove,
-	.event	= mlx4_ib_event
+	.event	= mlx4_ib_event,
+	.protocol	= MLX4_PROT_IB
 };
 
 static int __init mlx4_ib_init(void)
 {
-	return mlx4_register_interface(&mlx4_ib_interface);
+	int err;
+
+	wq = create_singlethread_workqueue("mlx4_ib");
+	if (!wq)
+		return -ENOMEM;
+
+	err = mlx4_register_interface(&mlx4_ib_interface);
+	if (err) {
+		destroy_workqueue(wq);
+		return err;
+	}
+
+	return 0;
 }
 
 static void __exit mlx4_ib_cleanup(void)
 {
 	mlx4_unregister_interface(&mlx4_ib_interface);
+	destroy_workqueue(wq);
 }
 
 module_init(mlx4_ib_init);
diff --git a/drivers/infiniband/hw/mlx4/mlx4_ib.h b/drivers/infiniband/hw/mlx4/mlx4_ib.h
index a0435cd..7f3590b 100644
--- a/drivers/infiniband/hw/mlx4/mlx4_ib.h
+++ b/drivers/infiniband/hw/mlx4/mlx4_ib.h
@@ -112,6 +112,13 @@ enum mlx4_ib_qp_flags {
 	MLX4_IB_QP_BLOCK_MULTICAST_LOOPBACK	= 1 << 1,
 };
 
+struct gid_entry {
+	struct list_head	list;
+	union ib_gid		gid;
+	int			added;
+	u8			port;
+};
+
 struct mlx4_ib_qp {
 	struct ib_qp		ibqp;
 	struct mlx4_qp		mqp;
@@ -139,6 +146,7 @@ struct mlx4_ib_qp {
 	u8			sq_no_prefetch;
 	u8			state;
 	int			mlx_type;
+	struct list_head	gid_list;
 };
 
 struct mlx4_ib_srq {
@@ -333,4 +341,7 @@ static inline int mlx4_ib_ah_grh_present(struct mlx4_ib_ah *ah)
 	return !!(ah->av.ib.g_slid & 0x80);
 }
 
+int mlx4_ib_add_mc(struct mlx4_ib_dev *mdev, struct mlx4_ib_qp *mqp,
+		   union ib_gid *gid);
+
 #endif /* MLX4_IB_H */
diff --git a/drivers/infiniband/hw/mlx4/qp.c b/drivers/infiniband/hw/mlx4/qp.c
index ce2a47e..7e7a165 100644
--- a/drivers/infiniband/hw/mlx4/qp.c
+++ b/drivers/infiniband/hw/mlx4/qp.c
@@ -470,6 +470,7 @@ static int create_qp_common(struct mlx4_ib_dev *dev, struct ib_pd *pd,
 	mutex_init(&qp->mutex);
 	spin_lock_init(&qp->sq.lock);
 	spin_lock_init(&qp->rq.lock);
+	INIT_LIST_HEAD(&qp->gid_list);
 
 	qp->state	 = IB_QPS_RESET;
 	if (init_attr->sq_sig_type == IB_SIGNAL_ALL_WR)
@@ -657,6 +658,16 @@ static void mlx4_ib_unlock_cqs(struct mlx4_ib_cq *send_cq, struct mlx4_ib_cq *re
 	}
 }
 
+static void del_gid_entries(struct mlx4_ib_qp *qp)
+{
+	struct gid_entry *ge, *tmp;
+
+	list_for_each_entry_safe(ge, tmp, &qp->gid_list, list) {
+		list_del(&ge->list);
+		kfree(ge);
+	}
+}
+
 static void destroy_qp_common(struct mlx4_ib_dev *dev, struct mlx4_ib_qp *qp,
 			      int is_user)
 {
@@ -703,6 +714,8 @@ static void destroy_qp_common(struct mlx4_ib_dev *dev, struct mlx4_ib_qp *qp,
 		if (!qp->ibqp.srq)
 			mlx4_db_free(dev->dev, &qp->db);
 	}
+
+	del_gid_entries(qp);
 }
 
 struct ib_qp *mlx4_ib_create_qp(struct ib_pd *pd,
@@ -914,6 +927,16 @@ static int mlx4_set_path(struct mlx4_ib_dev *dev, const struct ib_ah_attr *ah,
 	return 0;
 }
 
+static void update_mcg_macs(struct mlx4_ib_dev *dev, struct mlx4_ib_qp *qp)
+{
+	struct gid_entry *ge, *tmp;
+
+	list_for_each_entry_safe(ge, tmp, &qp->gid_list, list) {
+		if (!ge->added && mlx4_ib_add_mc(dev, qp, &ge->gid))
+			ge->added = 1;
+	}
+}
+
 static int __mlx4_ib_modify_qp(struct ib_qp *ibqp,
 			       const struct ib_qp_attr *attr, int attr_mask,
 			       enum ib_qp_state cur_state, enum ib_qp_state new_state)
@@ -1147,8 +1170,10 @@ static int __mlx4_ib_modify_qp(struct ib_qp *ibqp,
 		qp->atomic_rd_en = attr->qp_access_flags;
 	if (attr_mask & IB_QP_MAX_DEST_RD_ATOMIC)
 		qp->resp_depth = attr->max_dest_rd_atomic;
-	if (attr_mask & IB_QP_PORT)
+	if (attr_mask & IB_QP_PORT) {
 		qp->port = attr->port_num;
+		update_mcg_macs(dev, qp);
+	}
 	if (attr_mask & IB_QP_ALT_PATH)
 		qp->alt_port = attr->alt_port_num;
 
diff --git a/drivers/net/mlx4/en_main.c b/drivers/net/mlx4/en_main.c
index 507e11f..00e72b3 100644
--- a/drivers/net/mlx4/en_main.c
+++ b/drivers/net/mlx4/en_main.c
@@ -100,6 +100,13 @@ static int mlx4_en_get_profile(struct mlx4_en_dev *mdev)
 	return 0;
 }
 
+static void *get_netdev(struct mlx4_dev *dev, void *ctx, u8 port)
+{
+	struct mlx4_en_dev *endev = ctx;
+
+	return endev->pndev[port];
+}
+
 static void mlx4_en_event(struct mlx4_dev *dev, void *endev_ptr,
 			  enum mlx4_dev_event event, int port)
 {
@@ -262,9 +269,11 @@ err_free_res:
 }
 
 static struct mlx4_interface mlx4_en_interface = {
-	.add	= mlx4_en_add,
-	.remove	= mlx4_en_remove,
-	.event	= mlx4_en_event,
+	.add		= mlx4_en_add,
+	.remove		= mlx4_en_remove,
+	.event		= mlx4_en_event,
+	.get_prot_dev	= get_netdev,
+	.protocol	= MLX4_PROT_EN,
 };
 
 static int __init mlx4_en_init(void)
diff --git a/drivers/net/mlx4/en_port.c b/drivers/net/mlx4/en_port.c
index a29abe8..a249887 100644
--- a/drivers/net/mlx4/en_port.c
+++ b/drivers/net/mlx4/en_port.c
@@ -127,8 +127,8 @@ int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
 	memset(context, 0, sizeof *context);
 
 	context->base_qpn = cpu_to_be32(base_qpn);
-	context->promisc = cpu_to_be32(promisc << SET_PORT_PROMISC_SHIFT | base_qpn);
-	context->mcast = cpu_to_be32(1 << SET_PORT_PROMISC_SHIFT | base_qpn);
+	context->promisc = cpu_to_be32(promisc << SET_PORT_PROMISC_EN_SHIFT | base_qpn);
+	context->mcast = cpu_to_be32(1 << SET_PORT_PROMISC_MODE_SHIFT | base_qpn);
 	context->intra_no_vlan = 0;
 	context->no_vlan = MLX4_NO_VLAN_IDX;
 	context->intra_vlan_miss = 0;
diff --git a/drivers/net/mlx4/en_port.h b/drivers/net/mlx4/en_port.h
index e6477f1..9354891 100644
--- a/drivers/net/mlx4/en_port.h
+++ b/drivers/net/mlx4/en_port.h
@@ -36,7 +36,8 @@
 
 
 #define SET_PORT_GEN_ALL_VALID	0x7
-#define SET_PORT_PROMISC_SHIFT	31
+#define SET_PORT_PROMISC_EN_SHIFT	31
+#define SET_PORT_PROMISC_MODE_SHIFT	30
 
 enum {
 	MLX4_CMD_SET_VLAN_FLTR  = 0x47,
diff --git a/drivers/net/mlx4/intf.c b/drivers/net/mlx4/intf.c
index 0e7eb10..d64530e 100644
--- a/drivers/net/mlx4/intf.c
+++ b/drivers/net/mlx4/intf.c
@@ -159,3 +159,23 @@ void mlx4_unregister_device(struct mlx4_dev *dev)
 
 	mutex_unlock(&intf_mutex);
 }
+
+void *mlx4_find_get_prot_dev(struct mlx4_dev *dev, enum mlx4_prot proto, int port)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_device_context *dev_ctx;
+	unsigned long flags;
+	void *result = NULL;
+
+	spin_lock_irqsave(&priv->ctx_lock, flags);
+
+	list_for_each_entry(dev_ctx, &priv->ctx_list, list)
+		if (dev_ctx->intf->protocol == proto && dev_ctx->intf->get_prot_dev) {
+			result = dev_ctx->intf->get_prot_dev(dev, dev_ctx->context, port);
+			break;
+		}
+
+	spin_unlock_irqrestore(&priv->ctx_lock, flags);
+
+	return result;
+}
diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index 291a505..2407396 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -104,6 +104,12 @@ static int log_mtts_per_seg = ilog2(MLX4_MTT_ENTRY_PER_SEG);
 module_param_named(log_mtts_per_seg, log_mtts_per_seg, int, 0444);
 MODULE_PARM_DESC(log_mtts_per_seg, "Log2 number of MTT entries per segment (1-5)");
 
+void *mlx4_get_prot_dev(struct mlx4_dev *dev, enum mlx4_prot proto, int port)
+{
+	return mlx4_find_get_prot_dev(dev, proto, port);
+}
+EXPORT_SYMBOL(mlx4_get_prot_dev);
+
 int mlx4_check_port_params(struct mlx4_dev *dev,
 			   enum mlx4_port_type *port_type)
 {
diff --git a/drivers/net/mlx4/mlx4.h b/drivers/net/mlx4/mlx4.h
index bc72d6e..ab63445 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/net/mlx4/mlx4.h
@@ -362,6 +362,7 @@ int mlx4_restart_one(struct pci_dev *pdev);
 int mlx4_register_device(struct mlx4_dev *dev);
 void mlx4_unregister_device(struct mlx4_dev *dev);
 void mlx4_dispatch_event(struct mlx4_dev *dev, enum mlx4_dev_event type, int port);
+void *mlx4_find_get_prot_dev(struct mlx4_dev *dev, enum mlx4_prot proto, int port);
 
 struct mlx4_dev_cap;
 struct mlx4_init_hca_param;
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index 0f82293..22bd8d3 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -140,6 +140,7 @@ enum {
 	MLX4_SET_PORT_MAC_TABLE = 0x2,
 	MLX4_SET_PORT_VLAN_TABLE = 0x3,
 	MLX4_SET_PORT_PRIO_MAP  = 0x4,
+	MLX4_SET_PORT_GID_TABLE = 0x5,
 };
 
 struct mlx4_dev;
diff --git a/include/linux/mlx4/driver.h b/include/linux/mlx4/driver.h
index 53c5fdb..0083256 100644
--- a/include/linux/mlx4/driver.h
+++ b/include/linux/mlx4/driver.h
@@ -44,15 +44,23 @@ enum mlx4_dev_event {
 	MLX4_DEV_EVENT_PORT_REINIT,
 };
 
+enum mlx4_prot {
+	MLX4_PROT_IB,
+	MLX4_PROT_EN,
+};
+
 struct mlx4_interface {
-	void *			(*add)	 (struct mlx4_dev *dev);
-	void			(*remove)(struct mlx4_dev *dev, void *context);
-	void			(*event) (struct mlx4_dev *dev, void *context,
-					  enum mlx4_dev_event event, int port);
+	void *	(*add)	 (struct mlx4_dev *dev);
+	void   	(*remove)(struct mlx4_dev *dev, void *context);
+	void   	(*event) (struct mlx4_dev *dev, void *context,
+			  enum mlx4_dev_event event, int port);
+	void *	(*get_prot_dev) (struct mlx4_dev *dev, void *context, u8 port);
+	enum mlx4_prot		protocol;
 	struct list_head	list;
 };
 
 int mlx4_register_interface(struct mlx4_interface *intf);
 void mlx4_unregister_interface(struct mlx4_interface *intf);
+void *mlx4_get_prot_dev(struct mlx4_dev *dev, enum mlx4_prot proto, int port);
 
 #endif /* MLX4_DRIVER_H */
-- 
1.6.5.2
