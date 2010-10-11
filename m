From: Samuel Ortiz <samuel@sortiz.org>
Subject: [PATCH net-next 2/5] irda: Remove BKL instances from irnet
Date: Mon, 11 Oct 2010 02:24:59 +0200
Message-ID: <f8cba16cad68c9b9ee7fecae48a1b91708e8e482.1286756123.git.sameo@linux.intel.com>
References: <cover.1286756123.git.sameo@linux.intel.com>
Cc: netdev@vger.kernel.org, Samuel Ortiz <samuel@sortiz.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:23906 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750842Ab0JKAZq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Oct 2010 20:25:46 -0400
In-Reply-To: <cover.1286756123.git.sameo@linux.intel.com>
In-Reply-To: <cover.1286756123.git.sameo@linux.intel.com>
References: <cover.1286756123.git.sameo@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code intends to lock the irnet_socket, so adding a mutex to it allows
for a complet BKL removal.

Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
---
 net/irda/irnet/irnet.h     |    2 +
 net/irda/irnet/irnet_ppp.c |   61 ++++++++++++++++++++++++++++++-------------
 2 files changed, 44 insertions(+), 19 deletions(-)

diff --git a/net/irda/irnet/irnet.h b/net/irda/irnet/irnet.h
index 4300df3..0d82ff5 100644
--- a/net/irda/irnet/irnet.h
+++ b/net/irda/irnet/irnet.h
@@ -458,6 +458,8 @@ typedef struct irnet_socket
   int			disco_index;	/* Last read in the discovery log */
   int			disco_number;	/* Size of the discovery log */
 
+  struct mutex		lock;
+
 } irnet_socket;
 
 /*
diff --git a/net/irda/irnet/irnet_ppp.c b/net/irda/irnet/irnet_ppp.c
index 69f1fa6..0993bd4 100644
--- a/net/irda/irnet/irnet_ppp.c
+++ b/net/irda/irnet/irnet_ppp.c
@@ -480,7 +480,6 @@ dev_irnet_open(struct inode *	inode,
   ap = kzalloc(sizeof(*ap), GFP_KERNEL);
   DABORT(ap == NULL, -ENOMEM, FS_ERROR, "Can't allocate struct irnet...\n");
 
-  lock_kernel();
   /* initialize the irnet structure */
   ap->file = file;
 
@@ -502,18 +501,20 @@ dev_irnet_open(struct inode *	inode,
     {
       DERROR(FS_ERROR, "Can't setup IrDA link...\n");
       kfree(ap);
-      unlock_kernel();
+
       return err;
     }
 
   /* For the control channel */
   ap->event_index = irnet_events.index;	/* Cancel all past events */
 
+  mutex_init(&ap->lock);
+
   /* Put our stuff where we will be able to find it later */
   file->private_data = ap;
 
   DEXIT(FS_TRACE, " - ap=0x%p\n", ap);
-  unlock_kernel();
+
   return 0;
 }
 
@@ -664,7 +665,9 @@ dev_irnet_ioctl(
 	{
 	  DEBUG(FS_INFO, "Entering PPP discipline.\n");
 	  /* PPP channel setup (ap->chan in configued in dev_irnet_open())*/
-	  lock_kernel();
+	  if (mutex_lock_interruptible(&ap->lock))
+		  return -EINTR;
+
 	  err = ppp_register_channel(&ap->chan);
 	  if(err == 0)
 	    {
@@ -677,14 +680,17 @@ dev_irnet_ioctl(
 	    }
 	  else
 	    DERROR(FS_ERROR, "Can't setup PPP channel...\n");
-          unlock_kernel();
+
+          mutex_unlock(&ap->lock);
 	}
       else
 	{
 	  /* In theory, should be N_TTY */
 	  DEBUG(FS_INFO, "Exiting PPP discipline.\n");
 	  /* Disconnect from the generic PPP layer */
-	  lock_kernel();
+	  if (mutex_lock_interruptible(&ap->lock))
+		  return -EINTR;
+
 	  if(ap->ppp_open)
 	    {
 	      ap->ppp_open = 0;
@@ -693,24 +699,31 @@ dev_irnet_ioctl(
 	  else
 	    DERROR(FS_ERROR, "Channel not registered !\n");
 	  err = 0;
-	  unlock_kernel();
+
+	  mutex_unlock(&ap->lock);
 	}
       break;
 
       /* Query PPP channel and unit number */
     case PPPIOCGCHAN:
-      lock_kernel();
+      if (mutex_lock_interruptible(&ap->lock))
+	      return -EINTR;
+
       if(ap->ppp_open && !put_user(ppp_channel_index(&ap->chan),
 						(int __user *)argp))
 	err = 0;
-      unlock_kernel();
+
+      mutex_unlock(&ap->lock);
       break;
     case PPPIOCGUNIT:
-      lock_kernel();
+      if (mutex_lock_interruptible(&ap->lock))
+	      return -EINTR;
+
       if(ap->ppp_open && !put_user(ppp_unit_number(&ap->chan),
 						(int __user *)argp))
         err = 0;
-      unlock_kernel();
+
+      mutex_unlock(&ap->lock);
       break;
 
       /* All these ioctls can be passed both directly and from ppp_generic,
@@ -730,9 +743,12 @@ dev_irnet_ioctl(
       if(!capable(CAP_NET_ADMIN))
 	err = -EPERM;
       else {
-	lock_kernel();
+	if (mutex_lock_interruptible(&ap->lock))
+	      return -EINTR;
+
 	err = ppp_irnet_ioctl(&ap->chan, cmd, arg);
-	unlock_kernel();
+
+	mutex_unlock(&ap->lock);
       }
       break;
 
@@ -740,7 +756,9 @@ dev_irnet_ioctl(
       /* Get termios */
     case TCGETS:
       DEBUG(FS_INFO, "Get termios.\n");
-      lock_kernel();
+      if (mutex_lock_interruptible(&ap->lock))
+	      return -EINTR;
+
 #ifndef TCGETS2
       if(!kernel_termios_to_user_termios((struct termios __user *)argp, &ap->termios))
 	err = 0;
@@ -748,12 +766,15 @@ dev_irnet_ioctl(
       if(kernel_termios_to_user_termios_1((struct termios __user *)argp, &ap->termios))
 	err = 0;
 #endif
-      unlock_kernel();
+
+      mutex_unlock(&ap->lock);
       break;
       /* Set termios */
     case TCSETSF:
       DEBUG(FS_INFO, "Set termios.\n");
-      lock_kernel();
+      if (mutex_lock_interruptible(&ap->lock))
+	      return -EINTR;
+
 #ifndef TCGETS2
       if(!user_termios_to_kernel_termios(&ap->termios, (struct termios __user *)argp))
 	err = 0;
@@ -761,7 +782,8 @@ dev_irnet_ioctl(
       if(!user_termios_to_kernel_termios_1(&ap->termios, (struct termios __user *)argp))
 	err = 0;
 #endif
-      unlock_kernel();
+
+      mutex_unlock(&ap->lock);
       break;
 
       /* Set DTR/RTS */
@@ -784,9 +806,10 @@ dev_irnet_ioctl(
        * We should also worry that we don't accept junk here and that
        * we get rid of our own buffers */
 #ifdef FLUSH_TO_PPP
-      lock_kernel();
+      if (mutex_lock_interruptible(&ap->lock))
+	      return -EINTR;
       ppp_output_wakeup(&ap->chan);
-      unlock_kernel();
+      mutex_unlock(&ap->lock);
 #endif /* FLUSH_TO_PPP */
       err = 0;
       break;
-- 
1.7.1

