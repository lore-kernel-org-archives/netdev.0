From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 1/2] net: fix /proc/net/ip_mr_cache display - V2
Date: Wed, 03 Dec 2008 15:35:41 +0100
Message-ID: <20081203143540.414771888@localhost.localdomain>
References: <493415B4.7020600@bull.net> <20081201093341.537bf03d@extreme>
 <20081201211702.a8cjo5p08wscwcwg@intran0x.frec.bull.fr>
 <20081202.150330.157587697.davem@davemloft.net> <49368E23.6070406@bull.net>
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:48465 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751098AbYLCOwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2008 09:52:07 -0500
In-Reply-To: <49368E23.6070406@bull.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

/proc/net/ip_mr_cache and /proc/net/ip6_mr_cache displays garbage when
showing unresolved mfc_cache entries.

[root@qemu tests]# cat /proc/net/ip_mr_cache
Group    Origin   Iif     Pkts    Bytes    Wrong Oifs
014C00EF 010014AC 1         10    10050        0  2:1    3:1
024C00EF 010014AC 65535      514        2 -559067475

The first line is correct. It is a resolved cache entry, 10 packets used it...
The second line represents an unresolved entry, and the columns Pkts(4th),
Bytes(5th) and Wrong(6th) just show garbage.

In struct mfc_cache, there's an union to store data for resolved and
unresolved cases. And what ipmr_mfc_seq_show() is printing in these 
columns for the unresolved entries is some bytes from mfc_cache.mfc_un.res.
Bad.
(eg. In our case -559067475 is in fact 0xdead4ead which is the spinlock
magic from mfc_cache.mfc_un.unres.unresolved.lock.magic).

This patch replaces the garbage data written in these columns for the
unresolved entries by '0' (zeros) which is more correct.
This change doesn't break the ABI.

Also, mfc->mfc_un.res.pkt, mfc->mfc_un.res.bytes, mfc->mfc_un.res.wrong_if
are unsigned long.

It applies on top of net-next-2.6.

The patch for net-2.6 is slightly different because of the NIP6_FMT to
%pI6 conversion that was made in the seq_printf.

Changelog:
==========
V2:
* Instead of breaking the ABI by suppressing the columns that have no
  meaning for unresolved entries, fill them with 0 values.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 net/ipv4/ipmr.c  |   16 +++++++++++-----
 net/ipv6/ip6mr.c |   16 +++++++++++-----
 2 files changed, 22 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 77fc4d3..cb3a57d 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1879,15 +1879,16 @@ static int ipmr_mfc_seq_show(struct seq_file *seq, void *v)
 		const struct mfc_cache *mfc = v;
 		const struct ipmr_mfc_iter *it = seq->private;
 
-		seq_printf(seq, "%08lX %08lX %-3d %8ld %8ld %8ld",
+		seq_printf(seq, "%08lX %08lX %-3d",
 			   (unsigned long) mfc->mfc_mcastgrp,
 			   (unsigned long) mfc->mfc_origin,
-			   mfc->mfc_parent,
-			   mfc->mfc_un.res.pkt,
-			   mfc->mfc_un.res.bytes,
-			   mfc->mfc_un.res.wrong_if);
+			   mfc->mfc_parent);
 
 		if (it->cache != &mfc_unres_queue) {
+			seq_printf(seq, " %8lu %8lu %8lu",
+				   mfc->mfc_un.res.pkt,
+				   mfc->mfc_un.res.bytes,
+				   mfc->mfc_un.res.wrong_if);
 			for (n = mfc->mfc_un.res.minvif;
 			     n < mfc->mfc_un.res.maxvif; n++ ) {
 				if (VIF_EXISTS(n)
@@ -1896,6 +1897,11 @@ static int ipmr_mfc_seq_show(struct seq_file *seq, void *v)
 					   " %2d:%-3d",
 					   n, mfc->mfc_un.res.ttls[n]);
 			}
+		} else {
+			/* unresolved mfc_caches don't contain
+			 * pkt, bytes and wrong_if values
+			 */
+			seq_printf(seq, " %8lu %8lu %8lu", 0ul, 0ul, 0ul);
 		}
 		seq_putc(seq, '\n');
 	}
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index dfba9fd..2dc4b01 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -297,14 +297,15 @@ static int ipmr_mfc_seq_show(struct seq_file *seq, void *v)
 		const struct mfc6_cache *mfc = v;
 		const struct ipmr_mfc_iter *it = seq->private;
 
-		seq_printf(seq, "%pI6 %pI6 %-3d %8ld %8ld %8ld",
+		seq_printf(seq, "%pI6 %pI6 %-3d",
 			   &mfc->mf6c_mcastgrp, &mfc->mf6c_origin,
-			   mfc->mf6c_parent,
-			   mfc->mfc_un.res.pkt,
-			   mfc->mfc_un.res.bytes,
-			   mfc->mfc_un.res.wrong_if);
+			   mfc->mf6c_parent);
 
 		if (it->cache != &mfc_unres_queue) {
+			seq_printf(seq, " %8lu %8lu %8lu",
+				   mfc->mfc_un.res.pkt,
+				   mfc->mfc_un.res.bytes,
+				   mfc->mfc_un.res.wrong_if);
 			for (n = mfc->mfc_un.res.minvif;
 			     n < mfc->mfc_un.res.maxvif; n++) {
 				if (MIF_EXISTS(n) &&
@@ -313,6 +314,11 @@ static int ipmr_mfc_seq_show(struct seq_file *seq, void *v)
 						   " %2d:%-3d",
 						   n, mfc->mfc_un.res.ttls[n]);
 			}
+		} else {
+			/* unresolved mfc_caches don't contain
+			 * pkt, bytes and wrong_if values
+			 */
+			seq_printf(seq, " %8lu %8lu %8lu", 0ul, 0ul, 0ul);
 		}
 		seq_putc(seq, '\n');
 	}

