From: Nishank Trivedi <nistrive@cisco.com>
Subject: [PATCH] pktgen: fix crash with vlan and packet size less than 46
Date: Wed, 12 Sep 2012 16:32:49 -0700
Message-ID: <1347492769-32409-1-git-send-email-nistrive@cisco.com>
Cc: benve@cisco.com, Nishank Trivedi <nistrive@cisco.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-3.cisco.com ([173.36.130.14]:61728 "EHLO
	mtv-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933080Ab2ILXmc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 19:42:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If vlan option is being specified in the pktgen and packet size
being requested is less than 46 bytes, despite being illogical
request, pktgen should not crash the kernel.

BUG: unable to handle kernel paging request at ffff88021fb82000
Process kpktgend_0 (pid: 1184, threadinfo ffff880215f1a000, task ffff880218544530)
Call Trace:
[<ffffffffa0637cd2>] ? pktgen_finalize_skb+0x222/0x300 [pktgen]
[<ffffffff814f0084>] ? build_skb+0x34/0x1c0
[<ffffffffa0639b11>] pktgen_thread_worker+0x5d1/0x1790 [pktgen]
[<ffffffffa03ffb10>] ? igb_xmit_frame_ring+0xa30/0xa30 [igb]
[<ffffffff8107ba20>] ? wake_up_bit+0x40/0x40
[<ffffffff8107ba20>] ? wake_up_bit+0x40/0x40
[<ffffffffa0639540>] ? spin+0x240/0x240 [pktgen]
[<ffffffff8107b4e3>] kthread+0x93/0xa0
[<ffffffff81615de4>] kernel_thread_helper+0x4/0x10
[<ffffffff8107b450>] ? flush_kthread_worker+0x80/0x80
[<ffffffff81615de0>] ? gs_change+0x13/0x13

The root cause of why pktgen is not able to handle this case is due
to comparison of signed (datalen) and unsigned data (sizeof), which
eventually passes a huge number to skb_put().

Signed-off-by: Nishank Trivedi <nistrive@cisco.com>
---
 net/core/pktgen.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index cce9e53..148e73d 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2721,7 +2721,7 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 	/* Eth + IPh + UDPh + mpls */
 	datalen = pkt_dev->cur_pkt_size - 14 - 20 - 8 -
 		  pkt_dev->pkt_overhead;
-	if (datalen < sizeof(struct pktgen_hdr))
+	if (datalen < 0 || datalen < sizeof(struct pktgen_hdr))
 		datalen = sizeof(struct pktgen_hdr);
 
 	udph->source = htons(pkt_dev->cur_udp_src);
-- 
1.7.11.4
