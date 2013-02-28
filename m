From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net] tcp: Don't collapse if resulting skb could overflow
 skb->csum_start
Date: Thu, 28 Feb 2013 10:26:03 +0000
Message-ID: <20130228102603.GA7558@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, foraker1@llnl.gov
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:48853 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751370Ab3B1K0G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 05:26:06 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a TCP retransmission gets partially ACKed and collapsed multiple
times it is possible for the headroom to grow beyond 64K which will
overflow the 16bit skb->csum_start which is based on the start of
the headroom. It has been observed rarely in the wild with IPoIB due
to the 64K MTU.

With this patch, the overflow has not been observed for over a week
while previously it would occur within ~ 1 day.

A big thank you to Jim Foraker <foraker1@llnl.gov> and the team at
LLNL for helping out with the investigation and testing.

Reported-by: Jim Foraker <foraker1@llnl.gov>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/ipv4/tcp_output.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index e2b4461..1902fee 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2305,6 +2305,12 @@ static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *to,
 		if (after(TCP_SKB_CB(skb)->end_seq, tcp_wnd_end(tp)))
 			break;
 
+		/* Never collapse if the resulting headroom + data exceeds
+		 * 64K as that is the maximum csum_start can cover.
+		 */
+		if (skb_headroom(to) + to->len + skb->len > 0xFFFF)
+			break;
+
 		tcp_collapse_retrans(sk, to);
 	}
 }
