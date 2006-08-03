From: Sean Hefty <mshefty@ichips.intel.com>
Subject: Re: [openib-general] [PATCH v4 2/2] iWARP Core Changes.
Date: Thu, 03 Aug 2006 11:11:11 -0700
Message-ID: <44D23C3F.3000204@ichips.intel.com>
References: <20060802202747.24212.10931.stgit@dell3.ogc.int> <20060802202752.24212.73349.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, netdev@vger.kernel.org, davem@davemloft.net,
	openib-general@openib.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28026 "EHLO
	orsmga102-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S964777AbWHCSOj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 14:14:39 -0400
To: Steve Wise <swise@opengridcomputing.com>
In-Reply-To: <20060802202752.24212.73349.stgit@dell3.ogc.int>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steve Wise wrote:
> diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
> index d294bbc..83f84ef 100644
> --- a/drivers/infiniband/core/addr.c
> +++ b/drivers/infiniband/core/addr.c
> @@ -32,6 +32,7 @@ #include <linux/mutex.h>
>  #include <linux/inetdevice.h>
>  #include <linux/workqueue.h>
>  #include <linux/if_arp.h>
> +#include <linux/inetdevice.h>

File is included 3 lines up.

> diff --git a/drivers/infiniband/core/cache.c b/drivers/infiniband/core/cache.c
> index e05ca2c..061858c 100644
>  #include <linux/module.h>
>  #include <linux/errno.h>
>  #include <linux/slab.h>
> -#include <linux/sched.h>	/* INIT_WORK, schedule_work(), flush_scheduled_work() */

I'm guessing that the include isn't currently needed, since none of the other 
changes to the file should have removed its dependency.  Should this be put into 
a separate patch?

> +static int iw_conn_req_handler(struct iw_cm_id *cm_id, 
> +			       struct iw_cm_event *iw_event)
> +{
> +	struct rdma_cm_id *new_cm_id;
> +	struct rdma_id_private *listen_id, *conn_id;
> +	struct sockaddr_in *sin;
> +	struct net_device *dev = NULL;
> +	int ret;
> +
> +	listen_id = cm_id->context;
> +	atomic_inc(&listen_id->dev_remove);
> +	if (!cma_comp(listen_id, CMA_LISTEN)) {
> +		ret = -ECONNABORTED;
> +		goto out;
> +	}
> +
> +	/* Create a new RDMA id for the new IW CM ID */
> +	new_cm_id = rdma_create_id(listen_id->id.event_handler, 
> +				   listen_id->id.context,
> +				   RDMA_PS_TCP);
> +	if (!new_cm_id) {
> +		ret = -ENOMEM;
> +		goto out;
> +	}
> +	conn_id = container_of(new_cm_id, struct rdma_id_private, id);
> +	atomic_inc(&conn_id->dev_remove);

This is not released in error cases.  See below.

> +	conn_id->state = CMA_CONNECT;
> +
> +	dev = ip_dev_find(iw_event->local_addr.sin_addr.s_addr);
> +	if (!dev) {
> +		ret = -EADDRNOTAVAIL;

cma_release_remove(conn_id);

> +		rdma_destroy_id(new_cm_id);
> +		goto out;
> +	}
> +	ret = rdma_copy_addr(&conn_id->id.route.addr.dev_addr, dev, NULL);
> +	if (ret) {

cma_release_remove(conn_id);

> +		rdma_destroy_id(new_cm_id);
> +		goto out;
> +	}
> +
> +	ret = cma_acquire_dev(conn_id);
> +	if (ret) {

cma_release_remove(conn_id);

> +		rdma_destroy_id(new_cm_id);
> +		goto out;
> +	}
> +
> +	conn_id->cm_id.iw = cm_id;
> +	cm_id->context = conn_id;
> +	cm_id->cm_handler = cma_iw_handler;
> +
> +	sin = (struct sockaddr_in *) &new_cm_id->route.addr.src_addr;
> +	*sin = iw_event->local_addr;
> +	sin = (struct sockaddr_in *) &new_cm_id->route.addr.dst_addr;
> +	*sin = iw_event->remote_addr;
> +
> +	ret = cma_notify_user(conn_id, RDMA_CM_EVENT_CONNECT_REQUEST, 0,
> +			      iw_event->private_data,
> +			      iw_event->private_data_len);
> +	if (ret) {
> +		/* User wants to destroy the CM ID */
> +		conn_id->cm_id.iw = NULL;
> +		cma_exch(conn_id, CMA_DESTROYING);
> +		cma_release_remove(conn_id);
> +		rdma_destroy_id(&conn_id->id);
> +	}
> +
> +out:
> +	if (!dev)
> +		dev_put(dev);

Shouldn't this be: if (dev)?

> +	cma_release_remove(listen_id);
> +	return ret;
> +}
> @@ -1357,8 +1552,8 @@ static int cma_resolve_loopback(struct r
>  	ib_addr_set_dgid(&id_priv->id.route.addr.dev_addr, &gid);
>  
>  	if (cma_zero_addr(&id_priv->id.route.addr.src_addr)) {
> -		src_in = (struct sockaddr_in *)&id_priv->id.route.addr.src_addr;
> -		dst_in = (struct sockaddr_in *)&id_priv->id.route.addr.dst_addr;
> +		src_in = (struct sockaddr_in *) &id_priv->id.route.addr.src_addr;
> +		dst_in = (struct sockaddr_in *) &id_priv->id.route.addr.dst_addr;

trivial spacing change only

> +static inline void iw_addr_get_sgid(struct rdma_dev_addr* rda, 
> +				    union ib_gid *gid)
> +{
> +	memcpy(gid, rda->src_dev_addr, sizeof *gid);
> +}
> +
> +static inline union ib_gid* iw_addr_get_dgid(struct rdma_dev_addr* rda)
> +{
> +	return (union ib_gid *) rda->dst_dev_addr;
> +}

Minor personal nit: for consistency with the rest of the file, can you use 
dev_addr in place of rda?

- Sean
