From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH] Fix dccp_timestamp()'s use of do_div()
Date: Sat, 12 Jul 2008 14:14:34 +0100
Message-ID: <20080712131434.GA4697@gerrit.erg.abdn.ac.uk>
References: <20080711135735.28952.84285.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, acme@ghostprotocols.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:33511 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752921AbYGLNPb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jul 2008 09:15:31 -0400
Content-Disposition: inline
In-Reply-To: <20080711135735.28952.84285.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting David Howells:
| Fix dccp_timestamps()'s use of do_div() on an s64 by making delta a u64
| instead and dividing that.
| 
| Possibly this should be guarded lest the interval calculation turn up negative,
| but the possible negativity of the result of the division ignored anyway, and,
| indeed, should not happen.
| 
| This was introduced by patch 4c70f383e0c0273c4092c4efdb414be0966978b7.
| 
| Signed-off-by: David Howells <dhowells@redhat.com>
| ---
| 
|  net/dccp/timer.c |    4 +++-
|  1 files changed, 3 insertions(+), 1 deletions(-)
| 
| 
| diff --git a/net/dccp/timer.c b/net/dccp/timer.c
| index 8703a79..27218c5 100644
| --- a/net/dccp/timer.c
| +++ b/net/dccp/timer.c
| @@ -300,8 +300,10 @@ static ktime_t dccp_timestamp_seed;
|   */
|  u32 dccp_timestamp(void)
|  {
| -	s64 delta = ktime_us_delta(ktime_get_real(), dccp_timestamp_seed);
| +	u64 delta = ktime_us_delta(ktime_get_real(), dccp_timestamp_seed);
|  
| +	/* This will produce huge values if the current time should happen to
| +	 * be earlier than the initial timestamp, but that shouldn't happen */
|  	do_div(delta, 10);
|  	return delta;
|  }
| 
I agree that the use of do_div() is problematic but I don't this is a
good solution. It would be better to use div_u64() with the same effect
as shown below (taken from a patch soon to be submitted).

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -74,6 +74,9 @@ extern void dccp_time_wait(struct sock *
 #define DCCP_TIMEWAIT_LEN (60 * HZ) /* how long to wait to destroy TIME-WAIT
 				     * state, about 60 seconds */
 
+/* DCCP base time resolution - 10 microseconds (RFC 4340, 13.1 ... 13.3) */
+#define DCCP_TIME_RESOLUTION	10
+
 /* RFC 1122, 4.2.3.1 initial RTO value */
 #define DCCP_TIMEOUT_INIT ((unsigned)(3 * HZ))
 
--- a/net/dccp/timer.c
+++ b/net/dccp/timer.c
@@ -281,8 +281,7 @@ u32 dccp_timestamp(void)
 {
 	s64 delta = ktime_us_delta(ktime_get_real(), dccp_timestamp_seed);
 
-	do_div(delta, 10);
-	return delta;
+	return div_u64(delta, DCCP_TIME_RESOLUTION);
 }
 EXPORT_SYMBOL_GPL(dccp_timestamp);
 
