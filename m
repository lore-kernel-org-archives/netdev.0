From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 2/5] pktgen: set different default min_pkt_size for different protocols
Date: Tue,  9 Oct 2012 18:05:28 +0800
Message-ID: <1349777131-4425-2-git-send-email-amwang@redhat.com>
References: <1349777131-4425-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56894 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755258Ab2JIKFp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2012 06:05:45 -0400
In-Reply-To: <1349777131-4425-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ETH_ZLEN is too small for IPv6, so this default value is not
suitable.

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/core/pktgen.c |   26 +++++++++++++++++++-------
 1 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index e356b8d..16921c3 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -248,8 +248,8 @@ struct pktgen_dev {
 	int removal_mark;	/* non-zero => the device is marked for
 				 * removal by worker thread */
 
-	int min_pkt_size;	/* = ETH_ZLEN; */
-	int max_pkt_size;	/* = ETH_ZLEN; */
+	int min_pkt_size;
+	int max_pkt_size;
 	int pkt_overhead;	/* overhead for MPLS, VLANs, IPSEC etc */
 	int nfrags;
 	struct page *page;
@@ -2036,10 +2036,16 @@ static void pktgen_setup_inject(struct pktgen_dev *pkt_dev)
 	/* Set up Dest MAC */
 	memcpy(&(pkt_dev->hh[0]), pkt_dev->dst_mac, ETH_ALEN);
 
-	/* Set up pkt size */
-	pkt_dev->cur_pkt_size = pkt_dev->min_pkt_size;
-
 	if (pkt_dev->flags & F_IPV6) {
+		if (pkt_dev->min_pkt_size == 0) {
+			pkt_dev->min_pkt_size = 14 + sizeof(struct ipv6hdr)
+						+ sizeof(struct udphdr)
+						+ sizeof(struct pktgen_hdr)
+						+ pkt_dev->pkt_overhead;
+		}
+
+		pkt_dev->cur_pkt_size = pkt_dev->min_pkt_size;
+
 		/*
 		 * Skip this automatic address setting until locks or functions
 		 * gets exported
@@ -2086,6 +2092,14 @@ static void pktgen_setup_inject(struct pktgen_dev *pkt_dev)
 		}
 #endif
 	} else {
+		if (pkt_dev->min_pkt_size == 0) {
+			pkt_dev->min_pkt_size = 14 + sizeof(struct iphdr)
+						+ sizeof(struct udphdr)
+						+ sizeof(struct pktgen_hdr)
+						+ pkt_dev->pkt_overhead;
+		}
+		pkt_dev->cur_pkt_size = pkt_dev->min_pkt_size;
+
 		pkt_dev->saddr_min = 0;
 		pkt_dev->saddr_max = 0;
 		if (strlen(pkt_dev->src_min) == 0) {
@@ -3548,8 +3562,6 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 	}
 
 	pkt_dev->removal_mark = 0;
-	pkt_dev->min_pkt_size = ETH_ZLEN;
-	pkt_dev->max_pkt_size = ETH_ZLEN;
 	pkt_dev->nfrags = 0;
 	pkt_dev->delay = pg_delay_d;
 	pkt_dev->count = pg_count_d;
-- 
1.7.7.6
