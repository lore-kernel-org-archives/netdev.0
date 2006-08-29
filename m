From: Olaf Kirch <okir@suse.de>
Subject: [RFC IPv6] Disabling IPv6 autoconf
Date: Tue, 29 Aug 2006 10:24:35 +0200
Message-ID: <20060829082435.GA2676@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="FCuugMFkClbJLl1L"
Cc: Jan Beulich <jbeulich@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:56499 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S1750869AbWH2IYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 04:24:36 -0400
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 31689FB2D
	for <netdev@vger.kernel.org>; Tue, 29 Aug 2006 10:24:35 +0200 (CEST)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--FCuugMFkClbJLl1L
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

we had bug reports from people seeing lots of spurious messages
like the following:

kernel: peth0: received packet with own address as source address.

and

xenbr0: duplicate address detected!

This is on a Xen enabled machine, with lots of Xen machines on the
same network.

When the Xen code configures the bridge device, this will do IPv6
autoconfiguration for the interface, and since they use synthetic MAC
addresses, there will be DAD collisions.

When the Xen people looked for a way to disable IPv6 autoconf of the
bridge, they didn't find any way to do it without bringing up the
device first (and thereby triggering DAD).

The attached tentative patch makes IPv6 autoconf depend on the
availability of IFF_MULTICAST. This is admittedly a bit of a hack, but
it makes sense, since DAD and router solicitation do rely on multicast.

Any comments?

Thanks,
Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

--FCuugMFkClbJLl1L
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=ipv6-no-autoconf

Summary: Allow to bring up network interface w/o ipv6 autoconf

When bringing up a xen bridge device, it will always be configured to
use a MAC address of ff:ff:ff:ff:ff:fe.  This greatly confuses IPv6 DAD,
which starts logging lots and lots of useless messages to syslog.

We really want to disable IPv6 on these interfaces, and there doesn't
seem to be a reliable way to do this without bringing the interface
up first (and triggering IPv6 autoconf). 

This patch makes autoconf (DAD and router discovery) depend on the
interface's ability to do multicast. Turning off multicast for an
interface before bringing it up will suppress autoconfiguration.

Signed-off-by: Olaf Kirch <okir@suse.de>

 net/ipv6/addrconf.c |    2 ++
 1 files changed, 2 insertions(+)

Index: build/net/ipv6/addrconf.c
===================================================================
--- build.orig/net/ipv6/addrconf.c
+++ build/net/ipv6/addrconf.c
@@ -2462,6 +2462,7 @@ static void addrconf_dad_start(struct in
 	spin_lock_bh(&ifp->lock);
 
 	if (dev->flags&(IFF_NOARP|IFF_LOOPBACK) ||
+	    !(dev->flags&IFF_MULTICAST) ||
 	    !(ifp->flags&IFA_F_TENTATIVE)) {
 		ifp->flags &= ~IFA_F_TENTATIVE;
 		spin_unlock_bh(&ifp->lock);
@@ -2546,6 +2547,7 @@ static void addrconf_dad_completed(struc
 	if (ifp->idev->cnf.forwarding == 0 &&
 	    ifp->idev->cnf.rtr_solicits > 0 &&
 	    (dev->flags&IFF_LOOPBACK) == 0 &&
+	    (dev->flags & IFF_MULTICAST) &&
 	    (ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL)) {
 		struct in6_addr all_routers;
 

--FCuugMFkClbJLl1L--
