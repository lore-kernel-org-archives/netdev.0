From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/3] netfilter: ipt_ULOG: fix info leaks
Date: Wed, 23 Oct 2013 11:15:23 +0200
Message-ID: <1382519724-3953-3-git-send-email-pablo@netfilter.org>
References: <1382519724-3953-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36885 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751509Ab3JWJPe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Oct 2013 05:15:34 -0400
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
 net/ipv4/netfilter/ipt_ULOG.c |    7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
index cbc2215..9cb993c 100644
--- a/net/ipv4/netfilter/ipt_ULOG.c
+++ b/net/ipv4/netfilter/ipt_ULOG.c
@@ -220,6 +220,7 @@ static void ipt_ulog_packet(struct net *net,
 	ub->qlen++;
 
 	pm = nlmsg_data(nlh);
+	memset(pm, 0, sizeof(*pm));
 
 	/* We might not have a timestamp, get one */
 	if (skb->tstamp.tv64 == 0)
@@ -238,8 +239,6 @@ static void ipt_ulog_packet(struct net *net,
 	}
 	else if (loginfo->prefix[0] != '\0')
 		strncpy(pm->prefix, loginfo->prefix, sizeof(pm->prefix));
-	else
-		*(pm->prefix) = '\0';
 
 	if (in && in->hard_header_len > 0 &&
 	    skb->mac_header != skb->network_header &&
@@ -251,13 +250,9 @@ static void ipt_ulog_packet(struct net *net,
 
 	if (in)
 		strncpy(pm->indev_name, in->name, sizeof(pm->indev_name));
-	else
-		pm->indev_name[0] = '\0';
 
 	if (out)
 		strncpy(pm->outdev_name, out->name, sizeof(pm->outdev_name));
-	else
-		pm->outdev_name[0] = '\0';
 
 	/* copy_len <= skb->len, so can't fail. */
 	if (skb_copy_bits(skb, 0, pm->payload, copy_len) < 0)
-- 
1.7.10.4
