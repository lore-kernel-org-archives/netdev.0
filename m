From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Bug#251215: kernel-image-2.6.6-1-k7: pppd locks up, cannot be  killed, during ppp shutdown
Date: Sat, 29 May 2004 22:00:52 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1BU2WC-0003nd-00@gondolin.me.apana.org.au>
References: <20040529051736.GA11303@gondor.apana.org.au>
Cc: debian.bugs@kepier.clara.net, 251215@bugs.debian.org, shemminger@osdl.org,
        davem@redhat.com, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au (Herbert Xu)
In-Reply-To: <20040529051736.GA11303@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> OK, I've had a look and it looks like the free_netdev call in
> ppp_shutdown_inteface is the problem.  What's happening is that
> the todo list is being processed either on another CPU or by
> preemption in another context.  As a result when the subsequent
> free_netdev is called the device hasn't yet been processed and
> is still in state UNREGISTERING.
> 
> Why do we need to call free_netdev after unregistering the netdev
> from the drivers at all? What's wrong with calling it from run_todo
> itself?

Well I guess someone might want to reregister the net device :)

Here is a minimal fix for this problem.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
===== net/core/dev.c 1.141 vs edited =====
--- 1.141/net/core/dev.c	2004-05-23 06:45:55 +10:00
+++ edited/net/core/dev.c	2004-05-29 21:56:18 +10:00
@@ -2999,7 +2999,6 @@
 
 		case NETREG_UNREGISTERING:
 			netdev_unregister_sysfs(dev);
-			dev->reg_state = NETREG_UNREGISTERED;
 
 			netdev_wait_allrefs(dev);
 
@@ -3015,6 +3014,7 @@
 			 */
 			if (dev->destructor)
 				dev->destructor(dev);
+			class_device_put(&dev->class_dev);
 			break;
 
 		default:
@@ -3140,6 +3140,8 @@
 	free_divert_blk(dev);
 
 	/* Finish processing unregister after unlock */
+	dev->reg_state = NETREG_UNREGISTERED;
+	class_device_get(&dev->class_dev);
 	net_set_todo(dev);
 
 	dev_put(dev);
