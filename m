From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Move inetdev/ifa over to RCU
Date: Sat, 14 Aug 2004 07:56:02 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040813215602.GA15870@gondor.apana.org.au>
References: <20040812165954.00429e65.davem@redhat.com> <20040813090314.448c971d@dell_ss3.pdx.osdl.net> <20040813093838.6961c0d4.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="LZvS9be/3tNcYl/X"
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040813093838.6961c0d4.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--LZvS9be/3tNcYl/X
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Aug 13, 2004 at 09:38:38AM -0700, David S. Miller wrote:
> 
> Herbert, if we check inetdev->dead when trying to grab
> a reference it fixes the RCU destroy race you mentioned.

Sorry Dave but that just makes the window smaller.  A new
inetdev_destroy() can still start after the in_dev->dead
check and before the inc of the refcnt.

> I really don't want to put that ref drop into the
> RCU callback as that would kill performance.

Maybe I wasn't clear enough about the solution.  I've attached
an untested patch below.  Hopefully that should make it clearer.

> diff -Nru a/include/linux/inetdevice.h b/include/linux/inetdevice.h
> --- a/include/linux/inetdevice.h	2004-08-13 09:20:01 -07:00
> +++ b/include/linux/inetdevice.h	2004-08-13 09:20:01 -07:00
> @@ -143,9 +143,14 @@
>  	struct in_device *in_dev;
>  
>  	rcu_read_lock();
> +	smp_read_barrier_depends();

This isn't quite right either.  It rarely makes sense to have
smp_read_barrier_depends() immediately after an rcu_read_lock()
since it can't be reordered.

Now had you put this barrier between the reading of ip_ptr and
the checking of in_dev->dead, then the race would've been closed.

But I still prefer to move the work into inetdev_destroy.

>  	in_dev = dev->ip_ptr;
> -	if (in_dev)
> -		atomic_inc(&in_dev->refcnt);
> +	if (in_dev) {
> +		if (in_dev->dead)
> +			in_dev = NULL;
> +		else
> +			atomic_inc(&in_dev->refcnt);
> +	}
>  	rcu_read_unlock();
>  	return in_dev;
>  }

> diff -Nru a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> --- a/net/ipv4/devinet.c	2004-08-13 09:20:01 -07:00
> +++ b/net/ipv4/devinet.c	2004-08-13 09:20:01 -07:00
> @@ -210,6 +210,7 @@
>  int inet_addr_onlink(struct in_device *in_dev, u32 a, u32 b)
>  {
>  	rcu_read_lock();
> +	smp_read_barrier_depends();
>  	for_primary_ifa(in_dev) {
>  		if (inet_ifa_match(a, ifa)) {
>  			if (!b || inet_ifa_match(b, ifa)) {

Ditto.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--LZvS9be/3tNcYl/X
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== include/linux/inetdevice.h 1.14 vs edited =====
--- 1.14/include/linux/inetdevice.h	2004-08-14 07:43:21 +10:00
+++ edited/include/linux/inetdevice.h	2004-08-14 07:48:59 +10:00
@@ -163,16 +163,10 @@
 
 extern void in_dev_finish_destroy(struct in_device *idev);
 
-static inline void in_dev_rcu_destroy(struct rcu_head *head)
-{
-	struct in_device *idev = container_of(head, struct in_device, rcu_head);
-	in_dev_finish_destroy(idev);
-}
-
 static inline void in_dev_put(struct in_device *idev)
 {
 	if (atomic_dec_and_test(&idev->refcnt))
-		call_rcu(&idev->rcu_head, in_dev_rcu_destroy);
+		in_dev_finish_destroy(idev);
 }
 
 #define __in_dev_put(idev)  atomic_dec(&(idev)->refcnt)
===== net/ipv4/devinet.c 1.33 vs edited =====
--- 1.33/net/ipv4/devinet.c	2004-08-14 07:43:21 +10:00
+++ edited/net/ipv4/devinet.c	2004-08-14 07:49:51 +10:00
@@ -177,6 +177,12 @@
 	goto out;
 }
 
+static void in_dev_rcu_put(struct rcu_head *head)
+{
+	struct in_device *idev = container_of(head, struct in_device, rcu_head);
+	in_dev_put(idev);
+}
+
 static void inetdev_destroy(struct in_device *in_dev)
 {
 	struct in_ifaddr *ifa;
@@ -204,7 +210,7 @@
 	neigh_sysctl_unregister(in_dev->arp_parms);
 #endif
 	neigh_parms_release(&arp_tbl, in_dev->arp_parms);
-	in_dev_put(in_dev);
+	call_rcu(&idev->rcu_head, in_dev_rcu_put);
 }
 
 int inet_addr_onlink(struct in_device *in_dev, u32 a, u32 b)

--LZvS9be/3tNcYl/X--
