From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] caif: Do not dereference NULL in chnl_recv_cb()
Date: Fri, 17 Aug 2012 22:33:12 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1208172230570.15699@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Sjur Braendeland <sjur.brandeland@stericsson.com>,
	Daniel Martensson <Daniel.Martensson@stericsson.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1010ds2-suoe.0.fullrate.dk ([90.184.90.115]:11882 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754411Ab2HQUdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2012 16:33:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In net/caif/chnl_net.c::chnl_recv_cb() we call skb_header_pointer()
which may return NULL, but we do not check for a NULL pointer before
dereferencing it.
This patch adds such a NULL check and properly free's allocated memory
and return an error (-EINVAL) on failure - much better than crashing..

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 net/caif/chnl_net.c | 4 ++++
 1 file changed, 4 insertions(+)

 Note: compile tested only.

diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
index 69771c0..e597733 100644
--- a/net/caif/chnl_net.c
+++ b/net/caif/chnl_net.c
@@ -94,6 +94,10 @@ static int chnl_recv_cb(struct cflayer *layr, struct cfpkt *pkt)
 
 	/* check the version of IP */
 	ip_version = skb_header_pointer(skb, 0, 1, &buf);
+	if (!ip_version) {
+		kfree_skb(skb);
+		return -EINVAL;
+	}
 
 	switch (*ip_version >> 4) {
 	case 4:
-- 
1.7.11.4


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
