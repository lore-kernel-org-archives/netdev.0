From: Xin Xiaohui <xiaohui.xin@intel.com>
Subject: Is it a possible bug in dev_gro_receive()?
Date: Fri, 30 Jul 2010 09:54:15 +0800
Message-ID: <1280454855-7893-1-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:43037 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755245Ab0G3Bko (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jul 2010 21:40:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I looked into the code dev_gro_receive(), found the code here:
if the frags[0] is pulled to 0, then the page will be released,
and memmove() frags left.
Is that right? I'm not sure if memmove do right or not, but
frags[0].size is never set after memove at least. what I think
a simple way is not to do anything if we found frags[0].size == 0.
The patch is as followed.

Or am I missing something here?

---
 net/core/dev.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 264137f..28cdbbf 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2730,13 +2730,6 @@ pull:
 
 		skb_shinfo(skb)->frags[0].page_offset += grow;
 		skb_shinfo(skb)->frags[0].size -= grow;
-
-		if (unlikely(!skb_shinfo(skb)->frags[0].size)) {
-			put_page(skb_shinfo(skb)->frags[0].page);
-			memmove(skb_shinfo(skb)->frags,
-				skb_shinfo(skb)->frags + 1,
-				--skb_shinfo(skb)->nr_frags);
-		}
 	}
 
 ok:
-- 
1.5.4.4

