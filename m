From: "Paul Rolland" <rol@as2917.net>
Subject: Re: [BUG]:   problem when shutting down ppp connection since 2.5.70
Date: Mon, 14 Jul 2003 11:16:04 +0200
Sender: linux-ppp-owner@vger.kernel.org
Message-ID: <017701c349e8$8dfeeb40$2101a8c0@witbe>
References: <20030709114334.5b8cf7c6.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <linux-ppp@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
To: "'Stephen Hemminger'" <shemminger@osdl.org>,
	<cfriesen@nortelnetworks.com>, <paulus@samba.org>
In-Reply-To: <20030709114334.5b8cf7c6.shemminger@osdl.org>
List-Id: netdev.vger.kernel.org

Hello,

I've applied the patch from Stephen on top of the 2.6.0-test1 kernel,
and here is the result :

Jul 14 10:57:01 donald kernel: dst route cache has 0 references
Jul 14 10:57:01 donald kernel: unregister_netdevice: waiting for tap0 to become free. Usage count = -3
Jul 14 10:57:10 donald kernel: dst route cache has 0 references
Jul 14 10:57:10 donald kernel: unregister_netdevice: waiting for tap0 to become free. Usage count = -3
Jul 14 10:57:20 donald kernel: dst route cache has 0 references
Jul 14 10:57:20 donald kernel: unregister_netdevice: waiting for tap0 to become free. Usage count = -3
Jul 14 10:57:31 donald kernel: dst route cache has 0 references
Jul 14 10:57:31 donald kernel: unregister_netdevice: waiting for tap0 to become free. Usage count = -3

This is a big change compared to 2.5.74 (.75 not tested).

I guess a negative usage count should be considered as valid
by unregister_netdevice.

What about :

--- dev.c       2003-07-14 11:13:23.000000000 +0200
+++ dev.c.orig  2003-07-14 11:13:01.000000000 +0200
@@ -2746,7 +2746,7 @@
        unsigned long rebroadcast_time, warning_time;
 
        rebroadcast_time = warning_time = jiffies;
-       while (atomic_read(&dev->refcnt) > 0) {
+       while (atomic_read(&dev->refcnt) != 0) {
                if (time_after(jiffies, rebroadcast_time + 1 * HZ)) {
                        rtnl_shlock();
                        rtnl_exlock();

Regards,
Paul

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
REHAB is for quitters. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


Paul Rolland, rol@witbe.net
Witbe.net SA
Directeur Associe

--

Please no HTML, I'm not a browser - Pas d'HTML, je ne suis pas un navigateur

"Some people dream of success... while others wake up and work hard at it"

> -----Original Message-----
> From: Stephen Hemminger [mailto:shemminger@osdl.org]
> Sent: Wednesday, July 09, 2003 8:44 PM
> To: Paul Rolland; cfriesen@nortelnetworks.com; paulus@samba.org
> Cc: linux-ppp@vger.kernel.org; netdev@oss.sgi.com
> Subject: Re: [BUG]: problem when shutting down ppp connection
> since 2.5.70
> 
> 
> The problem is that some protocol is still holding a reference to the 
> device. This is a bug in the protocol, and needs to be fixed (ie not a 
> ppp bug).
> 
> Try building a kernel with only IPv4, eliminate all others then add 
> back until you find the culprit.
> 
> The following patch may help also.
> 
> diff -Nru a/net/core/dev.c b/net/core/dev.c
> --- a/net/core/dev.c	Wed Jul  9 11:40:56 2003
> +++ b/net/core/dev.c	Wed Jul  9 11:40:56 2003
> @@ -72,6 +72,8 @@
>   *				        - netif_rx() feedback
>   */
>  
> +#define DEBUG 1
> +
>  #include <asm/uaccess.h>
>  #include <asm/system.h>
>  #include <asm/bitops.h>
> @@ -2704,6 +2706,8 @@
>  	goto out;
>  }
>  
> +extern void dst_dumpref(const struct net_device *dev);
> +
>  static void netdev_wait_allrefs(struct net_device *dev)
>  {
>  	unsigned long rebroadcast_time, warning_time;
> @@ -2740,6 +2744,30 @@
>  		current->state = TASK_RUNNING;
>  
>  		if (time_after(jiffies, warning_time + 10 * HZ)) {
> +#ifdef DEBUG
> +			dst_dumpref(dev);
> +
> +			if (dev->atalk_ptr)
> +				printk(KERN_INFO
> "unregister_netdevice: "
> +				       " %s: probably in use as
> AppleTalk device\n", dev->name);
> +			if (dev->ip_ptr)
> +				printk(KERN_INFO
> "unregister_netdevice: "
> +				       " %s: probably in use as
> IPv4 device\n", dev->name);
> +
> +			if (dev->atalk_ptr)
> +				printk(KERN_INFO
> "unregister_netdevice: "
> +				       " %s: probably in use as
> DECnet device\n", dev->name);
> +			if (dev->ip6_ptr)
> +				printk(KERN_INFO
> "unregister_netdevice: "
> +				       " %s: probably in use as
> IPv6 device\n", dev->name);
> +
> +			if (dev->ec_ptr)
> +				printk(KERN_INFO
> "unregister_netdevice: "
> +				       " %s: probably in use as
> Econet device\n", dev->name);
> +			if (dev->ax25_ptr)
> +				printk(KERN_INFO
> "unregister_netdevice: "
> +				       " %s: probably in use as
> AX.25 device\n", dev->name); #endif
>  			printk(KERN_EMERG "unregister_netdevice: "
>  			       "waiting for %s to become free. Usage "
>  			       "count = %d\n",
> diff -Nru a/net/core/dst.c b/net/core/dst.c
> --- a/net/core/dst.c	Wed Jul  9 11:40:56 2003
> +++ b/net/core/dst.c	Wed Jul  9 11:40:56 2003
> @@ -41,6 +41,21 @@
>  static struct timer_list dst_gc_timer =
>  	TIMER_INITIALIZER(dst_run_gc, 0, DST_GC_MIN);
>  
> +
> +void dst_dumpref(const struct net_device *dev)
> +{
> +	struct dst_entry *dst;
> +	int count = 0;
> +
> +	spin_lock_bh(&dst_lock);
> +	for (dst = dst_garbage_list; dst; dst = dst->next) {
> +		if (dst->dev == dev) ++count;
> +	}
> +	spin_unlock_bh(&dst_lock);
> +
> +	printk(KERN_INFO "dst route cache has %d references\n",
> count); }
> +
>  static void dst_run_gc(unsigned long dummy)
>  {
>  	int    delayed = 0;
> 

