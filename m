From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: Frequent Oops on Shutdown 2.6.10
Date: Wed, 23 Feb 2005 18:35:55 +0900 (JST)
Message-ID: <20050223.183555.80618945.yoshfuji@linux-ipv6.org>
References: <20050221.162949.65179228.yoshfuji@linux-ipv6.org>
	<E1D3Wn9-00071h-00@gondolin.me.apana.org.au>
	<20050222101526.GA5814@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: AndyLiebman@aol.com, terryg@axian.com, netdev@oss.sgi.com,
        davem@davemloft.net, akpm@osdl.org, yoshfuji@linux-ipv6.org
To: herbert@gondor.apana.org.au
In-Reply-To: <20050222101526.GA5814@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20050222101526.GA5814@gondor.apana.org.au> (at Tue, 22 Feb 2005 21:15:26 +1100), Herbert Xu <herbert@gondor.apana.org.au> says:

> On Tue, Feb 22, 2005 at 08:57:19PM +1100, Herbert Xu wrote:
> > YOSHIFUJI Hideaki / ???? <yoshfuji@linux-ipv6.org> wrote:
> > > In article <20050221.162241.24618885.yoshfuji@linux-ipv6.org> (at Mon, 21 Feb 2005 16:22:41 +0900 (JST)), YOSHIFUJI Hideaki / ???? <yoshfuji@linux-ipv6.org> says:
> > > 
> > >> [IPV6] Don't remove dev_snmp6 procfs entry until all users gone.
> > 
> > Sorry, but I don't see how this patch explains the oops the
> > people saw.
:
> I see two solutions:
> 
> 1) Unregister the proc entry earlier.  In other words, do it in
> addrconf_ifdown.  Since this is highly serialised it means that
> we can't add the new proc entry before the old proc entry has
> been deleted.

Okay, it sounds reasonable.

What do you think of this?

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

===== include/net/ipv6.h 1.42 vs edited =====
--- 1.42/include/net/ipv6.h	2005-01-15 06:30:07 +09:00
+++ edited/include/net/ipv6.h	2005-02-23 17:10:38 +09:00
@@ -149,6 +149,8 @@
 
 int snmp6_register_dev(struct inet6_dev *idev);
 int snmp6_unregister_dev(struct inet6_dev *idev);
+int snmp6_alloc_dev(struct inet6_dev *idev);
+int snmp6_free_dev(struct inet6_dev *idev);
 int snmp6_mib_init(void *ptr[2], size_t mibsize, size_t mibalign);
 void snmp6_mib_free(void *ptr[2]);
 
===== net/ipv6/addrconf.c 1.129 vs edited =====
--- 1.129/net/ipv6/addrconf.c	2005-01-18 06:13:31 +09:00
+++ edited/net/ipv6/addrconf.c	2005-02-23 17:59:56 +09:00
@@ -308,7 +308,7 @@
 		printk("Freeing alive inet6 device %p\n", idev);
 		return;
 	}
-	snmp6_unregister_dev(idev);
+	snmp6_free_dev(idev);
 	kfree(idev);
 }
 
@@ -339,6 +339,16 @@
 		/* We refer to the device */
 		dev_hold(dev);
 
+		if (snmp6_alloc_dev(ndev) < 0) {
+			ADBG((KERN_WARNING
+				"%s(): cannot allocate memory for statistics; dev=%s.\n",
+				__FUNCTION__, dev->name));
+			neigh_parms_release(&nd_tbl, ndev->nd_parms);
+			ndev->dead = 1;
+			in6_dev_finish_destroy(ndev);
+			return NULL;
+		}
+
 		if (snmp6_register_dev(ndev) < 0) {
 			ADBG((KERN_WARNING
 				"%s(): cannot create /proc/net/dev_snmp6/%s\n",
@@ -2013,6 +2023,10 @@
 		dev->ip6_ptr = NULL;
 		idev->dead = 1;
 		write_unlock_bh(&addrconf_lock);
+
+		/* Step 1.5: remove snmp6 entry */
+		snmp6_unregister_dev(idev);
+
 	}
 
 	/* Step 2: clear hash table */
===== net/ipv6/proc.c 1.25 vs edited =====
--- 1.25/net/ipv6/proc.c	2004-07-08 07:17:29 +09:00
+++ edited/net/ipv6/proc.c	2005-02-23 18:05:27 +09:00
@@ -201,33 +201,23 @@
 
 int snmp6_register_dev(struct inet6_dev *idev)
 {
-	int err = -ENOMEM;
 	struct proc_dir_entry *p;
 
 	if (!idev || !idev->dev)
 		return -EINVAL;
 
-	if (snmp6_mib_init((void **)idev->stats.icmpv6, sizeof(struct icmpv6_mib),
-			   __alignof__(struct icmpv6_mib)) < 0)
-		goto err_icmp;
+	if (!proc_net_devsnmp6)
+		return -ENOENT;
 
-	if (!proc_net_devsnmp6) {
-		err = -ENOENT;
-		goto err_proc;
-	}
 	p = create_proc_entry(idev->dev->name, S_IRUGO, proc_net_devsnmp6);
 	if (!p)
-		goto err_proc;
+		return -ENOMEM;
+
 	p->data = idev;
 	p->proc_fops = &snmp6_seq_fops;
 
 	idev->stats.proc_dir_entry = p;
 	return 0;
-
-err_proc:
-	snmp6_mib_free((void **)idev->stats.icmpv6);
-err_icmp:
-	return err;
 }
 
 int snmp6_unregister_dev(struct inet6_dev *idev)
@@ -238,8 +228,6 @@
 		return -EINVAL;
 	remove_proc_entry(idev->stats.proc_dir_entry->name,
 			  proc_net_devsnmp6);
-	snmp6_mib_free((void **)idev->stats.icmpv6);
-
 	return 0;
 }
 
@@ -274,12 +262,21 @@
 	proc_net_remove("dev_snmp6");
 	proc_net_remove("snmp6");
 }
-
 #else	/* CONFIG_PROC_FS */
 
-
 int snmp6_register_dev(struct inet6_dev *idev)
 {
+	return 0;
+}
+
+int snmp6_unregister_dev(struct inet6_dev *idev)
+{
+	return 0;
+}
+#endif	/* CONFIG_PROC_FS */
+
+int snmp6_alloc_dev(struct inet6_dev *idev)
+{
 	int err = -ENOMEM;
 
 	if (!idev || !idev->dev)
@@ -295,11 +292,10 @@
 	return err;
 }
 
-int snmp6_unregister_dev(struct inet6_dev *idev)
+int snmp6_free_dev(struct inet6_dev *idev)
 {
 	snmp6_mib_free((void **)idev->stats.icmpv6);
 	return 0;
 }
 
-#endif
 

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
