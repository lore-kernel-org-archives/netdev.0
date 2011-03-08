From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] tcp_cubic: enable TCP timestamps
Date: Tue, 8 Mar 2011 11:17:57 -0800
Message-ID: <20110308111757.7db14e58@nehalam>
References: <20110308080926.GA22641@xanadu.blop.info>
	<20110308104211.3567526f@nehalam>
	<20110308.105503.104060436.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lucas.nussbaum@loria.fr, netdev@vger.kernel.org, sha2@ncsu.edu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57422 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754438Ab1CHTSA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2011 14:18:00 -0500
In-Reply-To: <20110308.105503.104060436.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 08 Mar 2011 10:55:03 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

Complete the sentence...

>  on old desktops.  

   But without it enabling RTT_STAMP, packets that
   get acked in less than a jiffie (1 - 10 ms) will 
   be processed with no rtt value (-1); this causes hystart
   never to be invoked on local connections.

Maybe the following would be better, it passes 0 as RTT
when not using RTT_STAMP for quick packets.

It turns out the Cubic ends up converting rtt_us back
to jiffies anyway, so RTT_STAMP is not really needed.

----
Subject: tcp: fix RTT for quick packets in congestion control

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
 
