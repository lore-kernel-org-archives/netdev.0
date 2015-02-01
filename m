From: Yann Droneaud <ydroneaud@opteya.com>
Subject: Re: [PATCH for-next 08/10] IB/cma: Add support for network
 namespaces
Date: Sun, 01 Feb 2015 14:44:32 +0100
Message-ID: <1422798272.3030.48.camel@opteya.com>
References: <1422790133-28725-1-git-send-email-raindel@mellanox.com>
	 <1422790133-28725-9-git-send-email-raindel@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: roland@kernel.org, sean.hefty@intel.com,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	liranl@mellanox.com, Guy Shapiro <guysh@mellanox.com>,
	Haggai Eran <haggaie@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>
To: Shachar Raindel <raindel@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ou.quest-ce.net ([195.154.187.82]:46035 "EHLO ou.quest-ce.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752965AbbBANoi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Feb 2015 08:44:38 -0500
In-Reply-To: <1422790133-28725-9-git-send-email-raindel@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Le dimanche 01 f=C3=A9vrier 2015 =C3=A0 13:28 +0200, Shachar Raindel a =
=C3=A9crit :
> From: Guy Shapiro <guysh@mellanox.com>
>=20
> Add support for network namespaces in the ib_cma module. This is
> accomplished by:
>=20
> 1. Adding network namespace parameter for rdma_create_id. This parame=
ter is used
>    to populate the network namespace field in rdma_id_private. rdma_c=
reate_id
>    keeps a reference on the network namespace.
> 2. Using the network namespace from the rdma_id instead of init_net i=
nside of
>    ib_cma.
> 3. Decrementing the reference count for the appropriate network names=
pace when
>    calling rdma_destroy_id.
>=20
> In order to preserve the current behavior init_net is passed when cal=
ling from
> other modules.
>=20
> Signed-off-by: Guy Shapiro <guysh@mellanox.com>
> Signed-off-by: Haggai Eran <haggaie@mellanox.com>
> Signed-off-by: Yotam Kenneth <yotamke@mellanox.com>
> Signed-off-by: Shachar Raindel <raindel@mellanox.com>
>=20
> ---
>  drivers/infiniband/core/cma.c                      | 52 ++++++++++++=
+---------
>  drivers/infiniband/core/ucma.c                     |  3 +-
>  drivers/infiniband/ulp/iser/iser_verbs.c           |  2 +-
>  drivers/infiniband/ulp/isert/ib_isert.c            |  2 +-
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |  4 +-
>  include/rdma/rdma_cm.h                             |  6 ++-
>  net/9p/trans_rdma.c                                |  2 +-
>  net/rds/ib.c                                       |  2 +-
>  net/rds/ib_cm.c                                    |  2 +-
>  net/rds/iw.c                                       |  2 +-
>  net/rds/iw_cm.c                                    |  2 +-
>  net/rds/rdma_transport.c                           |  2 +-
>  net/sunrpc/xprtrdma/svc_rdma_transport.c           |  2 +-
>  net/sunrpc/xprtrdma/verbs.c                        |  3 +-
>  14 files changed, 52 insertions(+), 34 deletions(-)
>=20
> diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/=
cma.c
> index 022b0d0a51cc..f6379b38b366 100644
> --- a/drivers/infiniband/core/cma.c
> +++ b/drivers/infiniband/core/cma.c
> @@ -540,7 +540,8 @@ static int cma_disable_callback(struct rdma_id_pr=
ivate *id_priv,
> =20
>  struct rdma_cm_id *rdma_create_id(rdma_cm_event_handler event_handle=
r,
>  				  void *context, enum rdma_port_space ps,
> -				  enum ib_qp_type qp_type)
> +				  enum ib_qp_type qp_type,
> +				  struct net *net)
>  {
>  	struct rdma_id_private *id_priv;
> =20
> @@ -562,7 +563,7 @@ struct rdma_cm_id *rdma_create_id(rdma_cm_event_h=
andler event_handler,
>  	INIT_LIST_HEAD(&id_priv->listen_list);
>  	INIT_LIST_HEAD(&id_priv->mc_list);
>  	get_random_bytes(&id_priv->seq_num, sizeof id_priv->seq_num);
> -	id_priv->id.route.addr.dev_addr.net =3D &init_net;
> +	id_priv->id.route.addr.dev_addr.net =3D get_net(net);
> =20
>  	return &id_priv->id;
>  }
> @@ -689,7 +690,7 @@ static int cma_modify_qp_rtr(struct rdma_id_priva=
te *id_priv,
>  	    rdma_port_get_link_layer(id_priv->id.device, id_priv->id.port_n=
um)
>  	    =3D=3D IB_LINK_LAYER_ETHERNET) {
>  		ret =3D rdma_addr_find_smac_by_sgid(&sgid, qp_attr.smac, NULL,
> -						  &init_net);
> +				id_priv->id.route.addr.dev_addr.net);
> =20
>  		if (ret)
>  			goto out;
> @@ -953,6 +954,7 @@ static void cma_cancel_operation(struct rdma_id_p=
rivate *id_priv,
>  static void cma_release_port(struct rdma_id_private *id_priv)
>  {
>  	struct rdma_bind_list *bind_list =3D id_priv->bind_list;
> +	struct net *net =3D id_priv->id.route.addr.dev_addr.net;
> =20
>  	if (!bind_list)
>  		return;
> @@ -960,7 +962,7 @@ static void cma_release_port(struct rdma_id_priva=
te *id_priv)
>  	mutex_lock(&lock);
>  	hlist_del(&id_priv->node);
>  	if (hlist_empty(&bind_list->owners)) {
> -		cma_ps_remove(bind_list->ps, &init_net, bind_list->port);
> +		cma_ps_remove(bind_list->ps, net, bind_list->port);
>  		kfree(bind_list);
>  	}
>  	mutex_unlock(&lock);
> @@ -1029,6 +1031,7 @@ void rdma_destroy_id(struct rdma_cm_id *id)
>  		cma_deref_id(id_priv->id.context);
> =20
>  	kfree(id_priv->id.route.path_rec);
> +	put_net(id_priv->id.route.addr.dev_addr.net);
>  	kfree(id_priv);
>  }
>  EXPORT_SYMBOL(rdma_destroy_id);
> @@ -1156,7 +1159,8 @@ static struct rdma_id_private *cma_new_conn_id(=
struct rdma_cm_id *listen_id,
>  	int ret;
> =20
>  	id =3D rdma_create_id(listen_id->event_handler, listen_id->context,
> -			    listen_id->ps, ib_event->param.req_rcvd.qp_type);
> +			    listen_id->ps, ib_event->param.req_rcvd.qp_type,
> +			    listen_id->route.addr.dev_addr.net);
>  	if (IS_ERR(id))
>  		return NULL;
> =20
> @@ -1201,10 +1205,11 @@ static struct rdma_id_private *cma_new_udp_id=
(struct rdma_cm_id *listen_id,
>  {
>  	struct rdma_id_private *id_priv;
>  	struct rdma_cm_id *id;
> +	struct net *net =3D listen_id->route.addr.dev_addr.net;
>  	int ret;
> =20
>  	id =3D rdma_create_id(listen_id->event_handler, listen_id->context,
> -			    listen_id->ps, IB_QPT_UD);
> +			    listen_id->ps, IB_QPT_UD, net);
>  	if (IS_ERR(id))
>  		return NULL;
> =20
> @@ -1455,7 +1460,8 @@ static int iw_conn_req_handler(struct iw_cm_id =
*cm_id,
>  	/* Create a new RDMA id for the new IW CM ID */
>  	new_cm_id =3D rdma_create_id(listen_id->id.event_handler,
>  				   listen_id->id.context,
> -				   RDMA_PS_TCP, IB_QPT_RC);
> +				   RDMA_PS_TCP, IB_QPT_RC,
> +				   listen_id->id.route.addr.dev_addr.net);
>  	if (IS_ERR(new_cm_id)) {
>  		ret =3D -ENOMEM;
>  		goto out;
> @@ -1528,11 +1534,11 @@ static int cma_ib_listen(struct rdma_id_priva=
te *id_priv)
>  	struct ib_cm_compare_data compare_data;
>  	struct sockaddr *addr;
>  	struct ib_cm_id	*id;
> +	struct net *net =3D id_priv->id.route.addr.dev_addr.net;
>  	__be64 svc_id;
>  	int ret;
> =20
> -	id =3D ib_create_cm_id(id_priv->id.device, cma_req_handler, id_priv=
,
> -			     &init_net);
> +	id =3D ib_create_cm_id(id_priv->id.device, cma_req_handler, id_priv=
, net);
>  	if (IS_ERR(id))
>  		return PTR_ERR(id);
> =20
> @@ -1596,6 +1602,7 @@ static void cma_listen_on_dev(struct rdma_id_pr=
ivate *id_priv,
>  {
>  	struct rdma_id_private *dev_id_priv;
>  	struct rdma_cm_id *id;
> +	struct net *net =3D id_priv->id.route.addr.dev_addr.net;
>  	int ret;
> =20
>  	if (cma_family(id_priv) =3D=3D AF_IB &&
> @@ -1603,7 +1610,7 @@ static void cma_listen_on_dev(struct rdma_id_pr=
ivate *id_priv,
>  		return;
> =20
>  	id =3D rdma_create_id(cma_listen_handler, id_priv, id_priv->id.ps,
> -			    id_priv->id.qp_type);
> +			    id_priv->id.qp_type, net);
>  	if (IS_ERR(id))
>  		return;
> =20
> @@ -2283,7 +2290,8 @@ static int cma_alloc_port(struct radix_tree_roo=
t *ps,
>  	if (!bind_list)
>  		return -ENOMEM;
> =20
> -	ret =3D cma_ps_alloc(ps, &init_net, bind_list, snum);
> +	ret =3D cma_ps_alloc(ps, id_priv->id.route.addr.dev_addr.net, bind_=
list,
> +			   snum);
>  	if (ret < 0)
>  		goto err;
> =20
> @@ -2302,13 +2310,14 @@ static int cma_alloc_any_port(struct radix_tr=
ee_root *ps,
>  	static unsigned int last_used_port;
>  	int low, high, remaining;
>  	unsigned int rover;
> +	struct net *net =3D id_priv->id.route.addr.dev_addr.net;
> =20
> -	inet_get_local_port_range(&init_net, &low, &high);
> +	inet_get_local_port_range(net, &low, &high);
>  	remaining =3D (high - low) + 1;
>  	rover =3D prandom_u32() % remaining + low;
>  retry:
>  	if (last_used_port !=3D rover &&
> -	    !cma_ps_find(ps, &init_net, (unsigned short)rover)) {
> +	    !cma_ps_find(ps, net, (unsigned short)rover)) {
>  		int ret =3D cma_alloc_port(ps, id_priv, rover);
>  		/*
>  		 * Remember previously used port number in order to avoid
> @@ -2376,7 +2385,7 @@ static int cma_use_port(struct radix_tree_root =
*ps,
>  	if (snum < PROT_SOCK && !capable(CAP_NET_BIND_SERVICE))
>  		return -EACCES;
> =20
> -	bind_list =3D cma_ps_find(ps, &init_net, snum);
> +	bind_list =3D cma_ps_find(ps, id_priv->id.route.addr.dev_addr.net, =
snum);
>  	if (!bind_list) {
>  		ret =3D cma_alloc_port(ps, id_priv, snum);
>  	} else {
> @@ -2573,8 +2582,11 @@ int rdma_bind_addr(struct rdma_cm_id *id, stru=
ct sockaddr *addr)
>  		if (addr->sa_family =3D=3D AF_INET)
>  			id_priv->afonly =3D 1;
>  #if IS_ENABLED(CONFIG_IPV6)
> -		else if (addr->sa_family =3D=3D AF_INET6)
> -			id_priv->afonly =3D init_net.ipv6.sysctl.bindv6only;
> +		else if (addr->sa_family =3D=3D AF_INET6) {
> +			struct net *net =3D id_priv->id.route.addr.dev_addr.net;
> +
> +			id_priv->afonly =3D net->ipv6.sysctl.bindv6only;
> +		}
>  #endif
>  	}
>  	ret =3D cma_get_port(id_priv);
> @@ -2687,7 +2699,7 @@ static int cma_resolve_ib_udp(struct rdma_id_pr=
ivate *id_priv,
>  	}
> =20
>  	id =3D ib_create_cm_id(id_priv->id.device, cma_sidr_rep_handler,
> -			     id_priv, &init_net);
> +			     id_priv, id_priv->id.route.addr.dev_addr.net);
>  	if (IS_ERR(id)) {
>  		ret =3D PTR_ERR(id);
>  		goto out;
> @@ -2737,7 +2749,7 @@ static int cma_connect_ib(struct rdma_id_privat=
e *id_priv,
>  		       conn_param->private_data_len);
> =20
>  	id =3D ib_create_cm_id(id_priv->id.device, cma_ib_handler, id_priv,
> -			     &init_net);
> +			     id_priv->id.route.addr.dev_addr.net);
>  	if (IS_ERR(id)) {
>  		ret =3D PTR_ERR(id);
>  		goto out;
> @@ -3387,6 +3399,7 @@ static int cma_netdev_change(struct net_device =
*ndev, struct rdma_id_private *id
>  	dev_addr =3D &id_priv->id.route.addr.dev_addr;
> =20
>  	if ((dev_addr->bound_dev_if =3D=3D ndev->ifindex) &&
> +	    (dev_net(ndev) =3D=3D dev_addr->net) &&

net_eq() ?

>  	    memcmp(dev_addr->src_dev_addr, ndev->dev_addr, ndev->addr_len))=
 {
>  		printk(KERN_INFO "RDMA CM addr change for ndev %s used by id %p\n"=
,
>  		       ndev->name, &id_priv->id);
> @@ -3412,9 +3425,6 @@ static int cma_netdev_callback(struct notifier_=
block *self, unsigned long event,
>  	struct rdma_id_private *id_priv;
>  	int ret =3D NOTIFY_DONE;
> =20
> -	if (dev_net(ndev) !=3D &init_net)
> -		return NOTIFY_DONE;
> -
>  	if (event !=3D NETDEV_BONDING_FAILOVER)
>  		return NOTIFY_DONE;
> =20
> diff --git a/drivers/infiniband/core/ucma.c b/drivers/infiniband/core=
/ucma.c
> index 56a4b7ca7ee3..de755f2c6166 100644
> --- a/drivers/infiniband/core/ucma.c
> +++ b/drivers/infiniband/core/ucma.c
> @@ -391,7 +391,8 @@ static ssize_t ucma_create_id(struct ucma_file *f=
ile, const char __user *inbuf,
>  		return -ENOMEM;
> =20
>  	ctx->uid =3D cmd.uid;
> -	ctx->cm_id =3D rdma_create_id(ucma_event_handler, ctx, cmd.ps, qp_t=
ype);
> +	ctx->cm_id =3D rdma_create_id(ucma_event_handler, ctx, cmd.ps, qp_t=
ype,
> +				    &init_net);
>  	if (IS_ERR(ctx->cm_id)) {
>  		ret =3D PTR_ERR(ctx->cm_id);
>  		goto err1;
> diff --git a/drivers/infiniband/ulp/iser/iser_verbs.c b/drivers/infin=
iband/ulp/iser/iser_verbs.c
> index 695a2704bd43..d4e9c639ad2f 100644
> --- a/drivers/infiniband/ulp/iser/iser_verbs.c
> +++ b/drivers/infiniband/ulp/iser/iser_verbs.c
> @@ -949,7 +949,7 @@ int iser_connect(struct iser_conn   *iser_conn,
> =20
>  	ib_conn->cma_id =3D rdma_create_id(iser_cma_handler,
>  					 (void *)iser_conn,
> -					 RDMA_PS_TCP, IB_QPT_RC);
> +					 RDMA_PS_TCP, IB_QPT_RC, &init_net);
>  	if (IS_ERR(ib_conn->cma_id)) {
>  		err =3D PTR_ERR(ib_conn->cma_id);
>  		iser_err("rdma_create_id failed: %d\n", err);
> diff --git a/drivers/infiniband/ulp/isert/ib_isert.c b/drivers/infini=
band/ulp/isert/ib_isert.c
> index dafb3c531f96..44a6fff8dc79 100644
> --- a/drivers/infiniband/ulp/isert/ib_isert.c
> +++ b/drivers/infiniband/ulp/isert/ib_isert.c
> @@ -2960,7 +2960,7 @@ isert_setup_id(struct isert_np *isert_np)
>  	isert_dbg("ksockaddr: %p, sa: %p\n", &np->np_sockaddr, sa);
> =20
>  	id =3D rdma_create_id(isert_cma_handler, isert_np,
> -			    RDMA_PS_TCP, IB_QPT_RC);
> +			    RDMA_PS_TCP, IB_QPT_RC, &init_net);
>  	if (IS_ERR(id)) {
>  		isert_err("rdma_create_id() failed: %ld\n", PTR_ERR(id));
>  		ret =3D PTR_ERR(id);
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/dr=
ivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
> index b02b4ec1e29d..128de4eb0959 100644
> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
> @@ -125,7 +125,9 @@ extern kib_tunables_t  kiblnd_tunables;
>  				     IBLND_CREDIT_HIGHWATER_V1 : \
>  				     *kiblnd_tunables.kib_peercredits_hiw) /* when eagerly to re=
turn credits */
> =20
> -#define kiblnd_rdma_create_id(cb, dev, ps, qpt) rdma_create_id(cb, d=
ev, ps, qpt)
> +#define kiblnd_rdma_create_id(cb, dev, ps, qpt) rdma_create_id(cb, d=
ev, \
> +							       ps, qpt, \
> +							       &init_net)
> =20
>  static inline int
>  kiblnd_concurrent_sends_v1(void)
> diff --git a/include/rdma/rdma_cm.h b/include/rdma/rdma_cm.h
> index 1ed2088dc9f5..3953e9c8bc94 100644
> --- a/include/rdma/rdma_cm.h
> +++ b/include/rdma/rdma_cm.h
> @@ -163,10 +163,14 @@ struct rdma_cm_id {
>   * @context: User specified context associated with the id.
>   * @ps: RDMA port space.
>   * @qp_type: type of queue pair associated with the id.
> + * @net: The network namespace in which to create the new id.
> + *
> + * The id holds a reference on the network namespace until it is des=
troyed.
>   */
>  struct rdma_cm_id *rdma_create_id(rdma_cm_event_handler event_handle=
r,
>  				  void *context, enum rdma_port_space ps,
> -				  enum ib_qp_type qp_type);
> +				  enum ib_qp_type qp_type,
> +				  struct net *net);
> =20
>  /**
>    * rdma_destroy_id - Destroys an RDMA identifier.
> diff --git a/net/9p/trans_rdma.c b/net/9p/trans_rdma.c
> index 14ad43b5cf89..577fd3129bcf 100644
> --- a/net/9p/trans_rdma.c
> +++ b/net/9p/trans_rdma.c
> @@ -635,7 +635,7 @@ rdma_create_trans(struct p9_client *client, const=
 char *addr, char *args)
> =20
>  	/* Create the RDMA CM ID */
>  	rdma->cm_id =3D rdma_create_id(p9_cm_event_handler, client, RDMA_PS=
_TCP,
> -				     IB_QPT_RC);
> +				     IB_QPT_RC, &init_net);
>  	if (IS_ERR(rdma->cm_id))
>  		goto error;
> =20
> diff --git a/net/rds/ib.c b/net/rds/ib.c
> index ba2dffeff608..cc137f523248 100644
> --- a/net/rds/ib.c
> +++ b/net/rds/ib.c
> @@ -326,7 +326,7 @@ static int rds_ib_laddr_check(__be32 addr)
>  	/* Create a CMA ID and try to bind it. This catches both
>  	 * IB and iWARP capable NICs.
>  	 */
> -	cm_id =3D rdma_create_id(NULL, NULL, RDMA_PS_TCP, IB_QPT_RC);
> +	cm_id =3D rdma_create_id(NULL, NULL, RDMA_PS_TCP, IB_QPT_RC, &init_=
net);
>  	if (IS_ERR(cm_id))
>  		return PTR_ERR(cm_id);
> =20
> diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
> index 31b74f5e61ad..d19b91296ddc 100644
> --- a/net/rds/ib_cm.c
> +++ b/net/rds/ib_cm.c
> @@ -584,7 +584,7 @@ int rds_ib_conn_connect(struct rds_connection *co=
nn)
>  	/* XXX I wonder what affect the port space has */
>  	/* delegate cm event handler to rdma_transport */
>  	ic->i_cm_id =3D rdma_create_id(rds_rdma_cm_event_handler, conn,
> -				     RDMA_PS_TCP, IB_QPT_RC);
> +				     RDMA_PS_TCP, IB_QPT_RC, &init_net);
>  	if (IS_ERR(ic->i_cm_id)) {
>  		ret =3D PTR_ERR(ic->i_cm_id);
>  		ic->i_cm_id =3D NULL;
> diff --git a/net/rds/iw.c b/net/rds/iw.c
> index 589935661d66..8501b73ed12f 100644
> --- a/net/rds/iw.c
> +++ b/net/rds/iw.c
> @@ -227,7 +227,7 @@ static int rds_iw_laddr_check(__be32 addr)
>  	/* Create a CMA ID and try to bind it. This catches both
>  	 * IB and iWARP capable NICs.
>  	 */
> -	cm_id =3D rdma_create_id(NULL, NULL, RDMA_PS_TCP, IB_QPT_RC);
> +	cm_id =3D rdma_create_id(NULL, NULL, RDMA_PS_TCP, IB_QPT_RC, &init_=
net);
>  	if (IS_ERR(cm_id))
>  		return PTR_ERR(cm_id);
> =20
> diff --git a/net/rds/iw_cm.c b/net/rds/iw_cm.c
> index a91e1db62ee6..e5ee2d562a60 100644
> --- a/net/rds/iw_cm.c
> +++ b/net/rds/iw_cm.c
> @@ -521,7 +521,7 @@ int rds_iw_conn_connect(struct rds_connection *co=
nn)
>  	/* XXX I wonder what affect the port space has */
>  	/* delegate cm event handler to rdma_transport */
>  	ic->i_cm_id =3D rdma_create_id(rds_rdma_cm_event_handler, conn,
> -				     RDMA_PS_TCP, IB_QPT_RC);
> +				     RDMA_PS_TCP, IB_QPT_RC, &init_net);
>  	if (IS_ERR(ic->i_cm_id)) {
>  		ret =3D PTR_ERR(ic->i_cm_id);
>  		ic->i_cm_id =3D NULL;
> diff --git a/net/rds/rdma_transport.c b/net/rds/rdma_transport.c
> index 6cd9d1deafc3..066b60b27b12 100644
> --- a/net/rds/rdma_transport.c
> +++ b/net/rds/rdma_transport.c
> @@ -160,7 +160,7 @@ static int rds_rdma_listen_init(void)
>  	int ret;
> =20
>  	cm_id =3D rdma_create_id(rds_rdma_cm_event_handler, NULL, RDMA_PS_T=
CP,
> -			       IB_QPT_RC);
> +			       IB_QPT_RC, &init_net);
>  	if (IS_ERR(cm_id)) {
>  		ret =3D PTR_ERR(cm_id);
>  		printk(KERN_ERR "RDS/RDMA: failed to setup listener, "
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xp=
rtrdma/svc_rdma_transport.c
> index 4e618808bc98..e3b246e305f9 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -701,7 +701,7 @@ static struct svc_xprt *svc_rdma_create(struct sv=
c_serv *serv,
>  	xprt =3D &cma_xprt->sc_xprt;
> =20
>  	listen_id =3D rdma_create_id(rdma_listen_handler, cma_xprt, RDMA_PS=
_TCP,
> -				   IB_QPT_RC);
> +				   IB_QPT_RC, &init_net);
>  	if (IS_ERR(listen_id)) {
>  		ret =3D PTR_ERR(listen_id);
>  		dprintk("svcrdma: rdma_create_id failed =3D %d\n", ret);
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.=
c
> index c98e40643910..f574e77165f4 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -483,7 +483,8 @@ rpcrdma_create_id(struct rpcrdma_xprt *xprt,
> =20
>  	init_completion(&ia->ri_done);
> =20
> -	id =3D rdma_create_id(rpcrdma_conn_upcall, xprt, RDMA_PS_TCP, IB_QP=
T_RC);
> +	id =3D rdma_create_id(rpcrdma_conn_upcall, xprt, RDMA_PS_TCP, IB_QP=
T_RC,
> +			    &init_net);
>  	if (IS_ERR(id)) {
>  		rc =3D PTR_ERR(id);
>  		dprintk("RPC:       %s: rdma_create_id() failed %i\n",

Regards.

--=20
Yann Droneaud
OPTEYA
