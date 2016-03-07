From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 4/4] gue: Enforce IP ID verification on outer
 headers
Date: Mon, 07 Mar 2016 09:22:20 -0800
Message-ID: <20160307172220.5295.43204.stgit@localhost.localdomain>
References: <20160307172201.5295.69740.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:35713 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752876AbcCGRWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 12:22:22 -0500
Received: by mail-pf0-f176.google.com with SMTP id x188so59300371pfb.2
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 09:22:22 -0800 (PST)
In-Reply-To: <20160307172201.5295.69740.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change enforces the IP ID verification on outer headers.  As a result
if the DF flag is not set on the outer header we will force the flow to be
flushed in the event that the IP ID is out of sequence with the existing
flow.

In addition I believe this fixes a bug in which it was possible for no GRO
handler to be defined for a given protocol but we were not setting the
flush bit as it had been cleared before the check.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/ipv4/fou.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 88dab0c1670c..5b93572e7434 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -319,8 +319,6 @@ static struct sk_buff **gue_gro_receive(struct sk_buff **head,
 
 	skb_gro_pull(skb, hdrlen);
 
-	flush = 0;
-
 	for (p = *head; p; p = p->next) {
 		const struct guehdr *guehdr2;
 
@@ -343,6 +341,9 @@ static struct sk_buff **gue_gro_receive(struct sk_buff **head,
 			NAPI_GRO_CB(p)->same_flow = 0;
 			continue;
 		}
+
+		/* Include the IP ID check from the outer IP hdr */
+		NAPI_GRO_CB(p)->flush |= NAPI_GRO_CB(p)->flush_id;
 	}
 
 	rcu_read_lock();
@@ -352,6 +353,7 @@ static struct sk_buff **gue_gro_receive(struct sk_buff **head,
 		goto out_unlock;
 
 	pp = ops->callbacks.gro_receive(head, skb);
+	flush = 0;
 
 out_unlock:
 	rcu_read_unlock();
