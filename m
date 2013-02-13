From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/2] net: sctp: add build check for sctp_sf_eat_sack_6_2/jsctp_sf_eat_sack
Date: Wed, 13 Feb 2013 12:03:50 +0100
Message-ID: <84afa536e3652ea27a7efb1f6c9f7c4f29c15043.1360752304.git.dborkman@redhat.com>
References: <7eef4b701794c1bb78819bc6e6c45bf99b49801d.1360752304.git.dborkman@redhat.com>
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33482 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932536Ab3BMLDy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Feb 2013 06:03:54 -0500
In-Reply-To: <7eef4b701794c1bb78819bc6e6c45bf99b49801d.1360752304.git.dborkman@redhat.com>
In-Reply-To: <cover.1360752304.git.dborkman@redhat.com>
References: <cover.1360752304.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to avoid any future surprises of kernel panics due to jprobes
function mismatches (as e.g. fixed in 4cb9d6eaf85ecd: sctp: jsctp_sf_eat_sack:
fix jprobes function signature mismatch), we should check both function
types during build and scream loudly if they do not match. __same_type
resolves to __builtin_types_compatible_p, which is 1 in case both types
are the same and 0 otherwise, qualifiers are ignored. Tested by myself.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/probe.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/sctp/probe.c b/net/sctp/probe.c
index 4eaaaf6..261b7b9 100644
--- a/net/sctp/probe.c
+++ b/net/sctp/probe.c
@@ -183,6 +183,13 @@ static __init int sctpprobe_init(void)
 {
 	int ret = -ENOMEM;
 
+	/* Warning: if the function signature of sctp_sf_eat_sack_6_2,
+	 * has been changed, you also have to change the signature of
+	 * jsctp_sf_eat_sack, otherwise you end up right here!
+	 */
+	BUILD_BUG_ON(__same_type(sctp_sf_eat_sack_6_2,
+				 jsctp_sf_eat_sack) == 0);
+
 	init_waitqueue_head(&sctpw.wait);
 	spin_lock_init(&sctpw.lock);
 	if (kfifo_alloc(&sctpw.fifo, bufsize, GFP_KERNEL))
-- 
1.7.11.7
