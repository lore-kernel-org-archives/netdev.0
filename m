From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v4 13/25] virtio_console: enable VQs early
Date: Mon, 20 Oct 2014 14:12:20 +0100
Message-ID: <20141020131220.GC18561@casper.infradead.org>
References: <1413114332-626-1-git-send-email-mst-v4@redhat.com>
 <1413114332-626-14-git-send-email-mst-v4@redhat.com>
 <20141020120750.GA18561@casper.infradead.org>
 <20141020131016.GA20489@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org,
	linux-scsi@vger.kernel.org, linux-s390@vger.kernel.org,
	v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
	kvm@vger.kernel.org, Amit Shah <amit.shah@redhat.com>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141020131016.GA20489@redhat.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/20/14 at 04:10pm, Michael S. Tsirkin wrote:
> On Mon, Oct 20, 2014 at 01:07:50PM +0100, Thomas Graf wrote:
> > On 10/13/14 at 10:50am, Michael S. Tsirkin wrote:
> > > virtio spec requires drivers to set DRIVER_OK before using VQs.
> > > This is set automatically after probe returns, virtio console violated this
> > > rule by adding inbufs, which causes the VQ to be used directly within
> > > probe.
> > > 
> > > To fix, call virtio_device_ready before using VQs.
> > > 
> > > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > > ---
> > >  drivers/char/virtio_console.c | 2 ++
> > >  1 file changed, 2 insertions(+)
> > > 
> > > diff --git a/drivers/char/virtio_console.c b/drivers/char/virtio_console.c
> > > index b585b47..6ebe8f6 100644
> > > --- a/drivers/char/virtio_console.c
> > > +++ b/drivers/char/virtio_console.c
> > > @@ -1449,6 +1449,8 @@ static int add_port(struct ports_device *portdev, u32 id)
> > >  	spin_lock_init(&port->outvq_lock);
> > >  	init_waitqueue_head(&port->waitqueue);
> > >  
> > > +	virtio_device_ready(portdev->vdev);
> > > +
> > >  	/* Fill the in_vq with buffers so the host can send us data. */
> > >  	nr_added_bufs = fill_queue(port->in_vq, &port->inbuf_lock);
> > >  	if (!nr_added_bufs) {
> 
> I see Cornelia sent a patch already.
> I'd like to reproduce this though - could you send me
> the command line please?

1. Invoke qemu:

/usr/bin/qemu-system-x86_64 -machine accel=kvm -name f20-2 -S -machine
pc-i440fx-1.4,accel=kvm,usb=off -m 2048 -realtime mlock=off -smp
4,sockets=4,cores=1,threads=1 -uuid
dd45ec4c-7c26-4b73-9b6b-81f2912c5235 -no-user-config -nodefaults
-chardev
socket,id=charmonitor,path=/var/lib/libvirt/qemu/f20-2.monitor,server,nowait
-mon chardev=charmonitor,id=monitor,mode=control -rtc base=utc
-no-shutdown -device piix3-usb-uhci,id=usb,bus=pci.0,addr=0x1.0x2
-device virtio-serial-pci,id=virtio-serial0,bus=pci.0,addr=0x5 -drive
file=/virt/f20n2-clone,if=none,id=drive-virtio-disk0,format=raw
-device
virtio-blk-pci,scsi=off,bus=pci.0,addr=0x6,drive=drive-virtio-disk0,id=virtio-disk0,bootindex=1
-netdev tap,fd=24,id=hostnet0,vhost=on,vhostfd=25 -device
virtio-net-pci,netdev=hostnet0,id=net0,mac=52:54:00:ef:72:4e,bus=pci.0,addr=0x3
-chardev pty,id=charserial0 -device
isa-serial,chardev=charserial0,id=serial0 -chardev
spicevmc,id=charchannel0,name=vdagent -device
virtserialport,bus=virtio-serial0.0,nr=1,chardev=charchannel0,id=channel0,name=com.redhat.spice.0
-device usb-tablet,id=input0 -spice
port=5900,addr=127.0.0.1,disable-ticketing,seamless-migration=on
-device
qxl-vga,id=video0,ram_size=67108864,vram_size=67108864,bus=pci.0,addr=0x2
-device intel-hda,id=sound0,bus=pci.0,addr=0x4 -device
hda-duplex,id=sound0-codec0,bus=sound0.0,cad=0 -device
virtio-balloon-pci,id=balloon0,bus=pci.0,addr=0x7

2. Attach console right away: virsh console f20-2
