From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPV4] Make loopback idev stick around
Date: Wed, 16 Feb 2005 21:12:45 +1100
Message-ID: <20050216101245.GA32341@gondor.apana.org.au>
References: <20050205053030.GA17412@gondor.apana.org.au> <20050205053532.GA17474@gondor.apana.org.au> <20050215144121.702767c5.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="LQksG6bCIzRHxTLp"
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050215144121.702767c5.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Feb 15, 2005 at 02:41:21PM -0800, David S. Miller wrote:
> 
> I wish ->notifier_call()'s value was actually checked, we could
> do intelligent things instead of panic()'ing when (for example)
> loopback's idev allocation fails.

Yes I missed the ipv6 module case.  It would be very nice to be able
to return errors there.

Since we initiate the loopback registration from addrconf_init,
perhaps we can get away for the time being by checking the error
there?

Let's also clean up loopback's ipv6 structure in addrconf_cleanup
even though it never happens currently :)

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== include/net/addrconf.h 1.22 vs edited =====
--- 1.22/include/net/addrconf.h	2005-01-15 08:30:07 +11:00
+++ edited/include/net/addrconf.h	2005-02-16 21:01:59 +11:00
@@ -49,7 +49,7 @@
 
 #define IN6_ADDR_HSIZE		16
 
-extern void			addrconf_init(void);
+extern int			addrconf_init(void);
 extern void			addrconf_cleanup(void);
 
 extern int			addrconf_add_ifaddr(void __user *arg);
===== net/ipv6/addrconf.c 1.130 vs edited =====
--- 1.130/net/ipv6/addrconf.c	2005-02-16 09:10:14 +11:00
+++ edited/net/ipv6/addrconf.c	2005-02-16 21:01:40 +11:00
@@ -1914,11 +1914,6 @@
 	struct inet6_dev *idev = __in6_dev_get(dev);
 
 	switch(event) {
-	case NETDEV_REGISTER:
-		if (dev == &loopback_dev && !ipv6_find_idev(dev))
-			panic("addrconf: Failed to create loopback\n");
-		break;
-
 	case NETDEV_UP:
 		switch(dev->type) {
 		case ARPHRD_SIT:
@@ -2003,7 +1998,7 @@
 
 	ASSERT_RTNL();
 
-	if (dev == &loopback_dev)
+	if (dev == &loopback_dev && how == 1)
 		how = 0;
 
 	rt6_ifdown(dev);
@@ -3432,8 +3427,10 @@
  *	Init / cleanup code
  */
 
-void __init addrconf_init(void)
+int __init addrconf_init(void)
 {
+	int err = 0;
+
 	/* The addrconf netdev notifier requires that loopback_dev
 	 * has it's ipv6 private information allocated and setup
 	 * before it can bring up and give link-local addresses
@@ -3447,13 +3444,17 @@
 	 * first, then loopback_dev, which cases all the non-loopback_dev
 	 * devices to fail to get a link-local address.
 	 *
-	 * So, as a temporary fix, register loopback_dev first by hand.
+	 * So, as a temporary fix, allocate the ipv6 structure for
+	 * loopback_dev first by hand.
 	 * Longer term, all of the dependencies ipv6 has upon the loopback
 	 * device and it being up should be removed.
 	 */
 	rtnl_lock();
-	addrconf_notify(&ipv6_dev_notf, NETDEV_REGISTER, &loopback_dev);
+	if (!ipv6_add_dev(&loopback_dev))
+		err = -ENOMEM;
 	rtnl_unlock();
+	if (err)
+		return err;
 
 	register_netdevice_notifier(&ipv6_dev_notf);
 
@@ -3471,6 +3472,8 @@
 		register_sysctl_table(addrconf_sysctl.addrconf_root_dir, 0);
 	addrconf_sysctl_register(NULL, &ipv6_devconf_dflt);
 #endif
+
+	return 0;
 }
 
 void __exit addrconf_cleanup(void)
@@ -3499,6 +3502,7 @@
 			continue;
 		addrconf_ifdown(dev, 1);
 	}
+	addrconf_ifdown(&loopback_dev, 2);
 
 	/*
 	 *	Check hash table.
===== net/ipv6/af_inet6.c 1.88 vs edited =====
--- 1.88/net/ipv6/af_inet6.c	2005-01-14 15:41:05 +11:00
+++ edited/net/ipv6/af_inet6.c	2005-02-16 20:54:25 +11:00
@@ -782,7 +782,9 @@
 	ipv6_packet_init();
 	ip6_route_init();
 	ip6_flowlabel_init();
-	addrconf_init();
+	err = addrconf_init();
+	if (err)
+		goto addrconf_fail;
 	sit_init();
 
 	/* Init v6 extension headers. */
@@ -798,7 +800,12 @@
 out:
 	return err;
 
+addrconf_fail:
+	ip6_flowlabel_cleanup();
+	ip6_route_cleanup();
+	ipv6_packet_cleanup();
 #ifdef CONFIG_PROC_FS
+	if6_proc_exit();
 proc_if6_fail:
 	ac6_proc_exit();
 proc_anycast6_fail:
@@ -810,8 +817,8 @@
 proc_tcp6_fail:
 	raw6_proc_exit();
 proc_raw6_fail:
-	igmp6_cleanup();
 #endif
+	igmp6_cleanup();
 igmp_fail:
 	ndisc_cleanup();
 ndisc_fail:

--LQksG6bCIzRHxTLp--
