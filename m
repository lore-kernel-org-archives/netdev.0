From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/6] tcp: timestamp code clarification
Date: Thu, 10 Mar 2011 08:51:24 -0800
Message-ID: <20110310165328.905636243@vyatta.com>
References: <20110310165119.224046957@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, sangtae.ha@gmail.com, rhee@ncsu.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:45017 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753290Ab1CJQ4V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2011 11:56:21 -0500
Content-Disposition: inline; filename=tcp-input-tstamp-clean.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use inline functions to make the checking of ack timestamp clearer.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv4/tcp_input.c	2011-03-10 07:58:37.715948842 -0800
+++ b/net/ipv4/tcp_input.c	2011-03-10 07:58:38.419937963 -0800
@@ -3263,7 +3263,7 @@ static int tcp_clean_rtx_queue(struct so
 				flag |= FLAG_NONHEAD_RETRANS_ACKED;
 		} else {
 			ca_seq_rtt = now - scb->when;
-			last_ackt = skb->tstamp;
+			last_ackt = skb_get_ktime(skb);
 			if (seq_rtt < 0) {
 				seq_rtt = ca_seq_rtt;
 			}
@@ -3345,9 +3345,8 @@ static int tcp_clean_rtx_queue(struct so
 			/* Is the ACK triggering packet unambiguous? */
 			if (!(flag & FLAG_RETRANS_DATA_ACKED)) {
 				/* High resolution needed and available? */
-				if (ca_ops->flags & TCP_CONG_RTT_STAMP &&
-				    !ktime_equal(last_ackt,
-						 net_invalid_timestamp()))
+				if ((ca_ops->flags & TCP_CONG_RTT_STAMP) &&
+				    net_timestamp_isvalid(last_ackt))
 					rtt_us = ktime_us_delta(ktime_get_real(),
 								last_ackt);
 				else if (ca_seq_rtt >= 0)
--- a/include/linux/skbuff.h	2011-03-10 07:55:27.181150325 -0800
+++ b/include/linux/skbuff.h	2011-03-10 07:58:38.419937963 -0800
@@ -1965,6 +1965,11 @@ static inline ktime_t net_invalid_timest
 	return ktime_set(0, 0);
 }
 
+static inline bool net_timestamp_isvalid(ktime_t t)
+{
+	return !ktime_equal(t, net_invalid_timestamp());
+}
+
 extern void skb_timestamping_init(void);
 
 #ifdef CONFIG_NETWORK_PHY_TIMESTAMPING


