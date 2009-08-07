From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH v1] tun: Cleanup error handling in tun_set_iff()
Date: Fri, 7 Aug 2009 10:22:44 +1000
Message-ID: <20090807002243.GB1566@gondor.apana.org.au>
References: <20090803161242.12947.14620.stgit@flek.lan> <m1ljlyvn9a.fsf@fess.ebiederm.org> <200908051738.43134.paul.moore@hp.com> <20090806101044.GA26589@gondor.apana.org.au> <m1hbwlkzt6.fsf@fess.ebiederm.org> <20090806133746.GA28557@gondor.apana.org.au> <m1ljlxj9vi.fsf@fess.ebiederm.org> <20090806143959.GA29323@gondor.apana.org.au> <m1zladhtoh.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Moore <paul.moore@hp.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55539 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751712AbZHGAWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 20:22:50 -0400
Content-Disposition: inline
In-Reply-To: <m1zladhtoh.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 06, 2009 at 08:02:22AM -0700, Eric W. Biederman wrote:
> 
> Why not?  We can sleep on that code path.
> Although now that you mention it we should use unlocked_ioctl unless
> we actually need the BKL.

You're right of course.  So the race is real, but I think there
is no good reason for such parallel operations to be allowed in
the first place.  So how about extending the coverage of the
locked section to the whole ioctl, like this:

tun: Extend RTNL lock coverage over whole ioctl

As it is, parts of the ioctl runs under the RTNL and parts of
it do not.  The unlocked section is still protected by the BKL,
but there can be subtle races.  For example, Eric Biederman and
Paul Moore observed that if two threads tried to create two tun
devices on the same file descriptor, then unexpected results
may occur.

As there isn't anything in the ioctl that is expected to sleep
indefinitely, we can prevent this from occurring by extending
the RTNL lock coverage.

This also allows to get rid of the BKL.

Finally, I changed tun_get_iff to take a tun device in order to
avoid calling tun_put which would dead-lock as it also tries to
take the RTNL lock.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 027f7ab..42b6c63 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1048,20 +1048,15 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 	return err;
 }
 
-static int tun_get_iff(struct net *net, struct file *file, struct ifreq *ifr)
+static int tun_get_iff(struct net *net, struct tun_struct *tun,
+		       struct ifreq *ifr)
 {
-	struct tun_struct *tun = tun_get(file);
-
-	if (!tun)
-		return -EBADFD;
-
 	DBG(KERN_INFO "%s: tun_get_iff\n", tun->dev->name);
 
 	strcpy(ifr->ifr_name, tun->dev->name);
 
 	ifr->ifr_flags = tun_flags(tun);
 
-	tun_put(tun);
 	return 0;
 }
 
@@ -1105,8 +1100,8 @@ static int set_offload(struct net_device *dev, unsigned long arg)
 	return 0;
 }
 
-static int tun_chr_ioctl(struct inode *inode, struct file *file,
-			 unsigned int cmd, unsigned long arg)
+static long tun_chr_ioctl(struct file *file, unsigned int cmd,
+			  unsigned long arg)
 {
 	struct tun_file *tfile = file->private_data;
 	struct tun_struct *tun;
@@ -1128,34 +1123,32 @@ static int tun_chr_ioctl(struct inode *inode, struct file *file,
 				(unsigned int __user*)argp);
 	}
 
+	rtnl_lock();
+
 	tun = __tun_get(tfile);
 	if (cmd == TUNSETIFF && !tun) {
-		int err;
-
 		ifr.ifr_name[IFNAMSIZ-1] = '\0';
 
-		rtnl_lock();
-		err = tun_set_iff(tfile->net, file, &ifr);
-		rtnl_unlock();
+		ret = tun_set_iff(tfile->net, file, &ifr);
 
-		if (err)
-			return err;
+		if (ret)
+			goto unlock;
 
 		if (copy_to_user(argp, &ifr, sizeof(ifr)))
-			return -EFAULT;
-		return 0;
+			ret = -EFAULT;
+		goto unlock;
 	}
 
-
+	ret = -EBADFD;
 	if (!tun)
-		return -EBADFD;
+		goto unlock;
 
 	DBG(KERN_INFO "%s: tun_chr_ioctl cmd %d\n", tun->dev->name, cmd);
 
 	ret = 0;
 	switch (cmd) {
 	case TUNGETIFF:
-		ret = tun_get_iff(current->nsproxy->net_ns, file, &ifr);
+		ret = tun_get_iff(current->nsproxy->net_ns, tun, &ifr);
 		if (ret)
 			break;
 
@@ -1201,7 +1194,6 @@ static int tun_chr_ioctl(struct inode *inode, struct file *file,
 
 	case TUNSETLINK:
 		/* Only allow setting the type when the interface is down */
-		rtnl_lock();
 		if (tun->dev->flags & IFF_UP) {
 			DBG(KERN_INFO "%s: Linktype set failed because interface is up\n",
 				tun->dev->name);
@@ -1211,7 +1203,6 @@ static int tun_chr_ioctl(struct inode *inode, struct file *file,
 			DBG(KERN_INFO "%s: linktype set to %d\n", tun->dev->name, tun->dev->type);
 			ret = 0;
 		}
-		rtnl_unlock();
 		break;
 
 #ifdef TUN_DEBUG
@@ -1220,9 +1211,7 @@ static int tun_chr_ioctl(struct inode *inode, struct file *file,
 		break;
 #endif
 	case TUNSETOFFLOAD:
-		rtnl_lock();
 		ret = set_offload(tun->dev, arg);
-		rtnl_unlock();
 		break;
 
 	case TUNSETTXFILTER:
@@ -1230,9 +1219,7 @@ static int tun_chr_ioctl(struct inode *inode, struct file *file,
 		ret = -EINVAL;
 		if ((tun->flags & TUN_TYPE_MASK) != TUN_TAP_DEV)
 			break;
-		rtnl_lock();
 		ret = update_filter(&tun->txflt, (void __user *)arg);
-		rtnl_unlock();
 		break;
 
 	case SIOCGIFHWADDR:
@@ -1248,9 +1235,7 @@ static int tun_chr_ioctl(struct inode *inode, struct file *file,
 		DBG(KERN_DEBUG "%s: set hw address: %pM\n",
 			tun->dev->name, ifr.ifr_hwaddr.sa_data);
 
-		rtnl_lock();
 		ret = dev_set_mac_address(tun->dev, &ifr.ifr_hwaddr);
-		rtnl_unlock();
 		break;
 
 	case TUNGETSNDBUF:
@@ -1273,7 +1258,10 @@ static int tun_chr_ioctl(struct inode *inode, struct file *file,
 		break;
 	};
 
-	tun_put(tun);
+unlock:
+	rtnl_unlock();
+	if (tun)
+		tun_put(tun);
 	return ret;
 }
 
@@ -1361,7 +1349,7 @@ static const struct file_operations tun_fops = {
 	.write = do_sync_write,
 	.aio_write = tun_chr_aio_write,
 	.poll	= tun_chr_poll,
-	.ioctl	= tun_chr_ioctl,
+	.unlocked_ioctl = tun_chr_ioctl,
 	.open	= tun_chr_open,
 	.release = tun_chr_close,
 	.fasync = tun_chr_fasync

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
