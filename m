From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH v3 for-next 05/13] IB/cm: Reference count ib_cm_ids
Date: Mon, 11 May 2015 12:34:59 -0600
Message-ID: <20150511183459.GB25405@obsidianresearch.com>
References: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
 <1431253604-9214-6-git-send-email-haggaie@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1431253604-9214-6-git-send-email-haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, May 10, 2015 at 01:26:36PM +0300, Haggai Eran wrote:
> Add reference count (kref) to the ib_cm_id to allow automatic destruction
> of an ib_cm_id. This will allow multiple RDMA CM IDs to use a single
> ib_cm_id when they are on different network namespaces.
> 
> Signed-off-by: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>  drivers/infiniband/core/cm.c | 41 +++++++++++++++++++++++++++++++++++++----
>  include/rdma/ib_cm.h         | 10 +++++++---
>  2 files changed, 44 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/infiniband/core/cm.c b/drivers/infiniband/core/cm.c
> index 08b18044552a..6b68402fd6df 100644
> +++ b/drivers/infiniband/core/cm.c
> @@ -711,6 +711,7 @@ struct ib_cm_id *ib_create_cm_id(struct ib_device *device,
>  	cm_id_priv->id.cm_handler = cm_handler;
>  	cm_id_priv->id.context = context;
>  	cm_id_priv->id.remote_cm_qpn = 1;
> +	kref_init(&cm_id_priv->id.ref);
>  	ret = cm_alloc_id(cm_id_priv);
>  	if (ret)
>  		goto error;

Idiomatically, once kref_init is called, kfree should not be used, you
have to kref_put to destroy it, this error path calls kfree directly.

Probably best to just move the kref_init to after the failable call.

> -void ib_destroy_cm_id(struct ib_cm_id *cm_id)
> +static void __ib_destroy_cm_id(struct kref *ref)
>  {
> +	struct ib_cm_id *cm_id = container_of(ref, struct ib_cm_id, ref);
> +
>  	cm_destroy_id(cm_id, 0);
>  }

Hum, this is quite a heavy free function. Did you check that this is
safe to do asynchronously, that there are no implicit kref's being
held by the caller?

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
