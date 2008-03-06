From: Patrick McManus <mcmanus@ducksong.com>
Subject: [PATCH 2/3 resend] TCP_DEFER_ACCEPT updates - dont retxmt synack
Date: Thu, 06 Mar 2008 18:52:50 -0500
Message-ID: <1204847570.17097.19.camel@tng>
References: <1204847472.17097.17.camel@tng>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from linode.ducksong.com ([64.22.125.164]:50785 "EHLO
	linode.ducksong.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758194AbYCFXwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 18:52:34 -0500
Received: from [192.168.16.214] (cpe-76-179-219-229.maine.res.rr.com [76.179.219.229])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by linode.ducksong.com (Postfix) with ESMTP id 9D0AD10163
	for <netdev@vger.kernel.org>; Thu,  6 Mar 2008 18:52:33 -0500 (EST)
In-Reply-To: <1204847472.17097.17.camel@tng>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 95dea62ad7004a1de84e1f38c1b5243e1cb0d554
Author: Patrick McManus <mcmanus@ducksong.com>
Date:   Sat Feb 23 15:59:22 2008 -0500

    a socket in LISTEN that had completed its 3 way handshake, but not notified
    userspace because of SO_DEFER_ACCEPT, would retransmit the already
    acked syn-ack during the time it was waiting for the first data byte
    from the peer.
    
    Signed-off-by: Patrick McManus <mcmanus@ducksong.com>
    Acked-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 03cc323..3380d04 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -461,8 +461,9 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
 		reqp=&lopt->syn_table[i];
 		while ((req = *reqp) != NULL) {
 			if (time_after_eq(now, req->expires)) {
-				if ((req->retrans < (inet_rsk(req)->acked ? max_retries : thresh))
-				    && !req->rsk_ops->rtx_syn_ack(parent, req, NULL)) {
+				if ((req->retrans < (inet_rsk(req)->acked ? max_retries : thresh)) &&
+				    (inet_rsk(req)->acked ||
+				     !req->rsk_ops->rtx_syn_ack(parent, req, NULL))) {
 					unsigned long timeo;
 
 					if (req->retrans++ == 0)


