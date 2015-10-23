From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next RFC 2/2] vhost_net: basic polling support
Date: Fri, 23 Oct 2015 16:39:26 +0300
Message-ID: <20151023163839-mutt-send-email-mst@redhat.com>
References: <1445491649-62614-1-git-send-email-jasowang@redhat.com>
 <1445491649-62614-2-git-send-email-jasowang@redhat.com>
 <20151022113824-mutt-send-email-mst@redhat.com>
 <5629DE03.7030902@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5629DE03.7030902@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 23, 2015 at 03:13:07PM +0800, Jason Wang wrote:
> 
> 
> On 10/22/2015 05:33 PM, Michael S. Tsirkin wrote:
> > On Thu, Oct 22, 2015 at 01:27:29AM -0400, Jason Wang wrote:
> >> This patch tries to poll for new added tx buffer for a while at the
> >> end of tx processing. The maximum time spent on polling were limited
> >> through a module parameter. To avoid block rx, the loop will end it
> >> there's new other works queued on vhost so in fact socket receive
> >> queue is also be polled.
> >>
> >> busyloop_timeout = 50 gives us following improvement on TCP_RR test:
> >>
> >> size/session/+thu%/+normalize%
> >>     1/     1/   +5%/  -20%
> >>     1/    50/  +17%/   +3%
> > Is there a measureable increase in cpu utilization
> > with busyloop_timeout = 0?
> 
> Just run TCP_RR, no increasing. Will run a complete test on next version.
> 
> >
> >> Signed-off-by: Jason Wang <jasowang@redhat.com>
> > We might be able to shave off the minor regression
> > by careful use of likely/unlikely, or maybe
> > deferring 
> 
> Yes, but what did "deferring" mean here?

Don't call local_clock until we know we'll need it.

> >
> >> ---
> >>  drivers/vhost/net.c | 19 +++++++++++++++++++
> >>  1 file changed, 19 insertions(+)
> >>
> >> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> >> index 9eda69e..bbb522a 100644
> >> --- a/drivers/vhost/net.c
> >> +++ b/drivers/vhost/net.c
> >> @@ -31,7 +31,9 @@
> >>  #include "vhost.h"
> >>  
> >>  static int experimental_zcopytx = 1;
> >> +static int busyloop_timeout = 50;
> >>  module_param(experimental_zcopytx, int, 0444);
> >> +module_param(busyloop_timeout, int, 0444);
> > Pls add a description, including the units and the special
> > value 0.
> 
> Ok.
> 
> >
> >>  MODULE_PARM_DESC(experimental_zcopytx, "Enable Zero Copy TX;"
> >>  		                       " 1 -Enable; 0 - Disable");
> >>  
> >> @@ -287,12 +289,23 @@ static void vhost_zerocopy_callback(struct ubuf_info *ubuf, bool success)
> >>  	rcu_read_unlock_bh();
> >>  }
> >>  
> >> +static bool tx_can_busy_poll(struct vhost_dev *dev,
> >> +			     unsigned long endtime)
> >> +{
> >> +	unsigned long now = local_clock() >> 10;
> > local_clock might go backwards if we jump between CPUs.
> > One way to fix would be to record the CPU id and break
> > out of loop if that changes.
> 
> Right, or maybe disable preemption in this case?
> 
> >
> > Also - defer this until we actually know we need it?
> 
> Right.
> 
> >
> >> +
> >> +	return busyloop_timeout && !need_resched() &&
> >> +	       !time_after(now, endtime) && !vhost_has_work(dev) &&
> >> +	       single_task_running();
> > signal pending as well?
> 
> Yes.
> 
> >> +}
> >> +
> >>  /* Expects to be always run from workqueue - which acts as
> >>   * read-size critical section for our kind of RCU. */
> >>  static void handle_tx(struct vhost_net *net)
> >>  {
> >>  	struct vhost_net_virtqueue *nvq = &net->vqs[VHOST_NET_VQ_TX];
> >>  	struct vhost_virtqueue *vq = &nvq->vq;
> >> +	unsigned long endtime;
> >>  	unsigned out, in;
> >>  	int head;
> >>  	struct msghdr msg = {
> >> @@ -331,6 +344,8 @@ static void handle_tx(struct vhost_net *net)
> >>  			      % UIO_MAXIOV == nvq->done_idx))
> >>  			break;
> >>  
> >> +		endtime  = (local_clock() >> 10) + busyloop_timeout;
> >> +again:
> >>  		head = vhost_get_vq_desc(vq, vq->iov,
> >>  					 ARRAY_SIZE(vq->iov),
> >>  					 &out, &in,
> >> @@ -340,6 +355,10 @@ static void handle_tx(struct vhost_net *net)
> >>  			break;
> >>  		/* Nothing new?  Wait for eventfd to tell us they refilled. */
> >>  		if (head == vq->num) {
> >> +			if (tx_can_busy_poll(vq->dev, endtime)) {
> >> +				cpu_relax();
> >> +				goto again;
> >> +			}
> >>  			if (unlikely(vhost_enable_notify(&net->dev, vq))) {
> >>  				vhost_disable_notify(&net->dev, vq);
> >>  				continue;
> >> -- 
> >> 1.8.3.1
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
