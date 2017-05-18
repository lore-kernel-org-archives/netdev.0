From: Ihar Hrachyshka <ihrachys@redhat.com>
Subject: [PATCH v2 4/4] arp: always override existing neigh entries with gratuitous ARP
Date: Thu, 18 May 2017 12:41:21 -0700
Message-ID: <e6632af3eda7467c9a61402e8561cef7d6b9d02b.1495136258.git.ihrachys@redhat.com>
References: <cover.1495136258.git.ihrachys@redhat.com>
Cc: Ihar Hrachyshka <ihrachys@redhat.com>, netdev@vger.kernel.org
To: davem@davemloft.net, ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48350 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932441AbdERTll (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 May 2017 15:41:41 -0400
In-Reply-To: <cover.1495136258.git.ihrachys@redhat.com>
In-Reply-To: <cover.1495136258.git.ihrachys@redhat.com>
References: <cover.1495136258.git.ihrachys@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, when arp_accept is 1, we always override existing neigh
entries with incoming gratuitous ARP replies. Otherwise, we override
them only if new replies satisfy _locktime_ conditional (packets arrive
not earlier than _locktime_ seconds since the last update to the neigh
entry).

The idea behind locktime is to pick the very first (=> close) reply
received in a unicast burst when ARP proxies are used. This helps to
avoid ARP thrashing where Linux would switch back and forth from one
proxy to another.

This logic has nothing to do with gratuitous ARP replies that are
generally not aligned in time when multiple IP address carriers send
them into network.

This patch enforces overriding of existing neigh entries by all incoming
gratuitous ARP packets, irrespective of their time of arrival. This will
make the kernel honour all incoming gratuitous ARP packets.

Signed-off-by: Ihar Hrachyshka <ihrachys@redhat.com>
---
 net/ipv4/arp.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index c22103c..ae96e6f 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -863,16 +863,17 @@ static int arp_process(struct net *net, struct sock *sk, struct sk_buff *skb)
 
 	n = __neigh_lookup(&arp_tbl, &sip, dev, 0);
 
-	if (IN_DEV_ARP_ACCEPT(in_dev)) {
+	if (n || IN_DEV_ARP_ACCEPT(in_dev)) {
 		addr_type = -1;
+		is_garp = arp_is_garp(net, dev, &addr_type, arp->ar_op,
+				      sip, tip, sha, tha);
+	}
 
+	if (IN_DEV_ARP_ACCEPT(in_dev)) {
 		/* Unsolicited ARP is not accepted by default.
 		   It is possible, that this option should be enabled for some
 		   devices (strip is candidate)
 		 */
-		is_garp = arp_is_garp(net, dev, &addr_type, arp->ar_op,
-				      sip, tip, sha, tha);
-
 		if (!n &&
 		    (is_garp ||
 		     (arp->ar_op == htons(ARPOP_REPLY) &&
-- 
2.9.3
