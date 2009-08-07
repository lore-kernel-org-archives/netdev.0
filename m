From: "Ira W. Snyder" <iws@ovro.caltech.edu>
Subject: Re: [PATCH 4/7] vbus-proxy: add a pci-to-vbus bridge
Date: Fri, 7 Aug 2009 08:55:00 -0700
Message-ID: <20090807155500.GB12561@ovro.caltech.edu>
References: <20090803171030.17268.26962.stgit@dev.haskins.net> <200908061903.05083.arnd@arndb.de> <4A7B0D090200005A00051D2E@sinclair.provo.novell.com> <200908070057.54795.arnd@arndb.de> <4A7B78580200005A00051D50@sinclair.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753707AbZHGPzI@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A7B78580200005A00051D50@sinclair.provo.novell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 06, 2009 at 10:42:00PM -0600, Gregory Haskins wrote:
> >>> On 8/6/2009 at  6:57 PM, in message <200908070057.54795.arnd@arndb.de>, Arnd
> Bergmann <arnd@arndb.de> wrote: 

[ big snip ]

> >> I see a few issues with that, however:
> >> 
> >> 1) The virtqueue library, while a perfectly nice ring design at the metadata 
> > level, does not have an API that is friendly to kernel-to-kernel communication. 
> >  It was designed more for frontend use to some remote backend.  The IOQ 
> > library on the other hand, was specifically designed to support use as 
> > kernel-to-kernel (see north/south designations).  So this made life easier 
> > for me.  To do what you propose, the eventq channel would need to terminate 
> > in kernel, and I would thus be forced to deal that the potential API 
> > problems.
> > 
> > Well, virtqueues are not that bad for kernel-to-kernel communication, as Ira 
> > mentioned
> > referring to his virtio-over-PCI driver. You can have virtqueues on both 
> > sides, having
> > the host kernel create a pair of virtqueues (one in user aka guest space, 
> > one in the host
> > kernel), with the host virtqueue_ops doing copy_{to,from}_user to move data 
> > between them.
> 
> Its been a while since I looked, so perhaps I am wrong here.  I will look again.
> 
> > 
> > If you have that, you can actually use the same virtio_net driver in both 
> > guest and
> > host kernel, just communicating over different virtio implementations. 
> > Interestingly,
> > that would mean that you no longer need a separation between guest and host 
> > device
> > drivers (vbus and vbus-proxy in your case) but could use the same device 
> > abstraction
> > with just different transports to back the shm-signal or virtqueue.
> 
> Actually, I think there are some problems with that model (such as management of the interface).  virtio-net really wants to connect to a virtio-net-backend (such as the one in qemu or vbus).  It wasn't designed to connect back to back like that.  I think you will quickly run into problems similar to what Ira faced with virtio-over-PCI with that model.
> 

Getting the virtio-net devices talking to each other over PCI was not
terribly difficult. However, the capabilities negotiation works in a
VERY awkward way. The capabilities negotiation was really designed with
a virtio-net-backend in mind. Unless I'm missing something obvious, it
is essentially broken for the case where two virtio-net's are talking to
each other.

For example, imagine the situation where you'd like the guest to get a
specific MAC address, but you do not care what MAC address the host
recieves.

Normally, you'd set struct virtio_net_config's mac[] field, and set the
VIRTIO_NET_F_MAC feature. However, when you have two virtio-net's
communicating directly, this doesn't work.

Let me explain with a quick diagram. The results described are the
values RETURNED from virtio_config_ops->get() and
virtio_config_ops->get_features() when called by the system in question.

Guest System
1) struct virtio_net_config->mac[]: 00:11:22:33:44:55
2) features: VIRTIO_NET_F_MAC

Host System
1) struct virtio_net_config->mac[]: unset
2) features: VIRTIO_NET_F_MAC unset

In this case, the feature negotiation code will not accept the
VIRTIO_NET_F_MAC feature, and both systems will generate random mac
addresses. Not the behavior we want at all.

I "fixed" the problem by ALWAYS setting a random MAC address, and ALWAYS
setting the VIRTIO_NET_F_MAC feature. By doing this, both sides always
negotiate the VIRTIO_NET_F_MAC feature.

In conclusion, the feature negotiation works fine for driver features,
such as VIRTIO_NET_MRG_RXBUF or VIRTIO_NET_F_GSO, but completely breaks
down for user-controlled features, like VIRTIO_NET_F_MAC.

I think the vbus configfs interface works great for this situation,
because it has an obvious and seperate backend. It is obvious where the
configuration information is coming from.

With my powerpc hardware, it should be easily possible to have at least
6 devices, each with two virtqueues, one for tx and one for rx. (The
limit is caused by the amount of distinct kick() events I can generate.)
This could allow many combinations of devices, such as:

* 1 virtio-net, 1 virtio-console
* 3 virtio-net, 2 virtio-console
* 6 virtio-net
* etc.

In all honesty, I don't really care so much about the management
interface for my purposes. A static configuration of devices works for
me. However, I doubt that would ever be accepted into the upstream
kernel, which is what I'm really concerned about. I hate seeing drivers
live out-of-tree.

Getting two virtio-net's talking to each other had one other major
problem: the fields in struct virtio_net_hdr are not defined with a
constant endianness. When connecting two virtio-net's running on
different machines, they may have different endianness, as in my case
between a big-endian powerpc guest and a little-endian x86 host. I'm not
confident that qemu-system-ppc, running on x86, using virtio for the
network interface, even works at all. (I have not tested it.)

Sorry that this got somewhat long winded and went a little off topic.
Ira
