From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC][PATCH v3 1/3] A device for zero-copy based on KVM
	virtio-net.
Date: Wed, 14 Apr 2010 19:16:10 +0300
Message-ID: <20100414161610.GA10897@redhat.com>
References: <1270805865-16901-1-git-send-email-xiaohui.xin@intel.com> <201004141655.21885.arnd@arndb.de> <20100414152615.GA8079@redhat.com> <201004141757.54829.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, davem@davemloft.net,
	jdike@linux.intel.com
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201004141757.54829.arnd@arndb.de>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 14, 2010 at 05:57:54PM +0200, Arnd Bergmann wrote:
> On Wednesday 14 April 2010, Michael S. Tsirkin wrote:
> > On Wed, Apr 14, 2010 at 04:55:21PM +0200, Arnd Bergmann wrote:
> > > On Friday 09 April 2010, xiaohui.xin@intel.com wrote:
> > > > From: Xin Xiaohui <xiaohui.xin@intel.com>
> >
> > > It seems that you are duplicating a lot of functionality that
> > > is already in macvtap. I've asked about this before but then
> > > didn't look at your newer versions. Can you explain the value
> > > of introducing another interface to user land?
> > 
> > Hmm, I have not noticed a lot of duplication.
> 
> The code is indeed quite distinct, but the idea of adding another
> character device to pass into vhost for direct device access is.

All backends besides tap seem to do this, btw :)

> > BTW macvtap also duplicates tun code, it might be
> > a good idea for tun to export some functionality.
> 
> Yes, that's something I plan to look into.
> 
> > > I'm still planning to add zero-copy support to macvtap,
> > > hopefully reusing parts of your code, but do you think there
> > > is value in having both?
> > 
> > If macvtap would get zero copy tx and rx, maybe not. But
> > it's not immediately obvious whether zero-copy support
> > for macvtap might work, though, especially for zero copy rx.
> > The approach with mpassthru is much simpler in that
> > it takes complete control of the device.
> 
> As far as I can tell, the most significant limitation of mpassthru
> is that there can only ever be a single guest on a physical NIC.
> 
> Given that limitation, I believe we can do the same on macvtap,
> and simply disable zero-copy RX when you want to use more than one
> guest, or both guest and host on the same NIC.
> 
> The logical next step here would be to allow VMDq and similar
> technologies to separate out the RX traffic in the hardware.
> We don't have a configuration interface for that yet, but
> since this is logically the same as macvlan, I think we should
> use the same interfaces for both, essentially treating VMDq
> as a hardware acceleration for macvlan. We can probably handle
> it in similar ways to how we handle hardware support for vlan.
> 
> At that stage, macvtap would be the logical interface for
> connecting a VMDq (hardware macvlan) device to a guest!

I won't object to that but ... code walks.

> > > > +static ssize_t mp_chr_aio_write(struct kiocb *iocb, const struct iovec *iov,
> > > > +				unsigned long count, loff_t pos)
> > > > +{
> > > > +	struct file *file = iocb->ki_filp;
> > > > +	struct mp_struct *mp = mp_get(file->private_data);
> > > > +	struct sock *sk = mp->socket.sk;
> > > > +	struct sk_buff *skb;
> > > > +	int len, err;
> > > > +	ssize_t result;
> > > 
> > > Can you explain what this function is even there for? AFAICT, vhost-net
> > > doesn't call it, the interface is incompatible with the existing
> > > tap interface, and you don't provide a read function.
> > 
> > qemu needs the ability to inject raw packets into device
> > from userspace, bypassing vhost/virtio (for live migration).
> 
> Ok, but since there is only a write callback and no read, it won't
> actually be able to do this with the current code, right?

I think it'll work as is, with vhost qemu only ever writes,
never reads from device. We'll also never need GSO etc
which is a large part of what tap does (and macvtap will
have to do).

> Moreover, it seems weird to have a new type of interface here that
> duplicates tap/macvtap with less functionality. Coming back
> to your original comment, this means that while mpassthru is currently
> not duplicating the actual code from macvtap, it would need to do
> exactly that to get the qemu interface right!
> 
> 	Arnd

I don't think so, see above. anyway, both can reuse tun.c :)

-- 
MST
