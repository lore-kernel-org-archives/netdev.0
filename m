From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next RFC V3 PATCH 4/6] tuntap: multiqueue support
Date: Wed, 27 Jun 2012 11:26:35 +0300
Message-ID: <20120627082635.GB15406@redhat.com>
References: <20120625060830.6765.27584.stgit@amd-6168-8-1.englab.nay.redhat.com>
 <20120625061018.6765.76633.stgit@amd-6168-8-1.englab.nay.redhat.com>
 <20120625082553.GC18229@redhat.com>
 <4FE94E39.6070305@redhat.com>
 <20120626115420.GD13108@redhat.com>
 <4FEAA149.5010306@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: habanero@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, krkumar2@in.ibm.com,
	tahm@linux.vnet.ibm.com, akong@redhat.com, davem@davemloft.net,
	shemminger@vyatta.com, mashirle@us.ibm.com,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4FEAA149.5010306@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 27, 2012 at 01:59:37PM +0800, Jason Wang wrote:
> On 06/26/2012 07:54 PM, Michael S. Tsirkin wrote:
> >On Tue, Jun 26, 2012 at 01:52:57PM +0800, Jason Wang wrote:
> >>On 06/25/2012 04:25 PM, Michael S. Tsirkin wrote:
> >>>On Mon, Jun 25, 2012 at 02:10:18PM +0800, Jason Wang wrote:
> >>>>This patch adds multiqueue support for tap device. This is done by abstracting
> >>>>each queue as a file/socket and allowing multiple sockets to be attached to the
> >>>>tuntap device (an array of tun_file were stored in the tun_struct). Userspace
> >>>>could write and read from those files to do the parallel packet
> >>>>sending/receiving.
> >>>>
> >>>>Unlike the previous single queue implementation, the socket and device were
> >>>>loosely coupled, each of them were allowed to go away first. In order to let the
> >>>>tx path lockless, netif_tx_loch_bh() is replaced by RCU/NETIF_F_LLTX to
> >>>>synchronize between data path and system call.
> >>>Don't use LLTX/RCU. It's not worth it.
> >>>Use something like netif_set_real_num_tx_queues.
> >>>
> >>For LLTX, maybe it's better to convert it to alloc_netdev_mq() to
> >>let the kernel see all queues and make the queue stopping and
> >>per-queue stats eaiser.
> >>RCU is used to handle the attaching/detaching when tun/tap is
> >>sending and receiving packets which looks reasonalbe for me.
> >Yes but do we have to allow this? How about we always ask
> >userspace to attach to all active queues?
> 
> Attaching/detaching is a method to active/deactive a queue, if all
> queues were kept attached, then we need other method or flag to mark
> the queue as activateddeactived and still need to synchronize with
> data path.

This is what I am trying to say: use an interface flag for
multiqueue. When it is set activate all queues attached.
When unset deactivate all queues except the default one.


> >>Not
> >>sure netif_set_real_num_tx_queues() can help in this situation.
> >Check it out.
> >
> >>>>The tx queue selecting is first based on the recorded rxq index of an skb, it
> >>>>there's no such one, then choosing based on rx hashing (skb_get_rxhash()).
> >>>>
> >>>>Signed-off-by: Jason Wang<jasowang@redhat.com>
> >>>Interestingly macvtap switched to hashing first:
> >>>ef0002b577b52941fb147128f30bd1ecfdd3ff6d
> >>>(the commit log is corrupted but see what it
> >>>does in the patch).
> >>>Any idea why?
> >>>
> >>>>---
> >>>>  drivers/net/tun.c |  371 +++++++++++++++++++++++++++++++++--------------------
> >>>>  1 files changed, 232 insertions(+), 139 deletions(-)
> >>>>
> >>>>diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> >>>>index 8233b0a..5c26757 100644
> >>>>--- a/drivers/net/tun.c
> >>>>+++ b/drivers/net/tun.c
> >>>>@@ -107,6 +107,8 @@ struct tap_filter {
> >>>>  	unsigned char	addr[FLT_EXACT_COUNT][ETH_ALEN];
> >>>>  };
> >>>>
> >>>>+#define MAX_TAP_QUEUES (NR_CPUS<   16 ? NR_CPUS : 16)
> >>>Why the limit? I am guessing you copied this from macvtap?
> >>>This is problematic for a number of reasons:
> >>>	- will not play well with migration
> >>>	- will not work well for a large guest
> >>>
> >>>Yes, macvtap needs to be fixed too.
> >>>
> >>>I am guessing what it is trying to prevent is queueing
> >>>up a huge number of packets?
> >>>So just divide the default tx queue limit by the # of queues.
> >>Not sure,
> >>another reasons I can guess:
> >>- to prevent storing a large array of pointers in tun_struct or macvlan_dev.
> >OK so with the limit of e.g. 1024 we'd allocate at most
> >2 pages of memory. This doesn't look too bad. 1024 is probably a
> >high enough limit: modern hypervisors seem to support on the order
> >of 100-200 CPUs so this leaves us some breathing space
> >if we want to match a queue per guest CPU.
> >Of course we need to limit the packets per queue
> >in such a setup more aggressively. 1000 packets * 1000 queues
> >* 64K per packet is too much.
> >
> >>- it may not be suitable to allow the number of virtqueues greater
> >>than the number of physical queues in the card
> >Maybe for macvtap, here we have no idea which card we
> >are working with and how many queues it has.
> >
> >>>And by the way, for MQ applications maybe we can finally
> >>>ignore tx queue altogether and limit the total number
> >>>of bytes queued?
> >>>To avoid regressions we can make it large like 64M/# queues.
> >>>Could be a separate patch I think, and for a single queue
> >>>might need a compatible mode though I am not sure.
> >>Could you explain more about this?
> >>Did you mean to have a total
> >>sndbuf for all sockets that attached to tun/tap?
> >Consider that we currently limit the # of
> >packets queued at tun for xmit to userspace.
> >Some limit is needed but # of packets sounds
> >very silly - limiting the total memory
> >might be more reasonable.
> >
> >In case of multiqueue, we really care about
> >total # of packets or total memory, but a simple
> >approximation could be to divide the allocation
> >between active queues equally.
> 
> A possible method is to divce the TUN_READQ_SIZE by #queues, but
> make it at least to be equal to the vring size (256).

I would not enforce any limit actually.
Simply divide by # of queues, and
fail if userspace tries to attach > queue size packets.

With 1000 queues this is 64Mbyte worst case as is.
If someone wants to allow userspace to drink
256 times as much that is 16Giga byte per
single device, let the user tweak tx queue len.



> >
> >qdisc also queues some packets, that logic is
> >using # of packets anyway. So either make that
> >1000/# queues, or even set to 0 as Eric once
> >suggested.
> >
> >>>>+
> >>>>  struct tun_file {
> >>>>  	struct sock sk;
> >>>>  	struct socket socket;
> >>>>@@ -114,16 +116,18 @@ struct tun_file {
> >>>>  	int vnet_hdr_sz;
> >>>>  	struct tap_filter txflt;
> >>>>  	atomic_t count;
> >>>>-	struct tun_struct *tun;
> >>>>+	struct tun_struct __rcu *tun;
> >>>>  	struct net *net;
> >>>>  	struct fasync_struct *fasync;
> >>>>  	unsigned int flags;
> >>>>+	u16 queue_index;
> >>>>  };
> >>>>
> >>>>  struct tun_sock;
> >>>>
> >>>>  struct tun_struct {
> >>>>-	struct tun_file		*tfile;
> >>>>+	struct tun_file		*tfiles[MAX_TAP_QUEUES];
> >>>>+	unsigned int            numqueues;
> >>>>  	unsigned int 		flags;
> >>>>  	uid_t			owner;
> >>>>  	gid_t			group;
> >>>>@@ -138,80 +142,159 @@ struct tun_struct {
> >>>>  #endif
> >>>>  };
> >>>>
> >>>>-static int tun_attach(struct tun_struct *tun, struct file *file)
> >>>>+static DEFINE_SPINLOCK(tun_lock);
> >>>>+
> >>>>+/*
> >>>>+ * tun_get_queue(): calculate the queue index
> >>>>+ *     - if skbs comes from mq nics, we can just borrow
> >>>>+ *     - if not, calculate from the hash
> >>>>+ */
> >>>>+static struct tun_file *tun_get_queue(struct net_device *dev,
> >>>>+				      struct sk_buff *skb)
> >>>>  {
> >>>>-	struct tun_file *tfile = file->private_data;
> >>>>-	int err;
> >>>>+	struct tun_struct *tun = netdev_priv(dev);
> >>>>+	struct tun_file *tfile = NULL;
> >>>>+	int numqueues = tun->numqueues;
> >>>>+	__u32 rxq;
> >>>>
> >>>>-	ASSERT_RTNL();
> >>>>+	BUG_ON(!rcu_read_lock_held());
> >>>>
> >>>>-	netif_tx_lock_bh(tun->dev);
> >>>>+	if (!numqueues)
> >>>>+		goto out;
> >>>>
> >>>>-	err = -EINVAL;
> >>>>-	if (tfile->tun)
> >>>>+	if (numqueues == 1) {
> >>>>+		tfile = rcu_dereference(tun->tfiles[0]);
> >>>Instead of hacks like this, you can ask for an MQ
> >>>flag to be set in SETIFF. Then you won't need to
> >>>handle attach/detach at random times.
> >>Consier user switch between a sq guest to mq guest, qemu would
> >>attach or detach the fd which could not be expceted in kernel.
> >Can't userspace keep it attached always, just deactivate MQ?
> >
> >>>And most of the scary num_queues checks can go away.
> >>Even we has a MQ flag, userspace could still just attach one queue
> >>to the device.
> >I think we allow too much flexibility if we let
> >userspace detach a random queue.
> 
> The point is to let tun/tap has the same flexibility as macvtap.
> Macvtap allows add/delete queues at any time and it's very easy to
> add detach/attach to macvtap. So we can easily use almost the same
> ioctls to active/deactive a queue at any time for both tap and
> macvtap.

Yes but userspace does not do this in practice:
it decides how many queues and just activates them all.

> >Maybe only allow attaching/detaching with MQ off?
> >If userspace wants to attach/detach, clear MQ first?
> 
> Maybe I didn't understand the point here but I didn't advantages
> except more times of ioctl().

Way simpler to implement.

> >Alternatively, attach/detach all queues in one ioctl?
> 
> Yes, it can be same one.
> >
> >>>You can then also ask userspace about the max # of queues
> >>>to expect if you want to save some memory.
> >>>
> >>Yes, good suggestion.
> >>>>  		goto out;
> >>>>+	}
> >>>>
> >>>>-	err = -EBUSY;
> >>>>-	if (tun->tfile)
> >>>>+	if (likely(skb_rx_queue_recorded(skb))) {
> >>>>+		rxq = skb_get_rx_queue(skb);
> >>>>+
> >>>>+		while (unlikely(rxq>= numqueues))
> >>>>+			rxq -= numqueues;
> >>>>+
> >>>>+		tfile = rcu_dereference(tun->tfiles[rxq]);
> >>>>  		goto out;
> >>>>+	}
> >>>>
> >>>>-	err = 0;
> >>>>-	tfile->tun = tun;
> >>>>-	tun->tfile = tfile;
> >>>>-	netif_carrier_on(tun->dev);
> >>>>-	dev_hold(tun->dev);
> >>>>-	sock_hold(&tfile->sk);
> >>>>-	atomic_inc(&tfile->count);
> >>>>+	/* Check if we can use flow to select a queue */
> >>>>+	rxq = skb_get_rxhash(skb);
> >>>>+	if (rxq) {
> >>>>+		u32 idx = ((u64)rxq * numqueues)>>   32;
> >>>This completely confuses me. What's the logic here?
> >>>How do we even know it's in range?
> >>>
> >>rxq is a u32, so the result should be less than numqueues.
> >Aha. So the point is to use multiply+shift instead of %?
> >Please add a comment.
> >
> 
> Yes sure.

Not just about this trick, but generally explaining why do we use
rxhash for transmit.

> >>>>+		tfile = rcu_dereference(tun->tfiles[idx]);
> >>>>+		goto out;
> >>>>+	}
> >>>>
> >>>>+	tfile = rcu_dereference(tun->tfiles[0]);
> >>>>  out:
> >>>>-	netif_tx_unlock_bh(tun->dev);
> >>>>-	return err;
> >>>>+	return tfile;
> >>>>  }
> >>>>
> >>>>-static void __tun_detach(struct tun_struct *tun)
> >>>>+static int tun_detach(struct tun_file *tfile, bool clean)
> >>>>  {
> >>>>-	struct tun_file *tfile = tun->tfile;
> >>>>-	/* Detach from net device */
> >>>>-	netif_tx_lock_bh(tun->dev);
> >>>>-	netif_carrier_off(tun->dev);
> >>>>-	tun->tfile = NULL;
> >>>>-	netif_tx_unlock_bh(tun->dev);
> >>>>-
> >>>>-	/* Drop read queue */
> >>>>-	skb_queue_purge(&tfile->socket.sk->sk_receive_queue);
> >>>>-
> >>>>-	/* Drop the extra count on the net device */
> >>>>-	dev_put(tun->dev);
> >>>>-}
> >>>>+	struct tun_struct *tun;
> >>>>+	struct net_device *dev = NULL;
> >>>>+	bool destroy = false;
> >>>>
> >>>>-static void tun_detach(struct tun_struct *tun)
> >>>>-{
> >>>>-	rtnl_lock();
> >>>>-	__tun_detach(tun);
> >>>>-	rtnl_unlock();
> >>>>-}
> >>>>+	spin_lock(&tun_lock);
> >>>>
> >>>>-static struct tun_struct *__tun_get(struct tun_file *tfile)
> >>>>-{
> >>>>-	struct tun_struct *tun = NULL;
> >>>>+	tun = rcu_dereference_protected(tfile->tun,
> >>>>+					lockdep_is_held(&tun_lock));
> >>>>+	if (tun) {
> >>>>+		u16 index = tfile->queue_index;
> >>>>+		BUG_ON(index>= tun->numqueues);
> >>>>+		dev = tun->dev;
> >>>>+
> >>>>+		rcu_assign_pointer(tun->tfiles[index],
> >>>>+				   tun->tfiles[tun->numqueues - 1]);
> >>>>+		tun->tfiles[index]->queue_index = index;
> >>>>+		rcu_assign_pointer(tfile->tun, NULL);
> >>>>+		--tun->numqueues;
> >>>>+		sock_put(&tfile->sk);
> >>>>
> >>>>-	if (atomic_inc_not_zero(&tfile->count))
> >>>>-		tun = tfile->tun;
> >>>>+		if (tun->numqueues == 0&&   !(tun->flags&   TUN_PERSIST))
> >>>>+			destroy = true;
> >>>Please don't use flags like that. Use dedicated labels and goto there on error.
> >>ok.
> >>>>+	}
> >>>>
> >>>>-	return tun;
> >>>>+	spin_unlock(&tun_lock);
> >>>>+
> >>>>+	synchronize_rcu();
> >>>>+	if (clean)
> >>>>+		sock_put(&tfile->sk);
> >>>>+
> >>>>+	if (destroy) {
> >>>>+		rtnl_lock();
> >>>>+		if (dev->reg_state == NETREG_REGISTERED)
> >>>>+			unregister_netdevice(dev);
> >>>>+		rtnl_unlock();
> >>>>+	}
> >>>>+
> >>>>+	return 0;
> >>>>  }
> >>>>
> >>>>-static struct tun_struct *tun_get(struct file *file)
> >>>>+static void tun_detach_all(struct net_device *dev)
> >>>>  {
> >>>>-	return __tun_get(file->private_data);
> >>>>+	struct tun_struct *tun = netdev_priv(dev);
> >>>>+	struct tun_file *tfile, *tfile_list[MAX_TAP_QUEUES];
> >>>>+	int i, j = 0;
> >>>>+
> >>>>+	spin_lock(&tun_lock);
> >>>>+
> >>>>+	for (i = 0; i<   MAX_TAP_QUEUES&&   tun->numqueues; i++) {
> >>>>+		tfile = rcu_dereference_protected(tun->tfiles[i],
> >>>>+						lockdep_is_held(&tun_lock));
> >>>>+		BUG_ON(!tfile);
> >>>>+		wake_up_all(&tfile->wq.wait);
> >>>>+		tfile_list[j++] = tfile;
> >>>>+		rcu_assign_pointer(tfile->tun, NULL);
> >>>>+		--tun->numqueues;
> >>>>+	}
> >>>>+	BUG_ON(tun->numqueues != 0);
> >>>>+	/* guarantee that any future tun_attach will fail */
> >>>>+	tun->numqueues = MAX_TAP_QUEUES;
> >>>>+	spin_unlock(&tun_lock);
> >>>>+
> >>>>+	synchronize_rcu();
> >>>>+	for (--j; j>= 0; j--)
> >>>>+		sock_put(&tfile_list[j]->sk);
> >>>>  }
> >>>>
> >>>>-static void tun_put(struct tun_struct *tun)
> >>>>+static int tun_attach(struct tun_struct *tun, struct file *file)
> >>>>  {
> >>>>-	struct tun_file *tfile = tun->tfile;
> >>>>+	struct tun_file *tfile = file->private_data;
> >>>>+	int err;
> >>>>+
> >>>>+	ASSERT_RTNL();
> >>>>+
> >>>>+	spin_lock(&tun_lock);
> >>>>
> >>>>-	if (atomic_dec_and_test(&tfile->count))
> >>>>-		tun_detach(tfile->tun);
> >>>>+	err = -EINVAL;
> >>>>+	if (rcu_dereference_protected(tfile->tun, lockdep_is_held(&tun_lock)))
> >>>>+		goto out;
> >>>>+
> >>>>+	err = -EBUSY;
> >>>>+	if (!(tun->flags&   TUN_TAP_MQ)&&   tun->numqueues == 1)
> >>>>+		goto out;
> >>>>+
> >>>>+	if (tun->numqueues == MAX_TAP_QUEUES)
> >>>>+		goto out;
> >>>>+
> >>>>+	err = 0;
> >>>>+	tfile->queue_index = tun->numqueues;
> >>>>+	rcu_assign_pointer(tfile->tun, tun);
> >>>>+	rcu_assign_pointer(tun->tfiles[tun->numqueues], tfile);
> >>>>+	sock_hold(&tfile->sk);
> >>>>+	tun->numqueues++;
> >>>>+
> >>>>+	if (tun->numqueues == 1)
> >>>>+		netif_carrier_on(tun->dev);
> >>>>+
> >>>>+	/* device is allowed to go away first, so no need to hold extra
> >>>>+	 * refcnt. */
> >>>>+
> >>>>+out:
> >>>>+	spin_unlock(&tun_lock);
> >>>>+	return err;
> >>>>  }
> >>>>
> >>>>  /* TAP filtering */
> >>>>@@ -331,16 +414,7 @@ static const struct ethtool_ops tun_ethtool_ops;
> >>>>  /* Net device detach from fd. */
> >>>>  static void tun_net_uninit(struct net_device *dev)
> >>>>  {
> >>>>-	struct tun_struct *tun = netdev_priv(dev);
> >>>>-	struct tun_file *tfile = tun->tfile;
> >>>>-
> >>>>-	/* Inform the methods they need to stop using the dev.
> >>>>-	 */
> >>>>-	if (tfile) {
> >>>>-		wake_up_all(&tfile->wq.wait);
> >>>>-		if (atomic_dec_and_test(&tfile->count))
> >>>>-			__tun_detach(tun);
> >>>>-	}
> >>>>+	tun_detach_all(dev);
> >>>>  }
> >>>>
> >>>>  /* Net device open. */
> >>>>@@ -360,10 +434,10 @@ static int tun_net_close(struct net_device *dev)
> >>>>  /* Net device start xmit */
> >>>>  static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
> >>>>  {
> >>>>-	struct tun_struct *tun = netdev_priv(dev);
> >>>>-	struct tun_file *tfile = tun->tfile;
> >>>>+	struct tun_file *tfile = NULL;
> >>>>
> >>>>-	tun_debug(KERN_INFO, tun, "tun_net_xmit %d\n", skb->len);
> >>>>+	rcu_read_lock();
> >>>>+	tfile = tun_get_queue(dev, skb);
> >>>>
> >>>>  	/* Drop packet if interface is not attached */
> >>>>  	if (!tfile)
> >>>>@@ -381,7 +455,8 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
> >>>>
> >>>>  	if (skb_queue_len(&tfile->socket.sk->sk_receive_queue)
> >>>>  	>= dev->tx_queue_len) {
> >>>>-		if (!(tun->flags&   TUN_ONE_QUEUE)) {
> >>>>+		if (!(tfile->flags&   TUN_ONE_QUEUE)&&
> >>>Which patch moved flags from tun to tfile?
> >>Patch 1 cache the tun->flags in tfile, but it seems this may let the
> >>flags out of sync. So we'd better to use the one in tun_struct.
> >>>>+		    !(tfile->flags&   TUN_TAP_MQ)) {
> >>>>  			/* Normal queueing mode. */
> >>>>  			/* Packet scheduler handles dropping of further packets. */
> >>>>  			netif_stop_queue(dev);
> >>>>@@ -390,7 +465,7 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
> >>>>  			 * error is more appropriate. */
> >>>>  			dev->stats.tx_fifo_errors++;
> >>>>  		} else {
> >>>>-			/* Single queue mode.
> >>>>+			/* Single queue mode or multi queue mode.
> >>>>  			 * Driver handles dropping of all packets itself. */
> >>>Please don't do this. Stop the queue on overrun as appropriate.
> >>>ONE_QUEUE is a legacy hack.
> >>>
> >>>BTW we really should stop queue before we start dropping packets,
> >>>but that can be a separate patch.
> >>The problem here is the using of NETIF_F_LLTX. Kernel could only see
> >>one queue even for a multiqueue tun/tap. If we use
> >>netif_stop_queue(), all other queues would be stopped also.
> >Another reason not to use LLTX?
> 
> Yes.
> >>>>  			goto drop;
> >>>>  		}
> >>>>@@ -408,9 +483,11 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
> >>>>  		kill_fasync(&tfile->fasync, SIGIO, POLL_IN);
> >>>>  	wake_up_interruptible_poll(&tfile->wq.wait, POLLIN |
> >>>>  				   POLLRDNORM | POLLRDBAND);
> >>>>+	rcu_read_unlock();
> >>>>  	return NETDEV_TX_OK;
> >>>>
> >>>>  drop:
> >>>>+	rcu_read_unlock();
> >>>>  	dev->stats.tx_dropped++;
> >>>>  	kfree_skb(skb);
> >>>>  	return NETDEV_TX_OK;
> >>>>@@ -527,16 +604,22 @@ static void tun_net_init(struct net_device *dev)
> >>>>  static unsigned int tun_chr_poll(struct file *file, poll_table * wait)
> >>>>  {
> >>>>  	struct tun_file *tfile = file->private_data;
> >>>>-	struct tun_struct *tun = __tun_get(tfile);
> >>>>+	struct tun_struct *tun = NULL;
> >>>>  	struct sock *sk;
> >>>>  	unsigned int mask = 0;
> >>>>
> >>>>-	if (!tun)
> >>>>+	if (!tfile)
> >>>>  		return POLLERR;
> >>>>
> >>>>-	sk = tfile->socket.sk;
> >>>>+	rcu_read_lock();
> >>>>+	tun = rcu_dereference(tfile->tun);
> >>>>+	if (!tun) {
> >>>>+		rcu_read_unlock();
> >>>>+		return POLLERR;
> >>>>+	}
> >>>>+	rcu_read_unlock();
> >>>>
> >>>>-	tun_debug(KERN_INFO, tun, "tun_chr_poll\n");
> >>>>+	sk =&tfile->sk;
> >>>>
> >>>>  	poll_wait(file,&tfile->wq.wait, wait);
> >>>>
> >>>>@@ -548,10 +631,12 @@ static unsigned int tun_chr_poll(struct file *file, poll_table * wait)
> >>>>  	     sock_writeable(sk)))
> >>>>  		mask |= POLLOUT | POLLWRNORM;
> >>>>
> >>>>-	if (tun->dev->reg_state != NETREG_REGISTERED)
> >>>>+	rcu_read_lock();
> >>>>+	tun = rcu_dereference(tfile->tun);
> >>>>+	if (!tun || tun->dev->reg_state != NETREG_REGISTERED)
> >>>>  		mask = POLLERR;
> >>>>+	rcu_read_unlock();
> >>>>
> >>>>-	tun_put(tun);
> >>>>  	return mask;
> >>>>  }
> >>>>
> >>>>@@ -708,9 +793,12 @@ static ssize_t tun_get_user(struct tun_file *tfile,
> >>>>  		skb_shinfo(skb)->gso_segs = 0;
> >>>>  	}
> >>>>
> >>>>-	tun = __tun_get(tfile);
> >>>>-	if (!tun)
> >>>>+	rcu_read_lock();
> >>>>+	tun = rcu_dereference(tfile->tun);
> >>>>+	if (!tun) {
> >>>>+		rcu_read_unlock();
> >>>>  		return -EBADFD;
> >>>>+	}
> >>>>
> >>>>  	switch (tfile->flags&   TUN_TYPE_MASK) {
> >>>>  	case TUN_TUN_DEV:
> >>>>@@ -720,26 +808,30 @@ static ssize_t tun_get_user(struct tun_file *tfile,
> >>>>  		skb->protocol = eth_type_trans(skb, tun->dev);
> >>>>  		break;
> >>>>  	}
> >>>>-
> >>>>-	netif_rx_ni(skb);
> >>>>  	tun->dev->stats.rx_packets++;
> >>>>  	tun->dev->stats.rx_bytes += len;
> >>>>-	tun_put(tun);
> >>>>+	rcu_read_unlock();
> >>>>+
> >>>>+	netif_rx_ni(skb);
> >>>>+
> >>>>  	return count;
> >>>>
> >>>>  err_free:
> >>>>  	count = -EINVAL;
> >>>>  	kfree_skb(skb);
> >>>>  err:
> >>>>-	tun = __tun_get(tfile);
> >>>>-	if (!tun)
> >>>>+	rcu_read_lock();
> >>>>+	tun = rcu_dereference(tfile->tun);
> >>>>+	if (!tun) {
> >>>>+		rcu_read_unlock();
> >>>>  		return -EBADFD;
> >>>>+	}
> >>>>
> >>>>  	if (drop)
> >>>>  		tun->dev->stats.rx_dropped++;
> >>>>  	if (error)
> >>>>  		tun->dev->stats.rx_frame_errors++;
> >>>>-	tun_put(tun);
> >>>>+	rcu_read_unlock();
> >>>>  	return count;
> >>>>  }
> >>>>
> >>>>@@ -833,12 +925,13 @@ static ssize_t tun_put_user(struct tun_file *tfile,
> >>>>  	skb_copy_datagram_const_iovec(skb, 0, iv, total, len);
> >>>>  	total += skb->len;
> >>>>
> >>>>-	tun = __tun_get(tfile);
> >>>>+	rcu_read_lock();
> >>>>+	tun = rcu_dereference(tfile->tun);
> >>>>  	if (tun) {
> >>>>  		tun->dev->stats.tx_packets++;
> >>>>  		tun->dev->stats.tx_bytes += len;
> >>>>-		tun_put(tun);
> >>>>  	}
> >>>>+	rcu_read_unlock();
> >>>>
> >>>>  	return total;
> >>>>  }
> >>>>@@ -869,28 +962,31 @@ static ssize_t tun_do_read(struct tun_file *tfile,
> >>>>  				break;
> >>>>  			}
> >>>>
> >>>>-			tun = __tun_get(tfile);
> >>>>+			rcu_read_lock();
> >>>>+			tun = rcu_dereference(tfile->tun);
> >>>>  			if (!tun) {
> >>>>-				ret = -EIO;
> >>>>+				ret = -EBADFD;
> >>>BADFD is for when you get passed something like -1 fd.
> >>>Here fd is OK, it's just in a bad state so you can not do IO.
> >>>
> >>Sure.
> >>>>+				rcu_read_unlock();
> >>>>  				break;
> >>>>  			}
> >>>>  			if (tun->dev->reg_state != NETREG_REGISTERED) {
> >>>>  				ret = -EIO;
> >>>>-				tun_put(tun);
> >>>>+				rcu_read_unlock();
> >>>>  				break;
> >>>>  			}
> >>>>-			tun_put(tun);
> >>>>+			rcu_read_unlock();
> >>>>
> >>>>  			/* Nothing to read, let's sleep */
> >>>>  			schedule();
> >>>>  			continue;
> >>>>  		}
> >>>>
> >>>>-		tun = __tun_get(tfile);
> >>>>+		rcu_read_lock();
> >>>>+		tun = rcu_dereference(tfile->tun);
> >>>>  		if (tun) {
> >>>>  			netif_wake_queue(tun->dev);
> >>>>-			tun_put(tun);
> >>>>  		}
> >>>>+		rcu_read_unlock();
> >>>>
> >>>>  		ret = tun_put_user(tfile, skb, iv, len);
> >>>>  		kfree_skb(skb);
> >>>>@@ -1038,6 +1134,9 @@ static int tun_flags(struct tun_struct *tun)
> >>>>  	if (tun->flags&   TUN_VNET_HDR)
> >>>>  		flags |= IFF_VNET_HDR;
> >>>>
> >>>>+	if (tun->flags&   TUN_TAP_MQ)
> >>>>+		flags |= IFF_MULTI_QUEUE;
> >>>>+
> >>>>  	return flags;
> >>>>  }
> >>>>
> >>>>@@ -1097,8 +1196,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
> >>>>  		err = tun_attach(tun, file);
> >>>>  		if (err<   0)
> >>>>  			return err;
> >>>>-	}
> >>>>-	else {
> >>>>+	} else {
> >>>>  		char *name;
> >>>>  		unsigned long flags = 0;
> >>>>
> >>>>@@ -1142,6 +1240,8 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
> >>>>  		dev->hw_features = NETIF_F_SG | NETIF_F_FRAGLIST |
> >>>>  			TUN_USER_FEATURES;
> >>>>  		dev->features = dev->hw_features;
> >>>>+		if (ifr->ifr_flags&   IFF_MULTI_QUEUE)
> >>>>+			dev->features |= NETIF_F_LLTX;
> >>>>
> >>>>  		err = register_netdevice(tun->dev);
> >>>>  		if (err<   0)
> >>>>@@ -1154,7 +1254,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
> >>>>
> >>>>  		err = tun_attach(tun, file);
> >>>>  		if (err<   0)
> >>>>-			goto failed;
> >>>>+			goto err_free_dev;
> >>>>  	}
> >>>>
> >>>>  	tun_debug(KERN_INFO, tun, "tun_set_iff\n");
> >>>>@@ -1174,6 +1274,11 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
> >>>>  	else
> >>>>  		tun->flags&= ~TUN_VNET_HDR;
> >>>>
> >>>>+	if (ifr->ifr_flags&   IFF_MULTI_QUEUE)
> >>>>+		tun->flags |= TUN_TAP_MQ;
> >>>>+	else
> >>>>+		tun->flags&= ~TUN_TAP_MQ;
> >>>>+
> >>>>  	/* Cache flags from tun device */
> >>>>  	tfile->flags = tun->flags;
> >>>>  	/* Make sure persistent devices do not get stuck in
> >>>>@@ -1187,7 +1292,6 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
> >>>>
> >>>>  err_free_dev:
> >>>>  	free_netdev(dev);
> >>>>-failed:
> >>>>  	return err;
> >>>>  }
> >>>>
> >>>>@@ -1264,38 +1368,40 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
> >>>>  				(unsigned int __user*)argp);
> >>>>  	}
> >>>>
> >>>>-	rtnl_lock();
> >>>>-
> >>>>-	tun = __tun_get(tfile);
> >>>>-	if (cmd == TUNSETIFF&&   !tun) {
> >>>>+	ret = 0;
> >>>>+	if (cmd == TUNSETIFF) {
> >>>>+		rtnl_lock();
> >>>>  		ifr.ifr_name[IFNAMSIZ-1] = '\0';
> >>>>-
> >>>>  		ret = tun_set_iff(tfile->net, file,&ifr);
> >>>>-
> >>>>+		rtnl_unlock();
> >>>>  		if (ret)
> >>>>-			goto unlock;
> >>>>-
> >>>>+			return ret;
> >>>>  		if (copy_to_user(argp,&ifr, ifreq_len))
> >>>>-			ret = -EFAULT;
> >>>>-		goto unlock;
> >>>>+			return -EFAULT;
> >>>>+		return ret;
> >>>>  	}
> >>>>
> >>>>+	rtnl_lock();
> >>>>+
> >>>>+	rcu_read_lock();
> >>>>+
> >>>>  	ret = -EBADFD;
> >>>>+	tun = rcu_dereference(tfile->tun);
> >>>>  	if (!tun)
> >>>>  		goto unlock;
> >>>>+	else
> >>>>+		ret = 0;
> >>>>
> >>>>-	tun_debug(KERN_INFO, tun, "tun_chr_ioctl cmd %d\n", cmd);
> >>>>-
> >>>>-	ret = 0;
> >>>>  	switch (cmd) {
> >>>>  	case TUNGETIFF:
> >>>>  		ret = tun_get_iff(current->nsproxy->net_ns, tun,&ifr);
> >>>>+		rcu_read_unlock();
> >>>>  		if (ret)
> >>>>-			break;
> >>>>+			goto out;
> >>>>
> >>>>  		if (copy_to_user(argp,&ifr, ifreq_len))
> >>>>  			ret = -EFAULT;
> >>>>-		break;
> >>>>+		goto out;
> >>>>
> >>>>  	case TUNSETNOCSUM:
> >>>>  		/* Disable/Enable checksum */
> >>>>@@ -1357,9 +1463,10 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
> >>>>  		/* Get hw address */
> >>>>  		memcpy(ifr.ifr_hwaddr.sa_data, tun->dev->dev_addr, ETH_ALEN);
> >>>>  		ifr.ifr_hwaddr.sa_family = tun->dev->type;
> >>>>+		rcu_read_unlock();
> >>>>  		if (copy_to_user(argp,&ifr, ifreq_len))
> >>>>  			ret = -EFAULT;
> >>>>-		break;
> >>>>+		goto out;
> >>>>
> >>>>  	case SIOCSIFHWADDR:
> >>>>  		/* Set hw address */
> >>>>@@ -1375,9 +1482,9 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
> >>>>  	}
> >>>>
> >>>>  unlock:
> >>>>+	rcu_read_unlock();
> >>>>+out:
> >>>>  	rtnl_unlock();
> >>>>-	if (tun)
> >>>>-		tun_put(tun);
> >>>>  	return ret;
> >>>>  }
> >>>>
> >>>>@@ -1517,6 +1624,11 @@ out:
> >>>>  	return ret;
> >>>>  }
> >>>>
> >>>>+static void tun_sock_destruct(struct sock *sk)
> >>>>+{
> >>>>+	skb_queue_purge(&sk->sk_receive_queue);
> >>>>+}
> >>>>+
> >>>>  static int tun_chr_open(struct inode *inode, struct file * file)
> >>>>  {
> >>>>  	struct net *net = current->nsproxy->net_ns;
> >>>>@@ -1540,6 +1652,7 @@ static int tun_chr_open(struct inode *inode, struct file * file)
> >>>>  	sock_init_data(&tfile->socket,&tfile->sk);
> >>>>
> >>>>  	tfile->sk.sk_write_space = tun_sock_write_space;
> >>>>+	tfile->sk.sk_destruct = tun_sock_destruct;
> >>>>  	tfile->sk.sk_sndbuf = INT_MAX;
> >>>>  	file->private_data = tfile;
> >>>>
> >>>>@@ -1549,31 +1662,8 @@ static int tun_chr_open(struct inode *inode, struct file * file)
> >>>>  static int tun_chr_close(struct inode *inode, struct file *file)
> >>>>  {
> >>>>  	struct tun_file *tfile = file->private_data;
> >>>>-	struct tun_struct *tun;
> >>>>-
> >>>>-	tun = __tun_get(tfile);
> >>>>-	if (tun) {
> >>>>-		struct net_device *dev = tun->dev;
> >>>>-
> >>>>-		tun_debug(KERN_INFO, tun, "tun_chr_close\n");
> >>>>-
> >>>>-		__tun_detach(tun);
> >>>>-
> >>>>-		/* If desirable, unregister the netdevice. */
> >>>>-		if (!(tun->flags&   TUN_PERSIST)) {
> >>>>-			rtnl_lock();
> >>>>-			if (dev->reg_state == NETREG_REGISTERED)
> >>>>-				unregister_netdevice(dev);
> >>>>-			rtnl_unlock();
> >>>>-		}
> >>>>
> >>>>-		/* drop the reference that netdevice holds */
> >>>>-		sock_put(&tfile->sk);
> >>>>-
> >>>>-	}
> >>>>-
> >>>>-	/* drop the reference that file holds */
> >>>>-	sock_put(&tfile->sk);
> >>>>+	tun_detach(tfile, true);
> >>>>
> >>>>  	return 0;
> >>>>  }
> >>>>@@ -1700,14 +1790,17 @@ static void tun_cleanup(void)
> >>>>   * holding a reference to the file for as long as the socket is in use. */
> >>>>  struct socket *tun_get_socket(struct file *file)
> >>>>  {
> >>>>-	struct tun_struct *tun;
> >>>>+	struct tun_struct *tun = NULL;
> >>>>  	struct tun_file *tfile = file->private_data;
> >>>>  	if (file->f_op !=&tun_fops)
> >>>>  		return ERR_PTR(-EINVAL);
> >>>>-	tun = tun_get(file);
> >>>>-	if (!tun)
> >>>>+	rcu_read_lock();
> >>>>+	tun = rcu_dereference(tfile->tun);
> >>>>+	if (!tun) {
> >>>>+		rcu_read_unlock();
> >>>>  		return ERR_PTR(-EBADFD);
> >>>>-	tun_put(tun);
> >>>>+	}
> >>>>+	rcu_read_unlock();
> >>>>  	return&tfile->socket;
> >>>>  }
> >>>>  EXPORT_SYMBOL_GPL(tun_get_socket);
