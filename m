From: Flavio Leitner <fbl@redhat.com>
Subject: [PATCH 1/2] tcp: bind() fix autoselection to share ports
Date: Wed, 25 Jan 2012 16:34:51 -0200
Message-ID: <1327516492-9045-1-git-send-email-fbl@redhat.com>
Cc: Marcelo Leitner <mleitner@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Flavio Leitner <fbl@redhat.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29850 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751028Ab2AYSfC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jan 2012 13:35:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code checks for conflicts when the application
requests a specific port.  If there is no conflict, then
the request is granted.

On the other hand, the port autoselection done by the kernel
fails when all ports are bound even when there is a port
with no conflict available.

The fix changes port autoselection to check if there is a
conflict and use it if not.

Signed-off-by: Flavio Leitner <fbl@redhat.com>
---
 net/ipv4/inet_connection_sock.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 2e4e244..ecd19b5 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -128,6 +128,11 @@ again:
 							goto have_snum;
 						}
 					}
+					if (!inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb)) {
+						spin_unlock(&head->lock);
+						snum = rover;
+						goto have_snum;
+					}
 					goto next;
 				}
 			break;
-- 
1.7.7.1
