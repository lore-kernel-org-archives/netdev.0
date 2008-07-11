From: David Howells <dhowells@redhat.com>
Subject: [PATCH] Fix dccp_timestamp()'s use of do_div()
Date: Fri, 11 Jul 2008 14:57:35 +0100
Message-ID: <20080711135735.28952.84285.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, acme@ghostprotocols.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: gerrit@erg.abdn.ac.uk, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54540 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761304AbYGKN6q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2008 09:58:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix dccp_timestamps()'s use of do_div() on an s64 by making delta a u64
instead and dividing that.

Possibly this should be guarded lest the interval calculation turn up negative,
but the possible negativity of the result of the division ignored anyway, and,
indeed, should not happen.

This was introduced by patch 4c70f383e0c0273c4092c4efdb414be0966978b7.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/dccp/timer.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)


diff --git a/net/dccp/timer.c b/net/dccp/timer.c
index 8703a79..27218c5 100644
--- a/net/dccp/timer.c
+++ b/net/dccp/timer.c
@@ -300,8 +300,10 @@ static ktime_t dccp_timestamp_seed;
  */
 u32 dccp_timestamp(void)
 {
-	s64 delta = ktime_us_delta(ktime_get_real(), dccp_timestamp_seed);
+	u64 delta = ktime_us_delta(ktime_get_real(), dccp_timestamp_seed);
 
+	/* This will produce huge values if the current time should happen to
+	 * be earlier than the initial timestamp, but that shouldn't happen */
 	do_div(delta, 10);
 	return delta;
 }

