From: David Howells <dhowells@redhat.com>
Subject: [PATCH] NET: Fix uninitialised variable in ip_frag_reasm()
Date: Wed, 17 Oct 2007 16:02:48 +0100
Message-ID: <20071017150248.22323.39167.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:35385 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756762AbXJQPCw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 11:02:52 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.1) with ESMTP id l9HF2p39002199
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 11:02:51 -0400
Received: from pobox.devel.redhat.com (pobox.devel.redhat.com [10.11.255.8])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l9HF2oPO030323
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 11:02:50 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix uninitialised variable in ip_frag_reasm().  err should be set to -ENOMEM
if the initial call of skb_clone() fails.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/ipv4/ip_fragment.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 443b3f8..4629dad 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -545,7 +545,6 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 	if (prev) {
 		head = prev->next;
 		fp = skb_clone(head, GFP_ATOMIC);
-
 		if (!fp)
 			goto out_nomem;
 
@@ -571,7 +570,6 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 		goto out_oversize;
 
 	/* Head of list must not be cloned. */
-	err = -ENOMEM;
 	if (skb_cloned(head) && pskb_expand_head(head, 0, 0, GFP_ATOMIC))
 		goto out_nomem;
 
@@ -627,6 +625,7 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 out_nomem:
 	LIMIT_NETDEBUG(KERN_ERR "IP: queue_glue: no memory for gluing "
 			      "queue %p\n", qp);
+	err = -ENOMEM;
 	goto out_fail;
 out_oversize:
 	if (net_ratelimit())

