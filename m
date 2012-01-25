From: Flavio Leitner <fbl@redhat.com>
Subject: [PATCH 2/2] tcp: bind() optimize port allocation
Date: Wed, 25 Jan 2012 16:34:52 -0200
Message-ID: <1327516492-9045-2-git-send-email-fbl@redhat.com>
References: <1327516492-9045-1-git-send-email-fbl@redhat.com>
Cc: Marcelo Leitner <mleitner@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Flavio Leitner <fbl@redhat.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33858 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751036Ab2AYSfG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jan 2012 13:35:06 -0500
In-Reply-To: <1327516492-9045-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Port autoselection finds a port and then drop the lock,
then right after that, gets the hash bucket again and lock it.

Fix it to go direct.

Signed-off-by: Flavio Leitner <fbl@redhat.com>
---
 net/ipv4/inet_connection_sock.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index ecd19b5..19d66ce 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -123,15 +123,13 @@ again:
 						smallest_size = tb->num_owners;
 						smallest_rover = rover;
 						if (atomic_read(&hashinfo->bsockets) > (high - low) + 1) {
-							spin_unlock(&head->lock);
 							snum = smallest_rover;
-							goto have_snum;
+							goto tb_found;
 						}
 					}
 					if (!inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb)) {
-						spin_unlock(&head->lock);
 						snum = rover;
-						goto have_snum;
+						goto tb_found;
 					}
 					goto next;
 				}
-- 
1.7.7.1
