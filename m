From: Yun Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Subject: Re: [RFC PATCH 07/11] IB/Verbs: Use management helper has_mcast()
 and, cap_mcast() for mcast-check
Date: Fri, 27 Mar 2015 18:31:26 +0100
Message-ID: <CAJuTgQUSm0pM8pqLiivTrKbhtXkKYZaZbBxYFTog0JatzQm3=g@mail.gmail.com>
References: <551579CA.4030901@profitbricks.com>
	<55157B71.6040505@profitbricks.com>
	<20150327162820.GC28412@obsidianresearch.com>
	<20150327170508.GB27862@phlsvsds.ph.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
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
To: "ira.weiny" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150327170508.GB27862-W4f6Xiosr+yv7QzWx2u06xL4W9x8LtSr@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 27, 2015 at 6:05 PM, ira.weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> wrote:
> On Fri, Mar 27, 2015 at 10:28:20AM -0600, Jason Gunthorpe wrote:
>> On Fri, Mar 27, 2015 at 04:46:57PM +0100, Michael Wang wrote:
>> >
[snip]
>> > -            if (rdma_transport_is_ib(id_priv->cma_dev->device)) {
>> > +            if (has_mcast(id_priv->cma_dev->device)) {
>>
>> This might make more sense as cap_ib_multicast / cap_ip_multicast
>
> Agreed.
>

Will be changed in next version :-)

>>
>> >                  switch (rdma_port_get_link_layer(id->device, id->port_num)) {
>> >                  case IB_LINK_LAYER_INFINIBAND:
>> >                      ib_sa_free_multicast(mc->multicast.ib);
>>
>> > diff --git a/drivers/infiniband/core/multicast.c b/drivers/infiniband/core/multicast.c
>> > index 17573ff..ffeaf27 100644
>> > +++ b/drivers/infiniband/core/multicast.c
>> > @@ -780,7 +780,7 @@ static void mcast_event_handler(struct ib_event_handler *handler,
>> >      int index;
>> >
>> >      dev = container_of(handler, struct mcast_device, event_handler);
>> > -    if (!rdma_port_ll_is_ib(dev->device, event->element.port_num))
>> > +    if (!cap_mcast(dev->device, event->element.port_num))
>> >          return;
>>
>> These should probably be cap_ib_sa - that is what they are guarding
>> against.
>>
>> But it seems redudent, since mcast_add_one will already not add a port that is
>> not IB, so mcast_event_handler is not callable. Something to do with
>> rocee/ib switching?
>
> I'm not sure about this either.  This check seems to be necessary only on a
> per-port level.  It does seem apparent that one can't go from Eth to IB.  What
> happens if you go from IB to Eth on the port?

I also feel it's redundant at first glance, but just not sure if it
could be removed, lack of some knowledge :-P

>
>>
>> >      index = event->element.port_num - dev->start_port;
>> > @@ -807,7 +807,7 @@ static void mcast_add_one(struct ib_device *device)
>> >      int i;
>> >      int count = 0;
>> >
>> > -    if (!rdma_transport_is_ib(device))
>> > +    if (!has_mcast(device))
>> >          return;
>>
>> Again, this seems redundant, every port is tested directly below, why
>> is this check needed?
>
> Agreed.  Same as my comments about the SA support.  This is really only
> needed on ports which need to register with the SA (or perhaps some future
> entity) for Mcast support.

I will recheck all the logical around has_XX() see if we can get rid of them ;-)

>
> Also this is part of the ib_sa module and exports the function
> ib_sa_join_multicast.  So that this point it is covered under the
> cap_sa(device, port) call.
>
> So the implementation of cap_mcast at this point is:
>
> cap_mcast(device, port)
> {
>         return cap_sa(device,port);
> }
>

Sounds good :-) will be in next version.

>>
>> Looking at this, I do wonder how a port can dynamically change between
>> rocee and IB.. If the link value changes then mcast_remove_one will
>> not be a perfect reversal of mcast_add_one. Bug?
>>
>> It feels necessary to understand what happens when a port dynamically
>> switches to ethernet on mlx hardware to validate these patches :(
>
> Agreed.

Maybe we can temporarily reserve the old logical, and gradually solve
these problems?

Regards,
Michael Wang


>
> :-(
>
> -- Ira
>
>>
>> Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
