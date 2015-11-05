From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] iproute2: Ignore EADDRNOTAVAIL errors during address flush operation
Date: Thu,  5 Nov 2015 14:54:17 -0500
Message-ID: <1446753257-10716-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36554 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752241AbbKETyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 14:54:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I found recently that, if I disabled address promotion in the kernel, that
ip addr flush dev <dev>

would fail with an EADDRNOTAVAIL errno (though the flush operation would in fact
flush all addresses from an interface properly)

Whats happening is that, if I add a primary and multiple secondary addresses to
an interface, the flush operation first ennumerates them all with a GETADDR |
DUMP operation, then sends a delete request for each address.  But the kernel,
having promotion disabled, deletes all secondary addresses when the primary is
removed.  That means, that several delete requests may still be pending in the
netlink request for addresses that have been removed on our behalf, resulting in
EADDRNOTAVAIL return codes.

It seems the simplest thing to do is to understand that EADDRUNAVAIL isn't a
fatal outcome on a flush operation, as it just indicates that an address which
you want to remove is already removed, so it can safely be ignored.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Stephen Hemminger <stephen@networkplumber.org>
CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
---
 ip/ipaddress.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index f290205..05358c9 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -893,7 +893,17 @@ int print_linkinfo(const struct sockaddr_nl *who,
 
 static int flush_update(void)
 {
-	if (rtnl_send_check(&rth, filter.flushb, filter.flushp) < 0) {
+
+	/*
+	 * Note that the kernel may delete multiple addresses for one
+	 * delete request (e.g. if ipv4 address promotion is disabled).
+	 * Since a flush operation is really a series of delete requests
+	 * its possible that we may request an address delete that has
+	 * already been done by the kernel. Therefore, ignore EADDRNOTAVAIL
+	 * errors returned from a flush request
+	 */
+	if ((rtnl_send_check(&rth, filter.flushb, filter.flushp) < 0) &&
+	    (errno != EADDRNOTAVAIL)) {
 		perror("Failed to send flush request");
 		return -1;
 	}
-- 
2.1.0
