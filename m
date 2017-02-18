From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 1/2] sctp: flush out queue once assoc state falls into SHUTDOWN_PENDING
Date: Sun, 19 Feb 2017 01:52:45 +0800
Message-ID: <1830885841c7bdd55510396300092f669896f2b0.1487440272.git.lucien.xin@gmail.com>
References: <cover.1487440272.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net,
        David Laight <david.laight@aculab.com>
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35876 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753412AbdBRRzS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Feb 2017 12:55:18 -0500
In-Reply-To: <cover.1487440272.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1487440272.git.lucien.xin@gmail.com>
References: <cover.1487440272.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to flush out queue when assoc state falls into
SHUTDOWN_PENDING if there are still chunks in it, so that the
data can be sent out as soon as possible before sending SHUTDOWN
chunk.

When sctp supports MSG_MORE flag in next patch, this improvement
can also solve the problem that the chunks with MSG_MORE flag
may be stuck in queue when closing an assoc.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/sm_sideeffect.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 51abcc9..25384fa 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -872,6 +872,10 @@ static void sctp_cmd_new_state(sctp_cmd_seq_t *cmds,
 		if (!sctp_style(sk, UDP))
 			sk->sk_state_change(sk);
 	}
+
+	if (sctp_state(asoc, SHUTDOWN_PENDING) &&
+	    !sctp_outq_is_empty(&asoc->outqueue))
+		sctp_outq_uncork(&asoc->outqueue, GFP_ATOMIC);
 }
 
 /* Helper function to delete an association. */
-- 
2.1.0
