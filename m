From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC] net: remove erroneous sk null assignment in timestamping
Date: Fri, 07 Oct 2011 19:11:41 +0200
Message-ID: <1318007501.3988.20.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:47946 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751667Ab1JGRLo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 13:11:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

skb->sk is obviously required to be non-NULL
when we get into skb_complete_tx_timestamp().
sock_queue_err_skb() will call skb_orphan()
first thing which sets skb->sk = NULL itself.
This may crash if the skb is still charged to
the socket (skb->destructor is sk_wfree).

The assignment here thus seems to not only be
pointless (due to the skb_orphan() call) but
also dangerous (due to the crash).

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/core/timestamping.c |    1 -
 1 file changed, 1 deletion(-)

--- a/net/core/timestamping.c	2011-10-07 18:59:12.000000000 +0200
+++ b/net/core/timestamping.c	2011-10-07 19:07:06.000000000 +0200
@@ -85,7 +85,6 @@ void skb_complete_tx_timestamp(struct sk
 	memset(serr, 0, sizeof(*serr));
 	serr->ee.ee_errno = ENOMSG;
 	serr->ee.ee_origin = SO_EE_ORIGIN_TIMESTAMPING;
-	skb->sk = NULL;
 	err = sock_queue_err_skb(sk, skb);
 	if (err)
 		kfree_skb(skb);
