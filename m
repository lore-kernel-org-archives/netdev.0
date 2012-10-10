From: Cong Wang <amwang@redhat.com>
Subject: [Patch v2 1/5] pktgen: fix crash when generating IPv6 packets
Date: Wed, 10 Oct 2012 11:48:16 +0800
Message-ID: <1349840900-24138-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>, <stable@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12107 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754618Ab2JJDs3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2012 23:48:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For IPv6, sizeof(struct ipv6hdr) = 40, thus the following
expression will result negative:

        datalen = pkt_dev->cur_pkt_size - 14 -
                  sizeof(struct ipv6hdr) - sizeof(struct udphdr) -
                  pkt_dev->pkt_overhead;

And,  the check "if (datalen < sizeof(struct pktgen_hdr))" will be
passed as "datalen" is promoted to unsigned, therefore will cause
a crash later.

This is a quick fix by checking if "datalen" is negative. The following
patch will increase the default value of 'min_pkt_size' for IPv6.

This bug should exist for a long time, so Cc -stable too.

Cc: <stable@vger.kernel.org>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/core/pktgen.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 148e73d..e356b8d 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2927,7 +2927,7 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 		  sizeof(struct ipv6hdr) - sizeof(struct udphdr) -
 		  pkt_dev->pkt_overhead;
 
-	if (datalen < sizeof(struct pktgen_hdr)) {
+	if (datalen < 0 || datalen < sizeof(struct pktgen_hdr)) {
 		datalen = sizeof(struct pktgen_hdr);
 		net_info_ratelimited("increased datalen to %d\n", datalen);
 	}
-- 
1.7.7.6
