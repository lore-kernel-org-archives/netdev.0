From: Cong Wang <amwang@redhat.com>
Subject: [Patch v2 4/5] pktgen: enable automatic IPv6 address setting
Date: Wed, 10 Oct 2012 11:48:19 +0800
Message-ID: <1349840900-24138-4-git-send-email-amwang@redhat.com>
References: <1349840900-24138-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54839 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932216Ab2JJDsf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2012 23:48:35 -0400
In-Reply-To: <1349840900-24138-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/core/pktgen.c |   18 +++++-------------
 1 files changed, 5 insertions(+), 13 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index f9b4637..47fe18e 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2037,6 +2037,9 @@ static void pktgen_setup_inject(struct pktgen_dev *pkt_dev)
 	memcpy(&(pkt_dev->hh[0]), pkt_dev->dst_mac, ETH_ALEN);
 
 	if (pkt_dev->flags & F_IPV6) {
+		int i, set = 0, err = 1;
+		struct inet6_dev *idev;
+
 		if (pkt_dev->min_pkt_size == 0) {
 			pkt_dev->min_pkt_size = 14 + sizeof(struct ipv6hdr)
 						+ sizeof(struct udphdr)
@@ -2044,15 +2047,6 @@ static void pktgen_setup_inject(struct pktgen_dev *pkt_dev)
 						+ pkt_dev->pkt_overhead;
 		}
 
-		/*
-		 * Skip this automatic address setting until locks or functions
-		 * gets exported
-		 */
-
-#ifdef NOTNOW
-		int i, set = 0, err = 1;
-		struct inet6_dev *idev;
-
 		for (i = 0; i < IN6_ADDR_HSIZE; i++)
 			if (pkt_dev->cur_in6_saddr.s6_addr[i]) {
 				set = 1;
@@ -2073,9 +2067,8 @@ static void pktgen_setup_inject(struct pktgen_dev *pkt_dev)
 				struct inet6_ifaddr *ifp;
 
 				read_lock_bh(&idev->lock);
-				for (ifp = idev->addr_list; ifp;
-				     ifp = ifp->if_next) {
-					if (ifp->scope == IFA_LINK &&
+				list_for_each_entry(ifp, &idev->addr_list, if_list) {
+					if ((ifp->scope & IFA_LINK) &&
 					    !(ifp->flags & IFA_F_TENTATIVE)) {
 						pkt_dev->cur_in6_saddr = ifp->addr;
 						err = 0;
@@ -2088,7 +2081,6 @@ static void pktgen_setup_inject(struct pktgen_dev *pkt_dev)
 			if (err)
 				pr_err("ERROR: IPv6 link address not available\n");
 		}
-#endif
 	} else {
 		if (pkt_dev->min_pkt_size == 0) {
 			pkt_dev->min_pkt_size = 14 + sizeof(struct iphdr)
-- 
1.7.7.6
