From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] virtio_net: implement
 VIRTIO_CONFIG_S_NEEDS_RESET
Date: Tue, 17 Oct 2017 06:44:06 +0300
Message-ID: <20171017064254-mutt-send-email-mst@kernel.org>
References: <20171013155140.124530-1-willemdebruijn.kernel@gmail.com>
 <20171015034018-mutt-send-email-mst@kernel.org>
 <CAF=yD-LdGiKuf=k2FDgFWbhvExVX8t+VVgTQetKTegjMeQ598g@mail.gmail.com>
 <20171016180442-mutt-send-email-mst@kernel.org>
 <CAF=yD-LW7f30V8Ci1SQUPZ-WBihqr93cWQP2QBFg2oQtytvAPg@mail.gmail.com>
 <20171016191806-mutt-send-email-mst@kernel.org>
 <CAF=yD-KkUH6=S6Q=Tjtd2Wo=-ebDUt1or-DqjoRV4dTaD8G0WA@mail.gmail.com>
 <ecf3dde0-d4e6-23d5-22a7-05ce45bdafc9@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        virtualization@lists.linux-foundation.org,
        Willem de Bruijn <willemb@google.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53254 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751161AbdJQDoH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Oct 2017 23:44:07 -0400
Content-Disposition: inline
In-Reply-To: <ecf3dde0-d4e6-23d5-22a7-05ce45bdafc9@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 17, 2017 at 11:05:07AM +0800, Jason Wang wrote:
> 
> 
> On 2017年10月17日 06:34, Willem de Bruijn wrote:
> > On Mon, Oct 16, 2017 at 12:38 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> > > On Mon, Oct 16, 2017 at 12:04:57PM -0400, Willem de Bruijn wrote:
> > > > On Mon, Oct 16, 2017 at 11:31 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> > > > > On Mon, Oct 16, 2017 at 11:03:18AM -0400, Willem de Bruijn wrote:
> > > > > > > > +static int virtnet_reset(struct virtnet_info *vi)
> > > > > > > > +{
> > > > > > > > +     struct virtio_device *dev = vi->vdev;
> > > > > > > > +     int ret;
> > > > > > > > +
> > > > > > > > +     virtio_config_disable(dev);
> > > > > > > > +     dev->failed = dev->config->get_status(dev) & VIRTIO_CONFIG_S_FAILED;
> > > > > > > > +     virtnet_freeze_down(dev, true);
> > > > > > > > +     remove_vq_common(vi);
> > > > > > > > +
> > > > > > > > +     virtio_add_status(dev, VIRTIO_CONFIG_S_ACKNOWLEDGE);
> > > > > > > > +     virtio_add_status(dev, VIRTIO_CONFIG_S_DRIVER);
> > > > > > > > +
> > > > > > > > +     ret = virtio_finalize_features(dev);
> > > > > > > > +     if (ret)
> > > > > > > > +             goto err;
> > > > > > > > +
> > > > > > > > +     ret = virtnet_restore_up(dev);
> > > > > > > > +     if (ret)
> > > > > > > > +             goto err;
> > > > > > > > +
> > > > > > > > +     ret = virtnet_set_queues(vi, vi->curr_queue_pairs);
> > > > > > > > +     if (ret)
> > > > > > > > +             goto err;
> > > > > > > > +
> > > > > > > > +     virtio_add_status(dev, VIRTIO_CONFIG_S_DRIVER_OK);
> > > > > > > > +     virtio_config_enable(dev);
> > > > > > > > +     return 0;
> > > > > > > > +
> > > > > > > > +err:
> > > > > > > > +     virtio_add_status(dev, VIRTIO_CONFIG_S_FAILED);
> > > > > > > > +     return ret;
> > > > > > > > +}
> > > > > > > > +
> > > > > > > >   static int virtnet_set_guest_offloads(struct virtnet_info *vi, u64 offloads)
> > > > > > > >   {
> > > > > > > >        struct scatterlist sg;
> > > > > > > I have a question here though. How do things like MAC address
> > > > > > > get restored?
> > > > > > > 
> > > > > > > What about the rx mode?
> > > > > > > 
> > > > > > > vlans?
> > > > > > The function as is releases and reinitializes only ring state.
> > > > > > Device configuration such as mac and vlan persist across
> > > > > > the reset.
> > > > > What gave you this impression? Take a look at e.g. this
> > > > > code in qemu:
> > > > > 
> > > > > static void virtio_net_reset(VirtIODevice *vdev)
> > > > > {
> > > > >      VirtIONet *n = VIRTIO_NET(vdev);
> > > > > 
> > > > >      /* Reset back to compatibility mode */
> > > > >      n->promisc = 1;
> > > > >      n->allmulti = 0;
> > > > >      n->alluni = 0;
> > > > >      n->nomulti = 0;
> > > > >      n->nouni = 0;
> > > > >      n->nobcast = 0;
> > > > >      /* multiqueue is disabled by default */
> > > > >      n->curr_queues = 1;
> > > > >      timer_del(n->announce_timer);
> > > > >      n->announce_counter = 0;
> > > > >      n->status &= ~VIRTIO_NET_S_ANNOUNCE;
> > > > > 
> > > > >      /* Flush any MAC and VLAN filter table state */
> > > > >      n->mac_table.in_use = 0;
> > > > >      n->mac_table.first_multi = 0;
> > > > >      n->mac_table.multi_overflow = 0;
> > > > >      n->mac_table.uni_overflow = 0;
> > > > >      memset(n->mac_table.macs, 0, MAC_TABLE_ENTRIES * ETH_ALEN);
> > > > >      memcpy(&n->mac[0], &n->nic->conf->macaddr, sizeof(n->mac));
> > > > >      qemu_format_nic_info_str(qemu_get_queue(n->nic), n->mac);
> > > > >      memset(n->vlans, 0, MAX_VLAN >> 3);
> > > > > }
> > > > > 
> > > > > So device seems to lose all state, you have to re-program it.
> > > > Oh, indeed! The guest does not reset its state, so it might
> > > > be out of sync with the host after the operation. Was this not
> > > > an issue when previously resetting in the context of xdp?
> > > I suspect it was broken back then, too.
> > Okay. I guess that in principle this is all programmable through
> > virtnet_set_rx_mode, virtnet_vlan_rx_add_vid, etc. But it's a
> > lot more complex than just restoring virtnet_reset. Will need to
> > be careful about concurrency issues at the least. Similar to the
> > ones you point out below.
> > 
> 
> The problem has been pointed out during developing virtio-net XDP. But it
> may not be a big issue since vhost_net ignores all kinds of the filters now.
> 
> Thanks

It might not keep doing that in the future though.
And virtio-net in userspace doesn't ignore the filters.

-- 
MST
