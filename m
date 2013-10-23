From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/3] netfilter: ebt_ulog: fix info leaks
Date: Wed, 23 Oct 2013 11:15:22 +0200
Message-ID: <1382519724-3953-2-git-send-email-pablo@netfilter.org>
References: <1382519724-3953-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36877 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751616Ab3JWJPd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Oct 2013 05:15:33 -0400
In-Reply-To: <1382519724-3953-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathias Krause <minipli@googlemail.com>

The ulog messages leak heap bytes by the means of padding bytes and
incompletely filled string arrays. Fix those by memset(0)'ing the
whole struct before filling it.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/ebt_ulog.c |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/bridge/netfilter/ebt_ulog.c b/net/bridge/netfilter/ebt_ulog.c
index 5180938..7c470c3 100644
--- a/net/bridge/netfilter/ebt_ulog.c
+++ b/net/bridge/netfilter/ebt_ulog.c
@@ -181,6 +181,7 @@ static void ebt_ulog_packet(struct net *net, unsigned int hooknr,
 	ub->qlen++;
 
 	pm = nlmsg_data(nlh);
+	memset(pm, 0, sizeof(*pm));
 
 	/* Fill in the ulog data */
 	pm->version = EBT_ULOG_VERSION;
@@ -193,8 +194,6 @@ static void ebt_ulog_packet(struct net *net, unsigned int hooknr,
 	pm->hook = hooknr;
 	if (uloginfo->prefix != NULL)
 		strcpy(pm->prefix, uloginfo->prefix);
-	else
-		*(pm->prefix) = '\0';
 
 	if (in) {
 		strcpy(pm->physindev, in->name);
@@ -204,16 +203,14 @@ static void ebt_ulog_packet(struct net *net, unsigned int hooknr,
 			strcpy(pm->indev, br_port_get_rcu(in)->br->dev->name);
 		else
 			strcpy(pm->indev, in->name);
-	} else
-		pm->indev[0] = pm->physindev[0] = '\0';
+	}
 
 	if (out) {
 		/* If out exists, then out is a bridge port */
 		strcpy(pm->physoutdev, out->name);
 		/* rcu_read_lock()ed by nf_hook_slow */
 		strcpy(pm->outdev, br_port_get_rcu(out)->br->dev->name);
-	} else
-		pm->outdev[0] = pm->physoutdev[0] = '\0';
+	}
 
 	if (skb_copy_bits(skb, -ETH_HLEN, pm->data, copy_len) < 0)
 		BUG();
-- 
1.7.10.4
