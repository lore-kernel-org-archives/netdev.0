From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NET: Make ts_recent_stamp and tw_ts_recent_stamp unsigned long
Date: Fri, 02 Nov 2007 16:21:31 -0400
Message-ID: <20071102202131.30769.8429.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]:35300 "EHLO
	flpi195.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758314AbXKBUVe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2007 16:21:34 -0400
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi195.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id lA2KLWY7026282
	for <netdev@vger.kernel.org>; Fri, 2 Nov 2007 13:21:32 -0700
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id lA2KLViV030785
	for <netdev@vger.kernel.org>; Fri, 2 Nov 2007 16:21:32 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The get_seconds() function now returns an unsigned long.  K&R states
that comparing a signed long with an unsigned long implicitly converts
the signed long to unsigned long [1].

Thus ts_recent_stamp and tw_ts_recent_stamp are already implicitly
converted to unsigned long in every comparison with get_seconds() or
other unsigned longs (such as tcp_ts_stamp).

Code review shows that ts_recent_stamp is compared only to get_seconds() or
zero.  It is set only to zero, the return value of get_seconds(), or the
value of tw_ts_recent_stamp.  Thus changing ts_recent_stamp to an unsigned
long does not change current behavior in any way, and eliminates implicit
type conversions in several places, including some comparisons.

Review shows that tw_ts_recent_stamp is set only to the return value of
get_seconds() or to the value of ts_recent_stamp.  It is compared to the
return value of get_seconds(), the value of tcp_ts_stamp (an unsigned
long), one, or zero.  Thus changing tw_ts_recent_stamp to an unsigned long
also does not change current behavior in any way.

It might improve matters even further if these open-coded timestamp
comparisons were replaced with something similar to the time_after_eq
macro from include/linux/jiffies.h.

[1] Kernighan & Ritchie, "The C Programming Language", 2nd. ed., appendix
A, sec. 6.5.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: netdev@vger.kernel.org
---

 include/linux/tcp.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index bac17c5..0122374 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -206,7 +206,7 @@ struct tcp_sack_block {
 
 struct tcp_options_received {
 /*	PAWS/RTTM data	*/
-	long	ts_recent_stamp;/* Time we stored ts_recent (for aging) */
+	unsigned long ts_recent_stamp;/* Time we stored ts_recent (for aging) */
 	u32	ts_recent;	/* Time stamp to echo next		*/
 	u32	rcv_tsval;	/* Time stamp value             	*/
 	u32	rcv_tsecr;	/* Time stamp echo reply        	*/
@@ -419,7 +419,7 @@ struct tcp_timewait_sock {
 	u32			  tw_snd_nxt;
 	u32			  tw_rcv_wnd;
 	u32			  tw_ts_recent;
-	long			  tw_ts_recent_stamp;
+	unsigned long		  tw_ts_recent_stamp;
 #ifdef CONFIG_TCP_MD5SIG
 	u16			  tw_md5_keylen;
 	u8			  tw_md5_key[TCP_MD5SIG_MAXKEYLEN];

