From: Erik Hugne <erik.hugne@ericsson.com>
Subject: skb_try_coalesce and fraglists (bug?)
Date: Wed, 4 Feb 2015 17:33:43 +0100
Message-ID: <20150204163343.GA857@haze>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <mkubecek@suse.cz>, <ying.xue@windriver.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg23.ericsson.net ([193.180.251.45]:53054 "EHLO
	sessmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966683AbbBDQfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 11:35:45 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_try_coalesce should bail out for a number of reasons, if the target skb is
cloned, doesn't have enough room, or if either source or target skb have
fraglists.

However, it seems that the skb_has_frag_list check is done too late, and a small
skb may be copied into the tailroom of the head, even if it has a fraglist.

Wouldn't this be more correct?

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 56db472..8d02140 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4056,6 +4056,9 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
        if (skb_cloned(to))
                return false;
 
+       if (skb_has_frag_list(to) || skb_has_frag_list(from))
+               return false;
+
        if (len <= skb_tailroom(to)) {
                if (len)
                        BUG_ON(skb_copy_bits(from, 0, skb_put(to, len), len));
@@ -4063,9 +4066,6 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
                return true;
        }
 
-       if (skb_has_frag_list(to) || skb_has_frag_list(from))
-               return false;
-
        if (skb_headlen(from) != 0) {
                struct page *page;
                unsigned int offset;
