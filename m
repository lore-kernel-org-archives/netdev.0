From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: [PATCH 4/5] lguest: use KVM hypercalls
Date: Wed, 15 Apr 2009 16:47:17 +0800
Message-ID: <20090415084717.GA8829@gondor.apana.org.au>
References: <200903271022.38244.rusty@rustcorp.com.au>
	<1238709324.5823.8.camel@odie.local>
	<1239043798.27826.93.camel@zetabook>
	<200904081021.39877.rusty@rustcorp.com.au>
	<1239224319.17844.16.camel@zetabook>
	<49DDE91A.8060603@trash.net> <49DDF614.1060909@trash.net>
	<m1bpr6hqrm.fsf@fess.ebiederm.org> <49E47976.8020005@trash.net>
	<20090415083610.GA8579@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: lguest-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	virtualization-qjLDD68F18O7TbgM5vRIOg@public.gmane.org,
	Matias Zabaljauregui <zabaljauregui-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Return-path: <lguest-bounces+glkvl-lguest=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090415083610.GA8579-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
List-Unsubscribe: <https://ozlabs.org/mailman/options/lguest>,
	<mailto:lguest-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/lguest>
List-Post: <mailto:lguest-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>
List-Help: <mailto:lguest-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/lguest>,
	<mailto:lguest-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=subscribe>
Sender: lguest-bounces+glkvl-lguest=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
Errors-To: lguest-bounces+glkvl-lguest=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 15, 2009 at 04:36:10PM +0800, Herbert Xu wrote:
> 
> Let me whip up a patch.

tun: Fix sk_sleep races when attaching/detaching

As the sk_sleep wait queue actually lives in tfile, which may be
detached from the tun device, bad things will happen when we use
sk_sleep after detaching.

Since the tun device is the persistent data structure here (when
requested by the user), it makes much more sense to have the wait
queue live there.  There is no reason to have it in tfile at all
since the only time we can wait is if we have a tun attached.
In fact we already have a wait queue in tun_struct, so we might
as well use it.

Reported-by: Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Reported-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Reported-by: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Signed-off-by: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index a1b0697..412b578 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -93,7 +93,6 @@ struct tun_file {
 	atomic_t count;
 	struct tun_struct *tun;
 	struct net *net;
-	wait_queue_head_t	read_wait;
 };
 
 struct tun_sock;
@@ -333,7 +332,7 @@ static void tun_net_uninit(struct net_device *dev)
 	/* Inform the methods they need to stop using the dev.
 	 */
 	if (tfile) {
-		wake_up_all(&tfile->read_wait);
+		wake_up_all(&tun->socket.wait);
 		if (atomic_dec_and_test(&tfile->count))
 			__tun_detach(tun);
 	}
@@ -393,7 +392,7 @@ static int tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Notify and wake up reader process */
 	if (tun->flags & TUN_FASYNC)
 		kill_fasync(&tun->fasync, SIGIO, POLL_IN);
-	wake_up_interruptible(&tun->tfile->read_wait);
+	wake_up_interruptible(&tun->socket.wait);
 	return 0;
 
 drop:
@@ -490,7 +489,7 @@ static unsigned int tun_chr_poll(struct file *file, poll_table * wait)
 
 	DBG(KERN_INFO "%s: tun_chr_poll\n", tun->dev->name);
 
-	poll_wait(file, &tfile->read_wait, wait);
+	poll_wait(file, &tun->socket.wait, wait);
 
 	if (!skb_queue_empty(&tun->readq))
 		mask |= POLLIN | POLLRDNORM;
@@ -762,7 +761,7 @@ static ssize_t tun_chr_aio_read(struct kiocb *iocb, const struct iovec *iv,
 		goto out;
 	}
 
-	add_wait_queue(&tfile->read_wait, &wait);
+	add_wait_queue(&tun->socket.wait, &wait);
 	while (len) {
 		current->state = TASK_INTERRUPTIBLE;
 
@@ -793,7 +792,7 @@ static ssize_t tun_chr_aio_read(struct kiocb *iocb, const struct iovec *iv,
 	}
 
 	current->state = TASK_RUNNING;
-	remove_wait_queue(&tfile->read_wait, &wait);
+	remove_wait_queue(&tun->socket.wait, &wait);
 
 out:
 	tun_put(tun);
@@ -861,7 +860,6 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 	struct sock *sk;
 	struct tun_struct *tun;
 	struct net_device *dev;
-	struct tun_file *tfile = file->private_data;
 	int err;
 
 	dev = __dev_get_by_name(net, ifr->ifr_name);
@@ -921,11 +919,11 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 
 		/* This ref count is for tun->sk. */
 		dev_hold(dev);
+		init_waitqueue_head(&tun->socket.wait);
 		sock_init_data(&tun->socket, sk);
 		sk->sk_write_space = tun_sock_write_space;
 		sk->sk_destruct = tun_sock_destruct;
 		sk->sk_sndbuf = INT_MAX;
-		sk->sk_sleep = &tfile->read_wait;
 
 		tun->sk = sk;
 		container_of(sk, struct tun_sock, sk)->tun = tun;
@@ -1265,7 +1263,6 @@ static int tun_chr_open(struct inode *inode, struct file * file)
 	atomic_set(&tfile->count, 0);
 	tfile->tun = NULL;
 	tfile->net = get_net(current->nsproxy->net_ns);
-	init_waitqueue_head(&tfile->read_wait);
 	file->private_data = tfile;
 	return 0;
 }

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
