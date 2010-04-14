From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC][PATCH v3 1/3] A device for zero-copy based on KVM
	virtio-net.
Date: Wed, 14 Apr 2010 18:26:15 +0300
Message-ID: <20100414152615.GA8079@redhat.com>
References: <1270805865-16901-1-git-send-email-xiaohui.xin@intel.com> <1270805865-16901-2-git-send-email-xiaohui.xin@intel.com> <201004141655.21885.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, davem@davemloft.net,
	jdike@linux.intel.com
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201004141655.21885.arnd@arndb.de>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 14, 2010 at 04:55:21PM +0200, Arnd Bergmann wrote:
> On Friday 09 April 2010, xiaohui.xin@intel.com wrote:
> > From: Xin Xiaohui <xiaohui.xin@intel.com>
> > 
> > Add a device to utilize the vhost-net backend driver for
> > copy-less data transfer between guest FE and host NIC.
> > It pins the guest user space to the host memory and
> > provides proto_ops as sendmsg/recvmsg to vhost-net.
> 
> Sorry for taking so long before finding the time to look
> at your code in more detail.
> 
> It seems that you are duplicating a lot of functionality that
> is already in macvtap. I've asked about this before but then
> didn't look at your newer versions. Can you explain the value
> of introducing another interface to user land?

Hmm, I have not noticed a lot of duplication.
BTW macvtap also duplicates tun code, it might be
a good idea for tun to export some functionality.

> I'm still planning to add zero-copy support to macvtap,
> hopefully reusing parts of your code, but do you think there
> is value in having both?

If macvtap would get zero copy tx and rx, maybe not. But
it's not immediately obvious whether zero-copy support
for macvtap might work, though, especially for zero copy rx.
The approach with mpassthru is much simpler in that
it takes complete control of the device.

> > diff --git a/drivers/vhost/mpassthru.c b/drivers/vhost/mpassthru.c
> > new file mode 100644
> > index 0000000..86d2525
> > --- /dev/null
> > +++ b/drivers/vhost/mpassthru.c
> > @@ -0,0 +1,1264 @@
> > +
> > +#ifdef MPASSTHRU_DEBUG
> > +static int debug;
> > +
> > +#define DBG  if (mp->debug) printk
> > +#define DBG1 if (debug == 2) printk
> > +#else
> > +#define DBG(a...)
> > +#define DBG1(a...)
> > +#endif
> 
> This should probably just use the existing dev_dbg/pr_debug infrastructure.
> 
> > [... skipping buffer management code for now]
> 
> > +static int mp_sendmsg(struct kiocb *iocb, struct socket *sock,
> > +			struct msghdr *m, size_t total_len)
> > +{
> > [...]
> 
> This function looks like we should be able to easily include it into
> macvtap and get zero-copy transmits without introducing the new
> user-level interface.
> 
> > +static int mp_recvmsg(struct kiocb *iocb, struct socket *sock,
> > +			struct msghdr *m, size_t total_len,
> > +			int flags)
> > +{
> > +	struct mp_struct *mp = container_of(sock->sk, struct mp_sock, sk)->mp;
> > +	struct page_ctor *ctor;
> > +	struct vhost_virtqueue *vq = (struct vhost_virtqueue *)(iocb->private);
> 
> It smells like a layering violation to look at the iocb->private field
> from a lower-level driver. I would have hoped that it's possible to implement
> this without having this driver know about the higher-level vhost driver
> internals.

I agree.

> Can you explain why this is needed?
> 
> > +	spin_lock_irqsave(&ctor->read_lock, flag);
> > +	list_add_tail(&info->list, &ctor->readq);
> > +	spin_unlock_irqrestore(&ctor->read_lock, flag);
> > +
> > +	if (!vq->receiver) {
> > +		vq->receiver = mp_recvmsg_notify;
> > +		set_memlock_rlimit(ctor, RLIMIT_MEMLOCK,
> > +				   vq->num * 4096,
> > +				   vq->num * 4096);
> > +	}
> > +
> > +	return 0;
> > +}
> 
> Not sure what I'm missing, but who calls the vq->receiver? This seems
> to be neither in the upstream version of vhost nor introduced by your
> patch.
> 
> > +static void __mp_detach(struct mp_struct *mp)
> > +{
> > +	mp->mfile = NULL;
> > +
> > +	mp_dev_change_flags(mp->dev, mp->dev->flags & ~IFF_UP);
> > +	page_ctor_detach(mp);
> > +	mp_dev_change_flags(mp->dev, mp->dev->flags | IFF_UP);
> > +
> > +	/* Drop the extra count on the net device */
> > +	dev_put(mp->dev);
> > +}
> > +
> > +static DEFINE_MUTEX(mp_mutex);
> > +
> > +static void mp_detach(struct mp_struct *mp)
> > +{
> > +	mutex_lock(&mp_mutex);
> > +	__mp_detach(mp);
> > +	mutex_unlock(&mp_mutex);
> > +}
> > +
> > +static void mp_put(struct mp_file *mfile)
> > +{
> > +	if (atomic_dec_and_test(&mfile->count))
> > +		mp_detach(mfile->mp);
> > +}
> > +
> > +static int mp_release(struct socket *sock)
> > +{
> > +	struct mp_struct *mp = container_of(sock->sk, struct mp_sock, sk)->mp;
> > +	struct mp_file *mfile = mp->mfile;
> > +
> > +	mp_put(mfile);
> > +	sock_put(mp->socket.sk);
> > +	put_net(mfile->net);
> > +
> > +	return 0;
> > +}
> 
> Doesn't this prevent the underlying interface from going away while the chardev
> is open? You also have logic to handle that case, so why do you keep the extra
> reference on the netdev?
> 
> > +/* Ops structure to mimic raw sockets with mp device */
> > +static const struct proto_ops mp_socket_ops = {
> > +	.sendmsg = mp_sendmsg,
> > +	.recvmsg = mp_recvmsg,
> > +	.release = mp_release,
> > +};
> 
> > +static int mp_chr_open(struct inode *inode, struct file * file)
> > +{
> > +	struct mp_file *mfile;
> > +	cycle_kernel_lock();
> 
> I don't think you really want to use the BKL here, just kill that line.
> 
> > +static long mp_chr_ioctl(struct file *file, unsigned int cmd,
> > +		unsigned long arg)
> > +{
> > +	struct mp_file *mfile = file->private_data;
> > +	struct mp_struct *mp;
> > +	struct net_device *dev;
> > +	void __user* argp = (void __user *)arg;
> > +	struct ifreq ifr;
> > +	struct sock *sk;
> > +	int ret;
> > +
> > +	ret = -EINVAL;
> > +
> > +	switch (cmd) {
> > +	case MPASSTHRU_BINDDEV:
> > +		ret = -EFAULT;
> > +		if (copy_from_user(&ifr, argp, sizeof ifr))
> > +			break;
> 
> This is broken for 32 bit compat mode ioctls, because struct ifreq
> is different between 32 and 64 bit systems. Since you are only
> using the device name anyway, a fixed length string or just the
> interface index would be simpler and work better.
> 
> > +		ifr.ifr_name[IFNAMSIZ-1] = '\0';
> > +
> > +		ret = -EBUSY;
> > +
> > +		if (ifr.ifr_flags & IFF_MPASSTHRU_EXCL)
> > +			break;
> 
> Your current use of the IFF_MPASSTHRU* flags does not seem to make
> any sense whatsoever. You check that this flag is never set, but set
> it later yourself and then ignore all flags.
> 
> > +		ret = -ENODEV;
> > +		dev = dev_get_by_name(mfile->net, ifr.ifr_name);
> > +		if (!dev)
> > +			break;
> 
> There is no permission checking on who can access what device, which
> seems a bit simplistic. Any user that has access to the mpassthru device
> seems to be able to bind to any network interface in the namespace.
> This is one point where the macvtap model seems more appropriate, it
> separates the permissions for creating logical interfaces and using them.
> 
> > +static ssize_t mp_chr_aio_write(struct kiocb *iocb, const struct iovec *iov,
> > +				unsigned long count, loff_t pos)
> > +{
> > +	struct file *file = iocb->ki_filp;
> > +	struct mp_struct *mp = mp_get(file->private_data);
> > +	struct sock *sk = mp->socket.sk;
> > +	struct sk_buff *skb;
> > +	int len, err;
> > +	ssize_t result;
> 
> Can you explain what this function is even there for? AFAICT, vhost-net
> doesn't call it, the interface is incompatible with the existing
> tap interface, and you don't provide a read function.

qemu needs the ability to inject raw packets into device
from userspace, bypassing vhost/virtio (for live migration).

> > diff --git a/include/linux/mpassthru.h b/include/linux/mpassthru.h
> > new file mode 100644
> > index 0000000..2be21c5
> > --- /dev/null
> > +++ b/include/linux/mpassthru.h
> > @@ -0,0 +1,29 @@
> > +#ifndef __MPASSTHRU_H
> > +#define __MPASSTHRU_H
> > +
> > +#include <linux/types.h>
> > +#include <linux/if_ether.h>
> > +
> > +/* ioctl defines */
> > +#define MPASSTHRU_BINDDEV      _IOW('M', 213, int)
> > +#define MPASSTHRU_UNBINDDEV    _IOW('M', 214, int)
> 
> These definitions are slightly wrong, because you pass more than just an 'int'.
> 
> > +/* MPASSTHRU ifc flags */
> > +#define IFF_MPASSTHRU		0x0001
> > +#define IFF_MPASSTHRU_EXCL	0x0002
> 
> As mentioned above, these flags don't make any sense with your current code.
> 
> 	Arnd
