From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/6] tcp: fix RTT for quick packets in congestion control
Date: Thu, 10 Mar 2011 08:51:23 -0800
Message-ID: <20110310165328.811355927@vyatta.com>
References: <20110310165119.224046957@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, sangtae.ha@gmail.com, rhee@ncsu.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:45020 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753683Ab1CJQ4X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2011 11:56:23 -0500
Content-Disposition: inline; filename=tcp-input-rtt.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the congestion control interface, the callback for each ACK
includes an estimated round trip time in microseconds.
Some algorithms need high resolution (Vegas style) but most only
need jiffie resolution.  If RTT is not accurate (like a retransmission)
-1 is used as a flag value.

When doing coarse resolution if RTT is less than a a jiffie
then 0 should be returned rather than no estimate. Otherwise algorithms
that expect good ack's to trigger slow start (like CUBIC Hystart)
will be confused.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv4/tcp_input.c	2011-03-08 11:11:26.093183654 -0800
+++ b/net/ipv4/tcp_input.c	2011-03-08 11:11:46.641404939 -0800
@@ -3350,7 +3350,7 @@ static int tcp_clean_rtx_queue(struct so
 						 net_invalid_timestamp()))
 					rtt_us = ktime_us_delta(ktime_get_real(),
 								last_ackt);
-				else if (ca_seq_rtt > 0)
+				else if (ca_seq_rtt >= 0)
 					rtt_us = jiffies_to_usecs(ca_seq_rtt);
 			}
 


