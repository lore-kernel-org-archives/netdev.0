From: Jiannan Ouyang <ouyangj-b10kYP2dOMg@public.gmane.org>
Subject: [PATCH net-next v1 2/3] gtp: Support creating flow-based
	gtp net_device
Date: Wed, 12 Jul 2017 17:44:54 -0700
Message-ID: <20170713004455.3946570-3-ouyangj@fb.com>
References: <20170713004455.3946570-1-ouyangj@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: laforge-TgoAw6mPHtdg9hUCZPvPmw@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org
To: <osmocom-net-gprs-qjLDD68F18N4m7O/Vxda39i2O/JbrIOy@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20170713004455.3946570-1-ouyangj-b10kYP2dOMg@public.gmane.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Add the gtp_create_flow_based_dev() interface to create flow-based gtp
net_device, which sets gtp->collect_md. Under flow-based mode, UDP sockets are
created and maintained in kernel.

Signed-off-by: Jiannan Ouyang <ouyangj-b10kYP2dOMg@public.gmane.org>
---
 drivers/net/gtp.c | 213 +++++++++++++++++++++++++++++++++++++++++++++++++++++-
 include/net/gtp.h |   8 ++
 2 files changed, 217 insertions(+), 4 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 5a7b504..09712c9 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -642,9 +642,94 @@ static netdev_tx_t gtp_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+static int gtp_hashtable_new(struct gtp_dev *gtp, int hsize);
+static void gtp_hashtable_free(struct gtp_dev *gtp);
+static int gtp_encap_enable(struct gtp_dev *gtp, struct nlattr *data[]);
+
+static int gtp_change_mtu(struct net_device *dev, int new_mtu, bool strict)
+{
+	int max_mtu = IP_MAX_MTU - dev->hard_header_len - sizeof(struct iphdr)
+			- sizeof(struct udphdr) - sizeof(struct gtp1_header);
+
+	if (new_mtu < ETH_MIN_MTU)
+		return -EINVAL;
+
+	if (new_mtu > max_mtu) {
+		if (strict)
+			return -EINVAL;
+
+		new_mtu = max_mtu;
+	}
+
+	dev->mtu = new_mtu;
+	return 0;
+}
+
+static int gtp_dev_open(struct net_device *dev)
+{
+	struct gtp_dev *gtp = netdev_priv(dev);
+	struct net *net = gtp->net;
+	struct socket *sock1u;
+	struct socket *sock0;
+	struct udp_tunnel_sock_cfg tunnel_cfg;
+	struct udp_port_cfg udp_conf;
+	int err;
+
+	memset(&udp_conf, 0, sizeof(udp_conf));
+
+	udp_conf.family = AF_INET;
+	udp_conf.local_ip.s_addr = htonl(INADDR_ANY);
+	udp_conf.local_udp_port = htons(GTP1U_PORT);
+
+	err = udp_sock_create(gtp->net, &udp_conf, &sock1u);
+	if (err < 0)
+		return err;
+
+	udp_conf.local_udp_port = htons(GTP0_PORT);
+	err = udp_sock_create(gtp->net, &udp_conf, &sock0);
+	if (err < 0)
+		return err;
+
+	memset(&tunnel_cfg, 0, sizeof(tunnel_cfg));
+	tunnel_cfg.sk_user_data = gtp;
+	tunnel_cfg.encap_rcv = gtp_encap_recv;
+	tunnel_cfg.encap_destroy = gtp_encap_destroy;
+	tunnel_cfg.encap_type = UDP_ENCAP_GTP0;
+	setup_udp_tunnel_sock(net, sock0, &tunnel_cfg);
+
+	tunnel_cfg.encap_type = UDP_ENCAP_GTP1U;
+
+	setup_udp_tunnel_sock(net, sock1u, &tunnel_cfg);
+
+	sock_hold(sock0->sk);
+	sock_hold(sock1u->sk);
+
+	gtp->sk0 = sock0->sk;
+	gtp->sk1u = sock1u->sk;
+
+	return 0;
+}
+
+static int gtp_dev_stop(struct net_device *dev)
+{
+	struct gtp_dev *gtp = netdev_priv(dev);
+	struct sock *sk = gtp->sk1u;
+
+	udp_tunnel_sock_release(gtp->sk0->sk_socket);
+	udp_tunnel_sock_release(gtp->sk1u->sk_socket);
+
+	udp_sk(sk)->encap_type = 0;
+	rcu_assign_sk_user_data(sk, NULL);
+	sock_put(sk);
+
+	return 0;
+}
+
 static const struct net_device_ops gtp_netdev_ops = {
 	.ndo_init		= gtp_dev_init,
 	.ndo_uninit		= gtp_dev_uninit,
+	.ndo_open		= gtp_dev_open,
+	.ndo_stop		= gtp_dev_stop,
 	.ndo_start_xmit		= gtp_dev_xmit,
 	.ndo_get_stats64	= ip_tunnel_get_stats64,
 };
@@ -672,10 +757,6 @@ static void gtp_link_setup(struct net_device *dev)
 				  sizeof(struct gtp0_header);
 }
 
-static int gtp_hashtable_new(struct gtp_dev *gtp, int hsize);
-static void gtp_hashtable_free(struct gtp_dev *gtp);
-static int gtp_encap_enable(struct gtp_dev *gtp, struct nlattr *data[]);
-
 static int gtp_newlink(struct net *src_net, struct net_device *dev,
 		       struct nlattr *tb[], struct nlattr *data[],
 		       struct netlink_ext_ack *extack)
@@ -780,6 +861,130 @@ static struct rtnl_link_ops gtp_link_ops __read_mostly = {
 	.fill_info	= gtp_fill_info,
 };
 
+static void init_tnl_info(struct ip_tunnel_info *info, __u16 dst_port)
+{
+	memset(info, 0, sizeof(*info));
+	info->key.tp_dst = htons(dst_port);
+}
+
+static struct gtp_dev *gtp_find_flow_based_dev(
+	struct net *net)
+{
+	struct gtp_net *gn = net_generic(net, gtp_net_id);
+	struct gtp_dev *gtp, *t = NULL;
+
+	list_for_each_entry(gtp, &gn->gtp_dev_list, list) {
+		if (gtp->collect_md)
+			t = gtp;
+	}
+
+	return t;
+}
+
+static int gtp_configure(struct net *net, struct net_device *dev,
+			 const struct ip_tunnel_info *info)
+{
+	struct gtp_net *gn = net_generic(net, gtp_net_id);
+	struct gtp_dev *gtp = netdev_priv(dev);
+	int err;
+
+	gtp->net = net;
+	gtp->dev = dev;
+
+	if (gtp_find_flow_based_dev(net))
+		return -EBUSY;
+
+	dev->netdev_ops		= &gtp_netdev_ops;
+	dev->priv_destructor	= free_netdev;
+
+	dev->hard_header_len = 0;
+	dev->addr_len = 0;
+
+	/* Zero header length. */
+	dev->type = ARPHRD_NONE;
+	dev->flags = IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
+
+	dev->priv_flags	|= IFF_NO_QUEUE;
+	dev->features	|= NETIF_F_LLTX;
+	netif_keep_dst(dev);
+
+	/* Assume largest header, ie. GTPv0. */
+	dev->needed_headroom	= LL_MAX_HEADER +
+		sizeof(struct iphdr) +
+		sizeof(struct udphdr) +
+		sizeof(struct gtp0_header);
+
+	dst_cache_reset(&gtp->info.dst_cache);
+	gtp->info = *info;
+	gtp->collect_md = true;
+
+	err = gtp_hashtable_new(gtp, GTP_PDP_HASHSIZE); // JO: when to free??
+	if (err < 0) {
+		pr_err("Error gtp_hashtable_new");
+		return err;
+	}
+
+	err = register_netdevice(dev);
+	if (err) {
+		pr_err("Error when registering net device");
+		return err;
+	}
+
+	list_add_rcu(&gtp->list, &gn->gtp_dev_list);
+	return 0;
+}
+
+struct net_device *gtp_create_flow_based_dev(struct net *net,
+					     const char *name,
+					     u8 name_assign_type,
+					     u16 dst_port)
+{
+	struct nlattr *tb[IFLA_MAX + 1];
+	struct net_device *dev;
+	struct ip_tunnel_info info;
+	LIST_HEAD(list_kill);
+	int err;
+
+	memset(&tb, 0, sizeof(tb));
+	dev = rtnl_create_link(net, name, name_assign_type,
+			       &gtp_link_ops, tb);
+	if (IS_ERR(dev)) {
+		pr_err("error rtnl_create_link");
+		return dev;
+	}
+
+	init_tnl_info(&info, dst_port);
+	err = gtp_configure(net, dev, &info);
+	if (err < 0) {
+		pr_err("error gtp_configure");
+		free_netdev(dev);
+		return ERR_PTR(err);
+	}
+
+	/* openvswitch users expect packet sizes to be unrestricted,
+	 * so set the largest MTU we can.
+	 */
+	err = gtp_change_mtu(dev, IP_MAX_MTU, false);
+	if (err) {
+		pr_err("error gtp_change_mtu");
+		goto err;
+	}
+
+	err = rtnl_configure_link(dev, NULL);
+	if (err < 0)  {
+		pr_err("error rtnl_configure_link");
+		goto err;
+	}
+
+	return dev;
+
+err:
+	gtp_dellink(dev, &list_kill);
+	unregister_netdevice_many(&list_kill);
+	return ERR_PTR(err);
+}
+EXPORT_SYMBOL_GPL(gtp_create_flow_based_dev);
+
 static int gtp_hashtable_new(struct gtp_dev *gtp, int hsize)
 {
 	int i;
diff --git a/include/net/gtp.h b/include/net/gtp.h
index 6398891..a76b26c 100644
--- a/include/net/gtp.h
+++ b/include/net/gtp.h
@@ -31,4 +31,12 @@ struct gtp1_header {	/* According to 3GPP TS 29.060. */
 #define GTP1_F_EXTHDR	0x04
 #define GTP1_F_MASK	0x07
 
+#ifdef CONFIG_INET
+
+struct net_device *gtp_create_flow_based_dev(
+			struct net *net, const char *name,
+		     	u8 name_assign_type, u16 dst_port);
+
+#endif /*ifdef CONFIG_INET */
+
 #endif
-- 
2.9.3
