From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 1/6] ipaddress: make flush command more error-tolerant
Date: Sun,  8 Nov 2015 21:22:16 +0100
Message-ID: <1447014141-3565-2-git-send-email-phil@nwl.cc>
References: <1447010471-559-1-git-send-email-phil@nwl.cc>
 <1447014141-3565-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:39067 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751331AbbKHUWY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Nov 2015 15:22:24 -0500
In-Reply-To: <1447014141-3565-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The core issue here is that with promote_secondaries sysctl setting
being turned off, removing the primary address implicitly removes all
secondaries as well. Iproute is aware of this and therefore tries to
remove all secondary addresses first to circumvent errors due to
removing non-existent addresses. But this works only if not too many IP
addresses are assigned to an interface, otherwise the RTM_GETADDR
response is split up into multiple buffers. In my test-case, flushing
more than 42 IPv4 addresses was sufficient to trigger an error:

Failed to send flush request: Cannot assign requested address

This patch fixes the issue by simply ignoring EADDRNOTAVAIL when
flushing.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipaddress.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index f290205..75b3e27 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -893,7 +893,12 @@ int print_linkinfo(const struct sockaddr_nl *who,
 
 static int flush_update(void)
 {
-	if (rtnl_send_check(&rth, filter.flushb, filter.flushp) < 0) {
+	int rc = rtnl_send_check(&rth, filter.flushb, filter.flushp);
+
+	/* if promote_secondaries sysctl setting is off, removing the primary
+	 * address makes us try to remove non-existent secondaries. Since we're
+	 * flushing, this can be sanely ignored. */
+	if (rc < 0 && errno != EADDRNOTAVAIL) {
 		perror("Failed to send flush request");
 		return -1;
 	}
-- 
2.1.2
