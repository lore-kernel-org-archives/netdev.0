From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] Revert "ipv4: arp announce, arp_proxy and windows ip conflict verification"
Date: Tue, 30 Jun 2009 19:27:17 -0700
Message-ID: <m17hytrvcq.fsf_-_@fess.ebiederm.org>
References: <200903011344.45814.denys@visp.net.lb>
	<m1r5x1z5z4.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Denys Fedoryschenko <denys@visp.net.lb>,
	stable@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:54026 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752860AbZGAC1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 22:27:19 -0400
In-Reply-To: <m1r5x1z5z4.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Tue\, 30 Jun 2009 15\:55\:59 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 73ce7b01b4496a5fbf9caf63033c874be692333f.

After discovering that we don't listen to gratuitious arps in 2.6.30
I tracked the failure down to this commit.

The patch makes absolutely no sense.  RFC2131 RFC3927 and RFC5227.
are all in agreement that an arp request with sip == 0 should be used
for the probe (to prevent learning) and an arp request with sip == tip
should be used for the gratitous announcement that people can learn
from.

It appears the author of the broken patch got those two cases confused
and modified the code to drop all gratuitous arp traffic.  Ouch!

Cc: stable@kernel.org
Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 net/ipv4/arp.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index f11931c..9c22032 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -801,11 +801,8 @@ static int arp_process(struct sk_buff *skb)
  *  cache.
  */
 
-	/*
-	 *  Special case: IPv4 duplicate address detection packet (RFC2131)
-	 *  and Gratuitous ARP/ARP Announce. (RFC3927, Section 2.4)
-	 */
-	if (sip == 0 || tip == sip) {
+	/* Special case: IPv4 duplicate address detection packet (RFC2131) */
+	if (sip == 0) {
 		if (arp->ar_op == htons(ARPOP_REQUEST) &&
 		    inet_addr_type(net, tip) == RTN_LOCAL &&
 		    !arp_ignore(in_dev, sip, tip))
-- 
1.6.0.6

