From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [PATCH] tcp: fix premature termination of FIN_WAIT2 time-wait sockets
Date: Sat, 15 Aug 2009 03:39:12 +0300
Message-ID: <200908150339.12730.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_wOghK/PcY9lIoCU"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:16936 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750805AbZHOAlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 20:41:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--Boundary-00=_wOghK/PcY9lIoCU
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit


NOTE: this issue has been found, fixed and tested on an ancient 2.6.7 kernel. 
This patch is a blind port of that fix, since unfortunately there is no easy 
way for me to reproduce the original issue with a newer kernel. But the issue 
still seems to be there.

tavi
---

There is a race condition in the time-wait sockets code that can lead
to premature termination of FIN_WAIT2 and, subsequently, to RST
generation when the FIN,ACK from the peer finally arrives:

Time     TCP header
0.000000 30755 > http [SYN] Seq=0 Win=2920 Len=0 MSS=1460 TSV=282912 TSER=0
0.000008 http > 30755 aSYN, ACK] Seq=0 Ack=1 Win=2896 Len=0 MSS=1460 TSV=...
0.136899 HEAD /1b.html?n1Lg=v1 HTTP/1.0 [Packet size limited during capture]
0.136934 HTTP/1.0 200 OK [Packet size limited during capture]
0.136945 http > 30755 [FIN, ACK] Seq=187 Ack=207 Win=2690 Len=0 TSV=270521...
0.136974 30755 > http [ACK] Seq=207 Ack=187 Win=2734 Len=0 TSV=283049 TSER=...
0.177983 30755 > http [ACK] Seq=207 Ack=188 Win=2733 Len=0 TSV=283089 TSER=...
0.238618 30755 > http [FIN, ACK] Seq=207 Ack=188 Win=2733 Len=0 TSV=283151...
0.238625 http > 30755 [RST] Seq=188 Win=0 Len=0

Say twdr->slot = 1 and we are running inet_twdr_hangman and in this
instance inet_twdr_do_twkill_work returns 1. At that point we will
mark slot 1 and schedule inet_twdr_twkill_work. We will also make
twdr->slot = 2.

Next, a connection is closed and tcp_time_wait(TCP_FIN_WAIT2, timeo)
is called which will create a new FIN_WAIT2 time-wait socket and will
place it in the last to be reached slot, i.e. twdr->slot = 1.

At this point say inet_twdr_twkill_work will run which will start
destroying the time-wait sockets in slot 1, including the just added
TCP_FIN_WAIT2 one.

To avoid this issue we increment the slot only if all entries in the
slot have been purged.

This change may delay the slots cleanup by a time-wait death row
period but only if the worker thread didn't had the time to run/purge
the current slot in the next period (6 seconds with default sysctl
settings). However, on such a busy system even without this change we
would probably see delays...

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 net/ipv4/inet_timewait_sock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

--Boundary-00=_wOghK/PcY9lIoCU
Content-Type: text/x-patch;
  charset="utf-8";
  name="b36bc8257b528fc8ce5d6e1eb988459f5c2be10d.diff"
Content-Transfer-Encoding: 8bit
Content-Disposition: inline;
	filename="b36bc8257b528fc8ce5d6e1eb988459f5c2be10d.diff"

diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 61283f9..13f0781 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -218,8 +218,8 @@ void inet_twdr_hangman(unsigned long data)
 		/* We purged the entire slot, anything left?  */
 		if (twdr->tw_count)
 			need_timer = 1;
+		twdr->slot = ((twdr->slot + 1) & (INET_TWDR_TWKILL_SLOTS - 1));
 	}
-	twdr->slot = ((twdr->slot + 1) & (INET_TWDR_TWKILL_SLOTS - 1));
 	if (need_timer)
 		mod_timer(&twdr->tw_timer, jiffies + twdr->period);
 out:

--Boundary-00=_wOghK/PcY9lIoCU--


