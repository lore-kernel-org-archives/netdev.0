From: Tom Talpey <tom-CLs1Zie5N5HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 09/17] IB/Verbs: Use helper cap_read_multi_sge() and
 reform svc_rdma_accept()
Date: Tue, 07 Apr 2015 11:46:57 -0400
Message-ID: <5523FBF1.80304@talpey.com>
References: <5523CCD5.6030401@profitbricks.com> <5523CEE4.5060901@profitbricks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Tom Tucker <tom-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	Hoang-Nam Nguyen <hnguyen-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Christoph Raisch <raisch-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Mike Marciniszyn <infinipath-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Upinder Malhi <umalhi-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	PJ Waskiewicz <pj.waskiewicz-PrFOU5CTvK1l57MIdRCFDg@public.gmane.org>,
	Tatyana Nikolova <Tatyana.E.Nikolova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Ilya Nelkenbaum <ilyan-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yann Droneaud <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>,
	Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5523CEE4.5060901-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 4/7/2015 8:34 AM, Michael Wang wrote:
>   /**
> + * cap_read_multi_sge - Check if the port of device has the capability
> + * RDMA Read Multiple Scatter-Gather Entries.
> + *
> + * @device: Device to be checked
> + * @port_num: Port number of the device
> + *
> + * Return 0 when port of the device don't support
> + * RDMA Read Multiple Scatter-Gather Entries.
> + */
> +static inline int cap_read_multi_sge(struct ib_device *device, u8 port_num)
> +{
> +	return !rdma_transport_iwarp(device, port_num);
> +}

This just papers over the issue we discussed earlier. How *many*
entries does the device support? If a device supports one, or two,
is that enough? How does the upper layer know the limit?

This needs an explicit device attribute, to be fixed properly.

> +
> +/**
>    * cap_ipoib - Check if the port of device has the capability
>    * IP over Infiniband.
>    *
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> index e011027..604d035 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> @@ -118,8 +118,8 @@ static void rdma_build_arg_xdr(struct svc_rqst *rqstp,
>
>   static int rdma_read_max_sge(struct svcxprt_rdma *xprt, int sge_count)
>   {
> -	if (rdma_node_get_transport(xprt->sc_cm_id->device->node_type) ==
> -	     RDMA_TRANSPORT_IWARP)
> +	if (!cap_read_multi_sge(xprt->sc_cm_id->device,
> +				xprt->sc_cm_id->port_num))
>   		return 1;
>   	else
>   		return min_t(int, sge_count, xprt->sc_max_sge);

This is incorrect. The RDMA Read max is not at all the same as the
max_sge. It is a different operation, with a different set of work
request parameters.

In other words, the above same comment applies.


> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> index 4e61880..e75175d 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -979,8 +979,8 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
>   	/*
>   	 * Determine if a DMA MR is required and if so, what privs are required
>   	 */
> -	switch (rdma_node_get_transport(newxprt->sc_cm_id->device->node_type)) {
> -	case RDMA_TRANSPORT_IWARP:
> +	if (rdma_transport_iwarp(newxprt->sc_cm_id->device,
> +				 newxprt->sc_cm_id->port_num)) {
>   		newxprt->sc_dev_caps |= SVCRDMA_DEVCAP_READ_W_INV;

Do I read this correctly that it is forcing the "read with invalidate"
capability to "on" for all iWARP devices? I don't think that is correct,
for the legacy devices you're also supporting.


> @@ -992,8 +992,8 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
>   			dma_mr_acc = IB_ACCESS_LOCAL_WRITE;
>   		} else
>   			need_dma_mr = 0;
> -		break;
> -	case RDMA_TRANSPORT_IB:
> +	} else if (rdma_ib_mgmt(newxprt->sc_cm_id->device,
> +				newxprt->sc_cm_id->port_num)) {
>   		if (!(newxprt->sc_dev_caps & SVCRDMA_DEVCAP_FAST_REG)) {
>   			need_dma_mr = 1;
>   			dma_mr_acc = IB_ACCESS_LOCAL_WRITE;

Now I'm even more confused. How is the presence of IB management
related to needing a privileged lmr?


--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
