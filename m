From: Aaron Conole <aconole@bytheb.org>
Subject: [PATCH v3 2/2] [net] af_unix: return data from multiple SKBs on recv() with MSG_PEEK flag
Date: Mon, 21 Sep 2015 20:27:02 -0400
Message-ID: <1442881622-11316-3-git-send-email-aconole@bytheb.org>
References: <1442881622-11316-1-git-send-email-aconole@bytheb.org>
Cc: Aaron Conole <aconole@bytheb.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:32913 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756923AbbIVA1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 20:27:16 -0400
Received: by qgev79 with SMTP id v79so104295152qge.0
        for <netdev@vger.kernel.org>; Mon, 21 Sep 2015 17:27:15 -0700 (PDT)
In-Reply-To: <1442881622-11316-1-git-send-email-aconole@bytheb.org>
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
 net/unix/af_unix.c | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 03ee4d3..f8ef53f 100644
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
+			unix_state_lock(sk);
+			skb = skb_peek_next(skb, &sk->sk_receive_queue);
+			if (skb)
+				goto again;
+			goto unlock;
 		}
 	} while (size);
 
-- 
1.9.1
