From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [PATCH][net-next] LRO: improve aggregation in case of zero TSecr packets
Date: Thu, 27 Aug 2009 02:08:31 +0300
Message-ID: <200908270208.31581.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_vBclKyI536+P5Z0"
Cc: Christoph Raisch <raisch@de.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: "Jan-Bernd Themann" <themann@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:24651 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753437AbZHZXKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 19:10:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--Boundary-00=_vBclKyI536+P5Z0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit


This fixes a temporary performance issue we noticed in back to back
TSO - LRO tests when such tests are run within five minutes after
boot.

The TSval field of TCP packets is filled in based on the current
jiffie, which is initialized at -300*HZ. That means that in 5 minutes
after reboot it will wrap to zero.

While the jiffie value is 0 on the LRO side, TCP packets will be
send out with TSVal zero as well. The TSO side will respond with 
packets in which TSecr is set to zero. 

At this point LRO will avoid aggregating the packets, suddenly 
putting a lot of pressure on the stack which will result in drops and 
retransmission for a short while.

There are cases where aggregating zero TSecr is better and cases in
which is not:

1. non zero TSecr packets, zero TSecr packet

   Better not to aggregate, otherwise we miss a valid TSecr.

2. zero TSecr packets (amplified by TSO)

   Better to aggregate.

3. zero TSecr packet, non zero TSecr packets

   OK to aggregate.

4. non zero TSecr packets, zero TSecr packets, non zero TSecr packet

   OK to aggregate, but not a big overhead if we aggregate in 2
   segments instead of one.

This patch allows aggregation for cases 2 and 3 as well as aggregation
in 2 segments for case 4, while denying aggregation in case 1.

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 net/ipv4/inet_lro.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

--Boundary-00=_vBclKyI536+P5Z0
Content-Type: text/x-patch;
  charset="utf-8";
  name="d943fa4bd69b5ff21505eb6187120fe60868b5f9.diff"
Content-Transfer-Encoding: 8bit
Content-Disposition: inline;
	filename="d943fa4bd69b5ff21505eb6187120fe60868b5f9.diff"

diff --git a/net/ipv4/inet_lro.c b/net/ipv4/inet_lro.c
index 6a667da..d16c9d5 100644
--- a/net/ipv4/inet_lro.c
+++ b/net/ipv4/inet_lro.c
@@ -90,9 +90,9 @@ static int lro_tcp_ip_check(struct iphdr *iph, struct tcphdr *tcph,
 				      ntohl(*topt)))
 			return -1;
 
-		/* timestamp reply should not be zero */
+		/* aggregate if we are sure we won't miss a valid TSecr */
 		topt++;
-		if (*topt == 0)
+		if (*topt == 0 && lro_desc->tcp_rcv_tsecr != 0)
 			return -1;
 	}
 

--Boundary-00=_vBclKyI536+P5Z0--


