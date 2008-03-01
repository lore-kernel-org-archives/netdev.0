From: Patrick McManus <mcmanus@ducksong.com>
Subject: [PATCH 2/3] TCP_DEFER_ACCEPT updates - dont retxmt synack
Date: Sat, 01 Mar 2008 16:01:08 -0500
Message-ID: <1204405268.5792.31.camel@tng>
References: <1204405149.5792.28.camel@tng>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from linode.ducksong.com ([64.22.125.164]:40081 "EHLO
	linode.ducksong.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757805AbYCAVBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Mar 2008 16:01:03 -0500
Received: from [192.168.16.214] (cpe-76-179-219-229.maine.res.rr.com [76.179.219.229])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by linode.ducksong.com (Postfix) with ESMTP id C675010162
	for <netdev@vger.kernel.org>; Sat,  1 Mar 2008 16:01:02 -0500 (EST)
In-Reply-To: <1204405149.5792.28.camel@tng>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

    a socket in LISTEN that had completed its 3 way handshake, but not notified
    userspace because of SO_DEFER_ACCEPT, would retransmit the already
    acked syn-ack during the time it was waiting for the first data byte
    from the peer.


Signed-off-by: Patrick McManus <mcmanus@ducksong.com>
Acked-by: Eric Dumazet <dada1@cosmosbay.com>

----

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 03cc323..7216f5e 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -461,8 +461,9 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
                reqp=&lopt->syn_table[i];
                while ((req = *reqp) != NULL) {
                        if (time_after_eq(now, req->expires)) {
-                               if ((req->retrans < (inet_rsk(req)->acked ? max_retries : thresh))
-                                   && !req->rsk_ops->rtx_syn_ack(parent, req, NULL)) {
+                               if ((req->retrans < (inet_rsk(req)->acked ? max_retries : thresh))
+                                   &&  (inet_rsk(req)->acked ||
+                                        !req->rsk_ops->rtx_syn_ack(parent, req, NULL))) {
                                        unsigned long timeo;

                                        if (req->retrans++ == 0)


