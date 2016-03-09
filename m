From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v2 1/2] gro: Defer clearing of flush bit in tunnel
 paths
Date: Wed, 09 Mar 2016 09:24:23 -0800
Message-ID: <20160309172254.11477.43113.stgit@localhost.localdomain>
References: <20160309171924.11477.93179.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:32821 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753273AbcCIRYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 12:24:25 -0500
Received: by mail-pa0-f43.google.com with SMTP id fl4so44572988pad.0
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 09:24:25 -0800 (PST)
In-Reply-To: <20160309171924.11477.93179.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the GRO handlers for GRE, VXLAN, GENEVE, and FOU so that
we do not clear the flush bit until after we have called the next level GRO
handler.  Previously this was being cleared before parsing through the list
of frames, however this resulted in several paths where either the bit
needed to be reset but wasn't as in the case of FOU, or cases where it was
being set as in GENEVE.  By just deferring the clearing of the bit until
after the next level protocol has been parsed we can avoid any unnecessary
bit twiddling and avoid bugs.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---

v2: This was originally code for checking the flush_id in tunnels but since
    that was rejected I thought it best to at least submit the bit that can
    fix actual issues in the code.

 drivers/net/geneve.c   |    7 ++-----
 drivers/net/vxlan.c    |    3 +--
 net/ipv4/fou.c         |    3 +--
 net/ipv4/gre_offload.c |    3 +--
 4 files changed, 5 insertions(+), 11 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 6a0cbbe03e5d..aebb4a9289c1 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -462,8 +462,6 @@ static struct sk_buff **geneve_gro_receive(struct sk_buff **head,
 			goto out;
 	}
 
-	flush = 0;
-
 	for (p = *head; p; p = p->next) {
 		if (!NAPI_GRO_CB(p)->same_flow)
 			continue;
@@ -480,14 +478,13 @@ static struct sk_buff **geneve_gro_receive(struct sk_buff **head,
 
 	rcu_read_lock();
 	ptype = gro_find_receive_by_type(type);
-	if (!ptype) {
-		flush = 1;
+	if (!ptype)
 		goto out_unlock;
-	}
 
 	skb_gro_pull(skb, gh_len);
 	skb_gro_postpull_rcsum(skb, gh, gh_len);
 	pp = ptype->callbacks.gro_receive(head, skb);
+	flush = 0;
 
 out_unlock:
 	rcu_read_unlock();
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 2399099e68cf..63929877619f 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -591,8 +591,6 @@ static struct sk_buff **vxlan_gro_receive(struct sk_buff **head,
 
 	skb_gro_pull(skb, sizeof(struct vxlanhdr)); /* pull vxlan header */
 
-	flush = 0;
-
 	for (p = *head; p; p = p->next) {
 		if (!NAPI_GRO_CB(p)->same_flow)
 			continue;
@@ -606,6 +604,7 @@ static struct sk_buff **vxlan_gro_receive(struct sk_buff **head,
 	}
 
 	pp = eth_gro_receive(head, skb);
+	flush = 0;
 
 out:
 	skb_gro_remcsum_cleanup(skb, &grc);
diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 88dab0c1670c..780484243e14 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -319,8 +319,6 @@ static struct sk_buff **gue_gro_receive(struct sk_buff **head,
 
 	skb_gro_pull(skb, hdrlen);
 
-	flush = 0;
-
 	for (p = *head; p; p = p->next) {
 		const struct guehdr *guehdr2;
 
@@ -352,6 +350,7 @@ static struct sk_buff **gue_gro_receive(struct sk_buff **head,
 		goto out_unlock;
 
 	pp = ops->callbacks.gro_receive(head, skb);
+	flush = 0;
 
 out_unlock:
 	rcu_read_unlock();
diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index 47f4c544c916..540866dbd27d 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -175,8 +175,6 @@ static struct sk_buff **gre_gro_receive(struct sk_buff **head,
 					     null_compute_pseudo);
 	}
 
-	flush = 0;
-
 	for (p = *head; p; p = p->next) {
 		const struct gre_base_hdr *greh2;
 
@@ -213,6 +211,7 @@ static struct sk_buff **gre_gro_receive(struct sk_buff **head,
 	skb_gro_postpull_rcsum(skb, greh, grehlen);
 
 	pp = ptype->callbacks.gro_receive(head, skb);
+	flush = 0;
 
 out_unlock:
 	rcu_read_unlock();
