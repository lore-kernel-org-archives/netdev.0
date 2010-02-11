From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 0/3] Provide a zero-copy method on KVM virtio-net.
Date: Thu, 11 Feb 2010 14:25:01 +0100
Message-ID: <201002111425.01720.arnd@arndb.de>
References: <1265802540-6122-1-git-send-email-xiaohui.xin@intel.com> <201002101440.05063.arnd@arndb.de> <97F6D3BD476C464182C1B7BABF0B0AF5C11F641A@shzsmsx502.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mingo@elte.hu" <mingo@elte.hu>, "mst@redhat.com" <mst@redhat.com>,
	"jdike@c2.user-mode-linux.org" <jdike@c2.user-mode-linux.org>
To: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <97F6D3BD476C464182C1B7BABF0B0AF5C11F641A@shzsmsx502.ccr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 11 February 2010, Xin, Xiaohui wrote:
> >This does a lot of things that I had planned for macvtap. It's
> >great to hear that you have made this much progress.
> >
> >However, I'd hope that we could combine this with the macvtap driver,
> >which would give us zero-copy transfer capability both with and
> >without vhost, as well as (tx at least) when using multiple guests
> >on a macvlan setup.
> 
> You mean the zero-copy can work with macvtap driver without vhost.
> May you give me some detailed info about your macvtap driver and the
> relationship between vhost and macvtap to make me have a clear picture then?

macvtap provides a user interface that is largely compatible with
the tun/tap driver, and can be used in place of that from qemu.
Vhost-net currently interfaces with tun/tap, but not yet with macvtap,
which is easy enough to add and already on my list.

The underlying code is macvlan, which is a driver that virtualizes
network adapters in software, giving you multiple net_device instances
for a real NIC, each of them with their own MAC address.

In order to do zero-copy transmit with macvtap, the idea is to
add a nonblocking version of the aio_write() function that works
a lot like your transmit function.

For receive, the hardware does not currently know which guest
is supposed to get any frame coming in from the outside. Adding
zero-copy receive requires interaction with the device driver
and hardware capabilities to separate traffic by inbound MAC
address into separate buffers per VM.

> >I'm assuming that the idea is to allow VMDq adapters to simply
> >show up as separate adapters and have the driver handle this
> >in a hardware specific way.
> 
> Does the VMDq driver do so now?

I don't think anyone has published a VMDq capable driver so far.
I was just assuming that you were working on one.

	Arnd
