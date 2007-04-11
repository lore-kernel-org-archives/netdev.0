From: Patrick McHardy <kaber@trash.net>
Subject: Re: [SK_BUFF]: Fix missing offset adjustment in skb_copy_expand
Date: Wed, 11 Apr 2007 02:42:59 +0200
Message-ID: <461C2F13.1080808@trash.net>
References: <461849C5.8000507@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000809040502070202040406"
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Kernel Netdev Mailing List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39745 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932359AbXDKAnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2007 20:43:10 -0400
In-Reply-To: <461849C5.8000507@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000809040502070202040406
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Hi Dave,

Patrick McHardy wrote:
> [SK_BUFF]: Fix missing offset adjustment in skb_copy_expand
> 
> skb_copy_expand changes the headroom, so it needs to adjust the header
> offsets by the difference between the old and the new value.


it seems like you missed this one. Attached again for your convenience.



--------------000809040502070202040406
Content-Type: text/x-diff;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

[SK_BUFF]: Fix missing offset adjustment in skb_copy_expand

skb_copy_expand changes the headroom, so it needs to adjust the header
offsets by the difference between the old and the new value.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 9cb76fae709a9303777286998baa457b0730a225
tree 2ea619c7daf9c5e6829dad6d502386eb9c922700
parent fb98b03719ad23840ca005edbba3c86ef1e3282c
author Patrick McHardy <kaber@trash.net> Sun, 08 Apr 2007 03:36:49 +0200
committer Patrick McHardy <kaber@trash.net> Sun, 08 Apr 2007 03:36:49 +0200

 net/core/skbuff.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5c9ee94..f2cffd4 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -794,7 +794,9 @@ struct sk_buff *skb_copy_expand(const struct sk_buff *skb,
 	 */
 	struct sk_buff *n = alloc_skb(newheadroom + skb->len + newtailroom,
 				      gfp_mask);
+	int oldheadroom = skb_headroom(skb);
 	int head_copy_len, head_copy_off;
+	int off = 0;
 
 	if (!n)
 		return NULL;
@@ -804,7 +806,7 @@ struct sk_buff *skb_copy_expand(const struct sk_buff *skb,
 	/* Set the tail pointer and length */
 	skb_put(n, skb->len);
 
-	head_copy_len = skb_headroom(skb);
+	head_copy_len = oldheadroom;
 	head_copy_off = 0;
 	if (newheadroom <= head_copy_len)
 		head_copy_len = newheadroom;
@@ -818,6 +820,13 @@ struct sk_buff *skb_copy_expand(const struct sk_buff *skb,
 
 	copy_skb_header(n, skb);
 
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
+	off                  = newheadroom - oldheadroom;
+#endif
+	n->transport_header += off;
+	n->network_header   += off;
+	n->mac_header	    += off;
+
 	return n;
 }
 


--------------000809040502070202040406--
