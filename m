From: "Ira W. Snyder" <iws@ovro.caltech.edu>
Subject: Re: [RFC v3] net: add PCINet driver
Date: Wed, 31 Mar 2010 08:25:48 -0700
Message-ID: <20100331152548.GA22165@ovro.caltech.edu>
References: <20081105212225.GA17821@ovro.caltech.edu>
 <E924DFE1-9569-4805-9269-480F2D128636@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Jan-Bernd Themann <THEMANN@de.ibm.com>
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <E924DFE1-9569-4805-9269-480F2D128636@kernel.crashing.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 30, 2010 at 11:46:29PM -0500, Kumar Gala wrote:
> 
> On Nov 5, 2008, at 3:22 PM, Ira Snyder wrote:
> 
> > This adds support to Linux for a virtual ethernet interface which uses the
> > PCI bus as its transport mechanism. It creates a simple, familiar, and fast
> > method of communication for two devices connected by a PCI interface.
> > 
> > I have implemented client support for the Freescale MPC8349EMDS board,
> > which is capable of running in PCI Agent mode (It acts like a PCI card, but
> > is a complete PowerPC computer, running Linux). It is almost certainly
> > trivially ported to any MPC83xx system.
> > 
> > It was developed to work in a CompactPCI crate of computers, one of which
> > is a relatively standard x86 system (acting as the host) and many PowerPC
> > systems (acting as clients).
> > 
> > RFC v2 -> RFC v3:
> >  * use inline functions for accessing struct circ_buf_desc
> >  * use pointer dereferencing on PowerPC local memory instead of ioread32()
> >  * move IMMR and buffer descriptor accessors inside drivers
> >  * update for dma_mapping_error() API changes
> >  * use minimal locking primitives (i.e. spin_lock() instead of _irqsave())
> >  * always disable checksumming, PCI is reliable
> >  * replace typedef cbd_t with struct circ_buf_desc
> >  * use get_immrbase() to get IMMR register offsets
> > 
> > RFC v1 -> RFC v2:
> >  * remove vim modelines
> >  * use net_device->name in request_irq(), for irqbalance
> >  * remove unneccesary wqt_get_stats(), use default get_stats() instead
> >  * use dev_printk() and friends
> >  * add message unit to MPC8349EMDS dts file
> > 
> > Signed-off-by: Ira W. Snyder <iws@ovro.caltech.edu>
> > ---
> > This is the third RFC posting of this driver. I got some feedback, and have
> > corrected the problems. Thanks to everyone who has done review! I have
> > gotten off-list feedback from several potential users, so there are
> > definitely many potential users.
> > 
> > I'll post up a revised version about once a week as long as the changes are
> > minor. If they are more substantial, I'll post them as needed.
> > 
> > The remaining issues I see in this driver:
> > 1) ==== Naming ====
> >   The name wqt originally stood for "workqueue-test" and somewhat evolved
> >   over time into the current driver. I'm looking for suggestions for a
> >   better name. It should be the same between the host and client drivers,
> >   to make porting the code between them easier. The drivers are /very/
> >   similar other than the setup code.
> > 2) ==== IMMR Usage ====
> >   In the Freescale client driver, I use the whole set of board control
> >   registers (AKA IMMR registers). I only need a very small subset of them,
> >   during startup to set up the DMA window. I used the full set of
> >   registers so that I could share the register offsets between the drivers
> >   (in pcinet_hw.h)
> > 3) ==== Hardcoded DMA Window Address ====
> >   In the Freescale client driver, I just hardcoded the address of the
> >   outbound PCI window into the DMA transfer code. It is 0x80000000.
> >   Suggestions on how to get this value at runtime are welcome.
> > 
> > 
> > Rationale behind some decisions:
> > 1) ==== Usage of the PCINET_NET_REGISTERS_VALID bit ====
> >   I want to be able to use this driver from U-Boot to tftp a kernel over
> >   the PCI backplane, and then boot up the board. This means that the
> >   device descriptor memory, which lives in the client RAM, becomes invalid
> >   during boot.
> > 2) ==== Buffer Descriptors in client memory ====
> >   I chose to put the buffer descriptors in client memory rather than host
> >   memory. It seemed more logical to me at the time. In my application,
> >   I'll have 19 boards + 1 host per cPCI chassis. The client -> host
> >   direction will see most of the traffic, and so I thought I would cut
> >   down on the number of PCI accesses needed. I'm willing to change this.
> > 3) ==== Usage of client DMA controller for all data transfer ====
> >   This was done purely for speed. I tried using the CPU to transfer all
> >   data, and it is very slow: ~3MB/sec. Using the DMA controller gets me to
> >   ~40MB/sec (as tested with netperf).
> > 4) ==== Static 1GB DMA window ====
> >   Maintaining a window while DMA's in flight, and then changing it seemed
> >   too complicated. Also, testing showed that using a static window gave me
> >   a ~10MB/sec speedup compared to moving the window for each skb.
> > 5) ==== The serial driver ====
> >   Yes, there are two essentially separate drivers here. I needed a method
> >   to communicate with the U-Boot bootloader on these boards without
> >   plugging in a serial cable. With 19 clients + 1 host per chassis, the
> >   cable clutter is worth avoiding. Since everything is connected via the
> >   PCI bus anyway, I used that. A virtual serial port was simple to
> >   implement using the messaging unit hardware that I used for the network
> >   driver.
> > 
> > I'll post both U-Boot drivers to their mailing list once this driver is
> > finalized.
> > 
> > Thanks,
> > Ira
> > 
> > arch/powerpc/boot/dts/mpc834x_mds.dts |    7 +
> > drivers/net/Kconfig                   |   29 +
> > drivers/net/Makefile                  |    3 +
> > drivers/net/pcinet.h                  |   60 ++
> > drivers/net/pcinet_fsl.c              | 1358 ++++++++++++++++++++++++++++++++
> > drivers/net/pcinet_host.c             | 1388 +++++++++++++++++++++++++++++++++
> > drivers/net/pcinet_hw.h               |   77 ++
> > 7 files changed, 2922 insertions(+), 0 deletions(-)
> > create mode 100644 drivers/net/pcinet.h
> > create mode 100644 drivers/net/pcinet_fsl.c
> > create mode 100644 drivers/net/pcinet_host.c
> > create mode 100644 drivers/net/pcinet_hw.h
> 
> What ever happened to this?
> 

Basically, David Miller NAK'd it, and told me to use virtio instead. I
went through the trouble of implementing that, and it was NAK'd too,
since I connected two virtio-net drivers together, rather than writing a
backend (similar to qemu, kvm, lguest, etc.). Now that a year has
passed, there is an in-kernel backend (vhost-net), but the developers
pretty much ignored my use case, and I don't think it can work. I must
use DMA when copying data across PCI (to get bursts on the bus) for
speed.

I still get email from people interested in this kind of technology,
about once a month. I myself would love to have a PCI-to-PCI network
driver. Linux is majorly lacking in this area.

In the end, I used a derivative of the above driver. It is not
especially fast, but it works. I would be very happy to throw it away
and use a mainline Linux solution based on virtio. In my initial tests,
a virtio-based driver was 6x faster.

I still have my virtio code available on the web, URL below. I tried to
write a userspace backend at the time, but didn't get far. I couldn't
find any explanation of how TUN/TAP works. The kernel portion itself is
based on lguest, and works pretty well.
http://www.mmarray.org/~iws/virtio-phys/

I also spoke with Greg Haskins, and started work on a PCI-to-PCI backend
for vbus. If you've seen the anti-vbus flamewars that went on late last
year, you'll know why I gave up. That work is here:
http://www.mmarray.org/~iws/vbus/

I'm happy to provide you with my latest PCINet driver and U-Boot patches
if you want them. It has been running in production for a few months,
and is quite stable.

If you'd like to see the virtio driver continued and want to help me
interface with the virtualization folks, that would be wonderful.
They've completely ignored every post I've made to their mailing list so
far. :)

Thanks,
Ira
