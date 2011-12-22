From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 0/4] skb paged fragment destructors
Date: Thu, 22 Dec 2011 10:33:36 +0000
Message-ID: <1324550017.7877.77.camel@zakaz.uk.xensource.com>
References: <1324470605.2728.42.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324475280.7877.33.camel@zakaz.uk.xensource.com>
	 <1324476138.2728.65.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111221.142841.2253787084484360430.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"jesse.brandeburg@intel.com" <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:15631 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754602Ab1LVKdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2011 05:33:38 -0500
In-Reply-To: <20111221.142841.2253787084484360430.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-12-21 at 19:28 +0000, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 21 Dec 2011 15:02:18 +0100
> 
> > No idea on this +2 point.
> 
> I think I know, and I believe I instructed Alexey Kuznetsov to do
> this.
> 
> When sendfile() is performed, we might start the SKB with the last few
> bytes of one page, and end the SKB with the first few bytes of another
> page.
> 
> In order to fit a full 64K frame into an SKB in this situation we have
> to accomodate this case.

Thanks David, that makes sense.

However I think you only actually need 1 extra page for that. If the
data in frag[0] starts at $offset then frag[16] will need to have
$offset bytes in it. e.g.
	4096-$offset + 4096*15 + $offset = 65536
which == 17 pages rather than 18.

The following documents the status quo but I could update to switch to +
1 instead if there are no flaws in the above logic...

Ian.

>From 0a327232d6df809c4cf294edc8d02f6f88dd5678 Mon Sep 17 00:00:00 2001
From: Ian Campbell <ian.campbell@citrix.com>
Date: Thu, 22 Dec 2011 10:07:19 +0000
Subject: [PATCH] net: document reason for 2 additional pages in MAX_SKB_FRAGS

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
---
 include/linux/skbuff.h |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index fe86488..1c894a8 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -128,8 +128,12 @@ struct sk_buff_head {
 
 struct sk_buff;
 
-/* To allow 64K frame to be packed as single skb without frag_list. Since
- * GRO uses frags we allocate at least 16 regardless of page size.
+/* To allow 64K frame to be packed as single skb without frag_list we
+ * require 64K/PAGE_SIZE pages plus 2 additional pages to allow for
+ * buffers which do not start on a page boundary.
+ *
+ * Since GRO uses frags we allocate at least 16 regardless of page
+ * size.
  */
 #if (65536/PAGE_SIZE + 2) < 16
 #define MAX_SKB_FRAGS 16UL
-- 
1.7.2.5
