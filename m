From: Per Liden <per.liden@ericsson.com>
Subject: Re: [PATCH 1/3] [TIPC] Fixed skb_under_panic caused by tipc_link_bundle_buf
Date: Fri, 30 Jun 2006 10:49:08 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0606301032170.17932@ulinpc219.uab.ericsson.se>
References: <Pine.LNX.4.64.0606281358100.6341@ulinpc219.uab.ericsson.se>
 <11514964722073-git-send-email-per.liden@ericsson.com>
 <Pine.LNX.4.64.0606291703270.1695@ulinpc219.uab.ericsson.se>
 <20060629.124142.102573938.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:9614 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP id S932147AbWF3ItN
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 04:49:13 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060629.124142.102573938.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 29 Jun 2006, David Miller wrote:

> From: Per Liden <per.liden@ericsson.com>
> Date: Thu, 29 Jun 2006 17:17:20 +0200 (CEST)
> 
> > A problem was found with this patch. The direct inspection of bundle 
> > buffer tailroom did not account for the possiblity of unrequested tailroom 
> > added by skb_alloc(), thereby allowing a bundle to be created that exceeds 
> > the current link MTU.
> > 
> > I'll resend this patch set with this issue resolved.
> 
> I've applied the patch already, please send a relative fix.

Here's a relative fix.

/Per


[TIPC] Fixed sk_buff panic caused by tipc_link_bundle_buf (REVISED)

From: Allan Stephens <allan.stephens@windriver.com>

The recent change to direct inspection of bundle buffer tailroom did not
account for the possiblity of unrequested tailroom added by skb_alloc(),
thereby allowing a bundle to be created that exceeds the current link MTU.
An additional check now ensures that bundling works correctly no matter
if the bundle buffer is smaller, larger, or equal to the link MTU.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/core.h |    5 ++++-
 net/tipc/link.c |    2 ++
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/tipc/core.h b/net/tipc/core.h
index 86f54f3..762aac2 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -297,7 +297,10 @@ static inline struct tipc_msg *buf_msg(s
  * buf_acquire - creates a TIPC message buffer
  * @size: message size (including TIPC header)
  *
- * Returns a new buffer.  Space is reserved for a data link header.
+ * Returns a new buffer with data pointers set to the specified size.
+ * 
+ * NOTE: Headroom is reserved to allow prepending of a data link header.
+ *       There may also be unrequested tailroom present at the buffer's end.
  */
 
 static inline struct sk_buff *buf_acquire(u32 size)
diff --git a/net/tipc/link.c b/net/tipc/link.c
index c6831c7..c10e18a 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -998,6 +998,8 @@ static int link_bundle_buf(struct link *
 		return 0;
 	if (skb_tailroom(bundler) < (pad + size))
 		return 0;
+	if (link_max_pkt(l_ptr) < (to_pos + size))
+		return 0;
 
 	skb_put(bundler, pad + size);
 	memcpy(bundler->data + to_pos, buf->data, size);
-- 
1.4.0
