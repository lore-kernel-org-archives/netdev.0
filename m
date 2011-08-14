From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next RFC PATCH 4/7] tuntap: multiqueue support
Date: Sun, 14 Aug 2011 02:07:51 -0400 (EDT)
Message-ID: <1994320084.165913.1313302071630.JavaMail.root@zmail05.collab.prod.int.phx2.redhat.com>
References: <20110812232131.GU2395@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	qemu-devel@nongnu.org, netdev@vger.kernel.org,
	rusty@rustcorp.com.au, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	mirq-linux@rere.qmqm.pl, davem@davemloft.net
To: paulmck@linux.vnet.ibm.com
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <20110812232131.GU2395@linux.vnet.ibm.com>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: </archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org



----- Original Message -----
> On Fri, Aug 12, 2011 at 09:55:20AM +0800, Jason Wang wrote:
> > With the abstraction that each socket were a backend of a
> > queue for userspace, this patch adds multiqueue support for
> > tap device by allowing multiple sockets to be attached to a
> > tap device. Then we could parallize the transmission by put
> > them into different socket.
> >
> > As queue related information were stored in private_data of
> > file new, we could simply implement the multiqueue support
> > by add an array of pointers to sockets were stored in the
> > tap device. Then ioctls may be added to manipulate those
> > pointers for adding or removing queues.
> >
> > In order to let tx path lockless, NETIF_F_LLTX were used for
> > multiqueue tap device. And RCU is used for doing
> > synchronization between packet handling and system calls
> > such as removing queues.
> >
> > Currently, multiqueue support is limited for tap , but it's
> > easy also enable it for tun if we find it was also helpful.
> 
> Question below about calls to tun_get_slot().
> 
> Thanx, Paul
> 
> > Signed-off-by: Jason Wang <jasowang@redhat.com>
> > ---
> >  drivers/net/tun.c | 376
> >  ++++++++++++++++++++++++++++++++++-------------------
> >  1 files changed, 243 insertions(+), 133 deletions(-)
> >
> > diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> > index 4cd292a..8bc6dff 100644
> > --- a/drivers/net/tun.c
> > +++ b/drivers/net/tun.c
> > @@ -108,6 +108,8 @@ struct tap_filter {
> >  	unsigned char addr[FLT_EXACT_COUNT][ETH_ALEN];
> >  };
> >
> > +#define MAX_TAP_QUEUES (NR_CPUS < 16 ? NR_CPUS : 16)
> > +
> >  struct tun_file {
> >  	struct sock sk;
> >  	struct socket socket;
> > @@ -115,7 +117,7 @@ struct tun_file {
> >  	int vnet_hdr_sz;
> >  	struct tap_filter txflt;
> >  	atomic_t count;
> > - struct tun_struct *tun;
> > + struct tun_struct __rcu *tun;
> >  	struct net *net;
> >  	struct fasync_struct *fasync;
> >  	unsigned int flags;
> > @@ -124,7 +126,8 @@ struct tun_file {
> >  struct tun_sock;
> >
> >  struct tun_struct {
> > - struct tun_file *tfile;
> > + struct tun_file *tfiles[MAX_TAP_QUEUES];
> > + unsigned int numqueues;
> >  	unsigned int flags;
> >  	uid_t owner;
> >  	gid_t group;
> > @@ -139,80 +142,183 @@ struct tun_struct {
> >  #endif
> >  };
> >
> > -static int tun_attach(struct tun_struct *tun, struct file *file)
> > +static DEFINE_SPINLOCK(tun_lock);
> > +
> > +/*
> > + * get_slot: return a [unused/occupied] slot in tun->tfiles[]:
> > + * - if 'f' is NULL, return the first empty slot;
> > + * - otherwise, return the slot this pointer occupies.
> > + */
> > +static int tun_get_slot(struct tun_struct *tun, struct tun_file
> > *tfile)
> >  {
> > - struct tun_file *tfile = file->private_data;
> > - int err;
> > + int i;
> >
> > - ASSERT_RTNL();
> > + for (i = 0; i < MAX_TAP_QUEUES; i++) {
> > + if (rcu_dereference(tun->tfiles[i]) == tfile)
> > + return i;
> > + }
> >
> > - netif_tx_lock_bh(tun->dev);
> > + /* Should never happen */
> > + BUG_ON(1);
> > +}
> >
> > - err = -EINVAL;
> > - if (tfile->tun)
> > - goto out;
> > +/*
> > + * tun_get_queue(): calculate the queue index
> > + * - if skbs comes from mq nics, we can just borrow
> > + * - if not, calculate from the hash
> > + */
> > +static struct tun_file *tun_get_queue(struct net_device *dev,
> > + struct sk_buff *skb)
> > +{
> > + struct tun_struct *tun = netdev_priv(dev);
> > + struct tun_file *tfile = NULL;
> > + int numqueues = tun->numqueues;
> > + __u32 rxq;
> >
> > - err = -EBUSY;
> > - if (tun->tfile)
> > + BUG_ON(!rcu_read_lock_held());
> > +
> > + if (!numqueues)
> >  		goto out;
> >
> > - err = 0;
> > - tfile->tun = tun;
> > - tun->tfile = tfile;
> > - netif_carrier_on(tun->dev);
> > - dev_hold(tun->dev);
> > - sock_hold(&tfile->sk);
> > - atomic_inc(&tfile->count);
> > + if (likely(skb_rx_queue_recorded(skb))) {
> > + rxq = skb_get_rx_queue(skb);
> > +
> > + while (unlikely(rxq >= numqueues))
> > + rxq -= numqueues;
> > +
> > + tfile = rcu_dereference(tun->tfiles[rxq]);
> > + if (tfile)
> > + goto out;
> > + }
> > +
> > + /* Check if we can use flow to select a queue */
> > + rxq = skb_get_rxhash(skb);
> > + if (rxq) {
> > + tfile = rcu_dereference(tun->tfiles[rxq % numqueues]);
> > + if (tfile)
> > + goto out;
> > + }
> > +
> > + /* Everything failed - find first available queue */
> > + for (rxq = 0; rxq < MAX_TAP_QUEUES; rxq++) {
> > + tfile = rcu_dereference(tun->tfiles[rxq]);
> > + if (tfile)
> > + break;
> > + }
> >
> >  out:
> > - netif_tx_unlock_bh(tun->dev);
> > - return err;
> > + return tfile;
> >  }
> >
> > -static void __tun_detach(struct tun_struct *tun)
> > +static int tun_detach(struct tun_file *tfile, bool clean)
> >  {
> > - struct tun_file *tfile = tun->tfile;
> > - /* Detach from net device */
> > - netif_tx_lock_bh(tun->dev);
> > - netif_carrier_off(tun->dev);
> > - tun->tfile = NULL;
> > - netif_tx_unlock_bh(tun->dev);
> > -
> > - /* Drop read queue */
> > - skb_queue_purge(&tfile->socket.sk->sk_receive_queue);
> > -
> > - /* Drop the extra count on the net device */
> > - dev_put(tun->dev);
> > -}
> > + struct tun_struct *tun;
> > + struct net_device *dev = NULL;
> > + bool destroy = false;
> >
> > -static void tun_detach(struct tun_struct *tun)
> > -{
> > - rtnl_lock();
> > - __tun_detach(tun);
> > - rtnl_unlock();
> > -}
> > + spin_lock(&tun_lock);
> >
> > -static struct tun_struct *__tun_get(struct tun_file *tfile)
> > -{
> > - struct tun_struct *tun = NULL;
> > + tun = rcu_dereference_protected(tfile->tun,
> > + lockdep_is_held(&tun_lock));
> > + if (tun) {
> > + int index = tun_get_slot(tun, tfile);
> 
> Don't we need to be in an RCU read-side critical section in order to
> safely call tun_get_slot()?
> 
> Or is the fact that we are calling with tun_lock held sufficient?
> If the latter, then the rcu_dereference() in tun_get_slot() should
> use rcu_dereference_protected() rather than rcu_dereference().
> 

Nice catch. The latter, tun_lock held is sufficient. Thanks.
