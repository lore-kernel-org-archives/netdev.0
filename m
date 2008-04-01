From: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
Subject: [PATCH 2 of 2] IPv6: do not create temporary adresses with too short
	preferred lifetime
Date: Wed, 02 Apr 2008 01:09:01 +0200
Message-ID: <00affc24c178e6da3a3b.1207091341@pirzuine>
References: <patchbomb.1207091339@pirzuine>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp8-g19.free.fr ([212.27.42.65]:45761 "EHLO smtp8-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753167AbYDAXJC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2008 19:09:02 -0400
In-Reply-To: <patchbomb.1207091339@pirzuine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6: do not create temporary adresses with too short preferred lifetime

>From RFC341:
A temporary address is created only if this calculated Preferred
Lifetime is greater than REGEN_ADVANCE time units.  In particular,
an implementation must not create a temporary address with a zero
Preferred Lifetime.

Signed-off-by: Benoit Boissinot <benoit.boissinot@ens-lyon.org>

diff -r 0c33481968e0 -r 00affc24c178 net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	Sat Mar 22 00:41:39 2008 +0100
+++ b/net/ipv6/addrconf.c	Sat Mar 22 00:39:16 2008 +0100
@@ -776,6 +776,7 @@
 	struct inet6_dev *idev = ifp->idev;
 	struct in6_addr addr, *tmpaddr;
 	unsigned long tmp_prefered_lft, tmp_valid_lft, tmp_cstamp, tmp_tstamp;
+	unsigned long regen_advance;
 	int tmp_plen;
 	int ret = 0;
 	int max_addresses;
@@ -836,7 +837,22 @@
 	tmp_tstamp = ifp->tstamp;
 	spin_unlock_bh(&ifp->lock);
 
+	regen_advance = idev->cnf.regen_max_retry *
+	                idev->cnf.dad_transmits *
+	                idev->nd_parms->retrans_time / HZ;
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
