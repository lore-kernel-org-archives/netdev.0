From: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
Subject: [PATCH 3 of 5] IPv6: do not create temporary adresses with too short
	preferred lifetime
Date: Sun, 23 Mar 2008 21:46:11 +0100
Message-ID: <268e602e19080797193e.1206305171@pirzuine>
References: <patchbomb.1206305168@pirzuine>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp8-g19.free.fr ([212.27.42.65]:38131 "EHLO smtp8-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752335AbYCWUqP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Mar 2008 16:46:15 -0400
In-Reply-To: <patchbomb.1206305168@pirzuine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6: do not create temporary adresses with too short preferred lifetime

>From RFC341:
A temporary address is created only if this calculated Preferred
Lifetime is greater than REGEN_ADVANCE time units.  In particular,
an implementation must not create a temporary address with a zero
Preferred Lifetime.

Signed-off-by: Benoit Boissinot <benoit.boissinot@ens-lyon.org>

diff -r 5e50b19fbb75 -r 268e602e1908 net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	Sat Mar 22 00:41:39 2008 +0100
+++ b/net/ipv6/addrconf.c	Sat Mar 22 00:39:16 2008 +0100
@@ -776,6 +776,7 @@
 	struct inet6_dev *idev = ifp->idev;
 	struct in6_addr addr, *tmpaddr;
 	unsigned long tmp_prefered_lft, tmp_valid_lft, tmp_cstamp, tmp_tstamp;
+	unsigned int regen_advance;
 	int tmp_plen;
 	int ret = 0;
 	int max_addresses;
@@ -834,9 +835,24 @@
 	max_addresses = idev->cnf.max_addresses;
 	tmp_cstamp = ifp->cstamp;
 	tmp_tstamp = ifp->tstamp;
+	regen_advance = idev->cnf.regen_max_retry *
+	                idev->cnf.dad_transmits *
+	                idev->nd_parms->retrans_time / HZ;
 	spin_unlock_bh(&ifp->lock);
 
 	write_unlock(&idev->lock);
+
+	/* A temporary address is created only if this calculated Preferred
+	 * Lifetime is greater than REGEN_ADVANCE time units.  In particular,
+	 * an implementation must not create a temporary address with a zero
+	 * Preferred Lifetime.
+	 */
+	if (tmp_prefered_lft <= regen_advance) {
+		in6_ifa_put(ifp);
+		in6_dev_put(idev);
+		ret = -1;
+		goto out;
+	}
 
 	addr_flags = IFA_F_TEMPORARY;
 	/* set in addrconf_prefix_rcv() */
