From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] pktgen: Fix multiqueue handling
Date: Sat, 03 Oct 2009 08:24:59 +0200
Message-ID: <4AC6EE3B.6050407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <robert.olsson@its.uu.se>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54298 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752332AbZJCGZA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Oct 2009 02:25:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Note : I could not really test this patch, I dont have multi queue hardware yet.

I found this by code inspection, please double check, thanks

[PATCH] pktgen: Fix multiqueue handling

It is not currently possible to instruct pktgen to use one selected tx queue.

When Robert added multiqueue support in commit 45b270f8, he added
an interval (queue_map_min, queue_map_max), and his code doesnt take
into account the case of min = max, to select one tx queue exactly.

I suspect a high performance setup on a eight txqueue device wants 
to use exactly eight cpus, and assign one tx queue to each sender.

This patchs makes pktgen select the right tx queue, not the first one.

Also updates Documentation to reflect Robert changes.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 Documentation/networking/pktgen.txt |    8 ++++++++
 net/core/pktgen.c                   |    2 +-
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/pktgen.txt b/Documentation/networking/pktgen.txt
index c6cf4a3..61bb645 100644
--- a/Documentation/networking/pktgen.txt
+++ b/Documentation/networking/pktgen.txt
@@ -90,6 +90,11 @@ Examples:
  pgset "dstmac 00:00:00:00:00:00"    sets MAC destination address
  pgset "srcmac 00:00:00:00:00:00"    sets MAC source address
 
+ pgset "queue_map_min 0" Sets the min value of tx queue interval
+ pgset "queue_map_max 7" Sets the max value of tx queue interval, for multiqueue devices
+                         To select queue 1 of a given device,
+                         use queue_map_min=1 and queue_map_max=1
+
  pgset "src_mac_count 1" Sets the number of MACs we'll range through.  
                          The 'minimum' MAC is what you set with srcmac.
 
@@ -101,6 +106,9 @@ Examples:
                               IPDST_RND, UDPSRC_RND,
                               UDPDST_RND, MACSRC_RND, MACDST_RND 
                               MPLS_RND, VID_RND, SVID_RND
+                              QUEUE_MAP_RND # queue map random
+                              QUEUE_MAP_CPU # queue map mirrors smp_processor_id()
+
 
  pgset "udp_src_min 9"   set UDP source port min, If < udp_src_max, then
                          cycle through the port range.
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index b694552..421857c 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2212,7 +2212,7 @@ static void set_cur_queue_map(struct pktgen_dev *pkt_dev)
 	if (pkt_dev->flags & F_QUEUE_MAP_CPU)
 		pkt_dev->cur_queue_map = smp_processor_id();
 
-	else if (pkt_dev->queue_map_min < pkt_dev->queue_map_max) {
+	else if (pkt_dev->queue_map_min <= pkt_dev->queue_map_max) {
 		__u16 t;
 		if (pkt_dev->flags & F_QUEUE_MAP_RND) {
 			t = random32() %
