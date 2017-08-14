From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net] udp: fix linear skb reception with PEEK_OFF
Date: Mon, 14 Aug 2017 21:31:38 +0200
Message-ID: <18c1b112032a685518548760890547fdbf292b85.1502739025.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Sasha Levin <alexander.levin@verizon.com>,
        Al Viro <viro@ZenIV.linux.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38846 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750771AbdHNTcj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Aug 2017 15:32:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>

copy_linear_skb() is broken; both of its callers actually
expect 'len' to be the amount we are trying to copy,
not the offset of the end.
Fix it keeping the meanings of arguments in sync with what the
callers (both of them) expect.
Also restore a saner behavior on EFAULT (i.e. preserving
the iov_iter position in case of failure):

The commit fd851ba9caa9 ("udp: harden copy_linear_skb()")
avoids the more destructive effect of the buggy
copy_linear_skb(), e.g. no more invalid memory access, but
said function still behaves incorrectly: when peeking with
offset it can fail with EINVAL instead of copying the
appropriate amount of memory.

Reported-by: Sasha Levin <alexander.levin@verizon.com>
Fixes: b65ac44674dd ("udp: try to avoid 2 cache miss on dequeue")
Fixes: fd851ba9caa9 ("udp: harden copy_linear_skb()")
Signed-off-by: Al Viro <viro@ZenIV.linux.org.uk>
Acked-by: Paolo Abeni <pabeni@redhat.com>
Tested-by: Sasha Levin <alexander.levin@verizon.com>
---
This patch has been buried in a private email exchange for some
time.
I'm posting it on behalf of Al Viro, to avoid loosing this merge
window, since he is busy elsewhere.
---
 include/net/udp.h | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index e9b1d1eacb59..586de4b811b5 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -366,14 +366,13 @@ static inline bool udp_skb_is_linear(struct sk_buff *skb)
 static inline int copy_linear_skb(struct sk_buff *skb, int len, int off,
 				  struct iov_iter *to)
 {
-	int n, copy = len - off;
+	int n;
 
-	if (copy < 0)
-		return -EINVAL;
-	n = copy_to_iter(skb->data + off, copy, to);
-	if (n == copy)
+	n = copy_to_iter(skb->data + off, len, to);
+	if (n == len)
 		return 0;
 
+	iov_iter_revert(to, n);
 	return -EFAULT;
 }
 
-- 
2.13.5
