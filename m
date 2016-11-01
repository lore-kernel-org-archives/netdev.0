From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH 06/12] xen: make use of xenbus_read_unsigned() in
 xen-netback
Date: Tue, 1 Nov 2016 09:42:21 +0000
Message-ID: <4f93ec8497514ec891f90cb2b540b0b9@AMSPEX02CL03.citrite.net>
References: <1477932510-28594-1-git-send-email-jgross@suse.com>
 <1477932510-28594-7-git-send-email-jgross@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Vrabel <david.vrabel@citrix.com>,
        "boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>,
        Wei Liu <wei.liu2@citrix.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Juergen Gross <jgross@suse.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477932510-28594-7-git-send-email-jgross@suse.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Juergen Gross [mailto:jgross@suse.com]
> Sent: 31 October 2016 16:48
> To: linux-kernel@vger.kernel.org; xen-devel@lists.xen.org
> Cc: David Vrabel <david.vrabel@citrix.com>; boris.ostrovsky@oracle.com;
> Juergen Gross <jgross@suse.com>; Wei Liu <wei.liu2@citrix.com>; Paul
> Durrant <Paul.Durrant@citrix.com>; netdev@vger.kernel.org
> Subject: [PATCH 06/12] xen: make use of xenbus_read_unsigned() in xen-
> netback
> 
> Use xenbus_read_unsigned() instead of xenbus_scanf() when possible.
> This requires to change the type of some reads from int to unsigned,
> but these cases have been wrong before: negative values are not allowed
> for the modified cases.
> 
> Cc: wei.liu2@citrix.com
> Cc: paul.durrant@citrix.com

Reviewed-by: Paul Durrant <paul.durrant@citrix.com>

> Cc: netdev@vger.kernel.org
> 
> Signed-off-by: Juergen Gross <jgross@suse.com>
> ---
>  drivers/net/xen-netback/xenbus.c | 50 +++++++++++---------------------------
> --
>  1 file changed, 14 insertions(+), 36 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-
> netback/xenbus.c
> index 8674e18..7356e00 100644
> --- a/drivers/net/xen-netback/xenbus.c
> +++ b/drivers/net/xen-netback/xenbus.c
> @@ -785,12 +785,9 @@ static void xen_mcast_ctrl_changed(struct
> xenbus_watch *watch,
>  	struct xenvif *vif = container_of(watch, struct xenvif,
>  					  mcast_ctrl_watch);
>  	struct xenbus_device *dev = xenvif_to_xenbus_device(vif);
> -	int val;
> 
> -	if (xenbus_scanf(XBT_NIL, dev->otherend,
> -			 "request-multicast-control", "%d", &val) < 0)
> -		val = 0;
> -	vif->multicast_control = !!val;
> +	vif->multicast_control = !!xenbus_read_unsigned(dev->otherend,
> +					"request-multicast-control", 0);
>  }
> 
>  static int xen_register_mcast_ctrl_watch(struct xenbus_device *dev,
> @@ -934,12 +931,9 @@ static void connect(struct backend_info *be)
>  	/* Check whether the frontend requested multiple queues
>  	 * and read the number requested.
>  	 */
> -	err = xenbus_scanf(XBT_NIL, dev->otherend,
> -			   "multi-queue-num-queues",
> -			   "%u", &requested_num_queues);
> -	if (err < 0) {
> -		requested_num_queues = 1; /* Fall back to single queue */
> -	} else if (requested_num_queues > xenvif_max_queues) {
> +	requested_num_queues = xenbus_read_unsigned(dev->otherend,
> +					"multi-queue-num-queues", 1);
> +	if (requested_num_queues > xenvif_max_queues) {
>  		/* buggy or malicious guest */
>  		xenbus_dev_fatal(dev, err,
>  				 "guest requested %u queues, exceeding the
> maximum of %u.",
> @@ -1134,7 +1128,7 @@ static int read_xenbus_vif_flags(struct
> backend_info *be)
>  	struct xenvif *vif = be->vif;
>  	struct xenbus_device *dev = be->dev;
>  	unsigned int rx_copy;
> -	int err, val;
> +	int err;
> 
>  	err = xenbus_scanf(XBT_NIL, dev->otherend, "request-rx-copy",
> "%u",
>  			   &rx_copy);
> @@ -1150,10 +1144,7 @@ static int read_xenbus_vif_flags(struct
> backend_info *be)
>  	if (!rx_copy)
>  		return -EOPNOTSUPP;
> 
> -	if (xenbus_scanf(XBT_NIL, dev->otherend,
> -			 "feature-rx-notify", "%d", &val) < 0)
> -		val = 0;
> -	if (!val) {
> +	if (!xenbus_read_unsigned(dev->otherend, "feature-rx-notify", 0)) {
>  		/* - Reduce drain timeout to poll more frequently for
>  		 *   Rx requests.
>  		 * - Disable Rx stall detection.
> @@ -1162,34 +1153,21 @@ static int read_xenbus_vif_flags(struct
> backend_info *be)
>  		be->vif->stall_timeout = 0;
>  	}
> 
> -	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-sg",
> -			 "%d", &val) < 0)
> -		val = 0;
> -	vif->can_sg = !!val;
> +	vif->can_sg = !!xenbus_read_unsigned(dev->otherend, "feature-
> sg", 0);
> 
>  	vif->gso_mask = 0;
> 
> -	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-gso-tcpv4",
> -			 "%d", &val) < 0)
> -		val = 0;
> -	if (val)
> +	if (xenbus_read_unsigned(dev->otherend, "feature-gso-tcpv4", 0))
>  		vif->gso_mask |= GSO_BIT(TCPV4);
> 
> -	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-gso-tcpv6",
> -			 "%d", &val) < 0)
> -		val = 0;
> -	if (val)
> +	if (xenbus_read_unsigned(dev->otherend, "feature-gso-tcpv6", 0))
>  		vif->gso_mask |= GSO_BIT(TCPV6);
> 
> -	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-no-csum-
> offload",
> -			 "%d", &val) < 0)
> -		val = 0;
> -	vif->ip_csum = !val;
> +	vif->ip_csum = !xenbus_read_unsigned(dev->otherend,
> +					     "feature-no-csum-offload", 0);
> 
> -	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-ipv6-csum-
> offload",
> -			 "%d", &val) < 0)
> -		val = 0;
> -	vif->ipv6_csum = !!val;
> +	vif->ipv6_csum = !!xenbus_read_unsigned(dev->otherend,
> +						"feature-ipv6-csum-offload",
> 0);
> 
>  	return 0;
>  }
> --
> 2.6.6
