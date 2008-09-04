From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: BUG? locking issue(networking?) with latest git
Date: Thu, 4 Sep 2008 23:48:39 +0200
Message-ID: <20080904214839.GA2834@ami.dom.local>
References: <20080904072155.GA4691@ff.dom.local> <200809041246.11255.denys@visp.net.lb> <20080904100206.GB5407@ff.dom.local> <200809041714.05578.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:10513 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755019AbYIDVsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 17:48:46 -0400
Received: by fg-out-1718.google.com with SMTP id 19so547369fgg.17
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2008 14:48:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200809041714.05578.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 04, 2008 at 05:14:05PM +0300, Denys Fedoryshchenko wrote:
> On Thursday 04 September 2008, Jarek Poplawski wrote:
> > On Thu, Sep 04, 2008 at 12:46:11PM +0300, Denys Fedoryshchenko wrote:
> > ...
> >
> > > I tried to check for any additional logs, but there is nothing seems.
> > > Once i got softlockup for pppd, and server restarted. Other times it is
> > > just getting stuck on any network operations (ifconfig, pppd crashing in
> > > the middle, tc). I am not able to attach to processes by strace/gdb, so
> > > it is difficult to tell even on which point it does crash.
> >
> > BTW, I guess, it was checked with 2.6.26 (or .25) with the same config,
> > scripts and similar load and we are sure it's a really new bug?
> config, scripts and everything is completely same.
> It seems with nosmp i am getting watchdog fired (no messages over neconsole). 
> Probably one CPU becoming too busy in this case, and when it is single CPU - 
> such issue becoming critical and results in hardware watchdog triggering.

If this could behave like this with one CPU maybe some other time
other CPUs are not enough either, and it's not about locking? It would
be nice to monitor this load somehow then. On the other hand, if there
are no lockdep warnings you could probably turn it off to reduce the
overhead. BTW, since netconsole doesn't help much, you could do one
try without this too.

And to exclude some minimal doubts about last locking changes in
ppp_generic maybe you could try the patch below?

Jarek P.
---

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index ddccc07..b6b3a74 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -354,7 +354,6 @@ static const int npindex_to_ethertype[NUM_NP] = {
  */
 static int ppp_open(struct inode *inode, struct file *file)
 {
-	cycle_kernel_lock();
 	/*
 	 * This could (should?) be enforced by the permissions on /dev/ppp.
 	 */
@@ -547,7 +546,7 @@ static int get_filter(void __user *arg, struct sock_filter **p)
 }
 #endif /* CONFIG_PPP_FILTER */
 
-static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
+static long __ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 {
 	struct ppp_file *pf = file->private_data;
 	struct ppp *ppp;
@@ -575,7 +574,6 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		 * this fd and reopening /dev/ppp.
 		 */
 		err = -EINVAL;
-		lock_kernel();
 		if (pf->kind == INTERFACE) {
 			ppp = PF_TO_PPP(pf);
 			if (file == ppp->owner)
@@ -587,7 +585,6 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		} else
 			printk(KERN_DEBUG "PPPIOCDETACH file->f_count=%ld\n",
 			       atomic_long_read(&file->f_count));
-		unlock_kernel();
 		return err;
 	}
 
@@ -595,7 +592,6 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		struct channel *pch;
 		struct ppp_channel *chan;
 
-		lock_kernel();
 		pch = PF_TO_CHANNEL(pf);
 
 		switch (cmd) {
@@ -617,7 +613,6 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 				err = chan->ops->ioctl(chan, cmd, arg);
 			up_read(&pch->chan_sem);
 		}
-		unlock_kernel();
 		return err;
 	}
 
@@ -627,7 +622,6 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		return -EINVAL;
 	}
 
-	lock_kernel();
 	ppp = PF_TO_PPP(pf);
 	switch (cmd) {
 	case PPPIOCSMRU:
@@ -775,10 +769,18 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	default:
 		err = -ENOTTY;
 	}
-	unlock_kernel();
 	return err;
 }
 
+static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
+{
+	long ret;
+
+	lock_kernel();
+	ret = __ppp_ioctl(file, cmd, arg);
+	unlock_kernel();
+	return ret;
+}
 static int ppp_unattached_ioctl(struct ppp_file *pf, struct file *file,
 				unsigned int cmd, unsigned long arg)
 {
@@ -787,7 +789,6 @@ static int ppp_unattached_ioctl(struct ppp_file *pf, struct file *file,
 	struct channel *chan;
 	int __user *p = (int __user *)arg;
 
-	lock_kernel();
 	switch (cmd) {
 	case PPPIOCNEWUNIT:
 		/* Create a new ppp unit */
@@ -836,7 +837,6 @@ static int ppp_unattached_ioctl(struct ppp_file *pf, struct file *file,
 	default:
 		err = -ENOTTY;
 	}
-	unlock_kernel();
 	return err;
 }
 
