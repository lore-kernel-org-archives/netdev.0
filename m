From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] virtio_net: implement
 VIRTIO_CONFIG_S_NEEDS_RESET
Date: Mon, 16 Oct 2017 19:38:47 +0300
Message-ID: <20171016191806-mutt-send-email-mst@kernel.org>
References: <20171013155140.124530-1-willemdebruijn.kernel@gmail.com>
 <20171015034018-mutt-send-email-mst@kernel.org>
 <CAF=yD-LdGiKuf=k2FDgFWbhvExVX8t+VVgTQetKTegjMeQ598g@mail.gmail.com>
 <20171016180442-mutt-send-email-mst@kernel.org>
 <CAF=yD-LW7f30V8Ci1SQUPZ-WBihqr93cWQP2QBFg2oQtytvAPg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jason Wang <jasowang@redhat.com>,
        virtualization@lists.linux-foundation.org,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58158 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755757AbdJPQis (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Oct 2017 12:38:48 -0400
Content-Disposition: inline
In-Reply-To: <CAF=yD-LW7f30V8Ci1SQUPZ-WBihqr93cWQP2QBFg2oQtytvAPg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 16, 2017 at 12:04:57PM -0400, Willem de Bruijn wrote:
> On Mon, Oct 16, 2017 at 11:31 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> > On Mon, Oct 16, 2017 at 11:03:18AM -0400, Willem de Bruijn wrote:
> >> >> +static int virtnet_reset(struct virtnet_info *vi)
> >> >> +{
> >> >> +     struct virtio_device *dev = vi->vdev;
> >> >> +     int ret;
> >> >> +
> >> >> +     virtio_config_disable(dev);
> >> >> +     dev->failed = dev->config->get_status(dev) & VIRTIO_CONFIG_S_FAILED;
> >> >> +     virtnet_freeze_down(dev, true);
> >> >> +     remove_vq_common(vi);
> >> >> +
> >> >> +     virtio_add_status(dev, VIRTIO_CONFIG_S_ACKNOWLEDGE);
> >> >> +     virtio_add_status(dev, VIRTIO_CONFIG_S_DRIVER);
> >> >> +
> >> >> +     ret = virtio_finalize_features(dev);
> >> >> +     if (ret)
> >> >> +             goto err;
> >> >> +
> >> >> +     ret = virtnet_restore_up(dev);
> >> >> +     if (ret)
> >> >> +             goto err;
> >> >> +
> >> >> +     ret = virtnet_set_queues(vi, vi->curr_queue_pairs);
> >> >> +     if (ret)
> >> >> +             goto err;
> >> >> +
> >> >> +     virtio_add_status(dev, VIRTIO_CONFIG_S_DRIVER_OK);
> >> >> +     virtio_config_enable(dev);
> >> >> +     return 0;
> >> >> +
> >> >> +err:
> >> >> +     virtio_add_status(dev, VIRTIO_CONFIG_S_FAILED);
> >> >> +     return ret;
> >> >> +}
> >> >> +
> >> >>  static int virtnet_set_guest_offloads(struct virtnet_info *vi, u64 offloads)
> >> >>  {
> >> >>       struct scatterlist sg;
> >> >
> >> > I have a question here though. How do things like MAC address
> >> > get restored?
> >> >
> >> > What about the rx mode?
> >> >
> >> > vlans?
> >>
> >> The function as is releases and reinitializes only ring state.
> >> Device configuration such as mac and vlan persist across
> >> the reset.
> >
> > What gave you this impression? Take a look at e.g. this
> > code in qemu:
> >
> > static void virtio_net_reset(VirtIODevice *vdev)
> > {
> >     VirtIONet *n = VIRTIO_NET(vdev);
> >
> >     /* Reset back to compatibility mode */
> >     n->promisc = 1;
> >     n->allmulti = 0;
> >     n->alluni = 0;
> >     n->nomulti = 0;
> >     n->nouni = 0;
> >     n->nobcast = 0;
> >     /* multiqueue is disabled by default */
> >     n->curr_queues = 1;
> >     timer_del(n->announce_timer);
> >     n->announce_counter = 0;
> >     n->status &= ~VIRTIO_NET_S_ANNOUNCE;
> >
> >     /* Flush any MAC and VLAN filter table state */
> >     n->mac_table.in_use = 0;
> >     n->mac_table.first_multi = 0;
> >     n->mac_table.multi_overflow = 0;
> >     n->mac_table.uni_overflow = 0;
> >     memset(n->mac_table.macs, 0, MAC_TABLE_ENTRIES * ETH_ALEN);
> >     memcpy(&n->mac[0], &n->nic->conf->macaddr, sizeof(n->mac));
> >     qemu_format_nic_info_str(qemu_get_queue(n->nic), n->mac);
> >     memset(n->vlans, 0, MAX_VLAN >> 3);
> > }
> >
> > So device seems to lose all state, you have to re-program it.
> 
> Oh, indeed! The guest does not reset its state, so it might
> be out of sync with the host after the operation. Was this not
> an issue when previously resetting in the context of xdp?

I suspect it was broken back then, too.

> >> > Also, it seems that LINK_ANNOUNCE requests will get ignored
> >> > even if they got set before the reset, leading to downtime.
> >>
> >> Do you mean act on VIRTIO_NET_F_GUEST_ANNOUNCE
> >> requests? That flag is tested and netdev_notify_peers
> >> called before resetting virtio ring state.
> >
> > Yes but I wonder if there's a race where announce
> > is set after it is read but before NEED_RESET is read.
> >
> > Re-reading status from the config before reset
> > might be necessary.
> 
> Thanks, I'll have a look. Perhaps a host should simply not
> request a reset while it is waiting for an announce ack.

It's one option though we can't make this change for existing hosts.
We also have the reverse condition where announce is requested after
NEED_RESET is set.

-- 
MST
