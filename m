From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp/dccp: remove obsolete WARN_ON() in icmp handlers
Date: Wed, 16 Mar 2016 22:52:15 -0700
Message-ID: <1458193935.7353.44.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Ben Lazarus <blazarus@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:34375 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751564AbcCQFwS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 01:52:18 -0400
Received: by mail-pf0-f172.google.com with SMTP id x3so105717458pfb.1
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 22:52:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Now SYN_RECV request sockets are installed in ehash table, an ICMP
handler can find a request socket while another cpu handles an incoming
packet transforming this SYN_RECV request socket into an ESTABLISHED
socket.

We need to remove the now obsolete WARN_ON(req->sk), since req->sk
is set when a new child is created and added into listener accept queue.

If this race happens, the ICMP will do nothing special.

Fixes: 079096f103fa ("tcp/dccp: install syn_recv requests into ehash table")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Ben Lazarus <blazarus@google.com>
Reported-by: Neal Cardwell <ncardwell@google.com>
---
 net/dccp/ipv4.c     |    2 --
 net/ipv4/tcp_ipv4.c |    2 --
 2 files changed, 4 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index b5672e5fe649..9c67a961ba53 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -204,8 +204,6 @@ void dccp_req_err(struct sock *sk, u64 seq)
 	 * ICMPs are not backlogged, hence we cannot get an established
 	 * socket here.
 	 */
-	WARN_ON(req->sk);
-
 	if (!between48(seq, dccp_rsk(req)->dreq_iss, dccp_rsk(req)->dreq_gss)) {
 		NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
 	} else {
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 0b02ef773705..e7528b101e68 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -319,8 +319,6 @@ void tcp_req_err(struct sock *sk, u32 seq, bool abort)
 	/* ICMPs are not backlogged, hence we cannot get
 	 * an established socket here.
 	 */
-	WARN_ON(req->sk);
-
 	if (seq != tcp_rsk(req)->snt_isn) {
 		NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
 	} else if (abort) {
