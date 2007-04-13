From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH tcp-2.6] [TCP]: Catch skb with S+L bugs earlier
Date: Fri, 13 Apr 2007 17:46:10 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0704131737110.28337@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-304686413-1176475570=:28337"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:36040 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754023AbXDMOqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2007 10:46:12 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-304686413-1176475570=:28337
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

SACKED_ACKED and LOST are mutually exclusive with SACK, thus
having their sum larger than packets_out is bug with SACK.
Eventually these bugs trigger traps in the tcp_clean_rtx_queue
with SACK but it's much more informative to do this here.

Non-SACK TCP, however, could get more than packets_out duplicate
ACKs which each increment sacked_out, so it makes sense to do
this kind of limitting for non-SACK TCP but not for SACK enabled
one. Perhaps the author had the opposite in mind but did the
logic accidently wrong way around? Anyway, the sacked_out
incrementer code for non-SACK already deals this issue before
calling sync_left_out so this trapping can be done
unconditionally.


Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
Please consider this for tcp-2.6...

While testing F-RTO, I had also this compiled in. Did some random things 
here and there with both SACK and NewReno. Nothing seemed to trigger 
this... :-) Besides that I have checked all places where lost_out is being 
incremented (with Reno) that they are not cause problems when 
sacked_out is close to packets_out already...

Old kernels should be safe since we have had no reports of failures  
(i.e., SACK scoreboard leaks) and NewReno code already considers this 
case... But it helps in future if somebody ever breaks this invariant 
accidently.

 include/net/tcp.h |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 0abf7db..89a357a 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -733,9 +733,7 @@ static inline __u32 tcp_current_ssthresh
 
 static inline void tcp_sync_left_out(struct tcp_sock *tp)
 {
-	if (tp->rx_opt.sack_ok &&
-	    (tp->sacked_out >= tp->packets_out - tp->lost_out))
-		tp->sacked_out = tp->packets_out - tp->lost_out;
+	BUG_ON(tp->sacked_out + tp->lost_out > tp->packets_out);
 	tp->left_out = tp->sacked_out + tp->lost_out;
 }
 
-- 
1.4.2

---696243703-304686413-1176475570=:28337--
