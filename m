From: Aji_Srinivas@emc.com
Subject: [PATCH] TCP: zero out rx_opt in tcp_disconnect()
Date: Thu, 3 May 2007 11:53:36 -0700
Message-ID: <20070503185336.GA19639@rainfinity.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:38831 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755337AbXECSxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 14:53:39 -0400
Received: from mailhub.lss.emc.com (nirah.lss.emc.com [10.254.144.13])
	by mexforward.lss.emc.com (Switch-3.2.5/Switch-3.1.7) with ESMTP id l43IrcE7023618
	for <netdev@vger.kernel.org>; Thu, 3 May 2007 14:53:38 -0400 (EDT)
Received: from localhost ([128.222.177.151])
	by mailhub.lss.emc.com (Switch-3.2.5/Switch-3.1.7) with ESMTP id l43IratR009110
	for <netdev@vger.kernel.org>; Thu, 3 May 2007 14:53:37 -0400 (EDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the server drops its connection, NFS client reconnects using the
same socket after disconnecting. If the new connection's SYN,ACK
doesn't contain the TCP timestamp option and the old connection's did,
tp->tcp_header_len is recomputed assuming no timestamp header but
tp->rx_opt.tstamp_ok remains set. Then tcp_build_and_update_options()
adds in a timestamp option past the end of the allocated TCP header,
overwriting TCP data, or when the data is in skb_shinfo(skb)->frags[],
overwriting skb_shinfo(skb) causing a crash soon after. (The issue was
debugged from such a crash.)

Similarly, wscale_ok and sack_ok also get set based on the SYN,ACK
packet but not reset on disconnect, since they are zeroed out at
initialization. The patch zeroes out the entire tp->rx_opt struct in
tcp_disconnect() to avoid this sort of problem.

Signed-off-by: Srinivas Aji <Aji_Srinivas@emc.com>
---
 net/ipv4/tcp.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index d6e4886..8b124ea 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1760,8 +1760,7 @@ int tcp_disconnect(struct sock *sk, int flags)
 	tcp_clear_retrans(tp);
 	inet_csk_delack_init(sk);
 	tcp_init_send_head(sk);
-	tp->rx_opt.saw_tstamp = 0;
-	tcp_sack_reset(&tp->rx_opt);
+	memset(&tp->rx_opt, 0, sizeof(tp->rx_opt));
 	__sk_dst_reset(sk);
 
 	BUG_TRAP(!inet->num || icsk->icsk_bind_hash);
