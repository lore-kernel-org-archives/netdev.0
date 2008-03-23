From: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
Subject: [PATCH 4 of 5] IPv6: fix lifetime calculation on temporary address
	creation
Date: Sun, 23 Mar 2008 21:46:12 +0100
Message-ID: <ec551b4a5bb25cda00ff.1206305172@pirzuine>
References: <patchbomb.1206305168@pirzuine>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp8-g19.free.fr ([212.27.42.65]:38138 "EHLO smtp8-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754650AbYCWUqP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Mar 2008 16:46:15 -0400
In-Reply-To: <patchbomb.1206305168@pirzuine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6: fix lifetime calculation on temporary address creation

The lifetime calculation was buggy since it copied the tstamp
from the associated public address.
If (now - ifp->prefered_lft)/HZ (ie the elapsed time since the
timestamp was set in the public address) was greater than
temp_prefered_lft, you would always get deprecated addresses.

This patch corrects the lifetime calculation by setting the tstamp
to "now" and calculating the remaining time from the public address.

Signed-off-by: Benoit Boissinot <benoit.boissinot@ens-lyon.org>

diff -r 268e602e1908 -r ec551b4a5bb2 net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	Sat Mar 22 00:39:16 2008 +0100
+++ b/net/ipv6/addrconf.c	Sat Mar 22 00:38:40 2008 +0100
@@ -775,8 +775,8 @@
 {
 	struct inet6_dev *idev = ifp->idev;
 	struct in6_addr addr, *tmpaddr;
-	unsigned long tmp_prefered_lft, tmp_valid_lft, tmp_cstamp, tmp_tstamp;
-	unsigned int regen_advance;
+	unsigned int tmp_prefered_lft, tmp_valid_lft, elapsed, regen_advance;
+	unsigned long now;
 	int tmp_plen;
 	int ret = 0;
 	int max_addresses;
@@ -825,16 +825,22 @@
 		goto out;
 	}
 	memcpy(&addr.s6_addr[8], idev->rndid, 8);
-	tmp_valid_lft = min_t(__u32,
-			      ifp->valid_lft,
-			      idev->cnf.temp_valid_lft);
-	tmp_prefered_lft = min_t(__u32,
-				 ifp->prefered_lft,
-				 idev->cnf.temp_prefered_lft - desync_factor / HZ);
+	now = jiffies;
+	elapsed = (now - ifp->tstamp) / HZ;
+	if (elapsed >= ifp->valid_lft)
+		tmp_valid_lft = 0;
+	else
+		tmp_valid_lft = min_t(__u32,
+				      ifp->valid_lft - elapsed,
+				      idev->cnf.temp_valid_lft);
+	if (elapsed >= ifp->prefered_lft)
+		tmp_prefered_lft = 0;
+	else
+		tmp_prefered_lft = min_t(__u32,
+					 ifp->prefered_lft - elapsed,
+					 idev->cnf.temp_prefered_lft - desync_factor / HZ);
 	tmp_plen = ifp->prefix_len;
 	max_addresses = idev->cnf.max_addresses;
-	tmp_cstamp = ifp->cstamp;
-	tmp_tstamp = ifp->tstamp;
 	regen_advance = idev->cnf.regen_max_retry *
 	                idev->cnf.dad_transmits *
 	                idev->nd_parms->retrans_time / HZ;
@@ -878,8 +884,6 @@
 	ift->ifpub = ifp;
 	ift->valid_lft = tmp_valid_lft;
 	ift->prefered_lft = tmp_prefered_lft;
-	ift->cstamp = tmp_cstamp;
-	ift->tstamp = tmp_tstamp;
 	spin_unlock_bh(&ift->lock);
 
 	addrconf_dad_start(ift, 0);
