From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [RFC PATCH 07/11] IB/Verbs: Use management helper has_mcast()
 and, cap_mcast() for mcast-check
Date: Fri, 27 Mar 2015 10:28:20 -0600
Message-ID: <20150327162820.GC28412@obsidianresearch.com>
References: <551579CA.4030901@profitbricks.com>
 <55157B71.6040505@profitbricks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Moni Shoua <monis-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	PJ Waskiewicz <pj.waskiewicz-PrFOU5CTvK1l57MIdRCFDg@public.gmane.org>,
	Tatyana Nikolova <Tatyana.E.Nikolova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Yan Burman <yanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>,
	Yann Droneaud <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>,
	Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Majd Dibbiny <majd-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Alex Estrin <alex.estrin@int
To: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <55157B71.6040505-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 27, 2015 at 04:46:57PM +0100, Michael Wang wrote:
> 
> Introduce helper has_mcast() and cap_mcast() to help us check if an
> IB device or it's port support Multicast.
> 
> Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
> Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
>  drivers/infiniband/core/cma.c       |  2 +-
>  drivers/infiniband/core/multicast.c |  8 ++++----
>  include/rdma/ib_verbs.h             | 28 ++++++++++++++++++++++++++++
>  3 files changed, 33 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
> index 276fb76..cbbc85b 100644
> +++ b/drivers/infiniband/core/cma.c
> @@ -3398,7 +3398,7 @@ void rdma_leave_multicast(struct rdma_cm_id *id, struct sockaddr *addr)
>                  ib_detach_mcast(id->qp,
>                          &mc->multicast.ib->rec.mgid,
>                          be16_to_cpu(mc->multicast.ib->rec.mlid));
> -            if (rdma_transport_is_ib(id_priv->cma_dev->device)) {
> +            if (has_mcast(id_priv->cma_dev->device)) {

This might make more sense as cap_ib_multicast / cap_ip_multicast

>                  switch (rdma_port_get_link_layer(id->device, id->port_num)) {
>                  case IB_LINK_LAYER_INFINIBAND:
>                      ib_sa_free_multicast(mc->multicast.ib);

> diff --git a/drivers/infiniband/core/multicast.c b/drivers/infiniband/core/multicast.c
> index 17573ff..ffeaf27 100644
> +++ b/drivers/infiniband/core/multicast.c
> @@ -780,7 +780,7 @@ static void mcast_event_handler(struct ib_event_handler *handler,
>      int index;
>  
>      dev = container_of(handler, struct mcast_device, event_handler);
> -    if (!rdma_port_ll_is_ib(dev->device, event->element.port_num))
> +    if (!cap_mcast(dev->device, event->element.port_num))
>          return;

These should probably be cap_ib_sa - that is what they are guarding
against.

But it seems redudent, since mcast_add_one will already not add a port that is
not IB, so mcast_event_handler is not callable. Something to do with
rocee/ib switching?

>      index = event->element.port_num - dev->start_port;
> @@ -807,7 +807,7 @@ static void mcast_add_one(struct ib_device *device)
>      int i;
>      int count = 0;
>  
> -    if (!rdma_transport_is_ib(device))
> +    if (!has_mcast(device))
>          return;

Again, this seems redundant, every port is tested directly below, why
is this check needed?

Looking at this, I do wonder how a port can dynamically change between
rocee and IB.. If the link value changes then mcast_remove_one will
not be a perfect reversal of mcast_add_one. Bug?

It feels necessary to understand what happens when a port dynamically
switches to ethernet on mlx hardware to validate these patches :(

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
