From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] Panic in ipv6_add_dev
Date: Tue, 10 Jun 2003 13:56:01 +0900 (JST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030610.135601.20565349.yoshfuji@linux-ipv6.org>
References: <3EE52C92.4060509@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, krkumar@us.ibm.com
Return-path: <linux-net-owner@vger.kernel.org>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
In-Reply-To: <3EE52C92.4060509@us.ibm.com>
List-Id: netdev.vger.kernel.org

In article <3EE52C92.4060509@us.ibm.com> (at Mon, 09 Jun 2003 17:55:46 -0700), Krishna Kumar <krkumar@us.ibm.com> says:

> We need to initialize sysctl_table to NULL in neigh_parms_alloc so that a 
> release can be called safely at any time.

It solves the problem, patch should be applied.

Well, it is also the problem that the tasks of 
  neigh_parms_alloc() / neigh_sysctl_register()
and 
  neigh_parms_release() / neigh_sysctl_unregister()
were not symmetric.

We have neigh_parms_alloc() - neigh_parms_release() pair and
neigh_sysctl_register() - neigh_sysctl_unregister() pair.
Memory for sysctl table is allocated by neigh_sysctl_register().
While it was/is very natural to free it by neigh_sysctl_unregister(),
it was freed by neigh_parms_release(), in rather different context...

Here's the fix.
(This patch alone also solve the problem.)

Index: linux25-LINUS/net/netsyms.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/netsyms.c,v
retrieving revision 1.1.1.29
diff -u -r1.1.1.29 netsyms.c
--- linux25-LINUS/net/netsyms.c	31 May 2003 07:30:46 -0000	1.1.1.29
+++ linux25-LINUS/net/netsyms.c	10 Jun 2003 04:25:32 -0000
@@ -190,6 +190,7 @@
 #endif
 #ifdef CONFIG_SYSCTL
 EXPORT_SYMBOL(neigh_sysctl_register);
+EXPORT_SYMBOL(neigh_sysctl_unregister);
 #endif
 EXPORT_SYMBOL(pneigh_lookup);
 EXPORT_SYMBOL(pneigh_enqueue);
Index: linux25-LINUS/net/core/neighbour.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/core/neighbour.c,v
retrieving revision 1.1.1.7
diff -u -r1.1.1.7 neighbour.c
--- linux25-LINUS/net/core/neighbour.c	26 May 2003 08:04:08 -0000	1.1.1.7
+++ linux25-LINUS/net/core/neighbour.c	10 Jun 2003 04:25:32 -0000
@@ -1113,9 +1113,6 @@
 		if (*p == parms) {
 			*p = parms->next;
 			write_unlock_bh(&tbl->lock);
-#ifdef CONFIG_SYSCTL
-			neigh_sysctl_unregister(parms);
-#endif
 			kfree(parms);
 			return;
 		}
@@ -1178,9 +1175,6 @@
 		}
 	}
 	write_unlock(&neigh_tbl_lock);
-#ifdef CONFIG_SYSCTL
-	neigh_sysctl_unregister(&tbl->parms);
-#endif
 	return 0;
 }
 
Index: linux25-LINUS/net/ipv4/devinet.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv4/devinet.c,v
retrieving revision 1.1.1.10
diff -u -r1.1.1.10 devinet.c
--- linux25-LINUS/net/ipv4/devinet.c	26 May 2003 08:04:08 -0000	1.1.1.10
+++ linux25-LINUS/net/ipv4/devinet.c	10 Jun 2003 04:25:32 -0000
@@ -197,7 +197,9 @@
 	/* in_dev_put following below will kill the in_device */
 	write_unlock_bh(&inetdev_lock);
 
-
+#ifdef CONFIG_SYSCTL
+	neigh_sysctl_unregister(in_dev->arp_parms);
+#endif
 	neigh_parms_release(&arp_tbl, in_dev->arp_parms);
 	in_dev_put(in_dev);
 }
Index: linux25-LINUS/net/ipv6/addrconf.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/addrconf.c,v
retrieving revision 1.1.1.20
diff -u -r1.1.1.20 addrconf.c
--- linux25-LINUS/net/ipv6/addrconf.c	5 Jun 2003 07:47:43 -0000	1.1.1.20
+++ linux25-LINUS/net/ipv6/addrconf.c	10 Jun 2003 04:25:33 -0000
@@ -1925,10 +1925,11 @@
 	/* Shot the device (if unregistered) */
 
 	if (how == 1) {
-		neigh_parms_release(&nd_tbl, idev->nd_parms);
 #ifdef CONFIG_SYSCTL
 		addrconf_sysctl_unregister(&idev->cnf);
+		neigh_sysctl_unregister(&idev->nd_parms);
 #endif
+		neigh_parms_release(&nd_tbl, idev->nd_parms);
 		in6_dev_put(idev);
 	}
 	return 0;
Index: linux25-LINUS/net/ipv6/ndisc.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/ndisc.c,v
retrieving revision 1.1.1.17
diff -u -r1.1.1.17 ndisc.c
--- linux25-LINUS/net/ipv6/ndisc.c	31 May 2003 07:30:52 -0000	1.1.1.17
+++ linux25-LINUS/net/ipv6/ndisc.c	10 Jun 2003 04:25:33 -0000
@@ -1487,6 +1487,9 @@
 
 void ndisc_cleanup(void)
 {
+#ifdef CONFIG_SYSCTL
+	neigh_sysctl_unregister(&nd_tbl.parms);
+#endif
 	neigh_table_clear(&nd_tbl);
 	sock_release(ndisc_socket);
 	ndisc_socket = NULL; /* For safety. */

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
