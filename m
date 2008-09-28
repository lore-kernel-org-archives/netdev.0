From: Bernard Pidoux <bpidoux@free.fr>
Subject: [PATCH] negative dev use in /proc/net/rose_neigh
Date: Sun, 28 Sep 2008 21:56:38 +0200
Message-ID: <200809282156.39466.bpidoux@free.fr>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_3F+3I9qRrDwZZFQ"
Cc: bpidoux@free.fr
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp8-g19.free.fr ([212.27.42.65]:36006 "EHLO smtp8-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752080AbYI1T4m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Sep 2008 15:56:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_3F+3I9qRrDwZZFQ
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline



--Boundary-00=_3F+3I9qRrDwZZFQ
Content-Type: text/plain;
  name="[PATCH] negative dev use in /proc/net/rose_neigh"
Content-Transfer-Encoding: 7bit

When running rose network applications, rose_neigh use counter can become negative as shown below.
Number 65535 actually represents a short integer underflow, meaning that use counter has been
decremented while equal to zero.
Then use counter continues to decrease by one each time the function is called.

proc/net/rose_neigh
addr  callsign  dev  count use mode restart  t0  tf digipeaters
00005 F5KCK-11  ax1      4   1  DTE     yes   0   0
00004 F6BVP-5   ax4      6   0  DTE      no   0   0
00003 F6BVP-7   ax4      6   0  DCE     yes   0   0
00002 F6BVP-11  ax4      6 65535  DCE     yes   0   0
00001 RSLOOP-0  ???      1   4  DCE     yes   0   0

After investigations I found that use counter value was going negative when
rose_kill_by_neigh() (in af_rose.c) was called and sk_for_each() macro loop activated
rose->neighbour->use-- more than once.

I propose the following patch to avoid use counter underflow.
However a KERN_WARNING message could be better instead of KERN_ERR.
 
Signed-off-by: Bernard Pidoux <f6bvp@amsat.org>
---
 net/rose/af_rose.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index a7f1ce1..8a54cff 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -175,7 +175,10 @@ void rose_kill_by_neigh(struct rose_neigh *neigh)
 
 		if (rose->neighbour == neigh) {
 			rose_disconnect(s, ENETUNREACH, ROSE_OUT_OF_ORDER, 0);
-			rose->neighbour->use--;
+			if (rose->neighbour->use > 0 ) 
+				rose->neighbour->use--;
+			else
+				printk(KERN_ERR "ROSE: rose_kill_by_neigh() - neighbour->use-- could be < 0\n");
 			rose->neighbour = NULL;
 		}
 	}
-- 
1.5.5


--Boundary-00=_3F+3I9qRrDwZZFQ--
