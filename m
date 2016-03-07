From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 05/13] net: Walk fragments in __skb_splice_bits
Date: Mon, 7 Mar 2016 14:11:04 -0800
Message-ID: <1457388672-2600559-6-git-send-email-tom@herbertland.com>
References: <1457388672-2600559-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:31454 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753660AbcCGWMC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 17:12:02 -0500
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u27MAEUp022036
	for <netdev@vger.kernel.org>; Mon, 7 Mar 2016 14:12:01 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 21hh470b0p-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 14:12:01 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 9d3b18bee4b111e599860002c9521c9e-b91d7420 for <netdev@vger.kernel.org>;	Mon,
 07 Mar 2016 14:12:00 -0800
In-Reply-To: <1457388672-2600559-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add walking of fragments in __skb_splice_bits.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/core/skbuff.c | 39 ++++++++++++++++-----------------------
 1 file changed, 16 insertions(+), 23 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 7af7ec6..0df9f6a 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1918,6 +1918,7 @@ static bool __skb_splice_bits(struct sk_buff *skb, struct pipe_inode_info *pipe,
 			      struct splice_pipe_desc *spd, struct sock *sk)
 {
 	int seg;
+	struct sk_buff *iter;
 
 	/* map the linear part :
 	 * If skb->head_frag is set, this 'linear' part is backed by a
@@ -1944,6 +1945,19 @@ static bool __skb_splice_bits(struct sk_buff *skb, struct pipe_inode_info *pipe,
 			return true;
 	}
 
+	skb_walk_frags(skb, iter) {
+		if (*offset >= iter->len) {
+			*offset -= iter->len;
+			continue;
+		}
+		/* __skb_splice_bits() only fails if the output has no room
+		 * left, so no point in going over the frag_list for the error
+		 * case.
+		 */
+		if (__skb_splice_bits(iter, pipe, offset, len, spd, sk))
+			return true;
+	}
+
 	return false;
 }
 
@@ -1970,9 +1984,7 @@ ssize_t skb_socket_splice(struct sock *sk,
 
 /*
  * Map data from the skb to a pipe. Should handle both the linear part,
- * the fragments, and the frag list. It does NOT handle frag lists within
- * the frag list, if such a thing exists. We'd probably need to recurse to
- * handle that cleanly.
+ * the fragments, and the frag list.
  */
 int skb_splice_bits(struct sk_buff *skb, struct sock *sk, unsigned int offset,
 		    struct pipe_inode_info *pipe, unsigned int tlen,
@@ -1991,29 +2003,10 @@ int skb_splice_bits(struct sk_buff *skb, struct sock *sk, unsigned int offset,
 		.ops = &nosteal_pipe_buf_ops,
 		.spd_release = sock_spd_release,
 	};
-	struct sk_buff *frag_iter;
 	int ret = 0;
 
-	/*
-	 * __skb_splice_bits() only fails if the output has no room left,
-	 * so no point in going over the frag_list for the error case.
-	 */
-	if (__skb_splice_bits(skb, pipe, &offset, &tlen, &spd, sk))
-		goto done;
-	else if (!tlen)
-		goto done;
+	__skb_splice_bits(skb, pipe, &offset, &tlen, &spd, sk);
 
-	/*
-	 * now see if we have a frag_list to map
-	 */
-	skb_walk_frags(skb, frag_iter) {
-		if (!tlen)
-			break;
-		if (__skb_splice_bits(frag_iter, pipe, &offset, &tlen, &spd, sk))
-			break;
-	}
-
-done:
 	if (spd.nr_pages)
 		ret = splice_cb(sk, pipe, &spd);
 
-- 
2.6.5
