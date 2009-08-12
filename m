From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/2] vhost_net: a kernel-level virtio server
Date: Wed, 12 Aug 2009 19:59:47 +0200
Message-ID: <200908121959.47222.arnd@arndb.de>
References: <cover.1249930169.git.mst@redhat.com> <200908121903.22325.arnd@arndb.de> <20090812172141.GA29966@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.linux-foundation.org,
	"Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752864AbZHLR7y@vger.kernel.org>
In-Reply-To: <20090812172141.GA29966@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 12 August 2009, Michael S. Tsirkin wrote:
> On Wed, Aug 12, 2009 at 07:03:22PM +0200, Arnd Bergmann wrote:
> > We discussed this before, and I still think this could be directly derived
> > from struct virtqueue, in the same way that vring_virtqueue is derived from
> > struct virtqueue.
> 
> I prefer keeping it simple. Much of abstraction in virtio is due to the
> fact that it needs to work on top of different hardware emulations:
> lguest,kvm, possibly others in the future.  vhost is always working on
> real hardware, using eventfd as the interface, so it does not need that.

Well, that was my point: virtio can already work on a number of abstractions,
so adding one more for vhost should not be too hard.

> > That would make it possible for simple device drivers
> > to use the same driver in both host and guest,
> 
> I don't think so. For example, there's a callback field that gets
> invoked in guest when buffers are consumed.  It could be overloaded to
> mean "buffers are available" in host but you never handle both
> situations in the same way, so what's the point?
>
...
> 
> As I pointed out earlier, most code in virtio net is asymmetrical: guest
> provides buffers, host consumes them.  Possibly, one could use virtio
> rings in a symmetrical way, but support of existing guest virtio net
> means there's almost no shared code.

The trick is to swap the virtqueues instead. virtio-net is actually
mostly symmetric in just the same way that the physical wires on a
twisted pair ethernet are symmetric (I like how that analogy fits).

virtio_net kicks the transmit virtqueue when it has data and
it kicks the receive queue when it has empty buffers to fill,
and it has callbacks when the two are done. You can do the
same in both the guest and the host, but then the guests input
virtqueue is the hosts output virtqueue and vice versa.

Once a virtqueue got kicked from both sides, the vhost_virtqueue
implementation between the two only needs to do a copy_from_user
or copy_to_user (possibly from a thread if it is in atomic context)
and then call the two callback functions. This is basically the
same thing you do already, except that you use slightly different
names for the components.

	Arnd <><
