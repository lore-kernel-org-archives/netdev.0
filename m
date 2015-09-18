From: Aaron Conole <aconole@bytheb.org>
Subject: [PATCH net] af_unix: return data from multiple SKBs on recv() with MSG_PEEK flag
Date: Fri, 18 Sep 2015 12:04:36 -0400
Message-ID: <f7tvbb7zpbf.fsf@aconole.bos.csb>
Mime-Version: 1.0
Content-Type: text/plain
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:34005 "EHLO
	mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752233AbbIRQEj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 12:04:39 -0400
Received: by qkfq186 with SMTP id q186so21250714qkf.1
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 09:04:38 -0700 (PDT)
Received: from aconole.bos.csb (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id 145sm3834831qhb.20.2015.09.18.09.04.37
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Sep 2015 09:04:37 -0700 (PDT)
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

This was tested using the python socketpair() code attached to the
bugzilla issue.

Signed-off-by: Aaron Conole <aconole@bytheb.org>
---
 net/unix/af_unix.c | 17+-
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 03ee4d3..d2fd342 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2179,9 +2181,22 @@ unlock:
 			if (UNIXCB(skb).fp)
 				scm.fp = scm_fp_dup(UNIXCB(skb).fp);
 
-			sk_peek_offset_fwd(sk, chunk);
+			if (skip)
+			{
+				sk_peek_offset_fwd(sk, chunk);
+				skip -= chunk;
+			}
 
-			break;
+			if (UNIXCB(skb).fp)
+				break;
+
+			/* XXX - this is ugly; better would be rewrite the function  */
+			last = skb;
+			last_len = skb->len;
+			unix_state_lock(&sk);
+			skb = skb_peek_next(skb, &sk->sk_receive_queue);
+			if (skb) goto again;
+			goto unlock;
 		}
 	} while (size);
 
--
1.9.1
