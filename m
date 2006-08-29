From: Olaf Kirch <okir@suse.de>
Subject: [PATCH IPv6] Fix race condition in ipv6_add_addr
Date: Tue, 29 Aug 2006 10:35:36 +0200
Message-ID: <20060829083536.GA10403@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Qxx1br4bt0+wmkIi"
Cc: Keir Fraser <keir.fraser@cl.cam.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:36021 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S1750831AbWH2Ifh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 04:35:37 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--Qxx1br4bt0+wmkIi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Here's a patch originally from Keir Fraser, which we included in SLES10,
but which we forgot to submit upstream so far.

During stress testing, machines were frequently crashing in
__ipv6_ifa_notify on dst_hold(&ifp->rt.u_dst), with ifp->rt being a
NULL pointer.

The attached patch fixes the problem.

Thanks,
Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

--Qxx1br4bt0+wmkIi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=ipv6-add-addr-install-dstentry

From: Keir Fraser <keir.fraser@cl.cam.ac.uk>
Subject: ipv6_add_addr should install dstentry earlier

ipv6_add_addr allocates a struct inet6_ifaddr and a dstentry, but it
doesn't install the dstentry in ifa->rt until after it releases the
addrconf_hash_lock. This means other CPUs will be able to see the new
address while it hasn't been initialized completely yet.

One possible fix would be to grab the ifp->lock spinlock when
creating the address struct; a simpler fix is to just move the
assignment.

Acked-by: jbeulich@novell.com
Acked-by: okir@suse.de

--- linux-2.6.16.13-old/net/ipv6/addrconf.c	2006-05-02 22:38:44.000000000 +0100
+++ linux-2.6.16.13-new/net/ipv6/addrconf.c	2006-06-18 10:16:50.000000000 +0100
@@ -549,6 +549,8 @@
 	ifa->flags = flags | IFA_F_TENTATIVE;
 	ifa->cstamp = ifa->tstamp = jiffies;
 
+	ifa->rt = rt;
+
 	ifa->idev = idev;
 	in6_dev_hold(idev);
 	/* For caller */
@@ -575,8 +577,6 @@
 	}
 #endif
 
-	ifa->rt = rt;
-
 	in6_ifa_hold(ifa);
 	write_unlock(&idev->lock);
 out2:

--Qxx1br4bt0+wmkIi--
