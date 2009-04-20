From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: [2/2] tun: Fix sk_sleep races when attaching/detaching
Date: Mon, 20 Apr 2009 16:35:50 +0800
Message-ID: <20090420083550.GA2582@gondor.apana.org.au>
References: <m18wm2rqy6.fsf@fess.ebiederm.org>
	<20090415132802.GA11408@gondor.apana.org.au>
	<m1skkaox8h.fsf@fess.ebiederm.org>
	<20090415134610.GA11683@gondor.apana.org.au>
	<m11vruovu5.fsf@fess.ebiederm.org>
	<20090415140819.GA11991@gondor.apana.org.au>
	<m1iql6m24b.fsf@fess.ebiederm.org>
	<20090415143834.GA12384@gondor.apana.org.au>
	<20090416110818.GA20950@gondor.apana.org.au>
	<20090416110952.GB20950@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: lguest-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, virtualization-qjLDD68F18O7TbgM5vRIOg@public.gmane.org,
	Matias Zabaljauregui <zabaljauregui-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <lguest-bounces+glkvl-lguest=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090416110952.GB20950-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
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

On Thu, Apr 16, 2009 at 07:09:52PM +0800, Herbert Xu wrote:
> 
> tun: Fix sk_sleep races when attaching/detaching

That patch doesn't apply anymore because of contextual changes
caused by the first patch.  Here's an update.

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

Reported-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Tested-by: Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Tested-by: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Signed-off-by: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 95ae40a..735bf41 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -93,7 +93,6 @@ struct tun_file {
 	atomic_t count;
 	struct tun_struct *tun;
 	struct net *net;
-	wait_queue_head_t	read_wait;
 };
 
 struct tun_sock;
@@ -331,7 +330,7 @@ static void tun_net_uninit(struct net_device *dev)
 	/* Inform the methods they need to stop using the dev.
 	 */
 	if (tfile) {
-		wake_up_all(&tfile->read_wait);
+		wake_up_all(&tun->socket.wait);
 		if (atomic_dec_and_test(&tfile->count))
 			__tun_detach(tun);
 	}
@@ -398,7 +397,7 @@ static int tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Notify and wake up reader process */
 	if (tun->flags & TUN_FASYNC)
 		kill_fasync(&tun->fasync, SIGIO, POLL_IN);
-	wake_up_interruptible(&tun->tfile->read_wait);
+	wake_up_interruptible(&tun->socket.wait);
 	return 0;
 
 drop:
@@ -495,7 +494,7 @@ static unsigned int tun_chr_poll(struct file *file, poll_table * wait)
 
 	DBG(KERN_INFO "%s: tun_chr_poll\n", tun->dev->name);
 
-	poll_wait(file, &tfile->read_wait, wait);
+	poll_wait(file, &tun->socket.wait, wait);
 
 	if (!skb_queue_empty(&tun->readq))
 		mask |= POLLIN | POLLRDNORM;
@@ -768,7 +767,7 @@ static ssize_t tun_chr_aio_read(struct kiocb *iocb, const struct iovec *iv,
 		goto out;
 	}
 
-	add_wait_queue(&tfile->read_wait, &wait);
+	add_wait_queue(&tun->socket.wait, &wait);
 	while (len) {
 		current->state = TASK_INTERRUPTIBLE;
 
@@ -799,7 +798,7 @@ static ssize_t tun_chr_aio_read(struct kiocb *iocb, const struct iovec *iv,
 	}
 
 	current->state = TASK_RUNNING;
-	remove_wait_queue(&tfile->read_wait, &wait);
+	remove_wait_queue(&tun->socket.wait, &wait);
 
 out:
 	tun_put(tun);
@@ -867,7 +866,6 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 	struct sock *sk;
 	struct tun_struct *tun;
 	struct net_device *dev;
-	struct tun_file *tfile = file->private_data;
 	int err;
 
 	dev = __dev_get_by_name(net, ifr->ifr_name);
@@ -925,10 +923,10 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		if (!sk)
 			goto err_free_dev;
 
+		init_waitqueue_head(&tun->socket.wait);
 		sock_init_data(&tun->socket, sk);
 		sk->sk_write_space = tun_sock_write_space;
 		sk->sk_sndbuf = INT_MAX;
-		sk->sk_sleep = &tfile->read_wait;
 
 		tun->sk = sk;
 		container_of(sk, struct tun_sock, sk)->tun = tun;
@@ -1270,7 +1268,6 @@ static int tun_chr_open(struct inode *inode, struct file * file)
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
