From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] net: llc: fix use after free in llc_ui_recvmsg
Date: Mon, 30 Dec 2013 23:40:50 +0100
Message-ID: <1388443250-30224-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1138 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932334Ab3L3WlB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Dec 2013 17:41:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While commit 30a584d944fb fixes datagram interface in LLC, a use
after free bug has been introduced for SOCK_STREAM sockets that do
not make use of MSG_PEEK.

The flow is as follow ...

  if (!(flags & MSG_PEEK)) {
    ...
    sk_eat_skb(sk, skb, false);
    ...
  }
  ...
  if (used + offset < skb->len)
    continue;

... where sk_eat_skb() calls __kfree_skb(). Therefore, cache
original length and work on skb_len to check partial reads.

Fixes: 30a584d944fb ("[LLX]: SOCK_DGRAM interface fixes")
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/llc/af_llc.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index 7b01b9f..c71b699 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -715,7 +715,7 @@ static int llc_ui_recvmsg(struct kiocb *iocb, struct socket *sock,
 	unsigned long cpu_flags;
 	size_t copied = 0;
 	u32 peek_seq = 0;
-	u32 *seq;
+	u32 *seq, skb_len;
 	unsigned long used;
 	int target;	/* Read at least this many bytes */
 	long timeo;
@@ -812,6 +812,7 @@ static int llc_ui_recvmsg(struct kiocb *iocb, struct socket *sock,
 		}
 		continue;
 	found_ok_skb:
+		skb_len = skb->len;
 		/* Ok so how much can we use? */
 		used = skb->len - offset;
 		if (len < used)
@@ -844,7 +845,7 @@ static int llc_ui_recvmsg(struct kiocb *iocb, struct socket *sock,
 		}
 
 		/* Partial read */
-		if (used + offset < skb->len)
+		if (used + offset < skb_len)
 			continue;
 	} while (len > 0);
 
-- 
1.7.11.7
