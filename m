From: Benjamin Poirier <bpoirier@suse.de>
Subject: [PATCH RESEND net/stable] gro: reset vlan_tci on reuse
Date: Wed, 30 Nov 2011 07:47:18 -0500
Message-ID: <1322657238-17159-1-git-send-email-bpoirier@suse.de>
Cc: netdev@vger.kernel.org, stable@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:48628 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750852Ab1K3MtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 07:49:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For drivers using the vlan_gro_frags() interface, a packet with an invalid tci
leads to GRO_DROP and napi_reuse_skb(). The skb has to be sanitized before
being reused or we may send an skb with an invalid vlan_tci field up the stack
where it is not expected.

Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
Cc: Jesse Gross <jesse@nicira.com>

---

Please apply to the -2.6.32.y stable branch.

This one liner is part of upstream
commit 3701e51382a026cba10c60b03efabe534fba4ca4
Author: Jesse Gross <jesse@nicira.com>

    vlan: Centralize handling of hardware acceleration.

The bulk of that commit is a rework of the hardware assisted vlan tagging
driver interface, and as such doesn't classify for -stable inclusion. The fix
that is needed is a part of that commit but can work independently of the
rest.

This patch can avoid panics on the 2.6.32.y -stable kernels and is in the same
spirit as mainline commits
66c46d7 gro: Reset dev pointer on reuse
6d152e2 gro: reset skb_iif on reuse
which are already in -stable.
---
 net/core/dev.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 64eb849..84a0705 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2614,6 +2614,7 @@ void napi_reuse_skb(struct napi_struct *napi, struct sk_buff *skb)
 {
 	__skb_pull(skb, skb_headlen(skb));
 	skb_reserve(skb, NET_IP_ALIGN - skb_headroom(skb));
+	skb->vlan_tci = 0;
 	skb->dev = napi->dev;
 	skb->iif = 0;
 
-- 
1.7.7
