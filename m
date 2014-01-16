From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH net-next 3/3] virtio-net: Add accelerated RFS support
Date: Thu, 16 Jan 2014 23:16:28 +0000
Message-ID: <1389914188.11912.146.camel@bwh-desktop.uk.level5networks.com>
References: <1389795654-28381-1-git-send-email-zwu.kernel@gmail.com>
	 <1389795654-28381-4-git-send-email-zwu.kernel@gmail.com>
	 <1389907887.11912.87.camel@bwh-desktop.uk.level5networks.com>
	 <CAEH94LjHcxkXLvs6AMNop_yzKG0zaT2mAgsAb21i+RtMbkXbmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Zhi Yong Wu <zwu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:24173 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775AbaAPXQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 18:16:33 -0500
In-Reply-To: <CAEH94LjHcxkXLvs6AMNop_yzKG0zaT2mAgsAb21i+RtMbkXbmQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-01-17 at 06:00 +0800, Zhi Yong Wu wrote:
> On Fri, Jan 17, 2014 at 5:31 AM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
> > On Wed, 2014-01-15 at 22:20 +0800, Zhi Yong Wu wrote:
> > [...]
> >> +static int virtnet_init_rx_cpu_rmap(struct virtnet_info *vi)
> >> +{
> >> +     int rc = 0;
> >> +
> >> +#ifdef CONFIG_RFS_ACCEL
> >> +     struct virtio_device *vdev = vi->vdev;
> >> +     unsigned int irq;
> >> +     int i;
> >> +
> >> +     if (!vi->affinity_hint_set)
> >> +             goto out;
> >> +
> >> +     vi->dev->rx_cpu_rmap = alloc_irq_cpu_rmap(vi->max_queue_pairs);
> >> +     if (!vi->dev->rx_cpu_rmap) {
> >> +             rc = -ENOMEM;
> >> +             goto out;
> >> +     }
> >> +
> >> +     for (i = 0; i < vi->max_queue_pairs; i++) {
> >> +             irq = virtqueue_get_vq_irq(vdev, vi->rq[i].vq);
> >> +             if (irq == -1)
> >> +                     goto failed;
> >
> > Jumping into an if-statement is confusing.  Also do you really want to
> > return 0 in this case?
> No, If it fail to get irq, i want it to exit as soon as possible,
> otherwise it will cause irq_cpu_rmap_add() to be invoked with one
> incorrect argument irq.

Well currently this goto does result in returning 0, as rc has not been
changed after its initialisation to 0.

> By the way, do you have thought about if it makes sense to add aRFS
> support to virtio_net? For [patch 2/3], what do you think of those
> missing stuff listed by me?
> For how indirect table is implemented in sfc NIC, do you have any doc
> to share with  me? thanks.

Going through that list:

> 1.)  guest virtio_net driver should have one filter table and its
> entries can be expired periodically;

In sfc, we keep a count how many entries have been inserted in each NAPI
context.  Whenever the NAPI poll function is about to call
napi_complete() and the count for that context has reached a trigger
level, it will scan some quota of filter entries for expiry.

> 2.)  guest virtio_net driver should pass rx queue index and filter
> info down to the emulated virtio_net NIC in QEMU.
> 3.) the emulated virtio_net NIC should have its indirect table to
> store the flow to rx queue mapping.
> 4.) the emulated virtio_net NIC should classify the rx packet to
> selected queue by applying the filter.

I think the most efficient way to do this would be to put a hash table
in some shared memory that both guest and host can read and write.  The
virtio control path would only be used to set up and tear down the
table.  I don't know whether virtio allows for that.

However, to take advantage of ARFS on a physical net driver, it would be
necessary to send a control request for part 2.

> 5.) update virtio spec.
> Do i miss anything? If yes, please correct me.
> For 3.) and 4.), do you have any doc about how they are implemented in
> physical NICs? e.g. mlx4_en or sfc, etc.

The Programmer's Reference Manuals for Solarflare controllers are only
available under NDA.  I can describe the hardware filtering briefly, but
actually I don't think it's very relevant to virtio_net.

There is a typical RSS hash indirection table (128 entries), but for
ARFS we use a different RX filter table which has 8K entries
(RX_FILTER_TBL0 on SFC4000/SFC9000 family).

Solarflare controllers support user-level networking, which requires
perfect filtering to deliver each application's flows into that
application's dedicated RX queue(s).  Lookups in this larger filter
table are still hash-based, but each entry specifies a TCP/IP or UDP/IP
4-tuple or local 2-tuple to match.  ARFS uses the 4-tuple type only.

To allow for hash collisions, a secondary hash function generates an
increment to be added to the initial table index repeatedly for hash
chaining.  There is a control register which tells the controller the
maximum hash chain length to search for each IP filter type; after this
it will fall back to checking MAC filters and then default filters.

On the SFC9100 family, filter updates and lookups are implemented by
firmware and the driver doesn't manage the filter table itself, but I
know it is still a hash table of perfect filters.

For ARFS, perfect filtering is not needed.  I think it would be
preferable to use a fairly big hash table and make insertion fail in
case of a collision.  Since the backend for virtio_net will do RX queue
selection in software, the entire table of queue indices should fit into
its L1 cache.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
