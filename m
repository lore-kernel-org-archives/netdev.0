From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH v2 1/2] xen-netback: fix memory leaks on XenBus disconnect
Date: Wed, 18 Jan 2017 09:27:06 +0000
Message-ID: <5a55d0748e7945539b9ee49f4c7f7084@AMSPEX02CL03.citrite.net>
References: <1484686178-76959-1-git-send-email-igor.druzhinin@citrix.com>
 <1484686178-76959-2-git-send-email-igor.druzhinin@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Igor Druzhinin <igor.druzhinin@citrix.com>
To: Igor Druzhinin <igor.druzhinin@citrix.com>,
        Wei Liu <wei.liu2@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1484686178-76959-2-git-send-email-igor.druzhinin@citrix.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Igor Druzhinin [mailto:igor.druzhinin@citrix.com]
> Sent: 17 January 2017 20:50
> To: Wei Liu <wei.liu2@citrix.com>
> Cc: Paul Durrant <Paul.Durrant@citrix.com>; xen-devel@lists.xenproject.org;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Igor Druzhinin
> <igor.druzhinin@citrix.com>
> Subject: [PATCH v2 1/2] xen-netback: fix memory leaks on XenBus
> disconnect
> 
> Eliminate memory leaks introduced several years ago by cleaning the
> queue resources which are allocated on XenBus connection event. Namely,
> queue
> structure array and pages used for IO rings.
> 
> Signed-off-by: Igor Druzhinin <igor.druzhinin@citrix.com>

Reviewed-by: Paul Durrant <paul.durrant@citrix.com>

> ---
>  drivers/net/xen-netback/xenbus.c | 11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-
> netback/xenbus.c
> index 6c57b02..3e99071 100644
> --- a/drivers/net/xen-netback/xenbus.c
> +++ b/drivers/net/xen-netback/xenbus.c
> @@ -493,11 +493,20 @@ static int backend_create_xenvif(struct
> backend_info *be)
>  static void backend_disconnect(struct backend_info *be)
>  {
>  	if (be->vif) {
> +		unsigned int queue_index;
> +
>  		xen_unregister_watchers(be->vif);
>  #ifdef CONFIG_DEBUG_FS
>  		xenvif_debugfs_delif(be->vif);
>  #endif /* CONFIG_DEBUG_FS */
>  		xenvif_disconnect_data(be->vif);
> +		for (queue_index = 0; queue_index < be->vif-
> >num_queues; ++queue_index)
> +			xenvif_deinit_queue(&be->vif-
> >queues[queue_index]);
> +
> +		vfree(be->vif->queues);
> +		be->vif->num_queues = 0;
> +		be->vif->queues = NULL;
> +
>  		xenvif_disconnect_ctrl(be->vif);
>  	}
>  }
> @@ -1026,6 +1035,8 @@ static void connect(struct backend_info *be)
>  err:
>  	if (be->vif->num_queues > 0)
>  		xenvif_disconnect_data(be->vif); /* Clean up existing
> queues */
> +	for (queue_index = 0; queue_index < be->vif->num_queues;
> ++queue_index)
> +		xenvif_deinit_queue(&be->vif->queues[queue_index]);
>  	vfree(be->vif->queues);
>  	be->vif->queues = NULL;
>  	be->vif->num_queues = 0;
> --
> 1.8.3.1
