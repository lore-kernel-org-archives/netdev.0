From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: dev->destructor
Date: Wed, 30 Apr 2003 09:33:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030430093303.2e80e7ad.shemminger@osdl.org>
References: <20030429.232631.68131803.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030429.232631.68131803.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 29 Apr 2003 23:26:31 -0700 (PDT)
"David S. Miller" <davem@redhat.com> wrote:

> 
> Stephen, you're right about the dev->destructor problem.
> I misread your postings, and I'm very sorry about that.
> We were talking about two different things, and admittedly
> I had forgotten how some of this stuff works.
> 
> Alexey, currently dev->{open,close} are what does get/put
> of device module reference.
> 
> However, device unregister can explode if dev->destructor is
> present.  Unlike in dev->destructor==NULL case, we do not
> wait for remnant dev->refcnt to go away.  Therefore we could
> invoke dev->destructor() after module is unloaded.
> 
> I guess there are two ways to address this problem:
> 
> 1) dev_get() gets module reference and dev_put() puts is.
>    Ugly, as this means dev_get() can fail, but this does
>    cover all the possible cases.
> 
> 2) Make unregister_netdev() wait for refcount to reach 1
>    regardless of whether dev->destructor is NULL or not.
> 
> I don't like #1.  Do you see some holes in #2?
> 
> As Stephen brought up, this also means we should do something
> about that NETDEV_UNREGISTER code in dst_dev_event() :-(

There are other (not nice possibilities).

A) Require driver have a wait queue per device and wait after unregister.
   Ugly and requires repeated work.

B) Put wait queue and wakeup logic in netdevice/unregister_netdev.
   Adds more to already overloaded netdevice structure, but
   could cleanup existing polling stuff.

C) Audit unregister notifier callbacks to ensure they all dev_put,
   all references to device.  This works for 
   normal IPv4 except for the dst cache.  The following patch causes
   the dst cache to do this.

--- linux-2.5/net/core/dst.c	2003-04-29 11:54:39.000000000 -0700
+++ linux-2.5-bridge/net/core/dst.c	2003-04-29 10:17:15.000000000 -0700
@@ -228,7 +228,7 @@
 				   _race_ _condition_.
 				 */
 				if (event!=NETDEV_DOWN &&
-				    dev->destructor == NULL &&
+				    (dev->destructor == NULL  || dev->owner) &&
 				    dst->output == dst_blackhole) {
 					dst->dev = &loopback_dev;
 					dev_put(dev);

D) Your option #2 only needs to be done if device is a module
   otherwise, can just let destructor run later.

--- linux-2.5/net/core/dev.c	2003-04-29 11:54:39.000000000 -0700
+++ linux-2.5-bridge/net/core/dev.c	2003-04-30 09:28:34.000000000 -0700
@@ -2737,7 +2737,7 @@
 	free_divert_blk(dev);
 #endif
 
-	if (dev->destructor != NULL) {
+	if (dev->destructor != NULL && dev->owner == NULL) {
 #ifdef NET_REFCNT_DEBUG
 		if (atomic_read(&dev->refcnt) != 1)
 			printk(KERN_DEBUG "unregister_netdevice: holding %s "
