From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: [1/2] tun: Only free a netdev when all tun descriptors are
	closed
Date: Thu, 16 Apr 2009 19:08:18 +0800
Message-ID: <20090416110818.GA20950@gondor.apana.org.au>
References: <20090415083610.GA8579@gondor.apana.org.au>
	<20090415084717.GA8829@gondor.apana.org.au>
	<m18wm2rqy6.fsf@fess.ebiederm.org>
	<20090415132802.GA11408@gondor.apana.org.au>
	<m1skkaox8h.fsf@fess.ebiederm.org>
	<20090415134610.GA11683@gondor.apana.org.au>
	<m11vruovu5.fsf@fess.ebiederm.org>
	<20090415140819.GA11991@gondor.apana.org.au>
	<m1iql6m24b.fsf@fess.ebiederm.org>
	<20090415143834.GA12384@gondor.apana.org.au>
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
In-Reply-To: <20090415143834.GA12384-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
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

On Wed, Apr 15, 2009 at 10:38:34PM +0800, Herbert Xu wrote:
> 
> So how about this? We replace the dev destructor with our own that
> doesn't immediately call free_netdev.  We only call free_netdev once
> all tun fd's attached to the device have been closed.

Here's the patch.  I'd appreciate if everyone can review it
and see if they can recreate the original race by

1) Starting a process using tun and polls on it;
2) Doing ip tun del tunXXX while the process is polling.

tun: Only free a netdev when all tun descriptors are closed

The commit c70f182940f988448f3c12a209d18b1edc276e33 ("tun: Fix
races between tun_net_close and free_netdev") fixed a race where
an asynchronous deletion of a tun device can hose a poll(2) on
a tun fd attached to that device.

However, this came at the cost of moving the tun wait queue into
the tun file data structure.  The problem with this is that it
imposes restrictions on when and where the tun device can access
the wait queue since the tun file may change at any time due to
detaching and reattaching.

In particular, now that we need to use the wait queue on the
receive path it becomes difficult to properly synchronise this
with the detachment of the tun device.

This patch solves the original race in a different way.  Since
the race is only because the underlying memory gets freed, we
can prevent it simply by ensuring that we don't do that until
all tun descriptors ever attached to the device (even if they
have since be detached because they may still be sitting in poll)
have been closed.

This is done by using reference counting the attached tun file
descriptors.  The refcount in tun->sk has been reappropriated
for this purpose since it was already being used for that, albeit
from the opposite angle.

Note that we no longer zero tfile->tun since tun_get will return
NULL anyway after the refcount on tfile hits zero.  Instead it
represents whether this device has ever been attached to a device.

Signed-off-by: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index a1b0697..540f829 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -156,6 +156,7 @@ static int tun_attach(struct tun_struct *tun, struct file *file)
 	tfile->tun = tun;
 	tun->tfile = tfile;
 	dev_hold(tun->dev);
+	sock_hold(tun->sk);
 	atomic_inc(&tfile->count);
 
 out:
@@ -165,11 +166,8 @@ out:
 
 static void __tun_detach(struct tun_struct *tun)
 {
-	struct tun_file *tfile = tun->tfile;
-
 	/* Detach from net device */
 	netif_tx_lock_bh(tun->dev);
-	tfile->tun = NULL;
 	tun->tfile = NULL;
 	netif_tx_unlock_bh(tun->dev);
 
@@ -339,6 +337,13 @@ static void tun_net_uninit(struct net_device *dev)
 	}
 }
 
+static void tun_free_netdev(struct net_device *dev)
+{
+	struct tun_struct *tun = netdev_priv(dev);
+
+	sock_put(tun->sk);
+}
+
 /* Net device open. */
 static int tun_net_open(struct net_device *dev)
 {
@@ -810,7 +815,7 @@ static void tun_setup(struct net_device *dev)
 	tun->group = -1;
 
 	dev->ethtool_ops = &tun_ethtool_ops;
-	dev->destructor = free_netdev;
+	dev->destructor = tun_free_netdev;
 }
 
 /* Trivial set of netlink ops to allow deleting tun or tap
@@ -847,7 +852,7 @@ static void tun_sock_write_space(struct sock *sk)
 
 static void tun_sock_destruct(struct sock *sk)
 {
-	dev_put(container_of(sk, struct tun_sock, sk)->tun->dev);
+	free_netdev(container_of(sk, struct tun_sock, sk)->tun->dev);
 }
 
 static struct proto tun_proto = {
@@ -919,8 +924,6 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		if (!sk)
 			goto err_free_dev;
 
-		/* This ref count is for tun->sk. */
-		dev_hold(dev);
 		sock_init_data(&tun->socket, sk);
 		sk->sk_write_space = tun_sock_write_space;
 		sk->sk_destruct = tun_sock_destruct;
@@ -1275,20 +1278,18 @@ static int tun_chr_close(struct inode *inode, struct file *file)
 	struct tun_file *tfile = file->private_data;
 	struct tun_struct *tun = __tun_get(tfile);
 
-
 	if (tun) {
-		DBG(KERN_INFO "%s: tun_chr_close\n", tun->dev->name);
-
-		rtnl_lock();
-		__tun_detach(tun);
-
 		/* If desireable, unregister the netdevice. */
-		if (!(tun->flags & TUN_PERSIST)) {
-			sock_put(tun->sk);
-			unregister_netdevice(tun->dev);
-		}
+		if (!(tun->flags & TUN_PERSIST))
+			unregister_netdev(tun->dev);
+		else
+			tun_put(tun);
+	} else
+		tun = tfile->tun;
 
-		rtnl_unlock();
+	if (tun) {
+		DBG(KERN_INFO "%s: tun_chr_close\n", tun->dev->name);
+		sock_put(tun->sk);
 	}
 
 	put_net(tfile->net);

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
