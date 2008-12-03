From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 2/2] net: /proc/net/ip_mr_cache, display Iif as a signed
 short
Date: Wed, 03 Dec 2008 15:35:42 +0100
Message-ID: <20081203143540.694846883@localhost.localdomain>
References: <493415B4.7020600@bull.net> <20081201093341.537bf03d@extreme>
 <20081201211702.a8cjo5p08wscwcwg@intran0x.frec.bull.fr>
 <20081202.150330.157587697.davem@davemloft.net> <49368E23.6070406@bull.net>
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:48518 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751263AbYLCOwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2008 09:52:16 -0500
In-Reply-To: <49368E23.6070406@bull.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Today, iproute2 fails to show multicast forwarding unresolved cache
entries while scanning /proc/net/ip_mr_cache.

Indeed, it expects to see -1 in 'Iif' column to identify unresolved
entries but the kernel outputs 65535. It's a signed/unsigned issue:

'Iif', the source interface, is retrieved from member mfc_parent in
struct mfc_cache. mfc_parent is a vifi_t: unsigned short, but is
displayed in ipmr_mfc_seq_show() as "%-3d", signed integer.

In unresolevd entries, the 65535 value (0xFFFF) comes from this define:
#define ALL_VIFS    ((vifi_t)(-1))

That may explains why the guy who added support for this in iproute2
thought a -1 should be expected.

I don't know if this must be fixed in kernel or in iproute2. Who is
right? What is the correct API? How was it designed originally?

I let you decide if it should goes in the kernel or be fixed in iproute2.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 net/ipv4/ipmr.c  |    2 +-
 net/ipv6/ip6mr.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index cb3a57d..244a624 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1879,7 +1879,7 @@ static int ipmr_mfc_seq_show(struct seq_file *seq, void *v)
 		const struct mfc_cache *mfc = v;
 		const struct ipmr_mfc_iter *it = seq->private;
 
-		seq_printf(seq, "%08lX %08lX %-3d",
+		seq_printf(seq, "%08lX %08lX %-3hd",
 			   (unsigned long) mfc->mfc_mcastgrp,
 			   (unsigned long) mfc->mfc_origin,
 			   mfc->mfc_parent);
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 2dc4b01..1446bec 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -297,7 +297,7 @@ static int ipmr_mfc_seq_show(struct seq_file *seq, void *v)
 		const struct mfc6_cache *mfc = v;
 		const struct ipmr_mfc_iter *it = seq->private;
 
-		seq_printf(seq, "%pI6 %pI6 %-3d",
+		seq_printf(seq, "%pI6 %pI6 %-3hd",
 			   &mfc->mf6c_mcastgrp, &mfc->mf6c_origin,
 			   mfc->mf6c_parent);
 

