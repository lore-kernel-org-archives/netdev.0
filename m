From: Chris Clark <chris.clark@alcatel-lucent.com>
Subject: [PATCH] ipv4: sendto/hdrincl: don't use destination address found
 in header
Date: Tue, 27 Aug 2013 12:02:15 -0600 (MDT)
Message-ID: <alpine.DEB.2.02.1308271153040.2079@optio.utah.ind.alcatel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postal2.ind.alcatel.com ([198.206.184.238]:55723 "EHLO
	ind.alcatel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752603Ab3H0SCR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 14:02:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


ipv4: raw_sendmsg: don't use header's destination address

A sendto() regression was bisected and found to start with commit
f8126f1d5136be1 (ipv4: Adjust semantics of rt->rt_gateway.)

The problem is that it tries to ARP-lookup the constructed packet's
destination address rather than the explicitly provided address.

Fix this using FLOWI_FLAG_KNOWN_NH so that given nexthop is used.

cf. commit 2ad5b9e4bd314fc685086b99e90e5de3bc59e26b

Reported-by: Chris Clark <chris.clark@alcatel-lucent.com>
Bisected-by: Chris Clark <chris.clark@alcatel-lucent.com>
Tested-by: Chris Clark <chris.clark@alcatel-lucent.com>
Suggested-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Chris Clark <chris.clark@alcatel-lucent.com>
---
 net/ipv4/raw.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index dd44e0a..61e60d6 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -571,7 +571,8 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	flowi4_init_output(&fl4, ipc.oif, sk->sk_mark, tos,
 			   RT_SCOPE_UNIVERSE,
 			   inet->hdrincl ? IPPROTO_RAW : sk->sk_protocol,
-			   inet_sk_flowi_flags(sk) | FLOWI_FLAG_CAN_SLEEP,
+			   inet_sk_flowi_flags(sk) | FLOWI_FLAG_CAN_SLEEP |
+			    (inet->hdrincl ? FLOWI_FLAG_KNOWN_NH : 0),
 			   daddr, saddr, 0, 0);

 	if (!inet->hdrincl) {
