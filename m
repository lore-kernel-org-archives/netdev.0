From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] ip-route: Fix for listing routes with RTAX_LOCK attribute
Date: Thu, 28 Sep 2017 19:33:56 +0200
Message-ID: <20170928173356.17892-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org, Thomas Haller <thaller@redhat.com>,
        Hangbin Liu <liuhangbin@gmail.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:35568 "EHLO orbyte.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752002AbdI1ReK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 28 Sep 2017 13:34:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes a corner-case for routes with a certain metric locked to
zero:

| ip route add 192.168.7.0/24 dev eth0 window 0
| ip route add 192.168.7.0/24 dev eth0 window lock 0

Since the kernel doesn't dump the attribute if it is zero, both routes
added above would appear as if they were equal although they are not.

Fix this by taking mxlock value for the given metric into account before
skipping it if it is not present.

Reported-by: Thomas Haller <thaller@redhat.com>
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iproute.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index a8733f45bf881..e81bc05ec16cb 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -574,10 +574,10 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		for (i = 2; i <= RTAX_MAX; i++) {
 			__u32 val = 0U;
 
-			if (mxrta[i] == NULL)
+			if (mxrta[i] == NULL && !(mxlock & (1 << i)))
 				continue;
 
-			if (i != RTAX_CC_ALGO)
+			if (mxrta[i] != NULL && i != RTAX_CC_ALGO)
 				val = rta_getattr_u32(mxrta[i]);
 
 			if (i == RTAX_HOPLIMIT && (int)val == -1)
-- 
2.13.1
