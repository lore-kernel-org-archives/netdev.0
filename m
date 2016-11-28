From: Neil Horman <nhorman@redhat.com>
Subject: Re: [PATCH net-next] virtio-net: enable multiqueue by default
Date: Mon, 28 Nov 2016 10:25:07 -0500
Message-ID: <20161128152507.GB14706@hmsreliant.think-freely.org>
References: <1480048646-17536-1-git-send-email-jasowang@redhat.com>
 <20161125064201-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Hannes Frederic Sowa <hannes@redhat.com>,
        Jeremy Eder <jeder@redhat.com>,
        Marko Myllynen <myllynen@redhat.com>,
        Maxime Coquelin <maxime.coquelin@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161125064201-mutt-send-email-mst@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 25, 2016 at 06:43:08AM +0200, Michael S. Tsirkin wrote:
> On Fri, Nov 25, 2016 at 12:37:26PM +0800, Jason Wang wrote:
> > We use single queue even if multiqueue is enabled and let admin to
> > enable it through ethtool later. This is used to avoid possible
> > regression (small packet TCP stream transmission). But looks like an
> > overkill since:
> > 
> > - single queue user can disable multiqueue when launching qemu
> > - brings extra troubles for the management since it needs extra admin
> >   tool in guest to enable multiqueue
> > - multiqueue performs much better than single queue in most of the
> >   cases
> > 
> > So this patch enables multiqueue by default: if #queues is less than or
> > equal to #vcpu, enable as much as queue pairs; if #queues is greater
> > than #vcpu, enable #vcpu queue pairs.
> > 
> > Cc: Hannes Frederic Sowa <hannes@redhat.com>
> > Cc: Michael S. Tsirkin <mst@redhat.com>
> > Cc: Neil Horman <nhorman@redhat.com>
> > Cc: Jeremy Eder <jeder@redhat.com>
> > Cc: Marko Myllynen <myllynen@redhat.com>
> > Cc: Maxime Coquelin <maxime.coquelin@redhat.com>
> > Signed-off-by: Jason Wang <jasowang@redhat.com>
> 
> OK at some level but all uses of num_online_cpus()
> like this are racy versus hotplug.
> I know we already have this bug but shouldn't we fix it
> before we add more?
> 
Isn't the fix orthogonal to this use though?  That is to say, you shoudl
register a hotplug notifier first, and use the handler to adjust the number of
queues on hotplug add/remove?

Neil

> 
> > ---
> >  drivers/net/virtio_net.c | 9 +++++++--
> >  1 file changed, 7 insertions(+), 2 deletions(-)
> > 
> > diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> > index d4ac7a6..a21d93a 100644
> > --- a/drivers/net/virtio_net.c
> > +++ b/drivers/net/virtio_net.c
> > @@ -1886,8 +1886,11 @@ static int virtnet_probe(struct virtio_device *vdev)
> >  	if (vi->any_header_sg)
> >  		dev->needed_headroom = vi->hdr_len;
> >  
> > -	/* Use single tx/rx queue pair as default */
> > -	vi->curr_queue_pairs = 1;
> > +	/* Enable multiqueue by default */
> > +	if (num_online_cpus() >= max_queue_pairs)
> > +		vi->curr_queue_pairs = max_queue_pairs;
> > +	else
> > +		vi->curr_queue_pairs = num_online_cpus();
> >  	vi->max_queue_pairs = max_queue_pairs;
> >  
> >  	/* Allocate/initialize the rx/tx queues, and invoke find_vqs */
> > @@ -1918,6 +1921,8 @@ static int virtnet_probe(struct virtio_device *vdev)
> >  		goto free_unregister_netdev;
> >  	}
> >  
> > +	virtnet_set_affinity(vi);
> > +
> >  	/* Assume link up if device can't report link status,
> >  	   otherwise get link status from config. */
> >  	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_STATUS)) {
> > -- 
> > 2.7.4
