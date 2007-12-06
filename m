From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH] SCTP: Add bind hash locking to the migrate code
Date: Thu,  6 Dec 2007 12:48:23 -0500
Message-ID: <1196963304-32494-2-git-send-email-vladislav.yasevich@hp.com>
References: <1196963304-32494-1-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:6619 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990AbXLFRs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 12:48:26 -0500
In-Reply-To: <1196963304-32494-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SCTP accept code tries to add a newliy created socket
to a bind bucket without holding a lock.   On a really
busy system, that can causes slab corruptions.
Add a lock around this code.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/socket.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index ff8bc95..9f5d793 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -6325,6 +6325,7 @@ static void sctp_sock_migrate(struct sock *oldsk, struct sock *newsk,
 	struct sctp_endpoint *newep = newsp->ep;
 	struct sk_buff *skb, *tmp;
 	struct sctp_ulpevent *event;
+	struct sctp_bind_hashbucket *head;
 	int flags = 0;
 
 	/* Migrate socket buffer sizes and all the socket level options to the
@@ -6342,10 +6343,15 @@ static void sctp_sock_migrate(struct sock *oldsk, struct sock *newsk,
 	newsp->hmac = NULL;
 
 	/* Hook this new socket in to the bind_hash list. */
+	head = &sctp_port_hashtable[sctp_phashfn(inet_sk(oldsk)->num)];
+	sctp_local_bh_disable();
+	sctp_spin_lock(&head->lock);
 	pp = sctp_sk(oldsk)->bind_hash;
 	sk_add_bind_node(newsk, &pp->owner);
 	sctp_sk(newsk)->bind_hash = pp;
 	inet_sk(newsk)->num = inet_sk(oldsk)->num;
+	sctp_spin_unlock(&head->lock);
+	sctp_local_bh_enable();
 
 	/* Copy the bind_addr list from the original endpoint to the new
 	 * endpoint so that we can handle restarts properly
-- 
1.5.3.5

