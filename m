From: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [PATCH 05/11] IB/cm: Share listening CM IDs
Date: Mon, 15 Jun 2015 22:13:30 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A82373A8FF5AAE@ORSMSX109.amr.corp.intel.com>
References: <1434358036-15526-1-git-send-email-haggaie@mellanox.com>
 <1434358036-15526-6-git-send-email-haggaie@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
To: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1434358036-15526-6-git-send-email-haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> @@ -722,6 +725,7 @@ struct ib_cm_id *ib_create_cm_id(struct ib_device
> *device,
>  	INIT_LIST_HEAD(&cm_id_priv->work_list);
>  	atomic_set(&cm_id_priv->work_count, -1);
>  	atomic_set(&cm_id_priv->refcount, 1);
> +	cm_id_priv->listen_sharecount = 1;

This is setting the listen count before we know whether the cm_id will actually be used to listen.


>  	return &cm_id_priv->id;
> 
>  error:
> @@ -847,11 +851,21 @@ retest:
>  	spin_lock_irq(&cm_id_priv->lock);
>  	switch (cm_id->state) {
>  	case IB_CM_LISTEN:
> -		cm_id->state = IB_CM_IDLE;
>  		spin_unlock_irq(&cm_id_priv->lock);
> +
>  		spin_lock_irq(&cm.lock);
> +		if (--cm_id_priv->listen_sharecount > 0) {
> +			/* The id is still shared. */
> +			atomic_dec(&cm_id_priv->refcount);
> +			spin_unlock_irq(&cm.lock);
> +			return;
> +		}
>  		rb_erase(&cm_id_priv->service_node, &cm.listen_service_table);
>  		spin_unlock_irq(&cm.lock);
> +
> +		spin_lock_irq(&cm_id_priv->lock);
> +		cm_id->state = IB_CM_IDLE;
> +		spin_unlock_irq(&cm_id_priv->lock);

Why is the state being changed?  The cm_id is about to be freed anyway.


>  		break;
>  	case IB_CM_SIDR_REQ_SENT:
>  		cm_id->state = IB_CM_IDLE;
> @@ -929,11 +943,32 @@ void ib_destroy_cm_id(struct ib_cm_id *cm_id)
>  }
>  EXPORT_SYMBOL(ib_destroy_cm_id);
> 
> -int ib_cm_listen(struct ib_cm_id *cm_id, __be64 service_id, __be64
> service_mask,
> -		 struct ib_cm_compare_data *compare_data)
> +/**
> + * __ib_cm_listen - Initiates listening on the specified service ID for
> + *   connection and service ID resolution requests.
> + * @cm_id: Connection identifier associated with the listen request.
> + * @service_id: Service identifier matched against incoming connection
> + *   and service ID resolution requests.  The service ID should be
> specified
> + *   network-byte order.  If set to IB_CM_ASSIGN_SERVICE_ID, the CM will
> + *   assign a service ID to the caller.
> + * @service_mask: Mask applied to service ID used to listen across a
> + *   range of service IDs.  If set to 0, the service ID is matched
> + *   exactly.  This parameter is ignored if %service_id is set to
> + *   IB_CM_ASSIGN_SERVICE_ID.
> + * @compare_data: This parameter is optional.  It specifies data that
> must
> + *   appear in the private data of a connection request for the specified
> + *   listen request.
> + * @lock: If set, lock the cm.lock spin-lock when adding the id to the
> + *   listener tree. When false, the caller must already hold the spin-
> lock,
> + *   and compare_data must be NULL.
> + */
> +static int __ib_cm_listen(struct ib_cm_id *cm_id, __be64 service_id,
> +			  __be64 service_mask,
> +			  struct ib_cm_compare_data *compare_data,
> +			  bool lock)
>  {
>  	struct cm_id_private *cm_id_priv, *cur_cm_id_priv;
> -	unsigned long flags;
> +	unsigned long flags = 0;
>  	int ret = 0;
> 
>  	service_mask = service_mask ? service_mask : ~cpu_to_be64(0);
> @@ -959,7 +994,8 @@ int ib_cm_listen(struct ib_cm_id *cm_id, __be64
> service_id, __be64 service_mask,
> 
>  	cm_id->state = IB_CM_LISTEN;
> 
> -	spin_lock_irqsave(&cm.lock, flags);
> +	if (lock)
> +		spin_lock_irqsave(&cm.lock, flags);

I'm not a fan of this sort of locking structure.  Why not just move the locking into the outside calls completely?  I.e. move to ib_cm_listen() instead of passing in true.


>  	if (service_id == IB_CM_ASSIGN_SERVICE_ID) {
>  		cm_id->service_id = cpu_to_be64(cm.listen_service_id++);
>  		cm_id->service_mask = ~cpu_to_be64(0);
> @@ -968,7 +1004,8 @@ int ib_cm_listen(struct ib_cm_id *cm_id, __be64
> service_id, __be64 service_mask,
>  		cm_id->service_mask = service_mask;
>  	}
>  	cur_cm_id_priv = cm_insert_listen(cm_id_priv);
> -	spin_unlock_irqrestore(&cm.lock, flags);
> +	if (lock)
> +		spin_unlock_irqrestore(&cm.lock, flags);
> 
>  	if (cur_cm_id_priv) {
>  		cm_id->state = IB_CM_IDLE;
> @@ -978,8 +1015,86 @@ int ib_cm_listen(struct ib_cm_id *cm_id, __be64
> service_id, __be64 service_mask,
>  	}
>  	return ret;
>  }
> +
> +int ib_cm_listen(struct ib_cm_id *cm_id, __be64 service_id, __be64
> service_mask,
> +		 struct ib_cm_compare_data *compare_data)
> +{
> +	return __ib_cm_listen(cm_id, service_id, service_mask, compare_data,
> +			      true);
> +}
>  EXPORT_SYMBOL(ib_cm_listen);
> 
> +/**
> + * Create a new listening ib_cm_id and listen on the given service ID.
> + *
> + * If there's an existing ID listening on that same device and service
> ID,
> + * return it.
> + *
> + * @device: Device associated with the cm_id.  All related communication
> will
> + * be associated with the specified device.
> + * @cm_handler: Callback invoked to notify the user of CM events.
> + * @service_id: Service identifier matched against incoming connection
> + *   and service ID resolution requests.  The service ID should be
> specified
> + *   network-byte order.  If set to IB_CM_ASSIGN_SERVICE_ID, the CM will
> + *   assign a service ID to the caller.
> + * @service_mask: Mask applied to service ID used to listen across a
> + *   range of service IDs.  If set to 0, the service ID is matched
> + *   exactly.  This parameter is ignored if %service_id is set to
> + *   IB_CM_ASSIGN_SERVICE_ID.
> + *
> + * Callers should call ib_destroy_cm_id when done with the listener ID.
> + */
> +struct ib_cm_id *ib_cm_id_create_and_listen(

Maybe ib_cm_insert_listen() instead?

> +		struct ib_device *device,
> +		ib_cm_handler cm_handler,
> +		__be64 service_id,
> +		__be64 service_mask)
> +{
> +	struct cm_id_private *cm_id_priv;
> +	struct ib_cm_id *cm_id;
> +	unsigned long flags;
> +	int err = 0;
> +
> +	/* Create an ID in advance, since the creation may sleep */
> +	cm_id = ib_create_cm_id(device, cm_handler, NULL);
> +	if (IS_ERR(cm_id))
> +		return cm_id;
> +
> +	spin_lock_irqsave(&cm.lock, flags);
> +
> +	if (service_id == IB_CM_ASSIGN_SERVICE_ID)
> +		goto new_id;
> +
> +	/* Find an existing ID */
> +	cm_id_priv = cm_find_listen(device, service_id, NULL);
> +	if (cm_id_priv) {
> +		atomic_inc(&cm_id_priv->refcount);
> +		++cm_id_priv->listen_sharecount;
> +		spin_unlock_irqrestore(&cm.lock, flags);
> +
> +		ib_destroy_cm_id(cm_id);
> +		cm_id = &cm_id_priv->id;
> +		if (cm_id->cm_handler != cm_handler || cm_id->context)
> +			/* Sharing an ib_cm_id with different handlers is not
> +			 * supported */
> +			return ERR_PTR(-EINVAL);

This leaks listen_sharecount references.


> +		return cm_id;
> +	}
> +
> +new_id:
> +	/* Use newly created ID */
> +	err = __ib_cm_listen(cm_id, service_id, service_mask, NULL, false);
> +
> +	spin_unlock_irqrestore(&cm.lock, flags);
> +
> +	if (err) {
> +		ib_destroy_cm_id(cm_id);
> +		return ERR_PTR(err);
> +	}
> +	return cm_id;
> +}
> +EXPORT_SYMBOL(ib_cm_id_create_and_listen);
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
