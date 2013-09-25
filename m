From: Paul Marks <pmarks@google.com>
Subject: [PATCH] ipv6: Fix preferred_lft not updating in some cases
Date: Wed, 25 Sep 2013 15:12:55 -0700
Message-ID: <1380147175-14874-1-git-send-email-pmarks@google.com>
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org, lorenzo@google.com,
	Paul Marks <pmarks@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f73.google.com ([209.85.128.73]:55725 "EHLO
	mail-qe0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752428Ab3IYWNi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 18:13:38 -0400
Received: by mail-qe0-f73.google.com with SMTP id 6so42682qea.4
        for <netdev@vger.kernel.org>; Wed, 25 Sep 2013 15:13:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consider the scenario where an IPv6 router is advertising a fixed
preferred_lft of 1800 seconds, while the valid_lft begins at 3600
seconds and counts down in realtime.

A client should reset its preferred_lft to 1800 every time the RA is
received, but a bug is causing Linux to ignore the update.

The core problem is here:
  if (prefered_lft != ifp->prefered_lft) {

Note that ifp->prefered_lft is an offset, so it doesn't decrease over
time.  Thus, the comparison is always (1800 != 1800), which fails to
trigger an update.

The most direct solution would be to compute a "stored_prefered_lft",
and use that value in the comparison.  But I think that trying to filter
out unnecessary updates here is a premature optimization.  In order for
the filter to apply, both of these would need to hold:

  - The advertised valid_lft and preferred_lft are both declining in
    real time.
  - No clock skew exists between the router & client.

So in this patch, I've set "update_lft = 1" unconditionally, which
allows the surrounding code to be greatly simplified.

Signed-off-by: Paul Marks <pmarks@google.com>
---
 net/ipv6/addrconf.c | 52 +++++++++++++++-------------------------------------
 1 file changed, 15 insertions(+), 37 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d6ff126..9a5052c 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2193,43 +2193,21 @@ ok:
 			else
 				stored_lft = 0;
 			if (!update_lft && !create && stored_lft) {
-				if (valid_lft > MIN_VALID_LIFETIME ||
-				    valid_lft > stored_lft)
-					update_lft = 1;
-				else if (stored_lft <= MIN_VALID_LIFETIME) {
-					/* valid_lft <= stored_lft is always true */
-					/*
-					 * RFC 4862 Section 5.5.3e:
-					 * "Note that the preferred lifetime of
-					 *  the corresponding address is always
-					 *  reset to the Preferred Lifetime in
-					 *  the received Prefix Information
-					 *  option, regardless of whether the
-					 *  valid lifetime is also reset or
-					 *  ignored."
-					 *
-					 *  So if the preferred lifetime in
-					 *  this advertisement is different
-					 *  than what we have stored, but the
-					 *  valid lifetime is invalid, just
-					 *  reset prefered_lft.
-					 *
-					 *  We must set the valid lifetime
-					 *  to the stored lifetime since we'll
-					 *  be updating the timestamp below,
-					 *  else we'll set it back to the
-					 *  minimum.
-					 */
-					if (prefered_lft != ifp->prefered_lft) {
-						valid_lft = stored_lft;
-						update_lft = 1;
-					}
-				} else {
-					valid_lft = MIN_VALID_LIFETIME;
-					if (valid_lft < prefered_lft)
-						prefered_lft = valid_lft;
-					update_lft = 1;
-				}
+				const u32 minimum_lft = min(
+					stored_lft, (u32)MIN_VALID_LIFETIME);
+				valid_lft = max(valid_lft, minimum_lft);
+
+				/* RFC4862 Section 5.5.3e:
+				 * "Note that the preferred lifetime of the
+				 *  corresponding address is always reset to
+				 *  the Preferred Lifetime in the received
+				 *  Prefix Information option, regardless of
+				 *  whether the valid lifetime is also reset or
+				 *  ignored."
+				 *
+				 * So we should always update prefered_lft here.
+				 */
+				update_lft = 1;
 			}
 
 			if (update_lft) {
-- 
1.8.4
