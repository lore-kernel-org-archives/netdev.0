From: Aaron Conole <aconole@bytheb.org>
Subject: [PATCH v2] [net] af_unix: return data from multiple SKBs on recv() with MSG_PEEK flag
Date: Sun, 20 Sep 2015 05:18:25 -0400
Message-ID: <1442740705-16452-1-git-send-email-aconole@bytheb.org>
Cc: Aaron Conole <aaron@bytheb.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:36253 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753769AbbITJS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2015 05:18:59 -0400
Received: by qgx61 with SMTP id 61so69572001qgx.3
        for <netdev@vger.kernel.org>; Sun, 20 Sep 2015 02:18:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Conole <aaron@bytheb.org>

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

Signed-off-by: Aaron Conole <aaron@bytheb.org>
---
 net/unix/af_unix.c | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 03ee4d3..988fbbd4 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2179,9 +2179,24 @@ unlock:
 			if (UNIXCB(skb).fp)
 				scm.fp = scm_fp_dup(UNIXCB(skb).fp);
 
-			sk_peek_offset_fwd(sk, chunk);
+			if (skip) {
+				sk_peek_offset_fwd(sk, chunk);
+				skip -= chunk;
+			}
 
-			break;
+			if (UNIXCB(skb).fp)
+				break;
+
+			/* XXX - this is ugly; a better approach would be
+			 * rewriting this function
+			 */
+			last = skb;
+			last_len = skb->len;
+			unix_state_lock(&sk);
+			skb = skb_peek_next(skb, &sk->sk_receive_queue);
+			if (skb)
+				goto again;
+			goto unlock;
 		}
 	} while (size);
 
-- 
1.9.1
