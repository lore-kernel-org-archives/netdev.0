From: Aaron Conole <aconole@bytheb.org>
Subject: [PATCH v4 2/2] [net] af_unix: return data from multiple SKBs on recv() with MSG_PEEK flag
Date: Sat, 26 Sep 2015 18:50:43 -0400
Message-ID: <1443307843-16880-3-git-send-email-aconole@bytheb.org>
References: <20150924.121459.1016780653505420756.davem@davemloft.net>
 <1443307843-16880-1-git-send-email-aconole@bytheb.org>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Aaron Conole <aconole@bytheb.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:34332 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753808AbbIZWvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Sep 2015 18:51:06 -0400
Received: by qkfq186 with SMTP id q186so55178304qkf.1
        for <netdev@vger.kernel.org>; Sat, 26 Sep 2015 15:51:06 -0700 (PDT)
In-Reply-To: <1443307843-16880-1-git-send-email-aconole@bytheb.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

AF_UNIX sockets now return multiple skbs from recv() when MSG_PEEK flag
is set.

This is referenced in kernel bugzilla #12323 @
https://bugzilla.kernel.org/show_bug.cgi?id=12323

As described both in the BZ and lkml thread @
http://lkml.org/lkml/2008/1/8/444 calling recv() with MSG_PEEK on an
AF_UNIX socket only reads a single skb, where the desired effect is
to return as much skb data has been queued, until hitting the recv
buffer size (whichever comes first).

The modified MSG_PEEK path will now move to the next skb in the tree
and jump to the again: label, rather than following the natural loop
structure. This requires duplicating some of the loop head actions.

This was tested using the python socketpair python code attached to
the bugzilla issue.

Signed-off-by: Aaron Conole <aconole@bytheb.org>
---
 net/unix/af_unix.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 03ee4d3..ef31b40 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2179,8 +2179,21 @@ unlock:
 			if (UNIXCB(skb).fp)
 				scm.fp = scm_fp_dup(UNIXCB(skb).fp);
 
-			sk_peek_offset_fwd(sk, chunk);
+			if (skip) {
+				sk_peek_offset_fwd(sk, chunk);
+				skip -= chunk;
+			}
 
+			if (UNIXCB(skb).fp)
+				break;
+
+			last = skb;
+			last_len = skb->len;
+			unix_state_lock(sk);
+			skb = skb_peek_next(skb, &sk->sk_receive_queue);
+			if (skb)
+				goto again;
+			unix_state_unlock(sk);
 			break;
 		}
 	} while (size);
-- 
1.9.1
