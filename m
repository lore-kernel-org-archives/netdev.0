From: Alexey Kodanev <alexey.kodanev@oracle.com>
Subject: [PATCH] tcp: initialize max window for a new fastopen socket
Date: Thu, 19 Jan 2017 16:36:39 +0300
Message-ID: <1484832999-1849-1-git-send-email-alexey.kodanev@oracle.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Alexey Kodanev <alexey.kodanev@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:29553 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751931AbdASNbX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 08:31:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Found that if we run LTP netstress test with large MSS (65K),
the first attempt from server to send data comparable to this
MSS on fastopen connection will be delayed by the probe timer.

Here is an example:

     < S  seq 0:0 win 43690 options [mss 65495 wscale 7 tfo cookie] length 32
     > S. seq 0:0 ack 1 win 43690 options [mss 65495 wscale 7] length 0
     < .  ack 1 win 342 length 0

Inside tcp_sendmsg(), tcp_send_mss() returns max MSS in 'mss_now',
as well as in 'size_goal'. This results the segment not queued for
transmition until all the data copied from user buffer. Then, inside
__tcp_push_pending_frames(), it breaks on send window test and
continues with the check probe timer.

Fragmentation occurs in tcp_write_wakeup()...

+0.2 > P. seq 1:43777 ack 1 win 342 length 43776
     < .  ack 43777, win 1365 length 0
     > P. seq 43777:65001 ack 1 win 342 options [...] length 21224
     ...

This also contradicts with the fact that we should bound to the half
of the window if it is large.

Fix this flaw by correctly initializing max_window. Before that, it
could have large values that affect further calculations of 'size_goal'.

Fixes: 168a8f58059a ("tcp: TCP Fast Open Server - main code path")
Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>
---
 net/ipv4/tcp_fastopen.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index f519195..dd2560c 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -205,6 +205,7 @@ void tcp_fastopen_add_skb(struct sock *sk, struct sk_buff *skb)
 	 * scaled. So correct it appropriately.
 	 */
 	tp->snd_wnd = ntohs(tcp_hdr(skb)->window);
+	tp->max_window = tp->snd_wnd;
 
 	/* Activate the retrans timer so that SYNACK can be retransmitted.
 	 * The request socket is not added to the ehash
-- 
1.7.1
