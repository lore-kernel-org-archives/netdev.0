From: Xi Wang <xii@google.com>
Subject: Re: [PATCH] net-tun: restructure tun_do_read for better sleep/wakeup efficiency
Date: Thu, 8 May 2014 11:22:46 -0700
Message-ID: <CAOBoifh6X8nbiqcNXNxJeFzWj1Q3N9Jc-xxQNrLWwFQf8LjZzQ@mail.gmail.com>
References: <1399422244-22751-1-git-send-email-xii@google.com>
	<5369AB36.6030609@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Maxim Krasnyansky <maxk@qti.qualcomm.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:49000 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755281AbaEHSWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 14:22:47 -0400
Received: by mail-lb0-f181.google.com with SMTP id u14so4148383lbd.12
        for <netdev@vger.kernel.org>; Thu, 08 May 2014 11:22:46 -0700 (PDT)
In-Reply-To: <5369AB36.6030609@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 6, 2014 at 8:40 PM, Jason Wang <jasowang@redhat.com> wrote:
>
> On 05/07/2014 08:24 AM, Xi Wang wrote:
> > tun_do_read always adds current thread to wait queue, even if a packet
> > is ready to read. This is inefficient because both sleeper and waker
> > want to acquire the wait queue spin lock when packet rate is high.
>
> After commit 61a5ff15ebdab87887861a6b128b108404e4706d, this will only
> help for blocking read. Looks like for performance critical userspaces,
> they will use non blocking reads.
> >
> > We restructure the read function and use common kernel networking
> > routines to handle receive, sleep and wakeup. With the change
> > available packets are checked first before the reading thread is added
> > to the wait queue.
>
> This is interesting, since it may help if we want to add rx busy loop
> for tun. (In fact I worked a similar patch like this).


Yes this should be a good side effect and I am also interested in trying.
Busy polling in user space is not ideal as it doesn't give the lowest latency.
Besides differences in interrupt latency etc., there is a bad case for
non blocking mode: When a packet arrives right before the polling thread
returns to userspace. The control flow has to cross kernel/userspace
boundary 3 times before the packet can be processed, while kernel
blocking or busy polling only needs 1 boundary crossing.


>
> >
> > Ran performance tests with the following configuration:
> >
> >  - my packet generator -> tap1 -> br0 -> tap0 -> my packet consumer
> >  - sender pinned to one core and receiver pinned to another core
> >  - sender send small UDP packets (64 bytes total) as fast as it can
> >  - sandy bridge cores
> >  - throughput are receiver side goodput numbers
> >
> > The results are
> >
> > baseline: 757k pkts/sec, cpu utilization at 1.54 cpus
> >  changed: 804k pkts/sec, cpu utilization at 1.57 cpus
> >
> > The performance difference is largely determined by packet rate and
> > inter-cpu communication cost. For example, if the sender and
> > receiver are pinned to different cpu sockets, the results are
> >
> > baseline: 558k pkts/sec, cpu utilization at 1.71 cpus
> >  changed: 690k pkts/sec, cpu utilization at 1.67 cpus
>
> So I believe your consumer is using blocking reads. How about re-test
> with non blocking reads and re-test to make sure no regression?


I tested non blocking read and found no regression. However the sender
is the bottleneck in my case so packet blasting is not a good test for
non blocking mode. I switched to RR / ping pong type of traffic through tap.
The packet rates for both cases are ~477k and the difference is way
below noise.


>
> >
> > Co-authored-by: Eric Dumazet <edumazet@google.com>
> > Signed-off-by: Xi Wang <xii@google.com>
> > ---
> >  drivers/net/tun.c | 68 +++++++++++++++++++++----------------------------------
> >  1 file changed, 26 insertions(+), 42 deletions(-)
> >
> > diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> > index ee328ba..cb25385 100644
> > --- a/drivers/net/tun.c
> > +++ b/drivers/net/tun.c
> > @@ -133,8 +133,7 @@ struct tap_filter {
> >  struct tun_file {
> >       struct sock sk;
> >       struct socket socket;
> > -     struct socket_wq wq;
> > -     struct tun_struct __rcu *tun;
> > +     struct tun_struct __rcu *tun ____cacheline_aligned_in_smp;
>
> This seems a optimization which is un-related to the topic. May send as
> another patch but did you really see improvement for this?


There is an ~1% difference (not as reliable as other data since the difference
is small). This is not a major performance contributor.


>
> >       struct net *net;
> >       struct fasync_struct *fasync;
> >       /* only used for fasnyc */
> > @@ -498,12 +497,12 @@ static void tun_detach_all(struct net_device *dev)
> >       for (i = 0; i < n; i++) {
> >               tfile = rtnl_dereference(tun->tfiles[i]);
> >               BUG_ON(!tfile);
> > -             wake_up_all(&tfile->wq.wait);
> > +             tfile->socket.sk->sk_data_ready(tfile->socket.sk);
> >               RCU_INIT_POINTER(tfile->tun, NULL);
> >               --tun->numqueues;
> >       }
> >       list_for_each_entry(tfile, &tun->disabled, next) {
> > -             wake_up_all(&tfile->wq.wait);
> > +     tfile->socket.sk->sk_data_ready(tfile->socket.sk);
> >               RCU_INIT_POINTER(tfile->tun, NULL);
> >       }
> >       BUG_ON(tun->numqueues != 0);
> > @@ -807,8 +806,7 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
> >       /* Notify and wake up reader process */
> >       if (tfile->flags & TUN_FASYNC)
> >               kill_fasync(&tfile->fasync, SIGIO, POLL_IN);
> > -     wake_up_interruptible_poll(&tfile->wq.wait, POLLIN |
> > -                                POLLRDNORM | POLLRDBAND);
> > +     tfile->socket.sk->sk_data_ready(tfile->socket.sk);
> >
> >       rcu_read_unlock();
> >       return NETDEV_TX_OK;
> > @@ -965,7 +963,7 @@ static unsigned int tun_chr_poll(struct file *file, poll_table *wait)
> >
> >       tun_debug(KERN_INFO, tun, "tun_chr_poll\n");
> >
> > -     poll_wait(file, &tfile->wq.wait, wait);
> > +     poll_wait(file, sk_sleep(sk), wait);
> >
> >       if (!skb_queue_empty(&sk->sk_receive_queue))
> >               mask |= POLLIN | POLLRDNORM;
> > @@ -1330,46 +1328,21 @@ done:
> >  static ssize_t tun_do_read(struct tun_struct *tun, struct tun_file *tfile,
> >                          const struct iovec *iv, ssize_t len, int noblock)
> >  {
> > -     DECLARE_WAITQUEUE(wait, current);
> >       struct sk_buff *skb;
> >       ssize_t ret = 0;
> > +     int peeked, err, off = 0;
> >
> >       tun_debug(KERN_INFO, tun, "tun_do_read\n");
> >
> > -     if (unlikely(!noblock))
> > -             add_wait_queue(&tfile->wq.wait, &wait);
> > -     while (len) {
> > -             if (unlikely(!noblock))
> > -                     current->state = TASK_INTERRUPTIBLE;
> > -
> > -             /* Read frames from the queue */
> > -             if (!(skb = skb_dequeue(&tfile->socket.sk->sk_receive_queue))) {
> > -                     if (noblock) {
> > -                             ret = -EAGAIN;
> > -                             break;
> > -                     }
> > -                     if (signal_pending(current)) {
> > -                             ret = -ERESTARTSYS;
> > -                             break;
> > -                     }
> > -                     if (tun->dev->reg_state != NETREG_REGISTERED) {
> > -                             ret = -EIO;
> > -                             break;
> > -                     }
> > -
> > -                     /* Nothing to read, let's sleep */
> > -                     schedule();
> > -                     continue;
> > -             }
> > +     if (!len)
> > +             return ret;
> >
> > +     /* Read frames from queue */
> > +     skb = __skb_recv_datagram(tfile->socket.sk, noblock ? MSG_DONTWAIT : 0,
> > +                               &peeked, &off, &err);
> > +     if (skb) {
>
> This changes the userspace ABI a little bit. Originally, userspace can
> see different error codes and do responds, but here it can only see zero.


Thanks for catching this! Seems forwarding the &err parameter of
__skb_recv_datagram
should get the most of the error code compatibility back? I'll check
related code.


>
> >               ret = tun_put_user(tun, tfile, skb, iv, len);
> >               kfree_skb(skb);
> > -             break;
> > -     }
> > -
> > -     if (unlikely(!noblock)) {
> > -             current->state = TASK_RUNNING;
> > -             remove_wait_queue(&tfile->wq.wait, &wait);
> >       }
> >
> >       return ret;
> > @@ -2187,20 +2160,28 @@ out:
> >  static int tun_chr_open(struct inode *inode, struct file * file)
> >  {
> >       struct tun_file *tfile;
> > +     struct socket_wq *wq;
> >
> >       DBG1(KERN_INFO, "tunX: tun_chr_open\n");
> >
> > +     wq = kzalloc(sizeof(*wq), GFP_KERNEL);
> > +     if (!wq)
> > +             return -ENOMEM;
> > +
>
> Why not just reusing the socket_wq structure inside tun_file structure
> like what we did in the past?


There is no strong reason for going either way. Changing to dynamic allocation
is based on: Less chance of cacheline contention and syncing the code pattern
with core stack.


-Xi
