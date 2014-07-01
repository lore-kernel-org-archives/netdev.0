From: Jan Tore Morken <jantore@morken.priv.no>
Subject: [backport request] netfilter: ipt_ULOG: fix info leaks
Date: Tue, 1 Jul 2014 20:20:13 +0200
Message-ID: <20140701182013.GM26742@32k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.coreless.net ([91.189.176.206]:56562 "EHLO
	sidney.coreless.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758700AbaGASjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 14:39:48 -0400
Received: from jantore by sidney.coreless.net with local (Exim 4.80)
	(envelope-from <jantore@morken.priv.no>)
	id 1X22f7-0005D7-Rl
	for netdev@vger.kernel.org; Tue, 01 Jul 2014 20:20:13 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I mistakenly sent this request to the stable list before being made
aware that it belonged here. Sorry to anyone reading this for the
second time.

I'd like to request that the commit below is backported to stable. The
commit fixes an old memory disclosure issue, and has already spent
some time in mainline.

Thanks!

===

>From 278f2b3e2af5f32ea1afe34fa12a2518153e6e49 Mon Sep 17 00:00:00 2001
From: Mathias Krause <minipli@googlemail.com>
Date: Mon, 30 Sep 2013 22:05:08 +0200
Subject: [PATCH] netfilter: ipt_ULOG: fix info leaks

The ulog messages leak heap bytes by the means of padding bytes and
incompletely filled string arrays. Fix those by memset(0)'ing the
whole struct before filling it.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/ipt_ULOG.c | 7 +------
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
2.0.0
