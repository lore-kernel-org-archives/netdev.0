From: Paul Moore <pmoore@redhat.com>
Subject: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK packet
Date: Mon, 08 Apr 2013 11:45:19 -0400
Message-ID: <20130408154519.18177.57709.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Miroslav Vadkerti <mvadkert@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55088 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936454Ab3DHPpV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Apr 2013 11:45:21 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r38FjKT7013543
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 8 Apr 2013 11:45:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 90ba9b1986b5ac4b2d184575847147ea7c4280a2 converted
tcp_make_synack() to use alloc_skb() directly instead of calling
sock_wmalloc(), the goal being the elimination of two atomic
operations.  Unfortunately, in doing so the change broke certain
SELinux/NetLabel configurations by no longer correctly assigning
the sock to the outgoing packet.

This patch fixes this regression by doing the skb->sk assignment
directly inside tcp_make_synack().

Reported-by: Miroslav Vadkerti <mvadkert@redhat.com>
Signed-off-by: Paul Moore <pmoore@redhat.com>
---
 net/ipv4/tcp_output.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 5d0b438..23cc295 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2705,6 +2705,8 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 		dst_release(dst);
 		return NULL;
 	}
+	skb->sk = sk;
+
 	/* Reserve space for headers. */
 	skb_reserve(skb, MAX_TCP_HEADER);
 
