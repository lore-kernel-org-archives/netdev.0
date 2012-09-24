From: pablo@netfilter.org
Subject: [PATCH 15/16] netfilter: nfnetlink_queue: fix maximum packet length to userspace
Date: Mon, 24 Sep 2012 21:19:27 +0200
Message-ID: <1348514369-3272-16-git-send-email-pablo@netfilter.org>
References: <1348514369-3272-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58142 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932081Ab2IXTVJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 15:21:09 -0400
In-Reply-To: <1348514369-3272-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

The packets that we send via NFQUEUE are encapsulated in the NFQA_PAYLOAD
attribute. The length of the packet in userspace is obtained via
attr->nla_len field. This field contains the size of the Netlink
attribute header plus the packet length.

If the maximum packet length is specified, ie. 65535 bytes, and
packets in the range of (65531,65535] are sent to userspace, the
attr->nla_len overflows and it reports bogus lengths to the
application.

To fix this, this patch limits the maximum packet length to 65531
bytes. If larger packet length is specified, the packet that we
send to user-space is truncated to 65531 bytes.

To support 65535 bytes packets, we have to revisit the idea of
the 32-bits Netlink attribute length.

Reported-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_queue_core.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 43de3a0..3e4ddcb7 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -526,9 +526,13 @@ nfqnl_set_mode(struct nfqnl_instance *queue,
 
 	case NFQNL_COPY_PACKET:
 		queue->copy_mode = mode;
-		/* we're using struct nlattr which has 16bit nla_len */
-		if (range > 0xffff)
-			queue->copy_range = 0xffff;
+		/* We're using struct nlattr which has 16bit nla_len. Note that
+		 * nla_len includes the header length. Thus, the maximum packet
+		 * length that we support is 65531 bytes. We send truncated
+		 * packets if the specified length is larger than that.
+		 */
+		if (range > 0xffff - NLA_HDRLEN)
+			queue->copy_range = 0xffff - NLA_HDRLEN;
 		else
 			queue->copy_range = range;
 		break;
-- 
1.7.10.4
